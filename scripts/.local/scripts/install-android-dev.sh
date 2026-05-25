#!/usr/bin/env bash

set -e

echo "======================================"
echo "Installing Android Development Tools"
echo "======================================"
echo ""

# Detect package manager
if command -v paru &>/dev/null; then
	PKG_MANAGER="paru"
	INSTALL_CMD="paru -S --noconfirm"
elif command -v pacman &>/dev/null; then
	PKG_MANAGER="pacman"
	INSTALL_CMD="sudo pacman -S --noconfirm"
else
	echo "Error: Neither pacman nor paru found. This script is for Arch-based systems."
	exit 1
fi

echo "Using package manager: $PKG_MANAGER"
echo ""

# Step 1: Install JDK
echo "Step 1: Installing Java Development Kit..."
if pacman -Qi jdk-openjdk &>/dev/null; then
	echo "✓ jdk-openjdk already installed"
else
	$INSTALL_CMD jdk-openjdk
	echo "✓ JDK installed"
fi
echo ""

# Step 2: Install Android Studio
echo "Step 2: Installing Android Studio..."
if command -v android-studio &>/dev/null || [[ -d /opt/android-studio ]]; then
	echo "✓ Android Studio already installed"
elif [[ "$PKG_MANAGER" == "paru" ]]; then
	paru -S --noconfirm android-studio
	echo "✓ Android Studio installed"
else
	echo "Note: Installing android-studio from AUR requires paru or yay"
	echo "You can manually install from: https://developer.android.com/studio"
fi
echo ""

# Step 3: Install Android SDK command-line tools
echo "Step 3: Installing Android SDK tools..."
if pacman -Qi android-tools &>/dev/null; then
	echo "✓ android-tools already installed"
else
	$INSTALL_CMD android-tools
	echo "✓ Android platform tools (adb, fastboot) installed"
fi
echo ""

# Step 4: Install additional development tools
echo "Step 4: Installing additional development tools..."
EXTRA_PACKAGES=(
	"gradle"       # Build automation tool
	"kotlin"       # Kotlin programming language
	"git"          # Version control
	"android-udev" # USB device rules for Android devices
)

for package in "${EXTRA_PACKAGES[@]}"; do
	if pacman -Qi "$package" &>/dev/null; then
		echo "✓ $package already installed"
	else
		$INSTALL_CMD "$package" || echo "⚠ Could not install $package"
	fi
done
echo ""

# Step 5: Set up Android SDK directory
ANDROID_SDK_ROOT="$HOME/Android/Sdk"
echo "Step 5: Setting up Android SDK..."
mkdir -p "$ANDROID_SDK_ROOT"
echo "✓ Created Android SDK directory at $ANDROID_SDK_ROOT"
echo ""

# Step 6: Set up environment variables
echo "Step 6: Configuring environment variables..."
ENV_FILE="$HOME/.android-dev-env"

cat >"$ENV_FILE" <<'EOF'
# Android Development Environment Variables
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_AVD_HOME="$HOME/.android/avd"

# Add Android tools to PATH
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/emulator:$PATH"
export PATH="$ANDROID_HOME/build-tools:$PATH"

# Java options for better Android Studio performance
export _JAVA_OPTIONS="-Xmx2G"
export JAVA_HOME="/usr/lib/jvm/default"

# Fix Android Studio on Wayland - force XWayland compatibility
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export _JAVA_AWT_WM_NONREPARENTING=1
fi
EOF

echo "✓ Environment variables configured in $ENV_FILE"
echo ""

# Step 7: Add to shell config if not already present
if [[ -f "$HOME/.zshrc" ]]; then
	if ! grep -q "source.*android-dev-env" "$HOME/.zshrc"; then
		echo "" >>"$HOME/.zshrc"
		echo "# Android Development Environment" >>"$HOME/.zshrc"
		echo "[ -f ~/.android-dev-env ] && source ~/.android-dev-env" >>"$HOME/.zshrc"
		echo "✓ Added Android environment to ~/.zshrc"
	else
		echo "✓ Android environment already in ~/.zshrc"
	fi

	# Add Android Studio launcher alias with Wayland fix
	if ! grep -q "alias android-studio=" "$HOME/.zshrc"; then
		echo "" >>"$HOME/.zshrc"
		echo "# Android Studio launcher with Wayland fix" >>"$HOME/.zshrc"
		echo "alias android-studio='~/.local/scripts/launch-android-studio.sh'" >>"$HOME/.zshrc"
		echo "✓ Added android-studio alias to ~/.zshrc"
	else
		echo "✓ Android Studio alias already in ~/.zshrc"
	fi
fi
echo ""

# Step 8: Configure USB access for Android devices
echo "Step 7: Configuring USB access for Android devices..."
if ! groups | grep -q adbusers; then
	if sudo -n true 2>/dev/null; then
		sudo usermod -aG adbusers "$USER"
		echo "✓ Added $USER to adbusers group"
		echo "⚠ You'll need to log out and back in for group changes to take effect"
	else
		echo "⚠ Run manually to add USB device access: sudo usermod -aG adbusers $USER"
		echo "  (Then log out and back in)"
	fi
else
	echo "✓ Already in adbusers group"
fi
echo ""

# Step 9: Configure Android Studio for Wayland/Hyprland
echo "Step 8: Configuring Android Studio for Wayland..."

# Create Android Studio config directories
mkdir -p "$HOME/.config/Google/AndroidStudio2025.2"
mkdir -p "$HOME/.config/Google/AndroidStudio2025.2.3"

# Create custom vmoptions for Wayland compatibility
VMOPTIONS_CONTENT='# Android Studio custom VM options for Wayland/Hyprland compatibility

# Wayland/XWayland fixes
-Dawt.toolkit.name=XToolkit
-Dsun.java2d.xrender=true
-Dsun.java2d.pmoffscreen=false

# Disable GPU acceleration (fixes rendering issues)
-Dsun.java2d.opengl=false

# Fix window manager issues
-Djava.awt.WM_CLASS=jetbrains-studio

# Performance options
-Xms512m
-Xmx4096m
-XX:ReservedCodeCacheSize=512m
-XX:+UseG1GC
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:CICompilerCount=2

# Fix splash screen issues
-Dsplash=false'

echo "$VMOPTIONS_CONTENT" >"$HOME/.config/Google/AndroidStudio2025.2/studio64.vmoptions"
echo "$VMOPTIONS_CONTENT" >"$HOME/.config/Google/AndroidStudio2025.2.3/studio64.vmoptions"

# Create launcher script
LAUNCHER_SCRIPT="$HOME/.local/scripts/launch-android-studio.sh"
cat >"$LAUNCHER_SCRIPT" <<'EOF'
#!/usr/bin/env bash

# Comprehensive Android Studio launcher for Wayland/Hyprland

# Export all necessary environment variables for Wayland compatibility
export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=XToolkit
export GDK_BACKEND=x11

# Ensure display is available
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:1
fi

# Critical JVM options for Wayland fix
export STUDIO_VM_OPTIONS="$HOME/.config/Google/AndroidStudio2025.2.3/studio64.vmoptions"
export STUDIO_PROPERTIES="$HOME/.config/Google/AndroidStudio2025.2.3/idea.properties"

# Force UI scale to prevent zero-size display errors and ensure readable fonts (CRITICAL FIX!)
# Set to 2.0 for 4K displays (adjust to 1.5, 2.0, or 2.5 based on preference)
export JAVA_TOOL_OPTIONS="-Djava.awt.headless=false -Dawt.toolkit.name=XToolkit -Dsun.java2d.opengl=false -Dsun.java2d.uiScale=2.0 -Dsun.java2d.pmoffscreen=false -Dsplash=false"

# Launch Android Studio
exec /opt/android-studio/bin/studio.sh "$@"
EOF
chmod +x "$LAUNCHER_SCRIPT"

# Clear any existing cache
rm -rf "$HOME/.cache/Google/AndroidStudio"* 2>/dev/null

echo "✓ Android Studio configured for Wayland/Hyprland"
echo ""

# Step 10: Load environment for current session
source "$ENV_FILE"

echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "Installed components:"
echo "  ✓ OpenJDK $(java -version 2>&1 | head -n1 | cut -d'"' -f2)"
echo "  ✓ Android Studio (launch via: android-studio)"
echo "  ✓ Android Platform Tools (adb, fastboot)"
echo "  ✓ Gradle, Kotlin, Git"
echo "  ✓ USB device rules for Android devices"
echo ""
echo "Environment variables configured:"
echo "  ANDROID_HOME=$ANDROID_HOME"
echo "  ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
echo ""
echo "Next steps:"
echo ""
echo "1. Restart your terminal or run: source ~/.android-dev-env"
echo ""
echo "2. Launch Android Studio and complete SDK setup:"
echo "   android-studio"
echo ""
echo "3. In Android Studio, go to:"
echo "   Tools > SDK Manager > SDK Tools"
echo "   Install:"
echo "   - Android SDK Build-Tools"
echo "   - Android SDK Platform-Tools"
echo "   - Android Emulator"
echo "   - Android SDK Command-line Tools"
echo "   - Google Play services"
echo ""
echo "4. Create a virtual device:"
echo "   Tools > Device Manager > Create Device"
echo ""
echo "5. Test ADB connection (with device connected):"
echo "   adb devices"
echo ""
echo "6. To enable USB debugging on your Android device:"
echo "   Settings > About Phone > Tap 'Build Number' 7 times"
echo "   Settings > Developer Options > Enable 'USB Debugging'"
echo ""
