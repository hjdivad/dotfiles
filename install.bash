#!/usr/bin/env bash

set -e

# bash garbage from https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel
#
# get the script DIR
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DOTFILES_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
PACKAGES_DIR="$DOTFILES_DIR/packages"


# Find a reasonable grep, i.e. that supports -P
if which ggrep > /dev/null 2>&1; then
  GREP=$(which ggrep)
elif [ -x /usr/bin/grep ]; then
  GREP=/usr/bin/grep
else
  GREP=grep
fi

TMP=$(mktemp -d)
MERGE_ALL=0

if [[ -z "$EDITOR" ]]; then
  for possible_editor in nvim vim nano; do
    if which $possible_editor > /dev/null 2>&1; then
      EDITOR=$possible_editor
      break
    fi
  done
fi

function __merge_conflicting_files {
  local src="$1"
  local dst="$2"

  local fname=$(basename $dst)
  local fname=$(basename $dst)
  local tmpf=$TMP/$fname

  cat <<< "<<<<<<< existing:$fname" > $tmpf
  cat $dst >> $tmpf
  cat <<< "=======" >> $tmpf
  cat $src >> $tmpf
  cat <<< ">>>>>>> new:$fname" >> $tmpf
  local tmpf=$TMP/$fname

  cat <<< "<<<<<<< existing:$fname" > $tmpf
  cat $dst >> $tmpf
  cat <<< "=======" >> $tmpf
  cat $src >> $tmpf
  cat <<< ">>>>>>> new:$fname" >> $tmpf

  $EDITOR $tmpf

  echo "Writing $dst"
  cp $tmpf $dst
}

function __copy_with_merge {
  local src="$1"
  local dst="$2"

  if [[ ! -f "$dst" ]]; then
    echo "Writing $dst"
    cp $src $dst
    return
  elif diff -sq "$src" "$dst" > /dev/null 2>&1; then
    echo "Skipping $dst (file exists)"
    return
  fi

  if [[ "$MERGE_ALL" == "1" ]]; then
    __merge_conflicting_files "$src" "$dst"
  fi

  local choice

  echo -e "\n\nConflict! $dst already exists. What to do?"
  select choice in \
    "Merge files and resolve conflicts with EDITOR ($EDITOR)" \
    'Merge file and all future conflicts' \
    'Overwrite existing file' \
    'Skip file'
  do
    case $choice in
      "Merge files and resolve conflicts with EDITOR ($EDITOR)")
        __merge_conflicting_files "$src" "$dst"
        break;
        ;;
      'Merge file and all future conflicts')
        MERGE_ALL=1
        __merge_conflicting_files "$src" "$dst"
        break;
        ;;
      'Overwrite existing file')
        echo "Writing $dst"
        cp $src $dst
        break;
        ;;
      'Skip file')
        echo "skipping $dst"
        break;
        ;;
      *) echo "invalid option $REPLY"
    esac
  done
}

function __symlink {
  local src="$1"
  local dst="$2"

  if [[ -e "$dst" ]] || [[ -L "$dst" ]] ; then
    if [[ -L "$dst" ]] && [[ $(readlink $dst) == "$src" ]] ; then
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

function __copy_with_transform_and_merge {
  local template="$1"
  local dst="$2"

  local sed_cmds=()
  for sed_cmd in ${@:3}; do
    sed_cmds+=" -e $sed_cmd"
  done

  local src=$(mktemp)
  sed $sed_cmds $template > $src
  __copy_with_merge "$src" "$dst"
}

function __copy_from_template_with_merge {
  local src="$1"
  local dst="$2"
  local PKG="$3"

  __copy_with_transform_and_merge "$src" "$dst" \
    s/#\$PKG/"${PKG//\//\\/}"/g \
    s/#\$DOTFILES/"${DOTFILES_DIR//\//\\/}"/g
}

function __install_bash_config () {
  local PKG="${PACKAGES_DIR}/bash"

  __copy_with_merge "$PKG/bash_logout" "$HOME/.bash_logout"
  __copy_with_merge "$PKG/bash_profile" "$HOME/.bash_profile"

  __copy_from_template_with_merge "$PKG/bashrc" "$HOME/.bashrc" "$PKG"
}

function __install_shell_extra {
  local PKG="${DOTFILES_DIR}/packages/shell"

  __symlink "$PKG/inputrc" "$HOME/.inputrc"
  __copy_with_merge "$PKG/profile" "$HOME/.profile"
}

function __mk_dirs {
  mkdir -p "$HOME/.config"
}

function __install_git_config {
  local PKG="${PACKAGES_DIR}/git"
  __symlink "$PKG/config" "$HOME/.config/git"

  __copy_from_template_with_merge "$PKG/gitconfig" "$HOME/.gitconfig"  $PKG
}

# TODO: preflight_checklist
#   volta homebrew neovim starship

__mk_dirs
__install_bash_config
__install_shell_extra
__install_git_config
__symlink "$PACKAGES_DIR/kitty/config" "$HOME/.config/kitty"
__symlink "$PACKAGES_DIR/nvim/config" "$HOME/.config/nvim"
__symlink "$PACKAGES_DIR/ssh/rc" "$HOME/.ssh/rc"
__symlink "$PACKAGES_DIR/starship/config/starship.toml" "$HOME/.config/starship.toml"
__symlink "$PACKAGES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

exit 0

# vim: ft=bash
