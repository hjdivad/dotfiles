alias t='tmux'
alias ts='tmux list-sessions | fzf  | cut -d':' -f 1 | xargs tmux switch-client -t'
alias tw='tmux list-windows | fzf  | cut -d':' -f 1 | xargs tmux select-window -t'

