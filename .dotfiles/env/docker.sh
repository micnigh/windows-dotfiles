#!/bin/bash
export DOCKER_DEV_MACHINE_NAME="dev"
export DOCKER_DEV_MACHINE_DISK_MB=80000

# use 1/2 physical ram of machine
export DOCKER_DEV_MACHINE_RAM_MB=$(expr $(grep MemTotal /proc/meminfo | awk '{print $2}') / $(expr 2 \* 1024))
