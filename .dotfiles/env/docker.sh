#!/bin/bash
if which docker-machine >/dev/null; then
  export DOCKER_DEV_MACHINE_NAME="dev"
elif which boot2docker >/dev/null; then
  export DOCKER_DEV_MACHINE_NAME="boot2docker-vm"
fi

export DOCKER_DEV_MACHINE_DISK_MB=80000
