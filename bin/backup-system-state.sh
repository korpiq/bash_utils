#!/bin/bash

set -euo pipefail

STATE_DIR="$HOME/.local/state/${HOSTNAME}"

mkdir -p "${STATE_DIR}"

# 1. Export apt keyrings referenced by repo sources (Signed-By / signed-by=),
#    so system-state-restore.sh can verify those repos before installing
#    anything from them (apt-get update fails with NO_PUBKEY otherwise).
KEYRING_FILES=$(
    grep -rhoE '(Signed-By:|signed-by=)[[:space:]]*[^],[:space:]]+' \
        /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null |
        sed -E 's/^(Signed-By:|signed-by=)[[:space:]]*//' |
        sort -u
)
[ -z "$KEYRING_FILES" ] || tar czf "${STATE_DIR}/apt-keyrings.tar.gz" -T - <<<"$KEYRING_FILES"

# 2. Export APT (native) package lists
dpkg --get-selections > "${STATE_DIR}/apt-packages.txt"
apt-mark showauto > "${STATE_DIR}/apt-auto.txt"

# 3. Export Snap packages, plus which ones need --classic to reinstall
#    (snap list's Notes column flags this; installing a classic snap
#    without the flag fails interactively asking for it)
if command -v snap &>/dev/null; then
    snap list > "${STATE_DIR}/snap-packages.txt"
    awk 'NR>1 && $NF ~ /classic/ {print $1}' "${STATE_DIR}/snap-packages.txt" \
        > "${STATE_DIR}/snap-classic.txt"
fi

# 4. Export Flatpak packages
! command -v flatpak &>/dev/null ||
    flatpak list --columns=application > "${STATE_DIR}/flatpak-packages.txt"

# 5. Export repositories (PPA keys and sources)
cp -r /etc/apt/sources.list* "${STATE_DIR}/"

CUSTOM_SW=$(
    find /usr/local/{bin,sbin,share} /opt /srv -type f |
        while read -r F
        do
            dpkg -S "$F" &>/dev/null || echo "$F"
        done
)

[ -z "$CUSTOM_SW" ] || tar czf "$STATE_DIR/custom-sw.tar.gz" -T - <<<"$CUSTOM_SW"
