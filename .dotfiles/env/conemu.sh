#!/bin/bash
if which ConEmuC >/dev/null 2>&1; then
  PROMPT_COMMAND='ConEmuC -StoreCWD'
fi
