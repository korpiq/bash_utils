#!/bin/bash

set -euo pipefail

DRY_RUN="${DRY_RUN:-}"
THRESHOLD="${THRESHOLD:-80}"

choose_action () {
  case "$1" in
    /var/log) echo free-disk-space-var-log.sh ;;
    /var/lib/docker) echo free-disk-space-var-docker.sh ;;
    /var/lib/snapd) echo free-disk-space-var-snap.sh ;;
  esac
}

# Percentage full for one mount, filesystem-appropriate:
# - btrfs subvolumes share one pool, so df reports the SAME pool-wide
#   percentage for every subvolume mounted from it; that can't tell
#   which subvolume is actually the problem. Use the subvolume's own
#   qgroup exclusive usage against its quota instead (or against the
#   pool total, if it has no quota).
# - anything else (LVM, plain partitions, ...) is already its own
#   independent filesystem, so df's own percentage is what we want.
usage_pct () {
  local mount="$1" fstype
  fstype=$(findmnt -rno FSTYPE "$mount" 2>/dev/null) || return 1
  if [ "$fstype" = "btrfs" ]; then
    btrfs_subvolume_pct "$mount"
  else
    df -P "$mount" | awk 'NR==2 { gsub("%","",$5); print $5 }'
  fi
}

btrfs_subvolume_pct () {
  local mount="$1" excl max_excl pool_size
  read -r _ _ excl max_excl < <(
    sudo btrfs qgroup show -e --raw "$mount" 2>/dev/null | tail -n +3 | head -n1
  )
  [ -n "${excl:-}" ] || return 1
  if [ "${max_excl:-none}" != "none" ]; then
    echo $((excl * 100 / max_excl))
  else
    pool_size=$(btrfs filesystem usage -b "$mount" 2>/dev/null |
      awk -F: '/Device size/ { gsub(/[^0-9]/,"",$2); print $2; exit }')
    [ -n "${pool_size:-}" ] && [ "$pool_size" -gt 0 ] || return 1
    echo $((excl * 100 / pool_size))
  fi
}

for MOUNT in /var/log /var/lib/docker /var/lib/snapd
do
  [ -d "$MOUNT" ] || continue
  PCT=$(usage_pct "$MOUNT") || { echo >&2 "$0: $MOUNT -> could not determine usage"; continue; }
  ACTION=$(choose_action "$MOUNT")
  echo >&2 "$0: $MOUNT ${PCT}% -> ${ACTION:-no action}"
  if [ -n "$ACTION" ] && [ "$PCT" -ge "$THRESHOLD" ]; then
    $DRY_RUN $ACTION
  fi
done
