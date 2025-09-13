# Dotfiles (managed by Chezmoi)

This repository contains personal configuration files managed using [chezmoi](https://www.chezmoi.io/).

## Features
- Shell configuration: bash, zsh, aliases
- Git configuration
- Tmux configuration and themes
- Custom scripts for system setup and maintenance
- Automated package installation and system configuration

## Structure
- `dot_bashrc`, `dot_zshenv`, `private_dot_config/zsh/dot_zshrc`, `private_dot_config/zsh/dot_aliases`: Shell configs
- `private_dot_config/git/config`: Git config
- `private_dot_config/tmux/tmux.conf`, `private_dot_config/tmux/themes/`: Tmux configs and themes
- `custom_scripts/`: Custom executable scripts
- `dot_local/private_share/scripts/setup-zsh.sh`: Zsh setup script
- `run_once_after_setup-configure-system.sh`: System configuration script (run once)
- `run_onchange_install-packages.sh.tmpl`: Package installation script (runs on change)

## Usage
1. **Install pre-requisites** 
   1. Chezmoi ([docs](https://www.chezmoi.io/install/#__tabbed_5_5))
   2. Bitwarden CLI ([docs](https://bitwarden.com/help/cli/#tab-snap-bI3gMs3A3z4pl0fwvRie9))
   ```sh
   snap install chezmoi --classic
   snap install bw
   ```
2. **Initialize chezmoi**:
   ```sh
   chezmoi init <your-github-username>
   chezmoi apply
   ```
3. **Customize** - Track new files or changes to tracked files:
   ```sh
   chezmoi add <file_path>
   chezmoi cd
   git commit -am "<update message>"
   git push
   ```

## Notes
- Private files are stored in `dot_local/private_share/`.
- Scripts in `custom_scripts/` are executable and can be used for system checks and setup.

## Todo
- Bitwarden integration
- setup_start.sh
- Templating by hostname

## Resources
- [chezmoi documentation](https://www.chezmoi.io/docs/)
- [Dotfiles best practices](https://dotfiles.github.io/)
