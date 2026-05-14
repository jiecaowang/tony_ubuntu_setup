#!/bin/bash
# Idempotent installer for the entire tony_ubuntu_setup repo.
#
#   sudo ./install.sh
#
# Sections:
#   1. /usr/local/sbin scripts
#   2. systemd unit + sleep hook (MECHREVO RGB-off)
#   3. udev rules (USB power, SteelSeries, MECHREVO RGB)
#   4. /etc/sudoers.d drop-ins
#   5. /etc/pam.d/sudo + sudo-i (Cursor agent passwordless bypass) — with rollback
#   6. user-space scripts → ~/.local/bin (symlinked)
#   7. final smoke test
#
# Files explicitly NOT installed (kept out by design):
#   - jzxwww-nopasswd.sudoers  (full NOPASSWD removed in favour of PAM bypass)
#   - 85-mechrevo-ite8291-usb.rules (plugdev approach replaced by RGB-off service)

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME=/home/jzxwww
USER_NAME=jzxwww
BACKUP=/var/backups/tony_ubuntu_setup-$(date +%Y%m%d-%H%M%S)

[ "$(id -u)" -eq 0 ] || { echo "must be root"; exit 1; }
mkdir -p "$BACKUP"

say() { printf '\n\033[1;36m== %s ==\033[0m\n' "$*"; }

# ---------------------------------------------------------------- 1. scripts
say "installing /usr/local/sbin scripts"
install -m 0755 -o root -g root \
    "$REPO/usr/local/sbin/cursor-sudo-bypass.sh" \
    /usr/local/sbin/cursor-sudo-bypass.sh
install -m 0755 -o root -g root \
    "$REPO/usr/local/sbin/mechrevo-rgb-off" \
    /usr/local/sbin/mechrevo-rgb-off

# ----------------------------------------------------- 2. systemd RGB-off unit
say "installing mechrevo-rgb-off systemd unit + sleep hook"
install -m 0644 -o root -g root \
    "$REPO/etc/systemd/system/mechrevo-rgb-off.service" \
    /etc/systemd/system/mechrevo-rgb-off.service
install -m 0755 -o root -g root \
    "$REPO/usr/lib/systemd/system-sleep/mechrevo-rgb-off" \
    /usr/lib/systemd/system-sleep/mechrevo-rgb-off
systemctl daemon-reload
systemctl enable mechrevo-rgb-off.service >/dev/null

# ---------------------------------------------------------------- 3. udev
say "installing udev rules"
# Remove obsolete plugdev-style RGB rule if present.
if [ -f /etc/udev/rules.d/85-mechrevo-ite8291-usb.rules ]; then
    cp -a /etc/udev/rules.d/85-mechrevo-ite8291-usb.rules "$BACKUP/"
    rm -f /etc/udev/rules.d/85-mechrevo-ite8291-usb.rules
fi
for rule in "$REPO"/etc/udev/rules.d/*.rules; do
    install -m 0644 -o root -g root "$rule" "/etc/udev/rules.d/$(basename "$rule")"
done
udevadm control --reload-rules
udevadm trigger --subsystem-match=usb
udevadm trigger --subsystem-match=input

# ---------------------------------------------------------------- 4. sudoers
say "installing /etc/sudoers.d drop-ins"
for f in "$REPO"/etc/sudoers.d/*; do
    base=$(basename "$f")
    # sudoers.d files must be 0440 root:root and pass visudo -c.
    install -m 0440 -o root -g root "$f" "/etc/sudoers.d/$base"
    visudo -cf "/etc/sudoers.d/$base"
done
# Remove the obsolete full-NOPASSWD drop-in if it ever existed.
if [ -f /etc/sudoers.d/jzxwww-nopasswd ]; then
    cp -a /etc/sudoers.d/jzxwww-nopasswd "$BACKUP/"
    rm -f /etc/sudoers.d/jzxwww-nopasswd
fi

# ---------------------------------------------------------------- 5. PAM
say "installing /etc/pam.d/sudo + sudo-i (with rollback safety)"
cp -a /etc/pam.d/sudo   "$BACKUP/pam.d.sudo.bak"
cp -a /etc/pam.d/sudo-i "$BACKUP/pam.d.sudo-i.bak"
install -m 0644 -o root -g root "$REPO/etc/pam.d/sudo"   /etc/pam.d/sudo
install -m 0644 -o root -g root "$REPO/etc/pam.d/sudo-i" /etc/pam.d/sudo-i

self_test() {
    CURSOR_INVOKED_AS=agent runuser -u "$USER_NAME" -- /usr/bin/sudo -n /bin/true
}
if self_test; then
    echo "PAM self-test OK: Cursor agent (CURSOR_INVOKED_AS=agent) bypasses sudo password."
else
    echo "PAM self-test FAILED — rolling back /etc/pam.d/sudo*"
    install -m 0644 -o root -g root "$BACKUP/pam.d.sudo.bak"   /etc/pam.d/sudo
    install -m 0644 -o root -g root "$BACKUP/pam.d.sudo-i.bak" /etc/pam.d/sudo-i
    exit 2
fi

# ------------------------------------------------- 6. user-space scripts (~/.local/bin)
say "linking user-space scripts into ~/.local/bin"
runuser -u "$USER_NAME" -- mkdir -p "$USER_HOME/.local/bin"
for f in "$REPO"/bin/*; do
    target="$USER_HOME/.local/bin/$(basename "$f")"
    runuser -u "$USER_NAME" -- ln -sfn "$f" "$target"
done

# ---------------------------------------------------------------- 7. RGB-off now
say "firing RGB-off service once"
systemctl start mechrevo-rgb-off.service || true
systemctl --no-pager status mechrevo-rgb-off.service | head -10 || true

echo
echo "Backup of replaced files: $BACKUP"
echo "Install complete."
