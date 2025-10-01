# Dotfiles (managed by Chezmoi)

This repository contains personal configuration files managed using [chezmoi](https://www.chezmoi.io/).

## Features
- Shell configuration: bash, zsh, aliases
- Git configuration
- Tmux configuration and themes
- Custom scripts for system setup and maintenance
- Automated package installation and system configuration

## Structure
- `private_dot_config/`: ~/.config/ contains most config files
  - tmux
  - zsh
  - git
- `./scripts`: Internal setup scripts like Zsh/OMZ installer
- `run_once_00_install-prerequisites.sh.tmpl`: Installs `snapd` and `bw`.
- `run_once_01_after_setup-configure-system.sh`: Installs Tmux Plugin Manager.

## Usage
1. Install cURL:
   ```sh
   sudo apt install curl
   ```
2. **Install** [**Chezmoi**](https://www.chezmoi.io/install/#__tabbed_5_5):
   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```
3. **Initialize dotfiles**:
   ```sh
   chezmoi init FeignMan
   chezmoi apply
   ```
   **Note:** Step #3 and #4 can be combined:
   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply FeignMan
   ```
4. **Customize** - Track new files or changes to tracked files:
   ```sh
   chezmoi add <file_path>
   chezmoi cd
   git commit -am "<update message>"
   git push
   ```

## Setup Bitwarden CLI
`bw` is installed by the package install script. Follow these steps to login with [API key](https://bitwarden.com/help/personal-api-key):
1. `bw login --api`
2. Enter `client_id` and `client_secret`
3. `export BW_SESSION=$(bw unlock --raw)`

## Notes
- Private files are stored in `dot_local/private_share/`.
- Scripts in `scripts/` are helper scripts, not run automatically by `chezmoi`.
- Initial setup is handled by `run_once_` scripts, which are executed automatically by `chezmoi apply` on a new machine.

## Todo
- Bitwarden integration
- setup_start.sh
- Templating by hostname

## Resources
- [chezmoi documentation](https://www.chezmoi.io/docs/)
- [Dotfiles best practices](https://dotfiles.github.io/)
