#!/bin/bash

set -euo pipefail

not_my_ip () {
  for IP in "$@"
  do
    ip addr | grep -q "inet $IP/" || echo "$IP"
  done
}

get_version_command () {
  # shellcheck disable=SC2016
  echo echo '$(git -C "'"$1"'" branch --show-current; git -C "'"$1"'" rev-parse HEAD)'
}

REMOTE_HOST="${1:-$(not_my_ip 192.168.0.246 192.168.0.222)}"
REMOTE_DIR="${2:-$PWD}"
LOCAL_DIR="${3:-$PWD}"

LOCAL_VERSION_COMMAND=$(get_version_command "$LOCAL_DIR")
LOCAL_VERSION=$(bash -c "$LOCAL_VERSION_COMMAND")
LOCAL_BRANCH=${LOCAL_VERSION%% *}
LOCAL_COMMIT=${LOCAL_VERSION#* }
echo "Local: $LOCAL_DIR $LOCAL_BRANCH $LOCAL_COMMIT" >&2
REMOTE_VERSION=$(ssh "$REMOTE_HOST" bash -c "true; $(get_version_command "$REMOTE_DIR")")
REMOTE_BRANCH=${REMOTE_VERSION%% *}
REMOTE_COMMIT=${REMOTE_VERSION#* }
echo "$REMOTE_HOST: $REMOTE_DIR $REMOTE_BRANCH $REMOTE_COMMIT" >&2
STASH_NAME="Sync $REMOTE_BRANCH $REMOTE_COMMIT"
EXCLUDE_FILES=${EXCLUDE_FILES:-.git .idea .next node_modules}

if [ "$LOCAL_BRANCH" != "$REMOTE_BRANCH" ]
then
  echo "Pulling $REMOTE_BRANCH" >&2
  STASH_NAME="$STASH_NAME in $LOCAL_BRANCH"
  git stash -m "$STASH_NAME"
  git fetch origin "$REMOTE_BRANCH"
  git checkout "$REMOTE_BRANCH"
  git pull
  LOCAL_COMMIT=$(git -C "$LOCAL_DIR" rev-parse HEAD)
fi

if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]
then
  echo "Checking out $REMOTE_COMMIT" >&2
  git stash -m "$STASH_NAME"
  git checkout "$REMOTE_COMMIT"
fi

echo "$EXCLUDE_FILES" | sed 's/  */\n/g' | grep . |
rsync -av --exclude-from - "$REMOTE_HOST:$REMOTE_DIR/" "$LOCAL_DIR/"
