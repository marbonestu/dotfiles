# Zsh Configuration

Cross-platform zsh configuration with OS-specific overrides.

## Structure

```
zsh/
├── .zshrc              # Main zsh config (common)
├── .zshrc.macos        # macOS-specific environment variables
├── .zshrc.linux        # Linux-specific environment variables
├── .alias              # Common aliases
├── .alias.macos        # macOS-specific aliases
└── .alias.linux        # Linux-specific aliases
```

## How It Works

The main `.zshrc` and `.alias` files contain cross-platform configuration. At the end of each file, OS-specific configurations are automatically loaded:

**Detection:**
- `darwin*` → loads `.zshrc.macos` and `.alias.macos`
- `linux-gnu*` → loads `.zshrc.linux` and `.alias.linux`

## Installation

Use the OS-specific install script from the root dotfiles directory:

**macOS:**
```bash
./install-osx
```

**Linux:**
```bash
./install-linux
```

This uses GNU Stow to symlink all zsh files to your home directory.

## OS-Specific Examples

### macOS (`.alias.macos`)
- `ibrew` - Intel homebrew for compatibility
- `gc` - Ghostty config switcher with AppleScript
- `video_to_gif` - Uses `say` command for notifications

### Linux (`.alias.linux`)
- `cargo` - Memory-limited cargo via systemd
- `limited` - systemd-run memory limiting function
- `gc` - Ghostty config switcher without AppleScript
- `video_to_gif` - Uses `notify-send` instead of `say`

### macOS (`.zshrc.macos`)
- Homebrew paths (`/opt/homebrew`)
- Homebrew curl for Bedrock support
- macOS-specific tool paths

### Linux (`.zshrc.linux`)
- WSL VS Code path detection
- Linux-specific dotnet paths
- Bun completions for Linux

## Adding OS-Specific Configuration

**For aliases:**
1. Add to `.alias.macos` or `.alias.linux`
2. Changes are automatically loaded on next shell

**For environment variables:**
1. Add to `.zshrc.macos` or `.zshrc.linux`
2. Changes are automatically loaded on next shell

## Common Configuration

Add cross-platform aliases and environment variables to:
- `.zshrc` - For environment variables, PATH, plugins
- `.alias` - For aliases and functions

## Current Features

- **Vim mode** with jj to escape
- **zsh-autosuggestions** with persistent history
- **zsh-history-substring-search** with vim keybindings
- **Zoxide** for smart directory jumping
- **Cross-platform aliases** for git, tmux, docker
- **Custom functions** for cd with ls, mkcd, gclone
- **Powerlevel10k** prompt theme

## Reload Configuration

After making changes:
```bash
source ~/.zshrc
```

Or commit and push to sync across machines:
```bash
cd ~/projects/dotfiles
git add zsh/
git commit -m "Update zsh config"
git push
```
