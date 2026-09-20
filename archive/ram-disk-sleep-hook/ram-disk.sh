#!/bin/bash

case "$1" in
    pre) 
        ram-to-disk
        ;;
    post)
        ram-from-disk
        ;;
    *)
        echo "Unknown parameter '$1'" >&2
        ;;
esac

