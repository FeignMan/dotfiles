# Gemini Context: Chezmoi Dotfiles

This `GEMINI.md` provides context for the AI agent regarding this directory, which is a **Chezmoi source state** repository. It contains dotfiles and provisioning scripts for a Linux environment.

## Project Overview

*   **Purpose:** Manages personal configuration files (dotfiles) and automates system bootstrapping.
*   **Tool:** [chezmoi](https://www.chezmoi.io/)
*   **Target OS:** Linux (specifically Debian/Ubuntu-based, due to `apt` usage).
*   **Key Features:**
    *   **Shell:** Zsh (with Oh-My-Zsh), Bash.
    *   **Terminal:** Tmux (with TPM and themes), custom aliases.
    *   **Secrets:** Vaultwarden/Bitwarden integration (via `bw` and `rbw`).
    *   **Languages:** Python (optional), Rust, Node.js (via NVM).
    *   **Package Management:** Automates installation of APT, Snap, and NPM packages defined in `.chezmoidata.yaml`.

## Key Files & Configuration

### Chezmoi Configuration
*   **`.chezmoi.toml.tmpl`**: The template for the local configuration file. It prompts the user for:
    *   `bw_server_url`: Vaultwarden Server URL.
    *   `my_email`: Vaultwarden login email.
    *   `install_python_tools`: Boolean toggle for Python dev tools.
*   **`.chezmoidata.yaml`**: Centralized list of packages to install (Apt, Snap, NPM). Edit this file to add/remove system packages.

### Provisioning Scripts
These scripts are executed by `chezmoi apply`:
*   **`run_once_00_install-prerequisites.sh.tmpl`**:
    *   Installs `snapd`.
    *   Installs `rbw` (Bitwarden client).
    *   Installs `bw` (Bitwarden CLI) and configures the server URL.
*   **`run_onchange_install-packages.sh.tmpl`**:
    *   Updates system repositories (`apt update`).
    *   Installs packages listed in `.chezmoidata.yaml`.
    *   Installs **Rust** (via `rustup`).
    *   Installs **Python** tools (if enabled).
    *   Installs **Node.js** (via `nvm`) and global NPM packages.
    *   Triggers `scripts/setup-zsh.sh` and installs `fzf`.
    *   **Note:** The filename `run_onchange_` means it re-runs whenever its hash changes (e.g., when you modify `.chezmoidata.yaml` referenced inside it).

### Configuration Structure
*   **`dot_bashrc` / `dot_zshenv`**: Files mapped to `~/.bashrc` and `~/.zshenv`.
*   **`private_dot_config/`**: Maps to `~/.config/`. Contains configs for:
    *   `git/`, `tmux/`, `zsh/`, `direnv/`, `rbw/`.
*   **`dot_local/private_share/`**: Maps to `~/.local/share/`.

## Usage & Commands

### Common Operations
*   **Apply changes:**
    ```bash
    chezmoi apply
    ```
*   **Edit a file (and apply):**
    ```bash
    chezmoi edit ~/.bashrc
    chezmoi apply
    ```
*   **Add a new file to tracking:**
    ```bash
    chezmoi add ~/.config/my-app/config.toml
    ```
*   **Update source from git:**
    ```bash
    chezmoi update
    ```

### Managing Packages
To add a new system package (e.g., `ripgrep`), do not edit the script directly. Instead:
1.  Open `.chezmoidata.yaml`.
2.  Add the package name under `packages.universal.apts` (or `snap`/`npm_packages`).
3.  Run `chezmoi apply`.

## Development Conventions

*   **Templating:** Files ending in `.tmpl` are Go templates. They can access variables defined in `.chezmoi.toml.tmpl` or `.chezmoidata.yaml`.
*   **Private Files:** Directories/files prefixed with `private_` generally have permissions `0700` or `0600`.
*   **Scripts:** Helper scripts in `scripts/` are not run automatically by chezmoi unless called by one of the `run_` scripts.
*   **Git:** The repo is configured to `autoCommit` and `autoPush` in `.chezmoi.toml.tmpl`.
