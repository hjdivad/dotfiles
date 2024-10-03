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

# Update dependencies interactively
alias npm-check-updates='npx npm-check-updates -i'
alias nr='npm run'

# go-task
alias tt=task

# rust
alias c='cargo'
alias ct='cargo nextest'
alias cr='cargo run'

alias 'nvim-debug'='nvim -V12 --cmd "set verbosefile=/tmp/vim.log"'

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
