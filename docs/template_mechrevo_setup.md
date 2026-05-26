# Mechrevo Post-Install Setup Script (Ubuntu 26 Target)

This script handles udev rules, user-space binaries, and RGB control for Mechrevo hardware.

## Installation Script Snippet

```bash
#!/bin/bash

# ---------------------------------------------------------------- 1. Variables
BACKUP="/home/$USER/.local/backup_$(date +%Y%m%d_%H%M%S)"
REPO="/home/$USER/mechrevo-config" # Adjust this to your actual repo path

mkdir -p "$BACKUP"

# ---------------------------------------------------------------- 2. Udev Rules (RGB Control)
echo "Setting up udev rules..."
sudo bash -c 'cat <<EOF > /etc/udev/rules.d/99-mechrevo-rgb.rules
ACTION=="add", SUBSYSTEM=="leds", ATTR{brightness}="0"
EOF'

# ---------------------------------------------------------------- 3. Sudoers Drop-ins (General)
echo "Setting up sudoers drop-ins..."
sudo bash -c 'cat <<EOF > /etc/sudoers.d/mechrevo-config
# Allow running specific mechrevo scripts without password
USER_NAME="'"$USER"'"
EOF'

# ---------------------------------------------------------------- 4. User Binaries and Symlinks
echo "Setting up user binaries..."
mkdir -p "$HOME/.local/bin"
for f in "$REPO"/bin/*; do
    target="$HOME/.local/bin/$(basename "$f")"
    ln -sfn "$f" "$target"
done

# ---------------------------------------------------------------- 5. RGB-off service
echo "Starting RGB-off service..."
systemctl start mechrevo-rgb-off.service || true

echo
echo "Backup of replaced files: $BACKUP"
echo "Install complete."
```

## Essential Third-Party Apps for New OS Setup

When setting up your new Ubuntu 26 environment, ensure you have these non-native applications installed to support your specific workflow in AI development, Robotics, and general productivity.

### 🤖 AI & Machine Learning (Local Inference)
*   **LM Studio**: The primary tool for running local LLMs with a GUI.
*   **Ollama**: For lightweight, CLI-driven model management and serving.
*   **Docker + NVIDIA Container Toolkit**: Essential for running GPU-accelerable AI models within isolated containers.
*   **Miniconda / Poetry**: For robust Python environment and dependency management.

### 🦾 Robotics & Simulation (ROS2 Ecosystem)
*   **ROS2 (Latest Stable)**: The core robotics framework.
*   **Gazebo**: The primary physics simulator for robot environments.
*   **Foxglove Studio**: An advanced, web-based tool for visualizing ROS2 data streams and debugging.
*   **Wireshark**: Crucial for analyzing DDS (Data Distribution Service) traffic in ROS2 networks.

### 💻 Software Development & IDEs
*   **Pi Code Insider / VS Code**: Your primary integrated development environment.
*   **JetBrains Suite (e.g., PyCharm)**: For more intensive Python-based robotics/AI logic development.
*   **GitKraken or Fork**: High-end GUI clients for Git version control management.
*   **DBeaver**: A universal database manager if your projects involve structured data storage.
*   **Postman / Insomnia**: For testing and documenting web APIs and microservices.

### 🛠️ System Utilities & Productivity
*   **Zsh + Oh My Zsh**: To transform the default terminal into a powerful, customized development environment.
*   **Tmux**: A terminal multiplexer to keep long-running ROS2 or training scripts alive in the background.
*   **Flameshot**: An advanced screenshot tool for documentation and bug reporting.
*   **Bitwarden / KeePassXC**: Secure password management for all your development credentials.

### 🌐 Communication & Web
*   **Steam**: For gaming and potential use of Steam Deck-like utility tools.
*   **Brave / Chrome / Xclier**: Your primary web browsers for research and documentation.
*   **Mission Control WeChat Extension**: For integrated communication within your development workflow.


## Strategy Reasoning
Upgrading to a clean Ubuntu 26 installation is the most stable path forward. This approach avoids "configuration drift" from previous installs, ensures compatibility with the latest ROS2 releases, and provides a clean base for heavy-duty workloads like LM Studio and Gazebo simulations. It minimizes dependency conflicts between AI tools and robotics frameworks.
