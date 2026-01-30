#!/bin/bash

echo "=== Network Activity Monitor for Pane Creation ==="
echo "Press Ctrl+C to stop monitoring"
echo ""

# Get tmux PID
TMUX_PID=$(pgrep -f "tmux$" | head -1)
echo "Monitoring tmux process: $TMUX_PID"
echo ""

# Create output directory
mkdir -p /tmp/pane_monitor
OUTPUT_DIR="/tmp/pane_monitor"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "=== Stopping monitoring ==="
    jobs -p | xargs -r kill 2>/dev/null
    echo "Results saved in $OUTPUT_DIR"
    exit 0
}
trap cleanup SIGINT

echo "=== Starting network monitoring ==="

# Monitor network connections
echo "1. Monitoring network connections..."
netstat -an > "$OUTPUT_DIR/netstat_before.txt"

# Monitor file descriptors
echo "2. Monitoring file descriptors..."
lsof -p $TMUX_PID > "$OUTPUT_DIR/lsof_before.txt" 2>/dev/null

# Monitor system calls (if available)
if command -v dtruss >/dev/null 2>&1; then
    echo "3. Starting system call trace..."
    sudo dtruss -p $TMUX_PID > "$OUTPUT_DIR/dtruss.txt" 2>&1 &
    DTRUSS_PID=$!
fi

# Monitor network traffic
echo "4. Starting packet capture..."
sudo tcpdump -i any -w "$OUTPUT_DIR/packets.pcap" > "$OUTPUT_DIR/tcpdump.txt" 2>&1 &
TCPDUMP_PID=$!

echo ""
echo "=== NOW CREATE A NEW PANE (Ctrl+B then %) ==="
echo "Press Enter when done creating the pane..."
read

# Capture after state
echo ""
echo "=== Capturing post-creation state ==="
netstat -an > "$OUTPUT_DIR/netstat_after.txt"
lsof -p $TMUX_PID > "$OUTPUT_DIR/lsof_after.txt" 2>/dev/null

# Stop monitoring
kill $TCPDUMP_PID 2>/dev/null
if [ ! -z "$DTRUSS_PID" ]; then
    sudo kill $DTRUSS_PID 2>/dev/null
fi

echo ""
echo "=== Analysis ==="
echo "Comparing network connections..."
diff "$OUTPUT_DIR/netstat_before.txt" "$OUTPUT_DIR/netstat_after.txt" > "$OUTPUT_DIR/netstat_diff.txt"

echo "Comparing file descriptors..."
diff "$OUTPUT_DIR/lsof_before.txt" "$OUTPUT_DIR/lsof_after.txt" > "$OUTPUT_DIR/lsof_diff.txt"

echo ""
echo "=== Results ==="
echo "Files created in $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR/"

echo ""
echo "Network connection changes:"
cat "$OUTPUT_DIR/netstat_diff.txt"

echo ""
echo "File descriptor changes:"
cat "$OUTPUT_DIR/lsof_diff.txt"