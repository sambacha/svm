#!/bin/bash
# SPDX-License-Identifier: ISC
# https://github.com/josh-richardson/svm
# v0.1.0
#

enter_directory() {
  if [[ $PWD == $PREV_PWD ]]; then
    return
  fi

  PREV_PWD=$PWD
  [[ -f ".svmrc" ]] && svm use
}

export PROMPT_COMMAND=enter_directory
