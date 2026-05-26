# tony_ubuntu_setup

Single source of truth for personal system configuration on this machine
(MECHREVO YAOSHI laptop, Ubuntu 26.04, GNOME/Wayland, Intel iGPU + RTX 5080
Mobile dGPU).

The repo mirrors the target filesystem layout. `install.sh` is idempotent and
deploys everything atomically with a backup under `/var/backups/`.

## Layout

```
tony_ubuntu_setup/
├── README.md
├── install.sh                 # idempotent root installer
├── bin/                       # user-space scripts -> symlinked into ~/.local/bin
│   └── mechrevo_ite8291_rgb_off.py
├── docs/
│   ├── tony_ubuntu_pref.md    # personal Ubuntu setup notes
│   └── MONITOR_FIX.md         # LG G-SYNC / NVIDIA hybrid GPU diagnosis
├── etc/
│   ├── pam.d/                 # sudo + sudo-i (Cursor agent passwordless bypass)
│   ├── sudoers.d/             # limitedadmins (secure_path scrub)
│   ├── systemd/system/        # mechrevo-rgb-off.service
│   └── udev/rules.d/          # USB power + input quirks
└── usr/
    ├── lib/systemd/system-sleep/   # RGB-off resume hook
    └── local/sbin/                 # privileged helpers
```

## Install / re-install

```bash
sudo ~/workplace/tony_ubuntu_setup/install.sh
```

Safe to run repeatedly. Always backs up replaced files to
`/var/backups/tony_ubuntu_setup-<timestamp>/`. The PAM section auto-rolls back
if the Cursor agent bypass self-test fails (so you never get locked out of sudo).

## What it installs

| Path                                                | Source                                              |
|-----------------------------------------------------|-----------------------------------------------------|
| `/usr/local/sbin/cursor-sudo-bypass.sh`             | `usr/local/sbin/cursor-sudo-bypass.sh`              |
| `/usr/local/sbin/mechrevo-rgb-off`                  | `usr/local/sbin/mechrevo-rgb-off`                   |
| `/etc/systemd/system/mechrevo-rgb-off.service`      | `etc/systemd/system/mechrevo-rgb-off.service`       |
| `/usr/lib/systemd/system-sleep/mechrevo-rgb-off`    | `usr/lib/systemd/system-sleep/mechrevo-rgb-off`     |
| `/etc/udev/rules.d/50-usb-autosuspend-off.rules`    | SteelSeries Sensei + Genesys hub: no autosuspend    |
| `/etc/udev/rules.d/80-steelseries-ignore-mouse-keyboard.rules` | hide bogus HID keyboard from libinput    |
| `/etc/udev/rules.d/85-mechrevo-rgb-off.rules`       | trigger RGB-off service on USB hotplug              |
| `/etc/udev/rules.d/99-usb-internal-hub-always-on.rules` | keep Genesys internal hubs powered             |
| `/etc/sudoers.d/limitedadmins`                      | scrubs `Defaults secure_path`                       |
| `/etc/pam.d/sudo`, `/etc/pam.d/sudo-i`              | Cursor agent passwordless bypass via `pam_exec`     |
| `~/.local/bin/mechrevo_ite8291_rgb_off.py`          | symlink to `bin/mechrevo_ite8291_rgb_off.py`        |

## Explicitly NOT installed (intentional)

- `jzxwww-nopasswd.sudoers` — full `NOPASSWD: ALL` was deemed too broad; the
  Cursor-agent-only PAM bypass is used instead. The drop-in is removed from
  `/etc/sudoers.d/` if found.
- `85-mechrevo-ite8291-usb.rules` (old plugdev approach) — replaced by the
  systemd-based `mechrevo-rgb-off` service triggered by
  `85-mechrevo-rgb-off.rules`. The old rule is removed if found.

## Useful docs

- `docs/MONITOR_FIX.md` — LG UltraGear G-SYNC monitor not lighting up; root
  cause + post-reboot verification commands. Generated 2026-05-13 during the
  `prime-select on-demand → nvidia` switch.
- `docs/template_mechrevo_setup.md` — Template for creating similar setup repos (Mechrevo specific).
