#!/bin/sh

setsid bash -c '
  plasmashell --replace > >(logger -t plasmashell -p user.info) 2> >(logger -t plasmashell -p user.err) &
  kwin_x11 --replace > >(logger -t kwin -p user.info) 2> >(logger -t kwin -p user.err) &
' &

