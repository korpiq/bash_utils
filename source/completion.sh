_complete_ssh()
{
    COMPREPLY=($(list_matching_ssh_hosts ${COMP_WORDS[COMP_CWORD]}))
    return 0
}

list_matching_ssh_hosts()
{
    (
        sed -ne "s/^Host  *//p" < "$HOME/.ssh/config"
        sed -ne "s/^\([a-z][a-z0-9.-]*[a-z]\),.*/\1/p" < "$HOME/.ssh/known_hosts"
    ) | grep "^$1" | sort -u
}

complete -F _complete_ssh ssh
