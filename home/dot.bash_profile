SHELL_UTILS_DIR=$(cd -- $(dirname $(dirname $(readlink "$BASH_SOURCE"))); pwd)

for PATH_DIR in "$HOME/bin" "$HOME/.local/bin" "$SHELL_UTILS_DIR/bin"
do
    # only add directories not yet in PATH and containing executables
    echo ":$PATH:" | grep -q ":$PATH_DIR:" ||
        [ -d "$PATH_DIR" ] && ls -l "$PATH_DIR" | egrep -q '^[^d]\S+x' &&
        export PATH="$PATH_DIR:$PATH"
done

for SOURCE_FILE in "$SHELL_UTILS_DIR/source"/* "$HOME/bin/"*/*.bash.inc
do
    [ -e "$SOURCE_FILE" ] && source "$SOURCE_FILE"
done

export HISTFILESIZE=262144
export HISTSIZE=64738
export HISTTIMEFORMAT="%F-%T "
mkdir -p -m 0700 "$HOME/.history"
# keep only a bunch of the latest history files:
#bash_history_sort.pl --comment --delete $(
#    ls -t "$HOME/.history/bash_history-"* | grep -v '/bash_history-0' | tail +100 | tail -n 10
#) >> "$HOME/.history/bash_history-0"

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

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
which kubectl 2>&1 >/dev/null && source <(kubectl completion bash)
[ -d "$HOME/.nvm" ] && export NVM_DIR="$HOME/.nvm"
[ -f "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
