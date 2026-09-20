#!/bin/bash

set -euo pipefail

DRY_RUN="${DRY_RUN:-}"

choose_action () {
  case "$1" in
    /var/log) echo free-disk-space-var-log.sh ;;
    /var/docker) echo free-disk-space-var-docker.sh ;;
    /var/snap) echo free-disk-space-var-snap.sh ;;
  esac
}

(df -P | grep -E ' (8[0-9]|9[0-9]|100)% ' || true) |
while read -r FS BLOCKS USED AVAIL PCT MOUNT
do
  ACTION=$(choose_action "$MOUNT")
  echo >&2 "$0: $MOUNT $PCT -> ${ACTION:-no action}"
  if [ -n "$ACTION" ]; then
    $DRY_RUN $ACTION
  fi
done
