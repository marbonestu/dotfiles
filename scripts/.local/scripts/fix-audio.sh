#!/bin/sh
# Quick script to fix audio output to LG HDR 4K HDMI

HDMI_SINK="alsa_output.pci-0000_0b_00.1.hdmi-stereo-extra1"

echo "Setting audio output to LG HDR 4K HDMI..."

if pactl set-default-sink "$HDMI_SINK"; then
    echo "✓ Successfully set default sink to HDMI"
    
    # Move any current audio streams
    pactl list short sink-inputs | while read -r stream _; do
        pactl move-sink-input "$stream" "$HDMI_SINK" 2>/dev/null
    done
    
    echo "✓ Moved existing audio streams"
    echo "Current default: $(pactl get-default-sink)"
else
    echo "✗ Failed to set HDMI as default"
    echo "Available sinks:"
    pactl list short sinks
fi