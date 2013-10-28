# Always colourize ls output.
export CLICOLOR=1

ls / --color=auto > /dev/null 2>&1
if [[ $? == 0 ]]; then
  alias ls='ls --color=auto'
fi
