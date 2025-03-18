#!/bin/zsh

link_dotfile() {
  local DOTFILES_DIR=$1
  local SRC=$2
  local DEST_PATH=$3
  local FORCE=$4

  local SRC_PATH="${DOTFILES_DIR}/${SRC}"

  # Check if source exists
  if [ ! -e "$SRC_PATH" ]; then
    echo "Source file $SRC_PATH not found, skipping link creation."
    return 0
  fi

  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$DEST_PATH")"

  # If FORCE is true, remove the target
  if [ "$FORCE" = "true" ]; then
    rm -rf "$DEST_PATH"
  fi

  if [ -L "$DEST_PATH" ]; then
    current=$(readlink "$DEST_PATH")

    # Check if it's a broken symlink
    if [ ! -e "$current" ]; then
      echo "$DEST_PATH is a broken symlink, replacing it"
      rm "$DEST_PATH"
      ln -s "$SRC_PATH" "$DEST_PATH"
    elif [ "$current" != "$SRC_PATH" ]; then
      echo "$DEST_PATH already exists and is symlinked to $current"
    fi
  elif [ -e "$DEST_PATH" ]; then
    echo "$DEST_PATH already exists and is not a symlink"
  else
    echo "creating link for $DEST_PATH"
    ln -s "$SRC_PATH" "$DEST_PATH"
  fi
}

# Parse command-line arguments
DOTFILES_DIR=""
SRC=""
DEST_PATH=""
FORCE="false"

while [[ $# -gt 0 ]]; do
  case $1 in
  --dotfiles-dir)
    DOTFILES_DIR="$2"
    shift 2
    ;;
  --src)
    SRC="$2"
    shift 2
    ;;
  --dest)
    DEST_PATH="$2"
    shift 2
    ;;
  --force)
    FORCE="true"
    shift
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

# Validate required arguments
if [[ -z "$DOTFILES_DIR" || -z "$SRC" || -z "$DEST_PATH" ]]; then
  echo "Usage: $0 --dotfiles-dir DOTFILES_DIR --src SRC --dest DEST [--force]"
  exit 1
fi

# Call the function with parsed arguments
link_dotfile "$DOTFILES_DIR" "$SRC" "$DEST_PATH" "$FORCE"
