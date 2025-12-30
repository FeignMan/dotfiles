# Dotfiles (managed by Chezmoi)

This repository contains personal configuration files managed using [chezmoi](https://www.chezmoi.io/) and automates system bootstrapping for Linux (specifically Debian/Ubuntu-based) environments.

## Features
*   **Shell:** Zsh (with Oh-My-Zsh), Bash, custom aliases.
*   **Terminal:** Tmux (with TPM and themes).
*   **Secrets:** Vaultwarden/Bitwarden integration (via `bw` and `rbw`).
*   **Languages:** Python (optional), Rust, Node.js (via NVM).
*   **Package Management:** Automates installation of APT, Snap, and NPM packages defined in `.chezmoidata.yaml`.
*   **Git:** Configuration.

## Key Files & Configuration
*   **`.chezmoi.toml.tmpl`**: The template for the local configuration file. Prompts for Vaultwarden URL, email, and Python tools toggle.
*   **`.chezmoidata.yaml`**: Centralized list of packages to install (Apt, Snap, NPM). Edit this file to add/remove system packages.
*   **`run_once_00_install-prerequisites.sh.tmpl`**: Installs `snapd`, `rbw`, and `bw`.
*   **`run_onchange_install-packages.sh.tmpl`**: Handles system updates, package installations (Apt, Snap, NPM, Rust, Python), and Zsh setup. Re-runs automatically if `.chezmoidata.yaml` changes.

### Directory Structure
*   **`dot_bashrc` / `dot_zshenv`**: Mapped to `~/.bashrc` and `~/.zshenv`.
*   **`private_dot_config/`**: Mapped to `~/.config/`. Contains configs for:
    *   `git/`, `tmux/`, `zsh/`, `direnv/`, `rbw/`.
*   **`dot_local/private_share/`**: Mapped to `~/.local/share/`.
*   **`scripts/`**: Internal helper scripts (e.g., Zsh setup), not run automatically by chezmoi unless called by a provisioning script.

## Usage

### 1. Installation
**One-step install:**
```sh
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply FeignMan
```
*(Logout and login for shell changes to take effect)*

**Manual install:**
```sh
# Install Chezmoi
sh -c "$(curl -fsLS get.chezmoi.io/lb)"

# Initialize and apply
chezmoi init FeignMan
chezmoi apply
```

**Testing a Dev Branch:**
```sh
chezmoi init --branch <branch_name> FeignMan
```

### 2. Common Operations
*   **Apply changes:** `chezmoi apply`
*   **Edit a file:** `chezmoi edit ~/.bashrc` (then apply)
*   **Add a file:** `chezmoi add ~/.config/my-app/config.toml`
*   **Update from git:** `chezmoi update`

### 3. Managing Packages
To add a new system package (e.g., `ripgrep`), do not edit the installation scripts directly.
1.  Open `.chezmoidata.yaml`.
2.  Add the package name under `packages.universal.apts` (or `snap`/`npm_packages`).
3.  Run `chezmoi apply`.

## Secrets Management (Bitwarden)
`bw` is installed by the package install script. Follow these steps to configure:
1.  Login with [API key](https://bitwarden.com/help/personal-api-key): `bw login --api`
2.  Enter `client_id` and `client_secret`
3.  Unlock session: `export BW_SESSION=$(bw unlock --raw)`

## Development Conventions
*   **Templating:** Files ending in `.tmpl` are Go templates. They can access variables defined in `.chezmoi.toml.tmpl` or `.chezmoidata.yaml`.
*   **Private Files:** Directories/files prefixed with `private_` generally have permissions `0700` or `0600`.
*   **Auto-commit:** The repo is configured to `autoCommit` and `autoPush` in `.chezmoi.toml.tmpl`.

## Todo
- Python toolchain
- setup_start.sh
- Templating by hostname

## Resources
- [chezmoi documentation](https://www.chezmoi.io/docs/)
- [Dotfiles best practices](https://dotfiles.github.io/)