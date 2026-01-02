#!/bin/bash
set -euo pipefail

log() {
    echo -e "\n\e[0;32m[install-docker] $@\e[00m"
}

# Add Docker's official GPG key:
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the latest version
sudo apt-get install -yqq docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin

# Add the current user to the docker group
sudo usermod -aG docker "$USER"

# Enable the docker service
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

log "Docker installed successfully."
echo "You need to log out and log back in for the group changes to take effect."
