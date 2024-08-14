# see <https://github.com/rwjblue/dotfiles/blob/master/zsh/plugins/tmux.zsh>

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
