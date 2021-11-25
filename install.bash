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
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"


# Find a reasonable grep, i.e. that supports -P
if which ggrep > /dev/null 2>&1; then
  GREP=$(which ggrep)
elif [ -x /usr/bin/grep ]; then
  GREP=/usr/bin/grep
else
  GREP=grep
fi

# Gather files 
cd $DIR
ALL_FILES=$(git ls-tree -r --name-only HEAD home)
ALL_SYMLINKS=$(echo "$ALL_FILES" | $GREP -oP '.*(?=\.symlink)' | uniq)
ALL_COPYS=$(echo "$ALL_FILES" | $GREP -oP '.*(?=\.copy)')


# Create symlinks for files that we want to update when we
# update the repo, and that aren't expected to have
# local changes
for symlink in $ALL_SYMLINKS; do
  # strip leading "/home" from symlink we're creating
  HOME_FILE="$HOME/${symlink:5}"
  ABS_PATH="$DIR/${symlink}.symlink"

  [[ ! -r "$HOME_FILE" ]] && ln -s $ABS_PATH $HOME_FILE
done


# Copy files that might get local changes
for copy in $ALL_COPYS; do
  # strip leading "/home" from the file we're copying to
  HOME_FILE="$HOME/${copy:5}"
  ABS_PATH="$DIR/${copy}.copy"

  [[ ! -r "$HOME_FILE" ]] && cp -r $ABS_PATH $HOME_FILE
done

# link $HOME/.dotfiles to this repo as some of the 
[[ ! -r "$HOME/.dotfiles" ]] && ln -s $DIR $HOME/.dotfiles

exit 0
