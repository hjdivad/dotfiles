#!/usr/bin/env bash

which rvm-prompt > /dev/null 2>&1
if [[ $? == 0 ]]; then
  _prompt_rvm() {
    local rvm_current=$(rvm-prompt)
    echo "$orange${rvm_current#ruby-}$reset_color "
  }
else
  _prompt_rvm() { echo ""; }
fi

if declare -f | $GREP -q -P '^nvm '; then
  _prompt_nvm() {
    local nvm_current=$(nvm_ls current)
    echo "$green${nvm_current#v}$reset_color "
  }
else
  _prompt_nvm() { echo ""; }
fi

# OPTIMISE: This is the slowest part of my prompt
# 
_prompt_git() {
  local ref=$(git symbolic-ref HEAD 2> /dev/null)
  if [ -n "$ref" ]; then
    # We have a git, ask him questions, unless it's disabled
    if  git config prompt.dontCheckStatus > /dev/null ||\
        [ -z "$(git status --ignore-submodules -z)" ]; then
      # Clean
      local state_prefix=""
    else
      # Dirty
      local state_prefix="[$red+$reset_color]"
    fi
    local branch=${ref#refs/heads/}
    echo "$state_prefix$green$branch$reset_color "
  else
    echo ""
  fi
}

_prompt_path() {
  # ~/full/path
  local path="~${PWD#$HOME}"
  echo "$yellow$path$reset_color "
}

_prompt_host() {
  echo "$cyan\h:$reset_color "
}

_prompt_command_indicator() {
  echo "$blue\$$reset_color "
}

set_prompt() {
  PS1="$(_prompt_host)$(_prompt_path)$(_prompt_git)$(_prompt_rvm)$(_prompt_nvm)\n$(_prompt_command_indicator)"
}


PROMPT_COMMAND=set_prompt
