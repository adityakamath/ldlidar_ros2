#!/bin/bash
# Installation script for LDLiDAR udev rules
# This script installs udev rules to create a persistent /dev/ttyLIDAR symlink

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UDEV_RULE_FILE="${SCRIPT_DIR}/../udev/99-ldlidar.rules"
UDEV_RULES_DIR="/etc/udev/rules.d"

echo "LDLiDAR Udev Rule Installer"
echo "============================"
echo

# Check if udev rule file exists
if [ ! -f "$UDEV_RULE_FILE" ]; then
    echo "Error: Udev rule file not found at $UDEV_RULE_FILE"
    exit 1
fi

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with sudo privileges"
    echo "Usage: sudo ./install_udev_rules.sh"
    exit 1
fi

# Check if the rule file has been configured
if grep -q "SUBSYSTEM.*XXXX.*YYYY" "$UDEV_RULE_FILE"; then
    echo "WARNING: The udev rule file contains placeholder values (XXXX, YYYY)"
    echo
    echo "Please configure the udev rule first:"
    echo "  1. Connect your LiDAR"
    echo "  2. Find the device (usually /dev/ttyUSB0)"
    echo "  3. Run: udevadm info --name=/dev/ttyUSB0 --attribute-walk | grep -E 'idVendor|idProduct'"
    echo "  4. Edit udev/99-ldlidar.rules and uncomment/modify the appropriate rule"
    echo "  5. Run this script again"
    echo
    read -p "Do you want to continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Copy udev rule to system directory
echo "Installing udev rule..."
cp "$UDEV_RULE_FILE" "$UDEV_RULES_DIR/"
chmod 644 "$UDEV_RULES_DIR/99-ldlidar.rules"
echo "✓ Copied udev rule to $UDEV_RULES_DIR/"

# Reload udev rules
echo
echo "Reloading udev rules..."
udevadm control --reload-rules
echo "✓ Udev rules reloaded"

# Trigger udev
echo
echo "Triggering udev..."
udevadm trigger
echo "✓ Udev triggered"

# Add current user to dialout group (if not running as root)
if [ -n "$SUDO_USER" ]; then
    echo
    echo "Adding user '$SUDO_USER' to 'dialout' group..."
    usermod -a -G dialout "$SUDO_USER"
    echo "✓ User added to dialout group"
    echo
    echo "IMPORTANT: You must log out and log back in for group changes to take effect!"
else
    echo
    echo "Note: Run 'sudo usermod -a -G dialout \$USER' to add your user to the dialout group"
fi

echo
echo "Installation complete!"
echo
echo "Verification:"
echo "  1. Connect your LiDAR"
echo "  2. Check if /dev/ttyLIDAR exists: ls -l /dev/ttyLIDAR"
echo "  3. Verify permissions: should show 'crw-rw-rw-' or similar"
echo
