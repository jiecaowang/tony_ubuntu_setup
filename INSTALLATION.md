# Ubuntu 24.04 Reinstallation Guide (Tony Setup)

This document serves as a comprehensive, step-by-step guide to restore all custom configurations and services after a clean OS reinstallation on Ubuntu 24.04. The goal is to minimize manual intervention by following the steps outlined below in order.

## 📦 Phase 0: Required Packages (Manual Installation)

**ACTION REQUIRED:** Before running any scripts or copying files, you must install all necessary system packages on a clean Ubuntu 24.04 OS using `apt`. This list includes dependencies for services and utilities found in this repository.

*   `sudo apt update && sudo apt install -y udev systemd python3-pip <add_other_packages>`

## ⚙️ Phase 1: Core Configuration Restoration (Manual File Copying)

These files define system behavior and must be copied/placed in their respective directories. **Use `cp` or appropriate deployment tools for these.**

### 2. Restore Core Configuration Files
*   **Systemd Services:** Copy all service definitions to `/etc/systemd/system/`.
    *   `etc/systemd/system/mechrevo-rgb-off.service`
*   **Udev Rules:** Copy all custom udev rules to `/etc/udev/rules.d/`.
    *   `etc/udev/rules.d/50-usb-autosuspend-off.rules`
    *   `etc/udev/rules.d/80-steelseries-ignore-mouse-keyboard.rules`
    *   `etc/udev/rules.d/85-mechrevo-rgb-off.rules`
    *   `etc/udev/rules.d/99-usb-internal-hub-always-on.rules`
*   **PAM & Sudoers:** Restore the necessary security and authentication files.
    *   `/etc/pam.d/sudo`, `/etc/pam.d/sudo-i` (Requires careful handling to maintain passwordless bypass).
    *   `/etc/sudoers.d/limitedadmins`

## 💻 Phase 2: Running Custom Scripts & Services (Automated)

Once the core files are in place, run the following scripts in order.

### 1. Run Main Installer Script
This script handles symlinking local binaries and setting up services atomically.
*   **Command:** `sudo ~/workplace/tony_ubuntu_setup/install.sh`

### 2. Configure Local Binaries
Ensure user-space scripts are available in the PATH.
*   **Action:** Symlink the local script to `~/.local/bin/`.
    *   `bin/mechrevo_ite8291_rgb_off.py` -> `~/.local/bin/mechrevo_ite8291_rgb_off.py`

## 🔑 Phase 3: User-Specific Setup (Manual)

These steps are specific to your user account and need manual execution or dedicated scripts.

### 1. Git Configuration
*   **Action:** Generate a new SSH key pair if necessary, and add the public key to all required services (GitHub, GitLab, etc.).
    *   `ssh-keygen -t ed25519 -C "your_email@example.com"`
    *   Copy `~/.ssh/id_ed25519.pub` content and add it to GitHub/GitLab settings.

### 2. Environment Variables & Dotfiles
*   **Action:** Restore custom environment variables (e.g., in `~/.bashrc`, `~/.zshrc`).
    *   *(Add specific variable restoration steps here)*

## 📚 Reference Documentation

For detailed troubleshooting or understanding the original intent of a configuration, refer to:
*   `docs/MONITOR_FIX.md`: LG G-SYNC monitor setup guide.
*   `docs/template_mechrevo_setup.md`: Template for future custom setups.

## 💻 Phase 2: Running Custom Scripts & Services

Once the core files are in place, run the following scripts in order.

### 1. Run Main Installer Script
This script handles symlinking local binaries and setting up services atomically.
*   **Command:** `sudo ~/workplace/tony_ubuntu_setup/install.sh`

### 2. Configure Local Binaries
Ensure user-space scripts are available in the PATH.
*   **Action:** Symlink the local script to `~/.local/bin/`.
    *   `bin/mechrevo_ite8291_rgb_off.py` -> `~/.local/bin/mechrevo_ite8291_rgb_off.py`

## 🔑 Phase 3: User-Specific Setup (Non-System)

These steps are specific to your user account and need manual execution or dedicated scripts.

### 1. Git Configuration
*   **Action:** Generate a new SSH key pair if necessary, and add the public key to all required services (GitHub, GitLab, etc.).
    *   `ssh-keygen -t ed25519 -C "your_email@example.com"`
    *   Copy `~/.ssh/id_ed25519.pub` content and add it to GitHub/GitLab settings.

### 2. Environment Variables & Dotfiles
*   **Action:** Restore custom environment variables (e.g., in `~/.bashrc`, `~/.zshrc`).
    *   *(Add specific variable restoration steps here)*

## 📚 Reference Documentation

For detailed troubleshooting or understanding the original intent of a configuration, refer to:
*   `docs/MONITOR_FIX.md`: LG G-SYNC monitor setup guide.
*   `docs/template_mechrevo_setup.md`: Template for future custom setups.