#!/bin/bash

xdotool search --onlyvisible --name vlc windowminimize &
qdbus | grep org.mpris.MediaPlayer2 | xargs -I _ qdbus _ /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Pause 

