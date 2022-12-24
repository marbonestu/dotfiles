#!/bin/sh

STATUS=$(nordvpn status | grep Status | tr -d ' ' | cut -d ':' -f2)
IP=$(nordvpn status | grep IP | cut -d ':' -f2)
CITY=$(nordvpn status | grep City | cut -d ':' -f2)

if [ "$STATUS" = "Connected" ]; then
    echo "$CITY -$IP"
else
    echo "%{F#f00}%{A1:nordvpn c:} no vpn%{A}%{F-}"
fi
