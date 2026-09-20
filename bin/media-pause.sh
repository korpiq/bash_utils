#!/bin/bash

busses=$(
    dbus-send --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ListNames |
    grep -oP "(?<=string \")org.mpris.MediaPlayer2.*instance.*(?=\")"
)

for bus in $busses; do
  dbus-send --print-reply --dest=$bus /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause
done
