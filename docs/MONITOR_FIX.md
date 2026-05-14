# LG UltraGear (G-SYNC, HDMI) — post-reboot verification

Context: hybrid laptop (Intel Arrow Lake iGPU + NVIDIA RTX 5080 Mobile dGPU),
HDMI port wired to dGPU only. G-SYNC requires the dGPU to own scanout, so we
switched `prime-select` from `on-demand` → `nvidia` and rebooted.

## 1. After reboot, run these checks (copy-paste block)

```bash
echo "=== prime profile (want: nvidia) ===";          prime-select query
echo "=== GL renderer (want: NVIDIA GeForce RTX 5080) ==="; glxinfo -B 2>/dev/null | grep -i "OpenGL renderer"
echo "=== xrandr providers (NVIDIA should be primary) ==="; xrandr --listproviders
echo "=== Connected outputs ===";                     xrandr --query | grep -E " connected"
echo "=== Mutter sees the LG? ===";                   gdbus call --session --dest org.gnome.Mutter.DisplayConfig --object-path /org/gnome/Mutter/DisplayConfig --method org.gnome.Mutter.DisplayConfig.GetCurrentState 2>&1 | grep -oE "'(LG|HDMI)[^']*'" | sort -u
echo "=== nvidia-smi ===";                            nvidia-smi --query-gpu=name,driver_version,pstate --format=csv
```

Expected after a successful reboot:

- `prime query` → `nvidia`
- `OpenGL renderer` → `NVIDIA GeForce RTX 5080 …`
- `xrandr --listproviders` → first provider is the NVIDIA one
- `xrandr --query` → both `eDP-1 connected` AND `HDMI-1 connected`
- Mutter list → contains `'LG ULTRAGEAR'` AND `'HDMI-1'`
- The LG panel itself is showing the desktop (not "no signal")

## 2. If the monitor STILL shows no signal after reboot

Collect logs and paste them back to me:

```bash
journalctl -b 0 -k     | grep -iE 'nvidia|drm|hdmi' | tail -80
journalctl -b 0 _COMM=gnome-shell | grep -iE 'monitor|kms|drm|nvidia' | tail -40
dmesg | grep -iE 'nvidia|drm-err|hdmi|hpd' | tail -40
cat /sys/class/drm/card*-HDMI-A-1/status   # want: connected
cat /sys/class/drm/card*-HDMI-A-1/enabled  # want: enabled
cat /sys/class/drm/card*-HDMI-A-1/modes | head
```

Then escalate in this order:

1. **Force fbdev for NVIDIA DRM** (helps with some Wayland + dGPU scanout edge cases):

   ```bash
   echo 'options nvidia_drm fbdev=1' | sudo tee /etc/modprobe.d/nvidia-drm-fbdev.conf
   sudo update-initramfs -u
   sudo reboot
   ```

2. **Check / replace the cable.** G-SYNC over HDMI 2.1 at 2560×1440 needs a real
   "Ultra High Speed HDMI" cable. Cheap cables drop the link silently.

3. **Try the LG's other input** (DP-on-laptop → DP-on-monitor if you have a USB-C/Thunderbolt → DP adapter). The dGPU's DP-5 is also wired out on this chassis.

4. **BIOS MUX switch.** MECHREVO YAOSHI: enter BIOS → look for
   `Graphics Configuration` / `Display Mode` / `Hybrid Mode`. Set to
   **Discrete only** (a.k.a. dGPU / MSHybrid disabled). Reboot.
   This makes the dGPU drive even the internal panel, eliminates PRIME entirely,
   and is the most reliable G-SYNC config.

5. **Driver swap.** You're on `nvidia-driver-595-open` (open kernel module).
   If issues persist, try the proprietary module:

   ```bash
   sudo apt install nvidia-driver-595        # proprietary, not -open
   sudo prime-select nvidia
   sudo reboot
   ```

## 3. To revert to laptop-only / battery-friendly mode

```bash
sudo prime-select on-demand
sudo reboot
```

Trade-off: `on-demand` saves ~10-15 W idle on battery but the HDMI port (wired
to dGPU) won't reliably light G-SYNC monitors. Use `nvidia` when docked at
the desk, `on-demand` when mobile.

## 4. State at the time this file was written (pre-reboot)

```
Distro       : Ubuntu 26.04 LTS, kernel 7.0.0-15-generic
Laptop       : MECHREVO YAOSHI Series (ARL)
GPUs         : Intel Arrow Lake iGPU + NVIDIA GeForce RTX 5080 Mobile (16 GB)
NVIDIA driver: 595.58.03 (open kernel module)
Session      : GNOME on Wayland (compositor on Intel iGPU)
prime-select : on-demand → switched to nvidia (pending reboot)
nvidia-drm   : modeset=1 (correct)
HDMI wiring  : card2-HDMI-A-1  (NVIDIA dGPU)
Mutter saw   : 'LG ULTRAGEAR' / 'LG Electronics 32"' (EDID parsed OK)
Symptom      : monitor reports "no signal" despite being detected by kernel + Mutter
Root cause   : PRIME on-demand cannot drive G-SYNC HDMI scanout from the dGPU
               while the iGPU owns the compositor; G-SYNC link refuses to bring up.
Fix applied  : sudo prime-select nvidia  (reboot pending to take effect)
```
