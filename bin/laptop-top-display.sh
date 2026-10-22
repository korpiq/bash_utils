#!/bin/sh
# Re-read the external monitor's EDID and restore the usual layout:
# HDMI-0 above, internal DP-0 below as primary.
xrandr --output HDMI-0 --auto
xrandr --output DP-0 --pos 445x1440 --primary
