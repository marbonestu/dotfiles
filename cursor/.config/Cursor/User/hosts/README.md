# Host-Specific Cursor Configuration

This directory contains host-specific configuration overrides for Cursor.

## Setup

1. Create a file named after your hostname (e.g., `REM-MAC-LL007.local.json`)
2. Add any settings that should override the default `settings.json`
3. The install script will merge these settings automatically

## Example

```json
{
  "terminal.integrated.shell.osx": "/opt/homebrew/bin/zsh",
  "workbench.colorTheme": "Custom Theme"
}
```

## Get Your Hostname

```bash
hostname
```
