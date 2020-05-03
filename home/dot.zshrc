PROMPT=$'%B%n@%m %1~ %(?..%K{yellow}%?%k)%#%b '
setopt autocd

. "$HOME/.bash_utils/bin/v"
. "$HOME/.bash_utils/source/aliases"
help () { bash -c "help $*"; }

setopt extendedhistory
setopt INC_APPEND_HISTORY_TIME
HIST_DIR="$HOME/.history/zsh"
HISTSIZE="999999"
SAVEHIST="$HISTSIZE"
HISTFILESIZE="$HISTSIZE"
# HISTTIMEFORMAT="%Y%m%d.%H%M%S,$(basename "$TTY"): "
HISTFILE="$HOME/.zsh_history"
if [ -f "$HIST_DIR"/*.history(Y1) ]
then
(
    cd "$HIST_DIR"
    ls -t | grep '\.history$' | tail -n +1000 | xargs rm
    sort -mns -k 2 "$HISTFILE" *.history | uniq > "$HISTFILE.new"
    mv -f "$HISTFILE.new" "$HISTFILE"
)
else
    mkdir -p "$HIST_DIR"
fi
fc -R "$HISTFILE"
HISTFILE="$HIST_DIR/$(date "+%Y-%m-%d-%H%M%S")-$(basename "$TTY")-$$.history"

zstyle ':completion:*:(ssh*|scp|rsync):*:users' hidden true
autoload -Uz compinit && compinit -u
