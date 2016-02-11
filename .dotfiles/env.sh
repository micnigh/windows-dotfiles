#!/bin/bash
export PATH=$PATH:/mingw64/bin
export PATH=/cmd:$PATH
export TERM=cygwin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH="$PATH:$HOME/npm/bin"
export PATH="$PATH:$HOME/npm"
export ANDROID_HOME="$LOCALAPPDATA/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

. ~/.dotfiles/env/conemu.sh
. ~/.dotfiles/env/docker.sh
. ~/.dotfiles/env/git-ssh-forwarding.sh
. ~/.dotfiles/env/git.sh
. ~/.dotfiles/env/msys.sh
