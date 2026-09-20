#!/bin/bash

THIS_DIR=$(dirname "$BASH_SOURCE")
aplay /home/kato/.local/share/sounds/clock-tock-150ms.wav

ACTIVITY=${1:-Default}
ACTIVITY_GUID=$(sed -ne "s/=$ACTIVITY$//p" < ~/.config/kactivitymanagerdrc)

$THIS_DIR/media-pause.sh &
qdbus6 org.kde.ActivityManager /ActivityManager/Activities SetCurrentActivity $ACTIVITY_GUID

