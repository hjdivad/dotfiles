#   zshenv
# zprofile
# zshrc
# zlogin
#
#   zshenv
# zshrc

# path sourced in zshenv for agents, cron &c.
# path is also in zshrc to work around impolite system rc, with
# /etc/paths.d

export ZSH_PATHRC="$(dirname "${(%):-%x}")/path.zsh"
source $ZSH_PATHRC
