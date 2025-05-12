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

export CARGO_HOME="$HOME/.cargo"

__ensure_first_path "/opt/homebrew/bin"
__ensure_first_path "/opt/homebrew/sbin"
if command -v volta > /dev/null 2>&1; then
  export VOLTA_HOME="$HOME/.volta"
  __ensure_first_path "$VOLTA_HOME/bin"
fi
__ensure_first_path "$CARGO_HOME/bin"
__ensure_first_path "$HOME/src/github/malleatus/shared_binutils/global/target/debug"
__ensure_first_path "$HOME/src/github/hjdivad/dotfiles/packages/binutils/crates/global/target/debug"
# org global added in $HOME/.zshrc.local
__ensure_first_path "$HOME/.local/bin"


# this is not using the `# CMD:` system because it captures `$PATH` at the time
# it is ran, and we don't want to do that (it needs to be capturing `$PATH` at
# shell startup time not when we build packages-dist)
eval "$(mise activate zsh)"
