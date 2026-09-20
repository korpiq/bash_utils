#!/bin/bash

set -euo pipefail

export XDG_RUNTIME_DIR="/run/user/$UID"
TICK_SOUND="$HOME/.local/share/sounds/clock-tick-250ms.wav"
TOCK_SOUND="$HOME/.local/share/sounds/clock-tock-250ms.wav"
HOUR=$(date +%-H)
MINUTE=$(date +%-M)

# 1. Check if the user is active
# Checks systemd loginctl for session activity state
SESSION_ID=$(loginctl | perl -wne 's/^ *(\d+) *'$UID' .*/$1/ and exit !print')
SESSION_STATE=$(loginctl show-session "$SESSION_ID" -p State --value 2>/dev/null)

if [ "$SESSION_STATE" != "active" ]; then
    exit 0
fi

SOUNDS=()

for ((i=1; i<=HOUR; i++))
do
    SOUNDS+=("$TICK_SOUND" "$TOCK_SOUND")
done

[ "$MINUTE" -ge "30" ] || SOUNDS+=("$TICK_SOUND")

aplay -q "${SOUNDS[@]}"
