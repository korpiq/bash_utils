#!/bin/sh
# Restart the Plasma shell (desktop backgrounds, panels, start menu)
# without logging out. Use when backgrounds are black and the panel and
# Meta key stop working, e.g. after resume from sleep.
systemctl --user restart plasma-plasmashell.service
