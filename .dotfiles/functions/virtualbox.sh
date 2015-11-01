#!/bin/bash

virtualbox-share-path() {
  VM_NAME=$1
  SHARE_NAME=$2
  SHARE_PATH=$3
  local VB_PATH="$(virtualbox-find-path)"
  "$VB_PATH/VBoxManage.exe" sharedfolder add "$VM_NAME" --name "$SHARE_NAME" --hostpath "$SHARE_PATH" --automount > /dev/null 2>&1
}

virtualbox-open-port() {
  VM_NAME=$1
  PORT=$2
  local VB_PATH="$(virtualbox-find-path)"
  if $("$VB_PATH"/VBoxManage.exe list runningvms | grep -e "^\"$VM_NAME\"" > /dev/null); then
    # running
    "$VB_PATH/VBoxManage.exe" controlvm "$VM_NAME" natpf1 ",tcp,,$PORT,,$PORT" > /dev/null 2>&1
  else
    # not running
    "$VB_PATH/VBoxManage.exe" modifyvm "$VM_NAME" --natpf1 ",tcp,,$PORT,,$PORT" > /dev/null 2>&1
  fi
}

virtualbox-find-path() {
  local VB_PATH=""
  if [[ $VBOX_INSTALL_PATH ]]; then
    VB_PATH="$VBOX_INSTALL_PATH"
  elif [[ $VBOX_MSI_INSTALL_PATH ]]; then
    VB_PATH="$VBOX_MSI_INSTALL_PATH"
  fi
  if [ ! -f "$VB_PATH/VBoxManage.exe" ]; then
    >&2 echo "VirtualBox not found!"
    return 1
  fi
  echo "$VB_PATH"
}
