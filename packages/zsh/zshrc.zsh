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

# TODO: add this to template/zshrc
path_add "$HOME/src/github/hjdivad/dotfiles/local-packages/crates/global/target/debug"
path_add "$HOME/src/github/hjdivad/dotfiles/packages/binutils/crates/global/target/debug"
path_add "$HOME/src/github/malleatus/shared_binutils/global/target/debug"
path_add "$HOME/.local/bin"


# TODO: enable once this bug is fixed
#
# Disabled because it doesn't work; probably due to a race condition
# sheldon source reads zsh/dist but it races with the other CMDs
#
## CMD: sheldon source
eval "$(sheldon source)"

set -o vi
