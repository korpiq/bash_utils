#!/bin/bash

set -euo pipefail

[ "$EUID" = "0" ] || exec sudo "$0" "$@"

snap list --all | awk '/disabled/ {print $1, $3}' |
while read pkg rev
do
    snap remove "$pkg" --revision="$rev"
done

rm /var/lib/snapd/cache/*
