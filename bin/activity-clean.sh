#!/bin/bash

ACTIVITY=${1:-Default}
ACTIVITY_GUID=$(sed -ne "s/=$ACTIVITY//p" < ~/.config/kactivitymanagerdrc)

while ! qdbus org.kde.ActivityManager /ActivityManager/Activities SetCurrentActivity $ACTIVITY_GUID
do
	sleep 1
done &
media-pause.sh &

