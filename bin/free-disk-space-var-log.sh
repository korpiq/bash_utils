#!/bin/bash

set -euo pipefail

[ "$EUID" = "0" ] || exec sudo "$0" "$@"

logrotate /etc/logrotate.conf
journalctl --vacuum-size=500M

