#!/bin/sh

export PATH=/sbin:/usr/sbin:/bin:/usr/bin

for HOOK_SCRIPT in /home/*/.config/systemd/system-sleep/*[a-z]
do
    if [ -x "$HOOK_SCRIPT" ]
    then
        HOOK_USER=$(stat -c "%U" "$HOOK_SCRIPT")
        [ -n "$DEBUG" ] && echo "Run '$HOOK_SCRIPT' as '$HOOK_USER'" >&2
        sudo -u "$HOOK_USER" -i "$HOOK_SCRIPT" "$@"
    fi
done

