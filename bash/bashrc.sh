BASH="$HOME/.dotfiles/bash/Lib"
SRC="$HOME/src"

source $BASH/git.aliases.sh
source $BASH/git-completion.sh

# Homebrew completion
[ -r /usr/local/etc/bash_completion ] && source /usr/local/etc/bash_completion
[ -r "$SRC/alacritty/alacritty/extra/completions/alacritty.bash" ] && source "$SRC/alacritty/alacritty/extra/completions/alacritty.bash"

source $BASH/colours.sh

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

  export NODE_PATH=/usr/local/lib/jsctags/:$NODE_PATH
fi

#}}}

# Version Mgmt {{{

# initialize rbenv
if [[ -z "$DOTFILES_BASHRC_INIT" && -x /usr/local/bin/rbenv ]]; then
  eval "$(rbenv init -)"
fi

# initialize volta
if [[ -z "$DOTFILES_BASHRC_INIT" && -d "$HOME/.volta" ]]; then
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
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
  
  if [ -d $HOME/Library/Python/2.7/bin ]; then
    export PATH=$PATH:$HOME/Library/Python/2.7/bin
  fi
  
  if [ -d $HOME/Library/Python/3.7/bin ]; then
    export PATH=$PATH:$HOME/Library/Python/3.7/bin
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
  
  export PATH=/usr/local/bin:$PATH
  export PATH=/usr/local/share/npm/bin:$PATH
  export PATH=$HOME/local/bin:$PATH
  export PATH=$HOME/.cargo/bin:$PATH
  export PATH=$HOME/.dotfiles/bin:$PATH
  export PATH=$HOME/bin:$PATH
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
export PWS_SECONDS=60

if [[ -r $HOME/.ssh/ssh_auth_sock ]]; then
  export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock
fi

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
  t_current_session=$(tmux display -p '#S')
  t_current_session=${t_current_session%\n}
  if [[ "$t_current_session" == "todos" ]]; then
    # switch to "last" (ie last used) session
    tmux switch-client -l
  else
    # switch to the todos session
    tmux switch-client -t todos
  fi
}

# tmux z and if successful rename the window to the current working directory;
# generally nice when that dir is the name of a specific repo
function __tz {
  _z $@ && tmux rename-window  "${PWD##*/}"
}

function __ts {
  # set IFS to loop over sessions with spaces
  IFS=$'\n'
  local sessions
  if local result=$(tmux ls -F '#{session_name}' 2>&1); then
    sessions=$result
  else
    echo $result
    return 1
  fi

  local choices=''
  local delim=' ' # non-breaking space, not a regular space!
  for session in $sessions; do
    local windows=$(tmux list-windows -t "$session" -F '#{window_name} #{window_id}')
    for window in $windows; do
      choices=$choices$session$delim$window$'\n'
    done
  done

  if local selection=$(printf "$choices" | fzf); then
    local selected_session=$(cut -d$delim -f 1 <<<$selection)
    local selected_window=$(cut -d$delim -f 2 <<<$selection)
    local selected_window_id=$(cut -d$delim -f 3 <<<$selection)
    tmux select-window -t "$selected_session"':'"$selected_window_id"
    __tss $selected_session
  fi
}

alias t='tmux'
alias ts='__ts'
alias tt='__ts_todos'
# alias tw='tmux list-windows | fzf  | cut -d':" -f 1 | $XARGS -r tmux select-window -t"
alias gz='__tz'

alias 'nvim-debug'='nvim -V12 --cmd "set verbosefile=/tmp/vim.log"'

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
elif [ -f /usr/local/Cellar/z/1.9/etc/profile.d/z.sh ]; then
  source /usr/local/Cellar/z/1.9/etc/profile.d/z.sh
fi

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

