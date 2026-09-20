#!/bin/bash

set -euo pipefail

# Define the state directory based on the current hostname or target hostname
STATE_DIR="$HOME/.local/state/${HOSTNAME}"

if [ ! -d "$STATE_DIR" ]; then
    echo "Error: State directory not found at $STATE_DIR" >&2
    exit 1
fi

echo "=================================================="
echo " Starting System Restore from: $STATE_DIR"
echo "=================================================="

echo '=== 1. Restore apt keyrings'
ARCHIVE_FILE="${STATE_DIR}/apt-keyrings.tar.gz"
if [ -f "$ARCHIVE_FILE" ]; then
    echo "--> Restoring apt keyrings (needed before apt-get update can verify added repos)..."
    sudo tar xzf "$ARCHIVE_FILE" -C /
fi

echo '=== 2. Restore repositories (PPAs and package sources)'
if [ -d "$STATE_DIR/sources.list.d" ] || [ -f "$STATE_DIR/sources.list" ]; then
    echo "--> Restoring APT repositories..."
    sudo cp -b -r "$STATE_DIR"/sources.list* /etc/apt/
    sudo apt-get update
fi

echo '=== 3. Restore APT (native) package lists (SAFE & ADDITIVE)'
if [ -f "$STATE_DIR/apt-packages.txt" ] && [ -f "$STATE_DIR/apt-auto.txt" ]; then
    echo "--> Calculating missing native APT packages..."

    # Extract only the names of packages that were marked for installation in the backup
    awk '$2 == "install" {print $1}' "$STATE_DIR/apt-packages.txt" > /tmp/backup_pkg_list.txt

    # Generate a list of what is currently installed on this system
    dpkg-query -f '${binary:Package}\n' -W > /tmp/current_pkg_list.txt

    # Find packages that exist in the backup but NOT on the current system
    # (LC_ALL=C: package names are plain ASCII, and comm requires its
    # inputs sorted in the same collation it checks against — locale-aware
    # sort/comm can disagree on order and abort with "not in sorted order")
    MISSING_PACKAGES=$(LC_ALL=C comm -23 <(LC_ALL=C sort /tmp/backup_pkg_list.txt) <(LC_ALL=C sort /tmp/current_pkg_list.txt))

    if [ -n "$MISSING_PACKAGES" ]; then
        # apt-get install aborts the whole batch if even one name doesn't
        # resolve on this host (e.g. from a PPA that isn't set up here) —
        # filter those out first instead of failing the entire step
        INSTALLABLE=""
        while read -r pkg; do
            [ -n "$pkg" ] || continue
            if apt-cache show "$pkg" >/dev/null 2>&1; then
                INSTALLABLE="$INSTALLABLE$pkg"$'\n'
            else
                echo "--> Skipping $pkg: not available on this host (no matching repo here)"
            fi
        done <<<"$MISSING_PACKAGES"

        if [ -n "$INSTALLABLE" ]; then
            echo "--> Installing missing packages..."
            # Install only the missing packages without touching existing ones
            echo "$INSTALLABLE" | xargs -r sudo apt-get install -y --no-upgrade
        fi
    else
        echo "--> All native packages from the backup are already installed."
    fi

    # Safely mark auto-installed packages without altering existing states
    echo "--> Updating auto-installed package markers..."
    # Filter the auto list to only include packages that actually exist on the system right now
    VALID_AUTO_PKGS=$(LC_ALL=C comm -12 <(LC_ALL=C sort "$STATE_DIR/apt-auto.txt") <(LC_ALL=C sort /tmp/current_pkg_list.txt))
    if [ -n "$VALID_AUTO_PKGS" ]; then
        echo "$VALID_AUTO_PKGS" | xargs -r sudo apt-mark auto >/dev/null
    fi

    # Clean up temp files
    rm -f /tmp/backup_pkg_list.txt /tmp/current_pkg_list.txt
fi

echo '=== 4. Restore Snap packages'
if [ -f "$STATE_DIR/snap-packages.txt" ] && command -v snap >/dev/null; then
    echo "--> Restoring Snap packages..."
    # Skip the header line and read package names
    awk 'NR>1 {print $1}' "$STATE_DIR/snap-packages.txt" | while read -r snap_name; do
        if [ -n "$snap_name" ] && ! snap list "$snap_name" >/dev/null 2>&1; then
            echo "Installing snap: $snap_name"
            # Attempt standard install; classic snaps might require human intervention later
            sudo snap install "$snap_name" || echo "Warning: Failed to install snap $snap_name automatically."
        fi
    done
fi

echo '=== 5. Restore Flatpak packages'
if [ -f "$STATE_DIR/flatpak-packages.txt" ] && command -v flatpak >/dev/null; then
    echo "--> Restoring Flatpak packages..."
    # Read application IDs line by line
    while read -r flatpak_id; do
        if [ -n "$flatpak_id" ]; then
            echo "Installing flatpak: $flatpak_id"
            flatpak install -y flathub "$flatpak_id" || echo "Warning: Failed to install flatpak $flatpak_id"
        fi
    done < "$STATE_DIR/flatpak-packages.txt"
fi

echo '=== 6. Extract untracked custom binaries and configurations outside of /home'
ARCHIVE_FILE="${STATE_DIR}/custom-sw.tar.gz"
if [ -f "$ARCHIVE_FILE" ]; then
    # Quick sanity check: verify tar size isn't just an empty skeleton archive (approx < 50 bytes)
    if [ $(stat -c%s "$ARCHIVE_FILE") -gt 50 ]; then
        echo "--> Restoring custom scripts and binaries to /usr/local, /opt, etc..."
        sudo tar xzf "$ARCHIVE_FILE" -C /
    else
        echo "--> Custom software archive is empty. Skipping."
    fi
fi

echo "=================================================="
echo " Restore completed successfully!"
echo " Recommended: Reboot the machine to apply all changes."
echo "=================================================="
