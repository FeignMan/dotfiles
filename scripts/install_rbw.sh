#!/bin/bash
#
# rbw-install.sh: A robust script to download and install the latest version
# of rbw (unofficial Bitwarden CLI) on Debian-based systems.
#
# This script intelligently finds the latest release from the official GitHub
# repository, downloads the .tar.gz package for the amd64 architecture,
# and extracts it to the user's local bin directory.

set -euo pipefail

GITHUB_REPO="doy/rbw"
TMP_DIR="" # Will be set by mktemp

log() {
    echo "[install_rbw] $@" >&2
}

# Print an error message and exit
fail() {
    echo "[install_rbw] ERROR: $@" >&2
    # Cleanup temporary directory if it was created
    log "Cleaning up temporary directory: ${TMP_DIR}"
    rm -rf "${TMP_DIR}"
    exit 1
}

# Check for the presence of a command
check_command() {
    if ! command -v "$1" &> /dev/null; then
        fail "Required command '$1' not found. Please install it. On Debian/Ubuntu, try: sudo apt update && sudo apt install $1"
    fi
}

# Verify system prerequisites
pre_flight_checks() {
    log "Checking pre-requisites..."

    # 1. Check architecture
    if [[ "$(uname -m)" != "x86_64" ]]; then
        fail "This script is intended for x86_64 (amd64) architecture only."
    fi

    # 2. Check for required tools
    check_command "curl"
    check_command "grep"
    check_command "jq"
    check_command "sudo"

    # 3. Check for root privileges for the final install step
    if [ "$(id -u)" -eq 0 ]; then
        fail "This script should not be run as root. It will use 'sudo' when needed."
    fi

    log "All checks passed."
}

# Find the download URL for the latest amd64.deb package
find_latest_release_url() {
    log "Querying GitHub API for the latest release of ${GITHUB_REPO}..."
    local api_url="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"

    # Fetch release data from GitHub API
    local response
    response=$(curl --silent --fail "${api_url}") || fail "Failed to fetch release data from GitHub API."

    # Parse the JSON response to find the download URL for the amd64.tar.gz asset
    local download_url
    download_url=$(echo "${response}" | jq -r '.assets[] | select(.name | endswith("_amd64.tar.gz")) |.browser_download_url')

    if [[ -z "${download_url}" ]]; then
        fail "Could not find a suitable amd64.tar.gz package in the latest release."
    fi

    echo "${download_url}"
}

# Download the package to a temporary directory
download_package() {
    local url="$1"
    local filename
    filename=$(basename "${url}")

    # Download to a temporary directory
    local TMP_DIR="${HOME}/.cache/rbw-install-$$-$RANDOM"
    mkdir -p "${TMP_DIR}"
    local destination="${TMP_DIR}/${filename}"
    log "Downloading ${filename} to ${destination}..."
    curl --progress-bar --fail --location -o "${destination}" "${url}" || fail "Failed to download the package from ${url}."

    echo "${destination}"
}

# Install the downloaded.deb package
install_package() {

    log "Install path: ${1}"
    mkdir -p "${HOME}/.local/bin"
    tar -xzf "${1}" -C "${HOME}/.local/bin" || fail "Failed to extract tar.gz file."
    chmod +x "${HOME}/.local/bin/rbw"

    log "Installation successful!"
}

main() {
    # Check if rbw is already installed
    if command -v rbw &> /dev/null; then
        log "rbw is already installed (version: $(rbw --version))."
        read -p "Do you want to attempt to re-install/upgrade? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Exiting."
            exit 0
        fi
    fi

    pre_flight_checks

    local release_url
    release_url=$(find_latest_release_url)
    log "Found latest release URL: ${release_url}"

    local package_path
    package_path=$(download_package "${release_url}")
    log "Package downloaded to: ${package_path}"
    TMP_DIR=$(dirname "${package_path}")

    install_package "${package_path}"

    # Cleanup
    log "Cleaning up temporary directory: ${TMP_DIR}"
    rm -rf "${TMP_DIR}"

    log "rbw has been successfully installed. Run 'rbw --version' to verify."
    log "Next steps: Configure your email with 'rbw config email your@email.com' and then run 'rbw sync'."
}

# Run the main function
main
