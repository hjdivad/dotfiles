# mvim has a terminal mode which seems to be a pretty good way of getting a
# proper vim build on the terminal.
which mvim > /dev/null 2>&1 && alias vim='mvim -v'

alias 'debug-vim'='vim -V12 --cmd "set verbosefile=/tmp/vim.log"'
