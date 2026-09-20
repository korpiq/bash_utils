#!/bin/bash

set -euo pipefail

docker image prune --force
docker volume prune --force
docker system prune --force

