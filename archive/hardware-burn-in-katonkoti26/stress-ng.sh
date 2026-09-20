#!/bin/bash

CPU_TAG="$(lscpu | sed -ne 's/^Model name:.* //p')"

stress-ng --seq 0 --aggressive --change-cpu --metrics-brief --tz --progress --yaml "$CPU_TAG-stress-ng.yaml"
