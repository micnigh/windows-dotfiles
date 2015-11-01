#!/bin/bash

docker-machine-init() {
  local MACHINE_NAME="$DOCKER_DEV_MACHINE_NAME"
  docker-machine create \
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
  if [ $(docker-machine ls | grep "^$MACHINE_NAME" | awk "{print \$3}") == "Stopped" ]; then
    echo "Starting development docker-machine \"$MACHINE_NAME\""

    # share folders
    virtualbox-share-path "$MACHINE_NAME" "c/Users" "C:/Users"
    virtualbox-share-path "$MACHINE_NAME" "c/projects" "C:/projects"

    # open ports
    virtualbox-open-port "$MACHINE_NAME" "80"
    virtualbox-open-port "$MACHINE_NAME" "443"

    docker-machine start "$MACHINE_NAME"
    docker-machine ssh "$MACHINE_NAME" 'sudo mkdir -p /c/projects && sudo mount -t vboxsf c/projects /c/projects'
    docker-machine ssh "$MACHINE_NAME" 'sudo mkdir -p /c/Users && sudo mount -t vboxsf c/Users /c/Users'
  fi

  echo "Loading docker-machine shell variables"
  eval $(docker-machine env "$MACHINE_NAME") > /dev/null 2>&1
}

b2dup() {
  local MACHINE_NAME="boot2docker-vm"
  if [ $(boot2docker status) != "running" ]; then
    echo "Starting boot2docker"

    # share folders
    virtualbox-share-path "$MACHINE_NAME" "c/Users" "C:/Users"
    virtualbox-share-path "$MACHINE_NAME" "c/projects" "C:/projects"

    # open ports
    virtualbox-open-port "$MACHINE_NAME" "80"
    virtualbox-open-port "$MACHINE_NAME" "443"

    boot2docker up
    boot2docker ssh 'sudo mkdir -p /c/projects && sudo mount -t vboxsf c/projects /c/projects'
    boot2docker ssh 'sudo mkdir -p /c/Users && sudo mount -t vboxsf c/Users /c/Users'
  fi

  # rebuild security certificates - workaround for [#531](https://github.com/docker/machine/issues/531#issuecomment-120554419)
  #echo "Generating new certificate if needed"
  #boot2docker ssh 'sudo /etc/init.d/docker restart'

  echo "Loading boot2docker shell variables"
  eval $(boot2docker shellinit) > /dev/null 2>&1
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
  elif which boot2docker >/dev/null; then
    boot2docker ssh -t "$DOCKER_CMD"
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
  elif which boot2docker >/dev/null; then
    boot2docker ssh -t "$DOCKER_CMD"
  else
    sh -c "$DOCKER_CMD"
  fi
}

docker-compose() {
  if [[ "$(docker images -q docker-compose 2> /dev/null)" == "" ]]; then
    docker build -t docker-compose github.com/docker/compose#1.4.0rc3
  fi
  docker run --rm -ti -v //var/run/docker.sock://var/run/docker.sock -v "/$PWD":"/$PWD" -w "/$PWD" docker-compose "$@"
}
