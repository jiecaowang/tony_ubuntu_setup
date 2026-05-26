#!/bin/bash

# ==============================================================
# tony_ubuntu_setup - Master Reinstallation Script
# Goal: Automate the restoration of all custom configurations 
#       and services for Ubuntu 24.04.
# Usage: sudo ./reinstall_all.sh
# ==============================================================

set -e # Exit immediately if a command exits with a non-zero status.

echo "--- Starting Tony Setup Reinstallation ---"

# --- Phase 1: System Dependency Check (Manual Step) ---
echo ""
echo "############################################################"
echo "# PHASE 1: SYSTEM DEPENDENCY CHECK & FILE RESTORATION #"
echo "############################################################"
echo "ACTION REQUIRED: Please ensure all necessary packages are installed."
echo "Example: sudo apt update && sudo apt install -y udev systemd python3-pip..."

# --- Phase 2: Core Configuration Restoration (Automated) ---
echo ""
echo "############################################################"
echo "# PHASE 2: CORE CONFIGURATION RESTORATION #"
echo "############################################################"

# 1. Restore Systemd Services and Udev Rules
echo "-> Restoring systemd services and udev rules..."
sudo cp -r ./etc/systemd/system/* /etc/systemd/system/
sudo cp -r ./etc/udev/rules.d/*.rules /etc/udev/rules.d/

# 2. Restore PAM & Sudoers files
echo "-> Restoring PAM and sudoers configurations..."
sudo cp ./etc/pam.d/sudo /etc/pam.d/sudo
sudo cp ./etc/pam.d/sudo-i /etc/pam.d/sudo-i
sudo cp ./etc/sudoers.d/limitedadmins /etc/sudoers.d/

# 3. Run Main Installer Script (Handles symlinks and remaining services)
echo "-> Running the main installer script to finalize setup..."
# Note: This assumes install.sh is designed to be run with sudo context
sudo ./install.sh

# --- Phase 3: Local Binaries & User Setup (Automated/Semi-Automated) ---
echo ""
echo "############################################################"
echo "# PHASE 3: LOCAL BINARIES AND USER SETUP #"
echo "############################################################"

# 1. Configure Local Binaries Symlink
LOCAL_BIN_SOURCE="./bin/mechrevo_ite8291_rgb_off.py"
LOCAL_BIN_TARGET="$HOME/.local/bin/mechrevo_ite8291_rgb_off.py"

if [ -f "$LOCAL_BIN_SOURCE" ]; then
    echo "-> Creating symlink for local binary: $LOCAL_BIN_SOURCE -> $LOCAL_BIN_TARGET"
    # Use -f to overwrite existing links/files if necessary
    sudo ln -sf "$LOCAL_BIN_SOURCE" "$LOCAL_BIN_TARGET"
else
    echo "WARNING: Local binary source not found at $LOCAL_BIN_SOURCE. Skipping symlink."
fi

# 2. Environment Variables & Dotfiles (Manual Step Reminder)
echo ""
echo "============================================================"
echo "✅ SETUP COMPLETE! ✅"
echo "============================================================"
echo "The system configuration is restored. Please manually complete the following:"
echo "1. Git Keys: Generate new SSH keys and add public key to GitHub/GitLab."
echo "2. Dotfiles: Manually restore custom environment variables in ~/.bashrc, ~/.zshrc, etc."

# Optional: Reload services after changes
echo ""
echo "Running systemctl daemon-reload to ensure all new services are recognized..."
sudo systemctl daemon-reload

exit 0