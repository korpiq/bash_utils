SHELL_UTILS_DIR=$(cd -- $(dirname $(readlink "$BASH_SOURCE")); pwd)

for PATH_DIR in "$HOME/bin" "$HOME/.local/bin" "$SHELL_UTILS_DIR/bin"
do
    echo ":$PATH:" | grep -q ":$PATH_DIR:" ||
        ls -l "$PATH_DIR" | egrep -q '^[^d]\S+x' &&
        export PATH="$PATH_DIR:$PATH"
done

for SOURCE_FILE in "$SHELL_UTILS_DIR/source"/*
do
    . "$SOURCE_FILE"
done

export HISTFILESIZE=262144
export HISTSIZE=64738
export HISTTIMEFORMAT="%F-%T "
mkdir -p -m 0700 "$HOME/.history"
# keep only a bunch of the latest history files:
ls -t "$HOME/.history/bash_history-"* | tail +500 | xargs rm

history_rewrite () {
	# combine histories:
	"$SHELL_UTILS_DIR/bin/bash_history_sort.pl" "$HOME/.history/bash_history-"* > "$HOME/.bash_history"
	# delay history loading to avoid timestamp mangling bug in bash 3.2
	export PROMPT_COMMAND='
		history -c; history -r "$HOME/.bash_history";
		export PROMPT_COMMAND="history -a'$(echo ";$PROMPT_COMMAND;"|sed "s/; *history -a *;/;/; s/;;*/;/g")'"
	'
}

export HISTFILE="$HOME/.history/bash_history-$(date +%F-%T)-$$"
touch "$HISTFILE"
history_rewrite

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
