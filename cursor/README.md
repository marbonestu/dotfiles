# Cursor Configuration

This directory contains Cursor IDE configuration that works across macOS and Linux.

## Structure

```
cursor/
├── .config/Cursor/User/
│   ├── settings.json           # Main settings file
│   ├── keybindings.json        # Keyboard shortcuts
│   └── hosts/                  # Host-specific overrides
│       └── hostname.json       # Per-machine settings
└── install-cursor.sh           # Installation script
```

## Installation

The installation is handled automatically by the main install scripts:

**macOS:**
```bash
./install-osx
```

**Linux:**
```bash
./install-linux
```

Or install Cursor config separately:
```bash
./cursor/install-cursor.sh
```

## How It Works

- The script detects your OS and uses the appropriate config path:
  - **macOS**: `~/Library/Application Support/Cursor/User/`
  - **Linux**: `~/.config/Cursor/User/`
- It creates symlinks from your dotfiles to the config location
- Any changes you make in Cursor will be reflected in your dotfiles

## Host-Specific Configuration

To add machine-specific settings:

1. Get your hostname: `hostname`
2. Create a file: `.config/Cursor/User/hosts/YOUR-HOSTNAME.json`
3. Add your host-specific settings (will override defaults)

Example for work vs personal machines:
- `work-macbook.local.json` - Work-specific themes, extensions
- `personal-linux.json` - Personal machine settings

## Updating Configuration

After making changes in Cursor, your dotfiles are automatically updated since they're symlinked. To save changes:

```bash
cd ~/projects/dotfiles
git add cursor/
git commit -m "Update Cursor configuration"
git push
```

## Current Configuration

- **Neovim Integration**: Using vscode-neovim extension
- **Vim Keybindings**: jj/jk to escape insert mode
- **Navigation**: Ctrl+hjkl for split navigation
- **File Explorer**: Vim-style navigation (j/k/h/l)
- **Scrolling**: Ctrl+e/Ctrl+y for smooth scrolling
