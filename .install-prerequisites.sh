#!/bin/bash
set -e
echo "Installing Pre-requisites..."
# Check if snapd is installed, install if not
if ! command -v snap &> /dev/null; then
    echo "snapd not found. Installing..."
    if sudo apt update && sudo apt install -y snapd; then
        echo "snapd installed successfully"
    else
        echo "Failed to install snapd with apt. Try manually."
        exit 1
    fi
else
    echo "snapd is already installed."
fi

# Install Bitwarden CLI if not already installed
if type bw >/dev/null 2>&1; then
    echo "Bitwarden CLI is already installed"
else
    echo "Installing Bitwarden CLI"
    if sudo snap install bw; then
        echo "Bitwarden CLI installed successfully"
    else
        echo "Failed to install Bitwarden CLI"
        exit 1
    fi
fi