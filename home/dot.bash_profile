[ -n "$DEBUG" ] && set -x
SHELL_UTILS_DIR=$(dirname $(dirname $(readlink "$BASH_SOURCE" || echo "$BASH_SOURCE")))
[ "${SHELL_UTILS_DIR:0:1}" = "/" ] || SHELL_UTILS_DIR="$HOME/$SHELL_UTILS_DIR"
SHELL_UTILS_DIR=$(cd -- "$SHELL_UTILS_DIR"; pwd)
export LC_ALL=fi_FI.UTF-8

for PATH_DIR in "$HOME/bin" "$HOME/.local/bin" "$HOME/go/bin" "$SHELL_UTILS_DIR/bin"
do
    # only add directories not yet in PATH and containing executables
    echo ":$PATH:" | grep -q ":$PATH_DIR:" ||
        [ -d "$PATH_DIR" ] && ls -l "$PATH_DIR" | egrep -q '^[^d]\S+x' &&
        export PATH="$PATH_DIR:$PATH"
done

for SOURCE_FILE in "$HOME/.bashrc" "$SHELL_UTILS_DIR/source"/* "$HOME/bin/"*/*.bash.inc
do
    if [ -e "$SOURCE_FILE" ] && ! grep -q " $SOURCE_FILE " <<<" $SOURCED "
    then
        SOURCED="${SOURCED:+$SOURCED }$SOURCE_FILE"
        source "$SOURCE_FILE"
    fi
done

export HISTFILESIZE=262144
export HISTSIZE=64738
export HISTTIMEFORMAT="%F-%T "
mkdir -p -m 0700 "$HOME/.history"

history_rewrite () {
	local HISTORY_LOCK="$HOME/.history/.lock"

	# combine histories, but only if nobody else is already doing it right
	# now (non-blocking): with several terminals launched at once at login,
	# there's no point in each of them redoing the same merge in turn
	(
		flock -x -n 200 || exit 0
		"$SHELL_UTILS_DIR/bin/bash_history_sort.pl" "$HOME/.history/bash_history-"* > "$HOME/.bash_history"
	) 200>"$HISTORY_LOCK"

	# then wait for whichever session is writing (ourselves or another) to
	# finish before reading, so we never load a partially-written file: a
	# shared lock blocks only against the exclusive writer above, not
	# against other readers. Held in this shell, not a subshell, so
	# `history -r` affects our own session's in-memory history.
	exec 201>"$HISTORY_LOCK"
	if flock -s -w 30 201
	then
		history -r "$HOME/.bash_history"
	else
		echo >&2 "history_rewrite: timed out waiting for history merge, skipping"
	fi
	exec 201>&-
}

export HISTFILE="$HOME/.history/bash_history-$(date +%F-%T)-$$"
touch "$HISTFILE"
history_rewrite

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -f /etc/profile.d/bash_completion.sh ] && . /etc/profile.d/bash_completion.sh
which kubectl 2>&1 >/dev/null && source <(kubectl completion bash)
[ -d "$HOME/.nvm" ] && export NVM_DIR="$HOME/.nvm"
[ -f "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh" --no-use # do not assume any version applies in general

. /usr/share/bash-completion/completions/git
__git_complete co git_checkout

true

