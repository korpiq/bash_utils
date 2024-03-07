[ -n "$DEBUG" ] && set -x
SHELL_UTILS_DIR=$(cd -- $(dirname $(dirname $(readlink "$BASH_SOURCE" || echo "$BASH_SOURCE"))); pwd)
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
	# combine histories:
	"$SHELL_UTILS_DIR/bin/bash_history_sort.pl" "$HOME/.history/bash_history-"* > "$HOME/.bash_history"
    history -r "$HOME/.bash_history"
}

export HISTFILE="$HOME/.history/bash_history-$(date +%F-%T)-$$"
touch "$HISTFILE"
history_rewrite

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -f /etc/profile.d/bash_completion.sh ] && . /etc/profile.d/bash_completion.sh
which kubectl 2>&1 >/dev/null && source <(kubectl completion bash)
[ -d "$HOME/.nvm" ] && export NVM_DIR="$HOME/.nvm"
[ -f "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh" --no-use # do not assume any version applies in general

#AWSume alias to source the AWSume script
alias awsume="source awsume"

#Auto-Complete function for AWSume
_awsume() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(awsume-autocomplete)
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}
complete -F _awsume awsume

. /usr/share/bash-completion/completions/git
__git_complete co git_checkout

true

