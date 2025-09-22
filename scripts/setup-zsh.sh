#!/bin/bash

OMZ_PATH="$HOME/.local/share/oh-my-zsh"
ZSH_PLUGIN_PATH="$HOME/.local/share/zsh/omz_plugins"

XDG_DATA_HOME="${XDG_DATA_HOME:-"${HOME}/.local/share"}"
declare -r -a plugins=(
    "zsh-users/zsh-autosuggestions"
    "zdharma-continuum/fast-syntax-highlighting"
    "Aloxaf/fzf-tab"
    "supercrabtree/k"
    "zsh-users/zsh-completions"
    # "zsh-users/zsh-history-substring-search"
)
declare -r -a omzPlugins=(
    "git/git.plugin.zsh"
)

# Check if Zsh is installed
if [ ! -z "$ZSH_VERSION" ]; then
    echo "[setup-zsh.sh] Error: Zsh is not installed. Please install Zsh and rerun this script."
    exit 1
fi

# Install Oh-my-zsh
install_OMZ() {
    if [ -d $OMZ_PATH ]; then
        echo -e "[setup-zsh.sh] Oh-my-zsh is already installed\n"
    else
        echo -e "[setup-zsh.sh] Installing Oh-my-zsh\n"
        mkdir -p $OMZ_PATH
        ZSH=$OMZ_PATH sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

download_OMZ_plugins() {
    mkdir -p "$ZSH_PLUGIN_PATH"

    for plugin in "${omzPlugins[@]}"; do
        plugin_name=$(basename "$plugin"  ".plugin.zsh")
        plugin_path="$ZSH_PLUGIN_PATH/${plugin_name}.plugin.zsh"
        if [ ! -f "$plugin_path" ]; then
            echo "[setup-zsh.sh] Downloading: $plugin_name"
            curl -fsSL "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/$plugin" -o "$plugin_path"
        fi
    done
}

install_plugins() {
    declare -r installPath="${XDG_DATA_HOME}/zsh"

    echo -e "[setup-zsh.sh] Installing plugins in: $installPath\n"
    mkdir -p "$installPath"

    for plugin in "${plugins[@]}"; do
        plugin_name=$(basename "$plugin")
        plugin_path="$installPath/$plugin_name"     
        if [ -d "$plugin_path/.git" ]; then
            echo "[setup-zsh.sh] Updating plugin: $plugin_name"
            git -C "$plugin_path" pull
        else
            [ -d "$plugin_path" ] && echo "[setup-zsh.sh] Removing existing directory: $plugin_path" && rm -rf "$plugin_path"
            echo "[setup-zsh.sh] Installing plugin: $plugin_name"
            git clone --depth=1 "https://github.com/$plugin" "$plugin_path"
        fi
    done

    download_OMZ_plugins
}

# install_OMZ()
install_plugins
download_OMZ_plugins
sudo usermod -s $(which zsh) ishan
echo -e "[setup-zsh.sh] Zsh and Oh-my-zsh setup complete. Please restart your terminal or run 'source ~/.zshrc' to apply changes.\n"
