#!/bin/bash

ps ax -o user,pid,command |
    grep /loginwindow.app/ |
    grep -v "^$USER " |
    while read user pid command
    do
        echo "Log out $user"
        sudo launchctl bsexec $pid osascript -e \
            'tell application "loginwindow" to «event aevtrlgo»'
    done

