# -- login; skip w/--noprofile
# /etc/profile
# ~/.bash_profile
# ~/.bash_login
# ~/.profile
# ...
# ~/.bash_logout
#
# -- interactive non-login; skip w/--norc
# ~/.bashrc
#
# -- non-interactive
# $"BASH_ENV"



BASH_LIB="$HOME/.dotfiles/bash/Lib"
SRC="$HOME/src"

if [ -d /opt/homebrew ]; then
  HOMEBREW="/opt/homebrew"
else
  HOMEBREW="/usr/local"
fi


# Homebrew bash completion
[ -r "${HOMEBREW}/etc/bash_completion" ] && source "${HOMEBREW}/etc/bash_completion"

# Homebrew bash completion@2
[[ -d "${HOMEBREW}/etc/bash_completion.d" ]] && export BASH_COMPLETION_COMPAT_DIR="${HOMEBREW}/etc/bash_completion.d"
[[ -r "${HOMEBREW}/etc/profile.d/bash_completion.sh" ]] && . "${HOMEBREW}/etc/profile.d/bash_completion.sh"

# Completion from alacritty src
[ -r "$SRC/alacritty/alacritty/extra/completions/alacritty.bash" ] && source "$SRC/alacritty/alacritty/extra/completions/alacritty.bash"

if [[ -d $HOME/.bash_completion.d ]]; then
  for local_completion in $(ls $HOME/.bash_completion.d); do
    source $HOME/.bash_completion.d/$local_completion
  done
fi

# If gh exists, add a wrapper that also completes aliases
which gh > /dev/null 2>&1 && source "$BASH_LIB/gh_completion.sh"

source $BASH_LIB/colours.sh

# Lang Libs + SDK{{{

if [[ -z "$DOTFILES_BASHRC_INIT" ]]; then
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
fi

#}}}

# Version Mgmt {{{

# initialize rbenv
if [[ -z "$DOTFILES_BASHRC_INIT" && -x ${HOMEBREW}/bin/rbenv ]]; then
  eval "$(rbenv init -)"
fi

# Load RVM, if it is present.
[[ -z "$DOTFILES_BASHRC_INIT" && -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

#}}}

# Path {{{

if [[ -z "$DOTFILES_BASHRC_INIT" ]]; then
  # Android SDK
  if [ -d $HOME/Library/Android/sdk/platform-tools ]; then
    export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
  fi
  
  if [ -d $HOME/Library/Python/3.7/bin ]; then
    export PATH=$PATH:$HOME/Library/Python/3.7/bin
  fi
  
  if [ -d $HOME/Library/Python/2.7/bin ]; then
    export PATH=$PATH:$HOME/Library/Python/2.7/bin
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
    # export PATH=$PATH:$(yarn global bin)
    export PATH=$PATH:$HOME/.yarn/bin # yarn global bin is really slow
  fi
  
  # This variable is used elsewhere to write an os-agnostic grep either with gnu
  # grep installed on macos or it being present on linux systems
  if which ggrep > /dev/null 2>&1; then
    export GREP=$(which ggrep)
  elif [ -x /usr/bin/grep ]; then
    export GREP=/usr/bin/grep
  fi
  
  # Use gnu xargs if possible on osx; on other systems the local xargs will
  # already be a reasonable version
  if which gxargs > /dev/null 2>&1; then
    export XARGS=$(which gxargs)
  elif [ -x /usr/bin/grep ]; then
    export XARGS=/usr/bin/xargs
  fi
  
  export PATH=$HOMEBREW/bin:$PATH
  export PATH=$HOME/local/bin:$PATH
  export PATH=$HOME/.cargo/bin:$PATH
  export PATH=$HOME/.dotfiles/bin:$PATH
  export PATH=$HOME/.local/bin:$PATH

  # initialize volta
  if [[ -d "$HOME/.volta" ]]; then
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
  fi
fi

# }}}

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
export PWS_CHARPOOL="${ALPHANUM}~@$%^*()_+="
export PWS_LENGTH=16
export PWS_SECONDS=60

if [[ -r $HOME/.ssh/ssh_auth_sock ]]; then
  export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock
fi

# see <https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html#Invoking-GPG_002dAGENT>
export GPG_TTY=$(tty)

#}}}

# Aliases {{{

# Add (proper) readline support to node
alias jsc='rlwrap --always-readline --ansi-colour-aware --remember --complete-filenames node'



# grep

# Grep git repo.
alias gg='git grep --untracked'

# lsof
alias lsof-tcp='lsof -iTCP'
alias lsof-tcp-listen='lsof -iTCP -sTCP:LISTEN -P'

# ifconfig
alias ifconfig-active="ifconfig | pcregrep -M  -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# use exa if it exists
# https://github.com/ogham/exa
if $(which exa > /dev/null 2>&1); then
  alias ls='exa'
  alias ll='exa -l --all --no-user --changed --sort=modified'
fi

# always create paths when using mkdir.
alias mkdir='mkdir -p'


# Ruby stream editor; a simple, primitive ruby analog to sed.
alias rsed="ruby -p -e '%w(rubygems active_support).each{|l| require l}' \
            -e 'def s *args; \$_.gsub! *args; end'"
alias chomp="rsed -e '\$_.chomp!'"
alias b="bundle exec"

# ssh
alias ssh-no-agent-forwarding='ssh -o "ForwardAgent no"'
alias ssh-copy-auth-sock='echo -n $SSH_AUTH_SOCK | pbcopy'

alias copy='tr -d "\n" | pbcopy'
# my-command | copy-url
# TODO: improve this with socat so we don't ruin stdout (e.g. b/c my-command
# doesn't realize it should output terminal escapes)
alias copy-url="tee /dev/tty | rg -o 'https?://(?:[\S]+)[\s]?' | copy"

alias js='node -e '"'"'global.js = require(`${process.env.HOME}/.volta/tools/image/packages/jstat/lib/node_modules/jstat`)'"'"' -i'
# startup jest with debugging + watch mode
alias jest-debug='NODE_OPTIONS="--inspect" ./node_modules/.bin/jest --runInBand --watch nothing'


# Trailing space to tell bash to check next word for alias as well
alias sudo='sudo '


# tmux

function __tss {
  if [ "$TMUX" ]; then
    t_cmd='switch-client'
  else
    t_cmd='attach'
  fi

  if [[ -n "$1" ]]; then
    tmux $t_cmd -t "$1"
  fi
}

function __ts_todos {
  tmux select-window -t "todos:todos"

  t_current_session=$(tmux display -p '#S')
  t_current_session=${t_current_session%\n}
  if [[ "$t_current_session" != "todos" ]]; then
    # switch to "last" (ie last used) session
    # switch to the todos session
    tmux switch-client -t todos
  fi
}

function __ts_journal {
  tmux select-window -t "todos:journal"

  t_current_session=$(tmux display -p '#S')
  t_current_session=${t_current_session%\n}
  if [[ "$t_current_session" != "todos" ]]; then
    # switch to "last" (ie last used) session
    # switch to the todos session
    tmux switch-client -t todos
  fi
}

function __ts_reference {
  tmux select-window -t "todos:reference"

  t_current_session=$(tmux display -p '#S')
  t_current_session=${t_current_session%\n}
  if [[ "$t_current_session" != "todos" ]]; then
    # switch to "last" (ie last used) session
    # switch to the todos session
    tmux switch-client -t todos
  fi
}

# tmux z and if successful rename the window to the current working directory;
# generally nice when that dir is the name of a specific repo
function __tz {
  local selection
  # TODO: fzf --query "$@" except that bash quoting with command substitution is terrible
  selection=$(z -l | fzf)
  path=$(cut <<< "$selection" -d' ' -f 2-)
  _z "$path" && tmux rename-window  "${PWD##*/}"
}

alias t='tmux'
alias ts='tmux display-popup -E -w 80% -h 80% nvim -c ":Telescope tmux windows quit_on_select=true"'
alias tt='tmux switch-client -l'
# TODO: telescope this
alias gz='__tz'

alias 'nvim-debug'='nvim -V12 --cmd "set verbosefile=/tmp/vim.log"'

alias y=yarn
alias nr='npm run'

alias we=watchexec

#}}}

# Useful Env {{{

export NODE_BIGMEM="--max-old-space-size=8192"

#}}}

# Bash CLI {{{

# Use vi-mode (escape to go into “normal” mode and j,k to scroll through
# history, navigate lines with bw, &c.)
set -o vi

# Make bash check its window size after each command, to keep $LINES and
# $COLUMNS correct.
shopt -s checkwinsize

# see https://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
# Don't care about duplicates in history
HISTCONTROL=ignoredups:erasedups
# When shell exits, append to history instead of overwriting
shopt -s histappend
# bash seems to default to 500 histsize
HISTSIZE=50000
HISTFILESIZE=50000

if [[ $(umask) = "0000" ]]; then
  # set a sane umask for wsl
  umask 0022
fi


# https://starship.rs/
eval "$(starship init bash)"

# see https://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# z jumparound; this must be sourced after $PROMPT_COMMAND is set
if [ -f "$SRC/rupa/z/z.sh" ]; then
  source "$SRC/rupa/z/z.sh"
elif [ -f "${HOMEBREW}/Cellar/z/1.9/etc/profile.d/z.sh" ]; then
  source "${HOMEBREW}/Cellar/z/1.9/etc/profile.d/z.sh"
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export FZF_CTRL_T_COMMAND='git branch | cut -c 3-'
export FZF_CTRL_T_OPTS='--preview="git log --decorate=full --color --abbrev-commit origin/master..{}"'

#}}}

# Windows Extra {{{
if uname -a | grep -q Microsoft; then
  alias pbcopy='clip.exe'
  alias pbpaste='powershell.exe Get-Clipboard'

  # Fix the way colors look by default
  if [ -f "$SRC/seebi/dircolors-solarized/dircolors.256dark" ]; then
    eval $(dircolors -b "$SRC/seebi/dircolors-solarized/dircolors.256dark")
  fi


  # autocomplete is not enabled by default in WSL
  if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
  fi

  # If we don't have an ssh agent running, launch one if we're interactive and
  # if we know how
  if [[ ! -r "$SSH_AUTH_SOCK" && $- =~ "i" ]]; then
    eval $(ssh-agent -s)
    echo "ssh agent started; adding default key"
    ssh-add
  fi
fi
#}}}

# OSX Extra {{{

# osx catalina cries about bash if you don't do this.
export BASH_SILENCE_DEPRECATION_WARNING=1
#}}}

if $(which nvim > /dev/null 2>&1); then
  export EDITOR='nvim'
  export GIT_EDITOR='nvim'
fi

# Some things here we only want to do once (eg PATH setup)
export DOTFILES_BASHRC_INIT=1

# vim:set tw=0 fdm=marker:

