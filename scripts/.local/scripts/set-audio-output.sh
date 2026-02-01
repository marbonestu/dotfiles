#!/bin/sh
# Script to set LG HDR 4K HDMI as default audio output
# This ensures the audio output persists across restarts

HDMI_SINK="alsa_output.pci-0000_0b_00.1.hdmi-stereo-extra1"
LOG_FILE="$HOME/.local/share/audio-output.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Wait for audio system to be ready
wait_for_audio_system() {
    local retries=0
    local max_retries=10
    
    while [ $retries -lt $max_retries ]; do
        if pactl info >/dev/null 2>&1; then
            log_message "Audio system ready after $retries attempts"
            return 0
        fi
        log_message "Waiting for audio system... attempt $((retries + 1))"
        sleep 2
        retries=$((retries + 1))
    done
    
    log_message "ERROR: Audio system not ready after $max_retries attempts"
    return 1
}

# Check if the HDMI sink exists
check_sink_exists() {
    if pactl list short sinks | grep -q "$HDMI_SINK"; then
        return 0
    else
        return 1
    fi
}

# Set the default sink
set_default_sink() {
    if pactl set-default-sink "$HDMI_SINK" 2>/dev/null; then
        log_message "SUCCESS: Set default sink to $HDMI_SINK"
        return 0
    else
        log_message "ERROR: Failed to set default sink to $HDMI_SINK"
        return 1
    fi
}

# Main execution
main() {
    log_message "Starting audio output configuration"
    
    # Wait for audio system
    if ! wait_for_audio_system; then
        exit 1
    fi
    
    # Wait a bit more for sinks to be available
    sleep 3
    
    # Check if HDMI sink exists
    if check_sink_exists; then
        log_message "HDMI sink found: $HDMI_SINK"
        
        # Set as default
        if set_default_sink; then
            # Move any existing audio streams to the new default sink
            pactl list short sink-inputs | while read -r stream _; do
                pactl move-sink-input "$stream" "$HDMI_SINK" 2>/dev/null
            done
            
            current_default=$(pactl get-default-sink 2>/dev/null)
            log_message "Current default sink: $current_default"
            exit 0
        else
            exit 1
        fi
    else
        log_message "ERROR: HDMI sink not found. Available sinks:"
        pactl list short sinks >> "$LOG_FILE"
        exit 1
    fi
}

# Run main function
main "$@"