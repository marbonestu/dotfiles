# Dotfiles Management Guide

Cross-platform dotfiles with OS-specific overrides for macOS and Linux.

## Quick Start

**On macOS:**
```bash
cd ~/projects/dotfiles
./install-osx
```

**On Linux:**
```bash
cd ~/projects/dotfiles
./install-linux
```

## Structure

```
dotfiles/
├── cursor/                    # Cursor IDE config
│   ├── .config/Cursor/User/
│   │   ├── settings.json      # Main settings
│   │   ├── keybindings.json   # Keybindings
│   │   └── hosts/             # Host-specific overrides
│   ├── install-cursor.sh      # Custom installer
│   └── README.md
│
├── zsh/                       # Zsh shell config
│   ├── .zshrc                 # Main config (common)
│   ├── .zshrc.macos          # macOS-specific env vars
│   ├── .zshrc.linux          # Linux-specific env vars
│   ├── .alias                # Common aliases
│   ├── .alias.macos          # macOS-specific aliases
│   ├── .alias.linux          # Linux-specific aliases
│   └── README.md
│
├── [other configs]/           # Other tool configs
│   └── .config/tool/
│
├── install-osx               # macOS installer
└── install-linux             # Linux installer
```

## OS-Specific Configuration

### How It Works

1. **Automatic Detection**: Uses `$OSTYPE` to detect the OS
   - `darwin*` → macOS
   - `linux-gnu*` → Linux

2. **Configuration Loading**:
   - Common config is in base files (`.zshrc`, `.alias`)
   - OS-specific config is automatically sourced from `.*.macos` or `.*.linux`

3. **Cursor Special Handling**:
   - Uses different paths per OS:
     - macOS: `~/Library/Application Support/Cursor/User/`
     - Linux: `~/.config/Cursor/User/`
   - Custom install script handles the differences

### Adding OS-Specific Configuration

**For Zsh:**

1. **Aliases** → Add to `.alias.macos` or `.alias.linux`
2. **Environment Variables** → Add to `.zshrc.macos` or `.zshrc.linux`
3. **Common** → Add to `.alias` or `.zshrc`

**For Cursor:**

1. **Host-specific** → Create `cursor/.config/Cursor/User/hosts/HOSTNAME.json`
2. **Common** → Edit `cursor/.config/Cursor/User/settings.json`

## Current OS-Specific Features

### macOS (`.alias.macos`)
- `ibrew` - Intel homebrew for compatibility
- `gconfig` - Ghostty config switcher with AppleScript
- `video_to_gif` - Uses `say` for notifications

### Linux (`.alias.linux`)
- `cargo` - Memory-limited cargo via systemd
- `limited` - systemd-run memory limiting function
- `gconfig` - Ghostty config switcher (no AppleScript)
- `video_to_gif` - Uses `notify-send` for notifications

### macOS (`.zshrc.macos`)
- Homebrew paths (`/opt/homebrew`)
- Homebrew curl for AWS Bedrock support
- macOS-specific tool paths (dprint, lua-ls)

### Linux (`.zshrc.linux`)
- WSL VS Code path detection
- Linux dotnet paths
- Bun completions for Linux

## Installation Process

### First Time Setup on New Machine

1. **Clone dotfiles:**
   ```bash
   git clone <your-repo> ~/projects/dotfiles
   cd ~/projects/dotfiles
   ```

2. **Install GNU Stow:**
   - macOS: `brew install stow`
   - Linux: `sudo apt install stow` or `sudo pacman -S stow`

3. **Run OS-specific installer:**
   ```bash
   # macOS
   ./install-osx

   # Linux
   ./install-linux
   ```

### What the Installer Does

1. Uses GNU Stow to symlink config directories to `~`
2. Runs custom installers (like Cursor) that need special handling
3. Creates symlinks from your home directory back to the dotfiles repo

### After Making Changes

Since configs are symlinked, changes are automatically reflected in your dotfiles:

```bash
cd ~/projects/dotfiles
git status                    # See what changed
git add .
git commit -m "Update configs"
git push
```

### Syncing to Another Machine

```bash
cd ~/projects/dotfiles
git pull                      # Get latest changes
./install-osx                 # or ./install-linux
```

## Restowing

If you add new files to a config directory, you need to restow:

```bash
cd ~/projects/dotfiles
stow -Rt ~ zsh               # Restow zsh configs
# or
./install-osx                # Restow everything
```

## Tools Configured

- **Cursor**: IDE with vim keybindings
- **Zsh**: Shell with vim mode, autosuggestions, history search
- **Tmux**: Terminal multiplexer
- **Git**: Version control
- **Neovim/Helix**: Text editors
- **Ghostty**: Terminal emulator
- **Kitty**: Terminal emulator
- **Lazygit**: Git TUI
- **Starship**: Shell prompt (or Powerlevel10k)
- **Hammerspoon**: macOS automation (cmd+7 for Cursor)
- **Karabiner**: macOS keyboard customization
- **Hyprland**: Linux window manager
- And many more...

## Troubleshooting

**Symlinks not updating?**
```bash
stow -Rt ~ <package>  # Restow the package
```

**Config not loading?**
```bash
source ~/.zshrc       # Reload zsh config
```

**OS-specific config not loading?**
```bash
echo $OSTYPE          # Check OS detection
ls -la ~/.alias.macos # Verify symlink exists
```

**Cursor config not applying?**
```bash
./cursor/install-cursor.sh    # Reinstall
ls -la ~/Library/Application\ Support/Cursor/User/  # macOS
ls -la ~/.config/Cursor/User/                       # Linux
```

## References

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Dotfiles Best Practices](https://dotfiles.github.io/)
- Individual tool READMEs in their directories
