source "/usr/local/opt/zsh-git-prompt/zshrc.sh"
PROMPT=$'%B%n@%m %1~ $(git_super_status)%(?..%K{yellow}%F{red}%?%f%k)%#%b '
setopt autocd
setopt rmstarsilent

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

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
# [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PATH="$HOME/bin:$PATH"

export SECRETS_PINENTRY=ask
