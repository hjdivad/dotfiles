# sourced by zshenv and zshrc

function __path_add() {
  case ":$PATH:" in
    *:"$1":*) ;;
    *) PATH="$1${PATH+:$PATH}" ;;
  esac
  export PATH
}

function __path_remove() {
  if which sd > /dev/null 2>&1; then
    case ":$PATH:" in
      *:"$1":*)
        PATH=$(echo ":$PATH:" | sd ":$1:" ":" | sd '^:' '' | sd ':$' '')
        ;;
    esac
    export PATH
  fi
}

function __ensure_first_path() {
  __path_remove $1
  __path_add $1
}

export VOLTA_HOME="$HOME/.volta"
export CARGO_HOME="$HOME/.cargo"

__ensure_first_path "/opt/homebrew/bin"
__ensure_first_path "/opt/homebrew/sbin"
__ensure_first_path "$VOLTA_HOME/bin"
__ensure_first_path "$CARGO_HOME/bin"
# TODO: add this to template/zshrc
__ensure_first_path "$HOME/src/github/malleatus/shared_binutils/global/target/debug"
__ensure_first_path "$HOME/src/github/hjdivad/dotfiles/packages/binutils/crates/global/target/debug"
# org global added in $HOME/.zshrc.local
__ensure_first_path "$HOME/.local/bin"
