#!/usr/bin/env bash
set -euo pipefail

# Install Docker Desktop on Arch Linux
# Provides: docker sandbox, docker-compose, docker-buildx, docker-mcp
# Requires: paru (AUR helper), Docker Engine already installed

echo "======================================"
echo "Installing Docker Desktop for Linux"
echo "======================================"
echo ""

# --- Preflight checks ---

if ! command -v paru &>/dev/null; then
    echo "Error: paru not found. Install it first."
    exit 1
fi

if ! pacman -Q docker &>/dev/null; then
    echo "Error: docker package not installed. Install it first:"
    echo "  sudo pacman -S docker"
    exit 1
fi

if ! grep -q kvm /proc/modules 2>/dev/null && ! [ -e /dev/kvm ]; then
    echo "Error: KVM not available. Docker Desktop requires hardware virtualization."
    echo "  sudo modprobe kvm_amd   # or kvm_intel"
    exit 1
fi

# --- Install dependencies ---

if ! pacman -Q pass &>/dev/null; then
    echo "Installing pass (credential storage for Docker Desktop)..."
    sudo pacman -S --noconfirm --needed pass
fi

# --- Install Docker Desktop ---
# paru handles conflict resolution automatically (docker-compose, docker-buildx, docker-mcp)

echo ""
echo "Installing docker-desktop from AUR..."
echo "Note: paru will ask to remove conflicting packages (docker-compose, docker-buildx) — say yes."
echo ""
paru -S --needed docker-desktop

# --- Configure services ---

echo ""
echo "Enabling Docker Desktop service..."
systemctl --user enable docker-desktop 2>/dev/null || true

# Ensure Docker Engine is enabled
sudo systemctl enable docker.service
sudo systemctl enable docker.socket

# --- Verify ---

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "  1. Launch: systemctl --user start docker-desktop"
echo "  2. Verify: docker sandbox ls"
echo ""
echo "For Ralph G8 sandbox:"
echo "  export ANTHROPIC_API_KEY=sk-ant-..."
echo "  docker sandbox run claude ~/projects/trading-terminal"
echo ""
