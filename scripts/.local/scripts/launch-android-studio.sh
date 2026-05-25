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

# Force UI scale to prevent zero-size display errors and ensure readable fonts
# Set to 2.0 for 4K displays (adjust to 1.5, 2.0, or 2.5 based on preference)
export JAVA_TOOL_OPTIONS="-Djava.awt.headless=false -Dawt.toolkit.name=XToolkit -Dsun.java2d.opengl=false -Dsun.java2d.uiScale=2.0 -Dsun.java2d.pmoffscreen=false -Dsplash=false"

# Launch Android Studio
exec /opt/android-studio/bin/studio.sh "$@"
