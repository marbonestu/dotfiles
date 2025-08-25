#!/bin/bash

# Define the URL you want to focus on or create
url="https://chat.openai.com"

if xdotool search --onlyvisible --class "firefox" windowactivate --sync key --clearmodifiers "Ctrl+t" type "$url"; then
	# If the URL is found, open a new tab and type the URL
	xdotool key "Return"
else
	# If the URL is not found, open a new Firefox window with the URL
	firefox --new-tab "$url" &
fi

# Wait for a moment to ensure the new tab is loaded
sleep 1

# Activate the Firefox window
xdotool search --onlyvisible --class "firefox" windowactivate
