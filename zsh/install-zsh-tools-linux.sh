#!/usr/bin/env bash

set -e

echo "======================================"
echo "Installing Zsh Tools for Linux"
echo "======================================"

# Detect package manager
if command -v paru &> /dev/null; then
    PKG_MANAGER="paru"
    INSTALL_CMD="paru -S --noconfirm"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
else
    echo "Error: Neither pacman nor paru found. This script is for Arch-based systems."
    exit 1
fi

echo "Using package manager: $PKG_MANAGER"

echo ""
echo "Installing required packages..."
$INSTALL_CMD \
    zsh \
    fzf \
    zoxide \
    git \
    stow \
    hyperfine

# fnm (Fast Node Manager) - install from AUR or binary
echo ""
echo "Installing fnm (Fast Node Manager)..."
if command -v fnm &> /dev/null; then
    echo "✓ fnm already installed"
elif [[ "$PKG_MANAGER" == "paru" ]]; then
    paru -S --noconfirm fnm-bin
elif command -v cargo &> /dev/null; then
    cargo install fnm
else
    echo "Installing fnm via binary..."
    curl -fsSL https://fnm.vercel.app/install | bash
fi

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
echo "Setting Zsh as default shell..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "Run: chsh -s $(which zsh)"
    echo "(You may need to add zsh to /etc/shells first)"
else
    echo "✓ Zsh is already your default shell"
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
if [[ "$PKG_MANAGER" == "paru" ]]; then
    echo "  paru -S tmux python-tmuxp aws-vault github-cli"
else
    echo "  sudo pacman -S tmux github-cli"
    echo "  # For aws-vault and tmuxp, use AUR or pip"
fi
