#!/bin/bash

git4prompt () {
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    [ -n "$branch" ] || return
    [ "$branch" = "HEAD" ] && branch=DETACHED
    local changes=$(git status --porcelain 2> /dev/null | grep -v '^??' | wc -l | sed 's/^ *0*//')
    [ "$changes" = "" ] || changes=":$changes"
    echo " ($branch$changes)"
}

export git4prompt

if [ "$0" = "$BASH_SOURCE" ]
then
    git4prompt
else
    export PS1=$(echo "$PS1" | sed '
	s/\\\[\\e\[0;34m\\\]$(git4prompt)\\\[\\e\[00m\\\]//g; # remove old
	s/\\\$/\\[\\e[0;34m\\]$(git4prompt)\\[\\e[00m\\]\\$/; # add new before $
    ')
fi

