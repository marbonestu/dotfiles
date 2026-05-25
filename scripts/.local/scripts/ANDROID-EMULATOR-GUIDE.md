# Android Emulator Quick Start Guide

## Prerequisites

1. Complete the Android Studio setup wizard (currently running)
2. This will download:
   - Android SDK
   - Platform Tools
   - Emulator
   - System Images

## Creating Your First Virtual Device

### Option 1: Using Android Studio GUI (Easiest)

1. In Android Studio welcome screen, click **"More Actions"** → **"Virtual Device Manager"**
2. Click **"Create Device"**
3. Select a device (recommended: **Pixel 6** or **Pixel 8**)
4. Click **"Next"**
5. Select a system image:
   - **Recommended**: Latest Android version with "Google APIs"
   - Click **"Download"** if not already installed
6. Click **"Next"**, then **"Finish"**

### Option 2: Using Command Line

After SDK setup completes, use these commands:

```bash
# Reload your shell to get updated PATH
source ~/.zshrc

# Download a system image (Android 14)
sdkmanager "system-images;android-34;google_apis;x86_64"

# Create virtual device
avdmanager create avd \
  -n Pixel_6_API_34 \
  -k "system-images;android-34;google_apis;x86_64" \
  -d pixel_6

# List available system images
sdkmanager --list | grep system-images

# List available device definitions
avdmanager list device
```

## Launching the Emulator

### Method 1: Using Helper Script (Recommended)

```bash
# List all available virtual devices
android-emulator list

# Launch emulator (auto GPU detection)
android-emulator Pixel_6_API_34

# Launch with specific GPU mode (if auto doesn't work)
android-emulator Pixel_6_API_34 swiftshader_indirect
```

### Method 2: Direct Command

```bash
# List AVDs
emulator -list-avds

# Launch emulator
emulator -avd Pixel_6_API_34 &

# With specific GPU mode
emulator -avd Pixel_6_API_34 -gpu swiftshader_indirect &
```

### Method 3: From Android Studio

1. Open **Device Manager** (toolbar icon or Tools → Device Manager)
2. Click the **▶️ Play button** next to your device
3. Emulator window will open

## GPU Modes Explained

If the emulator has graphics issues on Hyprland, try these modes:

- **`auto`** (default) - Let emulator choose
- **`host`** - Use your GPU (fastest, but may have compatibility issues)
- **`swiftshader_indirect`** - Software rendering (slower, most compatible)
- **`guest`** - Emulated GPU (slowest, maximum compatibility)

## Troubleshooting

### Emulator won't start
```bash
# Check if KVM is available (needed for hardware acceleration)
ls -la /dev/kvm

# If KVM not accessible, add yourself to kvm group
sudo usermod -aG kvm $USER
# Then log out and back in
```

### Graphics issues
```bash
# Force software rendering
android-emulator YOUR_AVD_NAME swiftshader_indirect
```

### Emulator is slow
```bash
# Ensure KVM is enabled and you're in kvm group
groups | grep kvm

# Check CPU supports virtualization
egrep -c '(vmx|svm)' /proc/cpuinfo
# Should return > 0
```

### Black screen in emulator
```bash
# Try different GPU mode
android-emulator YOUR_AVD_NAME host

# Or use software rendering
android-emulator YOUR_AVD_NAME swiftshader_indirect
```

## Quick Commands Reference

```bash
# Launch Android Studio
android-studio

# List emulators
android-emulator list

# Launch emulator
android-emulator <name>

# List running emulators
adb devices

# Connect to emulator via adb
adb shell

# Install APK to running emulator
adb install myapp.apk

# Take screenshot
adb shell screencap /sdcard/screen.png
adb pull /sdcard/screen.png
```

## Recommended First AVD Configuration

**Name**: Pixel_6_API_34  
**Device**: Pixel 6  
**System Image**: Android 14 (API 34) with Google APIs  
**Internal Storage**: 2048 MB (default)  
**SD Card**: 512 MB (optional)  

This provides a modern Android experience with Google Play Store support.

## Environment Variables

All Android environment variables are loaded from `~/.android-dev-env`:
- `ANDROID_HOME` - SDK location
- `ANDROID_SDK_ROOT` - SDK root
- `ANDROID_AVD_HOME` - Where AVDs are stored (`~/.android/avd`)

## Files and Locations

- **SDK**: `~/Android/Sdk/`
- **AVDs**: `~/.android/avd/`
- **Emulator**: `~/Android/Sdk/emulator/emulator`
- **SDK Manager**: `~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager`
- **AVD Manager**: `~/Android/Sdk/cmdline-tools/latest/bin/avdmanager`

## Next Steps

1. ✅ Complete Android Studio setup wizard
2. ✅ Create your first virtual device
3. ✅ Launch the emulator
4. Create your first Android project!

Happy Android Development! 🤖
