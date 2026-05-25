# Android Development Environment Setup

This directory contains scripts for setting up a complete Android development environment on Arch Linux with Hyprland/Wayland support.

## Installation

Run the installation script:
```bash
~/.local/scripts/install-android-dev.sh
```

The script is **idempotent** - you can run it multiple times safely.

## What Gets Installed

- **OpenJDK** - Java Development Kit
- **Android Studio** - Official IDE with SDK and emulator
- **Android Tools** - adb, fastboot, platform tools
- **Gradle** - Build automation
- **Kotlin** - Modern Android language
- **Android UDev Rules** - USB device access

## Wayland/Hyprland Compatibility

Android Studio has known issues with Wayland. This setup includes automatic fixes:

### Configured Components:

1. **Custom VM Options** (`~/.config/Google/AndroidStudio*/studio64.vmoptions`):
   - Forces XToolkit for AWT
   - Disables problematic GPU acceleration
   - Configures memory and performance settings
   - Disables splash screen (prevents rendering errors)

2. **Launch Script** (`~/.local/scripts/launch-android-studio.sh`):
   - Sets `_JAVA_AWT_WM_NONREPARENTING=1`
   - Forces `AWT_TOOLKIT=XToolkit`
   - Sets `GDK_BACKEND=x11`

3. **Shell Alias** (in `~/.zshrc`):
   ```bash
   alias android-studio='~/.local/scripts/launch-android-studio.sh'
   ```

## Usage

### Launch Android Studio
```bash
android-studio
```

### First Time Setup
1. Launch Android Studio
2. Go to: Tools → SDK Manager → SDK Tools
3. Install:
   - Android SDK Build-Tools
   - Android SDK Platform-Tools  
   - Android Emulator
   - Android SDK Command-line Tools
   - Google Play services

### Create Virtual Device
Tools → Device Manager → Create Device

### Connect Physical Device
```bash
# Enable USB debugging on device:
# Settings → About Phone → Tap 'Build Number' 7 times
# Settings → Developer Options → Enable 'USB Debugging'

# Add yourself to adbusers group (if not done):
sudo usermod -aG adbusers $USER
# (Then log out and back in)

# Test connection:
adb devices
```

## Environment Variables

Located in `~/.android-dev-env`:
- `ANDROID_HOME` - SDK root directory
- `ANDROID_SDK_ROOT` - Same as ANDROID_HOME
- `ANDROID_AVD_HOME` - Android Virtual Device storage
- `JAVA_HOME` - JDK location

## Troubleshooting

### Android Studio won't launch
1. Clear cache: `rm -rf ~/.cache/Google/AndroidStudio*`
2. Verify environment: `source ~/.android-dev-env`
3. Check display: `echo $DISPLAY` (should show `:0` or `:1`)

### ADB doesn't detect device
1. Check USB debugging is enabled on device
2. Verify group membership: `groups | grep adbusers`
3. Reload udev rules: `sudo udevadm control --reload-rules`
4. Reconnect device

### Performance issues
Edit `~/.config/Google/AndroidStudio*/studio64.vmoptions` and adjust:
- `-Xmx4096m` - Maximum heap size (increase if you have more RAM)
- `-XX:ReservedCodeCacheSize=512m` - Code cache size

## Files Created

- `~/.android-dev-env` - Environment variables
- `~/.local/scripts/launch-android-studio.sh` - Launch script
- `~/.local/scripts/install-android-dev.sh` - Installation script
- `~/.config/Google/AndroidStudio*/studio64.vmoptions` - JVM options
- `~/Android/Sdk/` - Android SDK directory

## Updating

To update Android Studio:
```bash
paru -Syu android-studio
```

The custom configurations will be preserved.
