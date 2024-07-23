#!/usr/bin/env zsh

# /etc/zsh/zshenv
# $HOME/.zshenv - environment variables
#
# /etc/zsh/zprofile
# $HOME/.zprofile - login configurations
#
# /etc/zsh/zshrc
# $HOME/.zshrc - interactive shell configurations
#
# /etc/zsh/zlogin
# $HOME/.zlogin - login configurations

(

  local DOTFILES="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  local DOTFILES_RELATIVE="${DOTFILES/#$HOME\//}"
  local PKG="$DOTFILES/packages"


  function link_dotfile {
    local src="$1"
    local dst="$2"

    if [[ -e "$dst" ]] || [[ -L "$dst" ]] ; then
      if [[ -L "$dst" ]] && [[ $(readlink "$dst") == "$src" ]] ; then
        echo "Skipping $dst (symlink exists)"
        return
      fi

      echo -e "\n\nConflict! $dst exists but is not a symlink to $src. What to do?"
      # TODO: handle conflicts
      echo "TODO: resolve these conflicts"
      return
    fi

    ln -s "$src" "$dst"
  }

  function merge_conflicting_file {
    local src="$1"
    local dst="$2"

    local fname=$(basename "$dst")
    local tmpf="$TMPDIR/$fname"

    cat <<< "<<<<<<< existing:$fname" > "$tmpf"
    cat "$dst" >> "$tmpf"
    cat <<< "=======" >> "$tmpf"
    cat "$src" >> "$tmpf"
    cat <<< ">>>>>>> new:$fname" >> "$tmpf"

    $EDITOR "$tmpf"

    echo "Writing $dst"
    cp "$tmpf" "$dst"
  }

  function copy_with_merge {
    local src="$1"
    local dst="$2"

    if [[ ! -f "$dst" ]]; then
      echo "Writing $dst"
      cp "$src" "$dst"
      return
    elif diff -sq "$src" "$dst" > /dev/null 2>&1; then
      echo "Skipping $dst (file exists)"
      return
    fi

    if [[ "$MERGE_ALL" == "1" ]]; then
      merge_conflicting_file "$src" "$dst"
      return
    fi

    local choice

    echo -e "\n\nConflict! $dst already exists. What to do?"
    select choice in \
      "Merge files and resolve conflicts with EDITOR / $EDITOR" \
      'Merge file and all future conflicts' \
      'Overwrite existing file' \
      'Skip file'
    do
      case "$choice" in
        "Merge files and resolve conflicts with EDITOR / $EDITOR")
          merge_conflicting_file "$src" "$dst"
          break
          ;;
        'Merge file and all future conflicts')
          MERGE_ALL=1
          merge_conflicting_file "$src" "$dst"
          break
          ;;
        'Overwrite existing file')
          echo "Writing $dst"
          cp "$src" "$dst"
          break
          ;;
        'Skip file')
          echo "Skipping $dst"
          break
          ;;
        *) echo "Invalid option $REPLY"
      esac
    done
  }

  function copy_template_with_merge {
    local src="$1"
    local dst="$2"

    local name=$(basename "$src")
    local rendered=$(mktemp -t "$name")

    cat "$src" | \
      sd '\$DOTFILES_RELATIVE' "$DOTFILES_RELATIVE" |\
      sd '\$DOTFILES' "$DOTFILES" \
      > "$rendered"

    copy_with_merge "$rendered" "$dst"
  }


  function preamble {
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"
  }

  function install_zsh_config {
    local ZSH="$PKG/zsh"

    link_dotfile "$ZSH" "$HOME/.zsh"
    copy_template_with_merge "$ZSH/template/zlogin" "$HOME/.zlogin"
    copy_template_with_merge "$ZSH/template/zshenv" "$HOME/.zshenv"
    copy_template_with_merge "$ZSH/template/zprofile" "$HOME/.zprofile"
    copy_template_with_merge "$ZSH/template/zshrc" "$HOME/.zshrc"
  }

  function install_shell_config {
    link_dotfile "$PKG/shell/sheldon" "$HOME/.config/sheldon"
    link_dotfile "$PKG/shell/inputrc" "$HOME/.inputrc"
  }

  function install_git_config {
    local GIT="$PKG/git"
    
    link_dotfile "$GIT/config" "$HOME/.config/git"
    copy_template_with_merge "$GIT/template/gitconfig" "$HOME/.gitconfig"
  }

  # TODO: preflight checklist brew

  preamble

  install_zsh_config
  install_shell_config
  install_git_config

  link_dotfile "$PKG/kitty/config" "$HOME/.config/kitty"
  link_dotfile "$PKG/nvim/config" "$HOME/.config/nvim"
  link_dotfile "$PKG/ssh/rc" "$HOME/.ssh/rc"
  link_dotfile "$PKG/starship/config/starship.toml" "$HOME/.config/starship.toml"
  link_dotfile "$PKG/tmux/tmux.conf" "$HOME/.tmux.conf"

  exit 0
)
