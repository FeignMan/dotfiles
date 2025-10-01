#!/bin/bash

# Setup tmux: Install Tmux plugin manager
TMUX_DIR="${HOME}/.config/tmux/plugins/tpm"
if [ -f /usr/bin/tmux ]; then
  if [ -d "$TMUX_DIR" ]; then
    git -C "$TMUX_DIR" pull
  else
    git clone https://github.com/tmux-plugins/tpm "${HOME}/.config/tmux/plugins/tpm"
  fi
fi