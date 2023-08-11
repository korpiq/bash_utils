#!/bin/bash

case "$1" in
    pre) 
        warp-cli disconnect
        ;;
    post)
        echo warp-cli connect
        ;;
    *)
        echo "Unknown parameter '$1'" >&2
        ;;
esac

warp-cli status

