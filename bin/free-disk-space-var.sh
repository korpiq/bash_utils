#!/bin/bash

[ "$EUID" = "0" ] || exec sudo "$0" "$@"

logrotate /etc/logrotate.conf
journalctl --vacuum-size=500M
docker images prune
docker volumes prune
docker system prune

snap list --all | awk '/disabled/ {print $1, $3}' |
while read pkg rev
do
    snap remove "$pkg" --revision="$rev"
done

rm /var/lib/snapd/cache/*
