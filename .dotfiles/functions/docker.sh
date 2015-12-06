#!/bin/bash

docker-machine-init() {
  local MACHINE_NAME="$DOCKER_DEV_MACHINE_NAME"
  local DOCKER_DEV_MACHINE_DISK_MB=80000
  # use 1/2 physical ram of machine
  local DOCKER_DEV_MACHINE_RAM_MB=$(expr $(grep MemTotal /proc/meminfo | awk '{print $2}') / $(expr 2 \* 1024))
  docker-machine -D create \
    -d virtualbox \
      --virtualbox-disk-size $DOCKER_DEV_MACHINE_DISK_MB \
      --virtualbox-memory $DOCKER_DEV_MACHINE_RAM_MB \
    "$MACHINE_NAME"
  docker-machine stop "$MACHINE_NAME"
  docker-machine-up
}

docker-machine-up() {
  local MACHINE_NAME="$DOCKER_DEV_MACHINE_NAME"
  local VB_PATH="$(virtualbox-find-path)"
  if [ "$(docker-machine status "$MACHINE_NAME")" != "Running" ]; then
    echo "Starting development docker-machine \"$MACHINE_NAME\""

    # share folders
    virtualbox-share-path "$MACHINE_NAME" "c/Users" "C:/Users"
    virtualbox-share-path "$MACHINE_NAME" "c/projects" "C:/projects"

    # open ports
    virtualbox-open-port "$MACHINE_NAME" "80"
    virtualbox-open-port "$MACHINE_NAME" "443"

    docker-machine start "$MACHINE_NAME"
    yes | docker-machine regenerate-certs "$MACHINE_NAME"
    docker-machine ssh "$MACHINE_NAME" 'sudo mkdir -p /c/projects && sudo mount -t vboxsf c/projects /c/projects'
    docker-machine ssh "$MACHINE_NAME" 'sudo mkdir -p /c/Users && sudo mount -t vboxsf c/Users /c/Users'
  fi

  echo "Loading docker-machine shell variables"
  eval $(docker-machine env "$MACHINE_NAME") > /dev/null 2>&1
}

docker-remove-exited-containers() {
  docker rm $(docker ps -q -f status=exited)
}

docker-remove-untagged-images() {
  docker rmi -f $(docker images | grep "<none>" | awk "{print \$3}")
}

docker-expose-port-to-localhost() {
  local IS_NUM='^[0-9]+$'
  if [[ $1 =~ $IS_NUM ]] ; then
    PORT=$1
    CONTAINER_NAME=$2
  else
    CONTAINER_NAME=$1
    PORT=$2
  fi
  virtualbox-open-port "$DOCKER_DEV_MACHINE_NAME" "$PORT"

DOCKER_CMD=$(cat <<CMD
  docker run \
    -d \
    -p $PORT:$PORT \
    -v //var/run/docker.sock://var/run/docker.sock \
  --name "${CONTAINER_NAME}-${PORT}" \
    cpuguy83/docker-grand-ambassador \
      -name "$CONTAINER_NAME"
CMD
)

  if which docker-machine >/dev/null; then
    docker-machine ssh $(docker-machine active) "$DOCKER_CMD"
  else
    sh -c "$DOCKER_CMD"
  fi

}

docker-run-cadvisor() {
DOCKER_CMD=$(cat <<CMD
  docker run                                      \
    --volume=/:/rootfs:ro                         \
    --volume=/var/run:/var/run:rw                 \
    --volume=/sys:/sys:ro                         \
    --volume=/var/lib/docker/:/var/lib/docker:ro  \
    --publish=8080                                \
    -e VIRTUAL_HOST="~^(.+)$"                     \
    -e VIRTUAL_PATH="/cadvisor"                   \
    -e VIRTUAL_PORT=8080                          \
    --detach=true                                 \
    --name=cadvisor                               \
    google/cadvisor:latest
CMD
)

  if which docker-machine >/dev/null; then
    docker-machine ssh $(docker-machine active) "$DOCKER_CMD"
  else
    sh -c "$DOCKER_CMD"
  fi
}
