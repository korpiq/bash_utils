#!/bin/bash
# https://linuxconfig.org/how-to-create-incremental-backups-using-rsync-on-linux
# A script to perform incremental backups using rsync

set -euo pipefail

usage () {
    echo "Usage: $0 SOURCE_DIR BACKUP_DIR" >&2
    exit 1
}

[ -d "${1:-}" -a -d "${2:-}" ] || usage

readonly SOURCE_DIR="$1"
readonly BACKUP_DIR="$2"

readonly RUN="${DRY_RUN:+echo }$([ -w "${BACKUP_DIR}" ] || echo sudo)"
readonly BACKUP_TIMESTAMP_DIRNAME="$(date '+%Y-%m-%d_%H:%M:%S')"
readonly BACKUP_PATH="${BACKUP_DIR}/${BACKUP_TIMESTAMP_DIRNAME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"

${RUN} rsync -va --delete \
  --link-dest "${LATEST_LINK}" \
  --filter "dir-merge /.backup-filter.conf" \
  "${SOURCE_DIR}" \
  "${BACKUP_PATH}"

${RUN} rm -f "${LATEST_LINK}"
${RUN} ln -s "${BACKUP_TIMESTAMP_DIRNAME}" "${LATEST_LINK}"

