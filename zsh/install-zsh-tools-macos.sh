#!/usr/bin/env bash

set -e

echo "======================================"
echo "Installing Zsh Tools for macOS"
echo "======================================"

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed. Please install it first:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

echo ""
echo "Installing required packages..."
brew install \
    zsh \
    fzf \
    zoxide \
    fnm \
    git \
    stow \
    hyperfine

echo ""
echo "Installing Zinit plugin manager..."
if [[ ! -d "$HOME/.local/share/zinit/zinit.git" ]]; then
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" -- -a
    echo "✓ Zinit installed"
else
    echo "✓ Zinit already installed"
fi

echo ""
echo "Installing Powerlevel10k theme..."
if [[ ! -d "$HOME/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
    echo "✓ Powerlevel10k installed"
else
    echo "✓ Powerlevel10k already installed"
fi

echo ""
echo "Creating necessary directories..."
mkdir -p ~/.zsh/cache

echo ""
echo "Setting up fzf keybindings..."
# fzf installation includes keybindings, just verify
if command -v fzf &> /dev/null; then
    echo "✓ fzf installed and ready"
fi

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. If you haven't already, run: stow -vSt ~ zsh"
echo "2. Restart your terminal or run: exec zsh"
echo "3. Configure Powerlevel10k: p10k configure"
echo ""
echo "Optional tools you might want:"
echo "  brew install tmux tmuxp aws-vault gh"
