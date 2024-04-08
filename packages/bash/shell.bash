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

# bash garbage from https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel
#
# get the script DIR
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
BASHRC_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

BASH_LIB="$BASHRC_DIR/lib"

if [ -d /opt/homebrew ]; then
  HOMEBREW="/opt/homebrew"
else
  HOMEBREW="/usr/local"
fi

# This variable is used elsewhere to write an os-agnostic grep either with gnu
# grep installed on macos or it being present on linux systems
if which ggrep > /dev/null 2>&1; then
  GREP=$(which ggrep)
elif [ -x /usr/bin/grep ]; then
  GREP=/usr/bin/grep
fi
export GREP

# Use gnu xargs if possible on osx; on other systems the local xargs will
# already be a reasonable version
if which gxargs > /dev/null 2>&1; then
  XARGS=$(which gxargs)
elif [ -x /usr/bin/grep ]; then
  XARGS=/usr/bin/xargs
fi
export XARGS


function __setup_bash_completion {
  # Homebrew bash completion
  [ -r "${HOMEBREW}/etc/bash_completion" ] && source "${HOMEBREW}/etc/bash_completion"

  # Homebrew bash completion@2
  [[ -d "${HOMEBREW}/etc/bash_completion.d" ]] && export BASH_COMPLETION_COMPAT_DIR="${HOMEBREW}/etc/bash_completion.d"
  [[ -r "${HOMEBREW}/etc/profile.d/bash_completion.sh" ]] && . "${HOMEBREW}/etc/profile.d/bash_completion.sh"

  if [[ -d $HOME/.bash_completion.d ]]; then
    for local_completion in $(ls "$HOME"/.bash_completion.d); do
      source $HOME/.bash_completion.d/$local_completion
    done
  fi


  # If gh exists, add a wrapper that also completes aliases
  which gh > /dev/null 2>&1 && source "$BASH_LIB/gh_completion.sh"
}

function __setup_prompt {
  # https://starship.rs/
  eval "$(starship init bash)"

  # see https://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
}

function __setup_sdks {
  if [[ -n "$(which android > /dev/null 2>&1)" ]]; then
    export ANDROID_HOME=$(dirname $(dirname $(which android)))
  fi

  if [[ -d $HOME/.go ]]; then
    export GOPATH="$HOME/.go"
  fi

  if [ -d "$HOME/apps/google-cloud-sdk/" ]; then
    # The next line updates PATH for the Google Cloud SDK.
    source "$HOME/apps/google-cloud-sdk/path.bash.inc"

    # The next line enables shell command completion for gcloud.
    source "$HOME/apps/google-cloud-sdk/completion.bash.inc"
  fi

  if [[ -x /usr/libexec/java_home ]]; then
    JAVA_HOME=$(/usr/libexec/java_home 2> /dev/null)
    export JAVA_HOME
  fi
}

function __setup_ruby {
  local rbp="${HOME}/.rbenv/shims"
  if [[ -d "${rbp}" ]] && grep -vq "${rbp}" <<<"$PATH" && [[ -x "${HOMEBREW}/bin/rbenv" ]]; then
    eval "$(rbenv init -)"
  fi

  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
}

function __setup_volta {
  # initialize volta
  if [[ -d "$HOME/.volta" ]]; then
    export VOLTA_HOME="$HOME/.volta"
  fi
}

function __prepend_path {
  if [[ -d "$1" ]] && grep -vq "$1" <<<"$PATH"; then
    export PATH="$1:$PATH"
  fi
}

function __setup_unix_cmds {
  # Support colour in pager, tabsize 2 and case insensitive searching.
  export LESS='-R -x2 -i'

  # Always colourize ls output.
  export CLICOLOR=1

  # always create paths when using mkdir.
  alias mkdir='mkdir -p'

  # use exa if it exists
  # https://github.com/ogham/exa
  if which exa > /dev/null 2>&1; then
    alias ls='exa --colour-scale'
    alias ll='exa -l --all --no-user --changed --sort=modified --color-scale'
    alias lt='exa --tree --level 3 -l --no-permissions --no-user --no-time --colour-scale'
  else
    # setup ls
    ls / --color=auto > /dev/null 2>&1
    if [[ $? == 0 ]]; then
      alias ls='ls --color=auto'
    fi
  fi
}

function __setup_env {
  if which nvim > /dev/null 2>&1; then
    export EDITOR='nvim'
    export GIT_EDITOR='nvim'
  fi
}

function __setup_aliases {
  alias lsof-tcp='lsof -iTCP'
  alias lsof-tcp-listen='lsof -iTCP -sTCP:LISTEN -P'

  alias ifconfig-active="ifconfig | pcregrep -M  -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

  # ssh
  alias ssh-no-agent-forwarding='ssh -o "ForwardAgent no"'
  alias ssh-copy-auth-sock='echo -n $SSH_AUTH_SOCK | pbcopy'

  # node ts
  alias node-ts='node --loader ts-node/esm --no-warnings'
  alias node-ts-debug='node --loader ts-node/esm --no-warnings --inspect --watch'
  alias node-ts-test='node --loader ts-node/esm --no-warnings --test'

  # startup jest with debugging + watch mode
  alias jest-debug='NODE_OPTIONS="--inspect" ./node_modules/.bin/jest --runInBand --watch nothing'
  alias vitest-debug='vitest --inspect-brk --threads false --isolate false --single-thread --test-timeout 0'

  # Trailing space to tell bash to check next word for alias as well
  alias sudo='sudo '

  # Update dependencies interactively
  alias npm-check-updates='npx npm-check-updates -i'
  alias nr='npm run'
  alias y=yarn

  # ask user for input
  # e.g. echo $(inp)
  alias inp='read -s -p "Password: " pass; echo $pass'

  alias py='python3'

  # rust
  alias c='cargo'
  alias ct='cargo nextest'
  alias cr='cargo run'

  alias 'nvim-debug'='nvim -V12 --cmd "set verbosefile=/tmp/vim.log"'
  if which watchexec > /dev/null 2>&1; then
    alias we=watchexec
  fi

  if which fd > /dev/null 2>&1; then
    function __pick_dir {
      fd --type directory | fzf
    }

    function __pick_file {
      fd . | fzf
    }

    function __go_to_dir {
      local to_dir=$(__pick_dir)

      if [[ -d "${to_dir}" ]]; then
        cd ${to_dir}
      fi
    }

    # "go directory (with fzf)
    alias gd='__go_to_dir'
    alias pd='__pick_dir'
    alias pf='__pick_file'
  fi

  function __pick_branch {
    git branch | sed 's/^.\{2\}//' | fzf -m --bind 'ctrl-h:clear-query'
  }
  alias pb='__pick_branch'
}

function __setup_clipboard {
  # echo foo | clipboard # copy w/o extra newline
  alias clipboard='tr -d "\n" | pbcopy'

  # cmd | copy-url
  alias copy-url="tee /dev/tty | rg -o 'https?://(?:[\S]+)[\s]?' | clipboard"
}

function __setup_bash_options {
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
}

function __setup_fzf {
  [ -f ~/.fzf.bash ] && source ~/.fzf.bash

  # see https://github.com/junegunn/fzf#custom-fuzzy-completion
  # TODO: bash version of https://github.com/junegunn/fzf/wiki/Examples-(completion)#zsh-complete-git-co-for-example
  #   - branches
  #   - PRs
  #   - objects?
}

function __setup_ssh {
  if [[ -r $HOME/.ssh/ssh_auth_sock ]]; then
    export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock
  fi
}

function __setup_gpg {
  # see <https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html#Invoking-GPG_002dAGENT>
  export GPG_TTY=$(tty)
}

function __setup_pws {
  export ALPHA=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
  export ALPHANUM="$ALPHA"0123456789
  export PWS_CHARPOOL="${ALPHANUM}~@$%^*()_+="
  export PWS_LENGTH=16
  export PWS_SECONDS=60
}

function __setup_tmux {
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

  if which fd > /dev/null 2>&1; then
    function __ts_go_source {
      local to_dir=$(
        fd . --type directory --max-depth 3 "$SRC" |\
        sed s/"${SRC//\//\\\/}\/"//g |\
        sed 's/\/$//g' |\
        fzf\
      )
      if [[ -d $SRC/$to_dir ]]; then
        local window_name=$(__src_rename $to_dir)
        cd $SRC/$to_dir && tmux rename-window "${window_name}"
      fi
    }

    alias gs=__ts_go_source
  fi

  alias t='tmux'
  alias tss='tmux display-popup -E -w 100% -h 100% nvim -c ":Telescope tmux windows quit_on_select=true"'
  alias tst='tmux switch-client -l'
  alias tsd=__ts_todos
  alias tsr=__ts_reference
  alias tsj=__ts_journal
}

function __setup_wsl {
  if [[ $(umask) = "0000" ]]; then
    # set a sane umask for wsl
    umask 0022
  fi


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
}

function __setup_osx {
  # osx catalina cries about bash if you don't do this.
  export BASH_SILENCE_DEPRECATION_WARNING=1
}


export NODE_BIGMEM="--max-old-space-size=16384" # mb

__setup_bash_completion
__setup_prompt
__setup_sdks
__setup_ruby
__setup_volta


__prepend_path "/opt/adt/sdk/tools"
__prepend_path "/opt/adt/eclipse/Eclipse.app/Contents/MacOS"
__prepend_path "$HOME/Library/Android/sdk/platform-tools"
__prepend_path "/Library/TeX/texbin"
[[ -n "$HOMEBREW" ]] && __prepend_path "$HOMEBREW/bin"
__prepend_path "${HOME}/Library/Python/2.7/bin"
__prepend_path "$HOME/Library/Python/3.7/bin"
[[ -n "$GOPATH" ]] && __prepend_path "${GOPATH}/bin"
__prepend_path "$HOME/.cargo/bin"
__prepend_path "$HOME/.bun/bin"
[[ -n "$VOLTA_HOME" ]] && __prepend_path "${VOLTA_HOME}/bin"
[[ -n "$DOTFILES_DIR" ]] && __prepend_path "$DOTFILES_DIR//bin"
__prepend_path "$HOME/.local/bin"

__setup_unix_cmds
__setup_env
__setup_ssh
__setup_gpg
__setup_pws
__setup_clipboard
__setup_aliases
__setup_bash_options
__setup_tmux
__setup_wsl
__setup_fzf
__setup_osx

# vim: tw=0 ft=bash
