# Lang Libs + SDK{{{

if [[ -n "$(which android > /dev/null 2>&1)" ]]; then
  export ANDROID_HOME=$(dirname $(dirname $(which android)))
fi

if [[ -d $HOME/.go ]]; then
  export GOPATH="$HOME/.go"
  export PATH=$PATH:$GOPATH/bin
fi

if [ -d "$HOME/apps/google-cloud-sdk/" ]; then
  # The next line updates PATH for the Google Cloud SDK.
  source "$HOME/apps/google-cloud-sdk/path.bash.inc"

  # The next line enables shell command completion for gcloud.
  source "$HOME/apps/google-cloud-sdk/completion.bash.inc"
fi

if [[ -x /usr/libexec/java_home ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home 2> /dev/null)
fi

export NODE_PATH=/usr/local/lib/jsctags/:$NODE_PATH

#}}}

# Path {{{

if [[ -n "$__PATH_RESET" ]]; then
  path=$__PATH_RESET
else
  path=$PATH
  export __PATH_RESET=$path
fi

# Android SDK
if [ -d $HOME/Library/Android/sdk/platform-tools ]; then
  export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
fi

if [ -d /opt/adt/sdk/tools ]; then
  export PATH=$PATH:/opt/adt/sdk/tools
fi

if [ -d /opt/adt/eclipse/Eclipse.app/Contents/MacOS ]; then
  export PATH=$PATH:/opt/adt/eclipse/Eclipse.app/Contents/MacOS
fi

if [ -d /Library/TeX/texbin ]; then
  export PATH=$PATH:/Library/TeX/texbin
fi

if which yarn > /dev/null 2>&1; then
  export PATH=$PATH:$(yarn global bin)
fi

# This variable is used elsewhere to write an os-agnostic grep either with gnu
# grep installed on macos or it being present on linux systems
if which ggrep > /dev/null 2>&1; then
  export GREP=$(which ggrep)
elif [ -x /usr/bin/grep ]; then
  export GREP=/usr/bin/grep
fi

export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/share/npm/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.notion/bin:$PATH
export PATH=$HOME/.notion/shim:$PATH
export PATH=$HOME/.dotfiles/bin:$path
export PATH=$HOME/bin:$PATH

# }}}

# Version Mgmt {{{

export NOTION_HOME=$HOME/.notion

# Load nvm, if it is present.
export NVM_DIR=$HOME/.nvm
[[ -n "$(which brew > /dev/null 2>&1)" ]] && [[ -s "$(brew --prefix nvm)/nvm.sh" ]] && source "$(brew --prefix nvm)/nvm.sh"

# initialize rbenv
if [ -x /usr/local/bin/rbenv ]; then
  eval "$(rbenv init -)"
fi

# Load RVM, if it is present.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

#}}}

# Apps + Aliases {{{

# Support colour in pager, tabsize 2 and case insensitive searching.
export LESS='-R -x2 -i'

# Always colourize ls output.
export CLICOLOR=1

ls / --color=auto > /dev/null 2>&1
if [[ $? == 0 ]]; then
  alias ls='ls --color=auto'
fi

# pws
export ALPHA=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
export ALPHANUM="$ALPHA"0123456789
export PWS_SECONDS=60

# useable for term, multiplexers, not really used any more
export HALF_COLUMNS=$(($COLUMNS/2))
export HALF_LINES=$(($LINES/2))


# fzf 
if [ -f "$HOME/src/rupa/z/z.sh" ]; then
  source "$HOME/src/rupa/z/z.sh"
elif [ -f /usr/local/Cellar/z/1.9/etc/profile.d/z.sh ]; then
  source /usr/local/Cellar/z/1.9/etc/profile.d/z.sh
fi

#}}}

# Aliases {{{

# Add (proper) readline support to node
alias jsc='rlwrap --always-readline --ansi-colour-aware --remember --complete-filenames node'



# grep

# Sensible defaults for grep (recursive, case-insensitive)
alias gi='grep -r -i --color'

# Add line numbers.
alias gin='grep -r -i -n --color'

# Grep with perl regex.
which ggrep > /dev/null 2>&1 &&\
  alias gp='ggrep -r -P --color' ||\
  alias gp='grep -r -P --color'

# Grep git repo.
alias gg='git grep --untracked'


# ls

# List in reverse last-modified, to see the newest files at the bottom of the
# output.
alias llr='ls -lhart'
alias ll='ls -lh'


# lsof
alias lsof-tcp='lsof -iTCP'
alias lsof-tcp-listen='lsof -iTCP -sTCP:LISTEN -P'

# always create paths when using mkdir.
alias mkdir='mkdir -p'



# Ruby stream editor; a simple, primitive ruby analog to sed.
alias rsed="ruby -p -e '%w(rubygems active_support).each{|l| require l}' \
            -e 'def s *args; \$_.gsub! *args; end'"
alias chomp="rsed -e '\$_.chomp!'"
alias b="bundle exec"


# ssh
alias ssh-no-agent-forwarding='ssh -o "ForwardAgent no"'
alias copy-ssh-auth-sock='echo -n $SSH_AUTH_SOCK | pbcopy'


# Trailing space to tell bash to check next word for alias as well
alias sudo='sudo '


# tmux
alias t='tmux'
alias ts='tmux list-sessions | fzf  | cut -d':' -f 1 | xargs tmux switch-client -t'
alias tw='tmux list-windows | fzf  | cut -d':' -f 1 | xargs tmux select-window -t'


# vim
# mvim has a terminal mode which seems to be a pretty good way of getting a
# proper vim build on the terminal.
which mvim > /dev/null 2>&1 && alias vim='mvim -v'

alias 'debug-vim'='vim -V12 --cmd "set verbosefile=/tmp/vim.log"'

# yarn
alias y=yarn

#}}}

# Bash CLI {{{

# Use vi-mode (escape to go into “normal” mode and j,k to scroll through
# history, navigate lines with bw, &c.)
set -o vi

# Make bash check its window size after each command, to keep $LINES and
# $COLUMNS correct.
shopt -s checkwinsize

# Skip over duplicates in bash history
HISTCONTROL=ignoredups



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

#}}}



if [[ -x "$(which mvim > /dev/null 2>&1)" ]]; then
  export EDITOR='mvim -v'
fi



# vim:set tw=0 fdm=marker:

