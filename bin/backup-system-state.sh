#!/bin/bash

set -euo pipefail

STATE_DIR="$HOME/.local/state/${HOSTNAME}"

mkdir -p "${STATE_DIR}"

# 1. Export APT (native) package lists
dpkg --get-selections > "${STATE_DIR}/apt-packages.txt"
apt-mark showauto > "${STATE_DIR}/apt-auto.txt"

# 2. Export Snap packages
! command -v snap &>/dev/null ||
    snap list > "${STATE_DIR}/snap-packages.txt"

# 3. Export Flatpak packages
! command -v flatpak &>/dev/null ||
    flatpak list --columns=application > "${STATE_DIR}/flatpak-packages.txt"

# 4. Export repositories (PPA keys and sources)
cp -r /etc/apt/sources.list* "${STATE_DIR}/"

CUSTOM_SW=$(
    find /usr/local/{bin,sbin,share} /opt /srv -type f |
        while read -r F
        do
            dpkg -S "$F" &>/dev/null || echo "$F"
        done
)

[ -z "$CUSTOM_SW" ] || tar czf "$STATE_DIR/custom-sw.tar.gz" -T - <<<"$CUSTOM_SW"
