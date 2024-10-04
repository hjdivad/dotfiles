# zshenv
# zprofile  - login
#   zshrc   - interactive
# zlogin
#
# zshenv
#   zshrc

function __path_add() {
  case ":$PATH:" in
    *:"$1":*) ;;
    *) PATH="$1${PATH+:$PATH}" ;;
  esac
  export PATH
}

function __path_remove() {
  case ":$PATH:" in
    *:"$1":*)
      PATH=$(echo ":$PATH:" | sed "s,:$1:,," | sed 's/^://;s/:$//')
      ;;
  esac
  export PATH
}


export VOLTA_HOME="$HOME/.volta"
__path_add "$VOLTA_HOME/bin"


# set up rust
if [[ -r "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi
alias c='cargo'
alias ct='cargo nextest'
alias cr='cargo run'


# set up nvim
alias 'nvim-debug'='nvim -V12 --cmd "set verbosefile=/tmp/vim.log"'
set -o vi


# set up fzf
# c.f. <https://github.com/rwjblue/dotfiles/blob/master/zsh/plugins/fzf.zsh>
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh

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
fi


# set up unixy defaults
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ensure we use a stable SSH_AUTH_SOCK (so reconnecting to prior tmux sessions
# continue to be able to auth)

if [[ -r $HOME/.ssh/ssh_auth_sock ]]; then
  export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock
fi

# always create paths when using mkdir.
alias mkdir='mkdir -p'

# List TCP listen sockets
alias lsof-tcp-listen='lsof -iTCP -sTCP:LISTEN -P'
alias lsof-tcp='lsof -iTCP'

# List only active network devices
alias ifconfig-active="ifconfig | rg --color=never -U '^[^\t:]+:([^\n]|\n\t)*status: active'"

alias ssh-no-agent-forwarding='ssh -o "ForwardAgent no"'
alias ssh-copy-auth-sock='echo -n $SSH_AUTH_SOCK | pbcopy'

function __path() {
  echo $PATH | rg : -r $'\n'
}
alias path=__path

# use eza if it exists
# https://github.com/eza-community/eza (replacement for https://github.com/ogham/exa)
if which eza > /dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -l --all --no-user --changed --sort=modified'
  alias lt='eza --tree --level 3 -l --no-permissions --no-user --no-time'
else
  # setup ls
  ls / --color=auto > /dev/null 2>&1
  if [[ $? == 0 ]]; then
    alias ls='ls --color=auto'
  fi
fi

if which gron > /dev/null 2>&1; then
  function __qj() {
    gron "$@" | fzf
  }
  alias qj='__qj'

  # FIXME: This doesn't work.
  #
  # function _qj() {
  #   _files
  # }
  # compdef _qj qj
fi

# Support colour in pager, tabsize 2 and case insensitive searching.
export LESS='-R -x2 -i'

# Always colourize ls output.
export CLICOLOR=1

# go-task
alias tt=task

if which watchexec > /dev/null 2>&1; then
  alias we=watchexec
fi

if which pandoc > /dev/null 2>&1; then
  alias md2jira='pandoc --from=markdown --to=jira'
fi

# echo foo | clipboard # copy w/o extra newline
alias clipboard='tr -d "\n" | pbcopy'

# cmd | copy-url
alias copy-url="tee /dev/tty | rg -o 'https?://(?:[\S]+)[\s]?' | clipboard"


# set up gpg
# see <https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html#Invoking-GPG_002dAGENT>
export GPG_TTY=$(tty)


# CMD: starship init zsh
# CMD: zoxide init zsh


# set up homebrew
# Don't use CMD: brew shellenv because brew shellenv is nuts and inlines $PATH
# at the time of execution
#
# Stop homebrew forom telling me about configuring frequency of auto-updates
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";


# set up pws
export ALPHA="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
export ALPHANUM="${ALPHA}0123456789"
export PWS_CHARPOOL="${ALPHANUM}~@$%^*()_+="
export PWS_LENGTH=16
export PWS_SECONDS=60


# set up android
if [[ -n "$(which android > /dev/null 2>&1)" ]]; then
  export ANDROID_HOME=$(dirname $(dirname $(which android)))
fi


# set up node
export NODE_BIGMEM="--max-old-space-size=16384" # mb

# Update dependencies interactively
alias npm-check-updates='npx npm-check-updates -i'
alias nr='npm run'


# pyenv is _sooooo_ slow so we only want to run it when we actually need it
function pyenv_init() {
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

  unalias pyenv

  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"

  echo "pyenv initialized; re-run your command"
}
alias pyenv=pyenv_init

function rbenv_init {
  eval "$(rbenv init -)"

  unalias gem
  unalias ruby
  unalias pws
  unfunction rbenv_init

  echo "rbenv init ran; re-run your command"
}

alias gem=rbenv_init
alias ruby=rbenv_init
alias pws=rbenv_init


# setup wsl
if [ $(umask) = "0000" ]; then
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

  # If we don't have an ssh agent running, launch one if we're interactive and
  # if we know how
  if [[ ! -r "$SSH_AUTH_SOCK" && $- =~ "i" ]]; then
    eval $(ssh-agent -s)
    echo "ssh agent started; adding default key"
    ssh-add
  fi
fi


# setup tmux
# see <https://github.com/rwjblue/dotfiles/blob/master/zsh/plugins/tmux.zsh>
TODOS="📋 todos"

function __ts_todos {
  tmux select-window -t "${TODOS}:todos"

  t_current_session=$(tmux display -p '#S')
  t_current_session=${t_current_session%\n}
  if [[ "$t_current_session" != "${TODOS}" ]]; then
    # switch to "last" (ie last used) session
    # switch to the todos session
    tmux switch-client -t "${TODOS}"
  fi
}

function __ts_journal {
  tmux select-window -t "${TODOS}:journal"

  t_current_session=$(tmux display -p '#S')
  t_current_session=${t_current_session%\n}
  if [[ "$t_current_session" != "${TODOS}" ]]; then
    # switch to "last" (ie last used) session
    # switch to the todos session
    tmux switch-client -t "${TODOS}"
  fi
}

function __ts_reference {
  tmux select-window -t "${TODOS}:reference"

  t_current_session=$(tmux display -p '#S')
  t_current_session=${t_current_session%\n}
  if [[ "$t_current_session" != "${TODOS}" ]]; then
    # switch to "last" (ie last used) session
    # switch to the todos session
    tmux switch-client -t "${TODOS}"
  fi
}

if which fd > /dev/null 2>&1; then
  function __ts_go_source {
    local to_dir=$(
      fd . --type directory --max-depth 3 "$HOME/src" |\
      sd "$HOME/src/" '' |\
      sd "/$" '' |\
      fzf\
    )

    if [[ -n "$to_dir" && -d $HOME/src/$to_dir ]]; then
      cd $HOME/src/$to_dir
      if [[ -n $TMUX ]]; then
        local window_name=$(
          echo "$to_dir" |\
          sd "hjdivad/" ''
        )
        tmux rename-window "${window_name}"
      fi
    fi
  }

  alias gs=__ts_go_source
fi

alias t='tmux'
alias tss='tmux display-popup -E -w 100% -h 100% nvim -c "lua require('"'"'hjdivad_util.tmux'"'"').goto_fzf_tmux_session({ quit_on_selection=true })"'
alias tst='tmux switch-client -l'
alias tsd=__ts_todos
alias tsr=__ts_reference
alias tsj=__ts_journal


# This is infuriating. However, /etc/zprofile invokes path_helper which reads 
# /etc/paths.d/ which contains a file that includes /opt/homebrew/bin and
# another file that contains a conflicting path.  The order is incorrect which
# is why I must force a duplication of /opt/homebrew/bin onto PATH.
__path_remove "/opt/homebrew/bin"
__path_add "/opt/homebrew/bin"
__path_add "/opt/homebrew/sbin"
# TODO: add this to template/zshrc
__path_add "$HOME/src/github/malleatus/shared_binutils/global/target/debug"
__path_add "$HOME/src/github/hjdivad/dotfiles/packages/binutils/crates/global/target/debug"
__path_add "$HOME/src/github/hjdivad/dotfiles/local-packages/crates/global/target/debug"
__path_add "$HOME/.local/bin"


# set up zsh completions
# see <https://github.com/sorin-ionescu/prezto/blob/9195b66161b196238cbd52a8a4abd027bdaf5f73/modules/completion/init.zsh#L32-L40>
#
# FETCH: https://raw.githubusercontent.com/sorin-ionescu/prezto/master/modules/completion/init.zsh
#
unsetopt AUTO_MENU # Don't show menu when spamming <tab>
fpath=( "/opt/homebrew/share/zsh/site-functions" $fpath )
fpath=( "$HOME/.zsh/completions" $fpath )
autoload -Uz compinit
compinit

