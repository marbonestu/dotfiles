#!/usr/bin/env bash

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
else
    # Linux
    CURSOR_CONFIG_DIR="$HOME/.config/Cursor/User"
fi

# Create config directory if it doesn't exist
mkdir -p "$CURSOR_CONFIG_DIR"

# Get the script's directory (the cursor dotfiles folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/.config/Cursor/User"

# Symlink config files
echo "Installing Cursor config to: $CURSOR_CONFIG_DIR"

for file in "$SOURCE_DIR"/*; do
    filename=$(basename "$file")
    target="$CURSOR_CONFIG_DIR/$filename"

    # Remove existing file/symlink
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Removing existing: $target"
        rm -rf "$target"
    fi

    # Create symlink
    echo "Linking: $filename"
    ln -sf "$file" "$target"
done

echo "Cursor config installed successfully!"
