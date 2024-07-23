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

