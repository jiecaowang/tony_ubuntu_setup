# Tony Ubuntu preferences (jzxwww @ tony-linux)

Golden notes for reproducing this setup on a **clean Ubuntu** of the same generation (kernel **7.x**, GNOME, **sudo-rs**). Adjust user name, USB IDs, and layouts if hardware differs.

---

## 1. Sudo — no password (`NOPASSWD`)

**Tradeoff:** anyone who runs commands as `jzxwww` can become root without a password. Fine on a personal machine; avoid on shared systems.

**Files:**

- `/etc/sudoers.d/jzxwww-nopasswd`:

```sudoers
jzxwww ALL=(ALL:ALL) NOPASSWD: ALL
```

- `/etc/sudoers.d/limitedadmins` — `Defaults secure_path=...` only.

**Install / validate:**

```bash
bash ~/apply-tony-system-tweaks.sh
# or manually:
sudo install -m 440 ~/jzxwww-nopasswd.sudoers /etc/sudoers.d/jzxwww-nopasswd
sudo install -m 440 ~/limitedadmins.sudoers /etc/sudoers.d/limitedadmins
sudo visudo -cf /etc/sudoers.d/jzxwww-nopasswd
sudo visudo -cf /etc/sudoers.d/limitedadmins
```

Optional: remove `/etc/sudoers.d/99-timestamp-timeout` if present (redundant with NOPASSWD).

---

## 2. Laptop lid + external monitor (systemd-logind)

**File:** `/etc/systemd/logind.conf.d/50-lid-and-external-display.conf`

```ini
[Login]
HandleLidSwitch=suspend
HandleLidSwitchDocked=ignore
```

Apply: reboot, or `sudo systemctl restart systemd-logind` (can disrupt the session).

---

## 3. USB autosuspend off (SteelSeries mouse + hub)

**Sources:** `~/50-usb-autosuspend-off.rules`  
**Install:** `/etc/udev/rules.d/50-usb-autosuspend-off.rules`

```udev
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1038", ATTR{idProduct}=="136b", TEST=="power/control", ATTR{power/control}="on"
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", ATTR{idProduct}=="0610", TEST=="power/control", ATTR{power/control}="on"
```

```bash
sudo cp 50-usb-autosuspend-off.rules /etc/udev/rules.d/50-usb-autosuspend-off.rules
sudo chmod 644 /etc/udev/rules.d/50-usb-autosuspend-off.rules
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=usb
```

Verify IDs with `lsusb` before copying to another machine.

---

## 4. Keyboard & input (GNOME)

**Layouts:** `ca+eng` and `cn+basic`.

**gsettings:**

```bash
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'ca+eng'), ('xkb', 'cn+basic')]"
gsettings set org.gnome.desktop.input-sources xkb-options '[]'
gsettings set org.gnome.desktop.input-sources xkb-model 'pc105'
gsettings set org.gnome.desktop.peripherals.keyboard numlock-state false
gsettings set org.gnome.desktop.peripherals.keyboard remember-numlock-state false
```

**`/etc/default/keyboard`:**

```sh
XKBMODEL="pc105"
XKBLAYOUT="ca,cn"
XKBVARIANT="eng,basic"
XKBOPTIONS=""
```

**SteelSeries Sensei macro “keyboard” (libinput ignore):** `/etc/udev/rules.d/80-steelseries-ignore-mouse-keyboard.rules`

```udev
ACTION=="add", SUBSYSTEM=="input", ENV{ID_INPUT_KEYBOARD}=="1", ATTR{name}=="La-VIEW Technology SteelSeries Sensei MLG Keyboard", ENV{LIBINPUT_IGNORE_DEVICE}="1"
```

Installed by `~/apply-tony-system-tweaks.sh`. Removing this rule restores mouse-side macro keys if you need them.

---

## 5. MECHREVO chassis RGB off (ITE `048d:600b`)

Chassis / light bar is **not** a normal `/sys/class/leds` device; Ubuntu leaves it at the EC default unless you poke the **ITE 8291** USB controller.

| USB        | Chip   |
|-----------|--------|
| `048d:600b` | ITE 8291 |
| `048d:7001` | ITE 8233 (other zones on some units) |

**One-time system pieces** (also in `~/apply-tony-system-tweaks.sh`): `python3-usb`, udev `85-mechrevo-ite8291-usb.rules`:

```udev
SUBSYSTEM=="usb", ATTR{idVendor}=="048d", ATTR{idProduct}=="600b", MODE="0660", GROUP="plugdev"
```

**Per login:** `~/.config/autostart/mechrevo-chassis-rgb-off.desktop` → `~/bin/mechrevo_ite8291_rgb_off.py`  
Disable under **Settings → Apps → Startup** if you want the lights back.

**Manual once:** `~/bin/mechrevo_ite8291_rgb_off.py`  
**Firmware optional:** reboot, tap **F2** or **Del** at MECHREVO logo, look for Logo / RGB / Illumination toggles, save (**F10**).

If the **lid logo** stays on, try BIOS options or **OpenRGB**; it may be on `7001`, not `600b`.

---

## 6. Host facts

| Item       | Value            |
|-----------|------------------|
| Hostname  | `tony-linux`     |
| User      | `jzxwww`         |
| Locale    | `en_CA.UTF-8`    |
| Sudo      | `sudo-rs`        |

---

## 7. Changelog (append)

_Add dated bullets when you change something system-wide._

---

## 8. Clean install — file bundle

Copy then run **`bash ~/apply-tony-system-tweaks.sh`**:

- `tony_ubuntu_pref.md` (this file)
- `apply-tony-system-tweaks.sh`
- `jzxwww-nopasswd.sudoers`, `limitedadmins.sudoers`
- `50-usb-autosuspend-off.rules`
- `80-steelseries-ignore-mouse-keyboard-interface.rules` → `/etc/udev/rules.d/80-steelseries-ignore-mouse-keyboard.rules`
- `85-mechrevo-ite8291-usb.rules`
- `bin/mechrevo_ite8291_rgb_off.py`
- `.config/autostart/mechrevo-chassis-rgb-off.desktop`

Then set **§2** logind, **§4** `/etc/default/keyboard`, and **gsettings** as above if not scripted yet. Reboot once.
