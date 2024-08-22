# disabled brew shellenv because homebrew always unshifts to the path, taking
# precedence over $HOME/.local/bin
#
## CMD: brew shellenv

export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
[ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

# Stop homebrew forom telling me about configuring frequency of auto-updates
export HOMEBREW_NO_ENV_HINTS=1
