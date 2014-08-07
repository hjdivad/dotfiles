# Sensible defaults for grep (recursive, case-insensitive)
alias gi='grep -r -i --color'

# Add line numbers.
alias gin='grep -r -i -n --color'

# Grep with perl regex.
which ggrep > /dev/null &&\
  alias gp='ggrep -r -P --color' ||\
  alias gp='grep -r -P --color'

# Grep git repo.
alias gg='git grep --untracked'
