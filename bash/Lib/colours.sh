#!/usr/bin/env bash

if [[ ! -f "$HOME/.bash/colors.sh" ]]; then
  source "$HOME/.dotfiles/bash/Lib/make-colours.sh"
fi

source "$HOME/.bash/colors.sh"
