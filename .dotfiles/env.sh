#!/bin/bash
export PATH=$PATH:/mingw64/bin
export PATH=/cmd:$PATH
export TERM=cygwin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH="$PATH:$HOME/npm/bin"
export PATH="$PATH:$HOME/npm"

. .dotfiles/env/docker.sh
. .dotfiles/env/git.sh
