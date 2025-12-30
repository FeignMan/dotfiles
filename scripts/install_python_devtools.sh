#!/bin/bash
set -e

log() {
    echo -e "\n\e[0;32m[python-devtools] $@\e[00m"
}

log_error() {
    echo -e "\n\e[0;31m[python-devtools] $@\e[00m" >&2
}

log "Installing Python Developer Tools..."

# Install uv
if ! command -v uv &> /dev/null; then
    log "uv not found. Installing..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        log "uv installed successfully"
    else
        log_error "Failed to install uv. Try manually."
        exit 1
    fi
else
    log "uv is already installed."
fi

# Install Ruff
if ! command -v ruff &> /dev/null; then
    log "Installing Ruff..."
    uv tool install ruff
else
    log "Ruff is already installed."
fi

# Install Poetry
if ! command -v poetry &> /dev/null; then
    log "Installing Poetry..."
    uv tool install poetry
else
    log "Poetry is already installed."
fi
