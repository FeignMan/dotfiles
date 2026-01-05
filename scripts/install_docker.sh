#!/bin/bash
set -euo pipefail

log() {
    echo -e "\n\e[0;32m[install-docker] $@\e[00m"
}

export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.18.1-1

# Add Docker's official GPG key, if it doesn't already exist
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  log "Adding Docker's official GPG key..."
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

# Add the repository to Apt sources if it doesn't already exist
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  log "Adding Docker Apt repository..." 
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

# Install the latest version if not already installed
if command -v docker &> /dev/null; then
    log "Docker is already installed. Skipping installation."
else
  sudo apt-get update -yqq
  sudo apt-get install -yqq docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin
  # Add the current user to the docker group
  sudo usermod -aG docker "$USER"

  # Enable the docker service
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service

  log "Docker installed successfully."
  echo "You need to log out and log back in for the group changes to take effect."
fi

# Install nvidia-container-toolkit if NVIDIA GPU is present
if command -v nvidia-smi &> /dev/null; then
    log "NVIDIA GPU detected. Installing nvidia-container-toolkit..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    sudo apt-get update
  
    sudo apt-get install -y \
      nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}
    sudo systemctl restart docker
    log "nvidia-container-toolkit installed successfully."
fi