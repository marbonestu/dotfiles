#!/bin/bash

# Install Oh My Zsh, plugins, and set zsh as default shell
if command -v zsh >/dev/null; then
  # Check if the directories exist before cloning the repositories
  if [ ! -d "$HOME/.zsh/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.zsh}/plugins/zsh-autosuggestions || true
  else
    echo "Directory zsh-autosuggestions already exists. Skipping cloning." 2>&1 | tee -a "$LOG"
  fi

  if [ ! -d "$HOME/.zsh/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.zsh}/plugins/zsh-syntax-highlighting || true
  else
    echo "Directory zsh-syntax-highlighting already exists. Skipping cloning." 2>&1 | tee -a "$LOG"
  fi

  if [ ! -d "$HOME/.zsh/plugins/zsh-history-substring-search" ]; then
    git clone https://github.com/zsh-users/zsh-history-substring-search.git ${ZSH_CUSTOM:-$HOME/.zsh}/plugins/zsh-history-substring-search || true
  else
    echo "Directory zsh-history-substring-search already exists. Skipping cloning." 2>&1 | tee -a "$LOG"
  fi

  if [ ! -d "$HOME/.zsh/plugins/zsh-vi-mode" ]; then
    git clone https://github.com/jeffreytse/zsh-vi-mode.git ${ZSH_CUSTOM:-$HOME/.zsh}/plugins/zsh-vi-mode || true
  else
    echo "Directory zsh-vi-mode already exists. Skipping cloning." 2>&1 | tee -a "$LOG"
  fi

  # Check if ~/.zshrc and .zprofile exists, create a backup, and copy the new configuration
  if [ -f "$HOME/.zshrc" ]; then
    cp -b "$HOME/.zshrc" "$HOME/.zshrc-backup" || true
  fi

  if [ -f "$HOME/.zprofile" ]; then
    cp -b "$HOME/.zprofile" "$HOME/.zprofile-backup" || true
  fi

  # Copying the preconfigured zsh themes and profile
  cp -r 'assets/.zshrc' ~/
  cp -r 'assets/.zprofile' ~/

  printf "${NOTE} Changing default shell to zsh...\n"

  while ! chsh -s $(which zsh); do
    echo "${ERROR} Authentication failed. Please enter the correct password." 2>&1 | tee -a "$LOG"
    sleep 1
  done
  printf "${NOTE} Shell changed successfully to zsh.\n" 2>&1 | tee -a "$LOG"

fi

clear
