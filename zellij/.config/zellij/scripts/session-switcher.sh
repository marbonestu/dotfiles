#!/bin/bash

# Session switcher script for zellij (mimics tmux session switcher)
sessions=$(zellij list-sessions 2>/dev/null | grep -v "EXITED" | awk '{print $1}')

if [ -z "$sessions" ]; then
    echo "No active sessions found"
    exit 1
fi

selected=$(echo "$sessions" | fzf --header="Switch to session:" --height=40% --reverse)

if [ -n "$selected" ]; then
    zellij attach "$selected"
fi