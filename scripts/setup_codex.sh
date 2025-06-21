#!/usr/bin/bash

set -e

function setup_mise() {
  # set up mise
  # https://mise.jdx.dev/installing-mise.html#apt

  if which mise > /dev/null 2>&1; then
    return
  fi

  apt update -y
  apt install -y gpg sudo wget curl
  install -dm 755 /etc/apt/keyrings

  wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=arm64] https://mise.jdx.dev/deb stable main" | tee /etc/apt/sources.list.d/mise.list

  apt update
  apt install -y mise
}

setup_mise
