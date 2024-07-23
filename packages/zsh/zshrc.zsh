# zshenv
# zprofile  - login
#   zshrc   - interactive
# zlogin
#
# zshenv
#   zshrc

function path_add() {
  case ":$PATH:" in
    *:"$1":*) ;;
    *) PATH="$1${PATH+:$PATH}" ;;
  esac
  export PATH
}

path_add "/opt/homebrew/bin"
path_add "/opt/homebrew/sbin"

export VOLTA_HOME="$HOME/.volta"
path_add "$VOLTA_HOME/bin"

if [[ -r "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi

path_add "$HOME/.local/bin"


eval "$(sheldon source)"

set -o vi
