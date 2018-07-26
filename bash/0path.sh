if [[ -n "$__PATH_RESET" ]]; then
  path=$__PATH_RESET
else
  path=$PATH
  export __PATH_RESET=$path
fi

# Android SDK
if [ -d $HOME/Library/Android/sdk/platform-tools ]; then
  export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
fi

if [ -d /opt/adt/sdk/tools ]; then
  export PATH=$PATH:/opt/adt/sdk/tools
fi

if [ -d /opt/adt/eclipse/Eclipse.app/Contents/MacOS ]; then
  export PATH=$PATH:/opt/adt/eclipse/Eclipse.app/Contents/MacOS
fi

if [ -d /Library/TeX/texbin ]; then
  export PATH=$PATH:/Library/TeX/texbin
fi

if which yarn > /dev/null 2>&1; then
  export PATH=$PATH:$(yarn global bin)
fi

# This variable is used elsewhere to write an os-agnostic grep either with gnu
# grep installed on macos or it being present on linux systems
if which ggrep > /dev/null 2>&1; then
  export GREP=$(which ggrep)
elif [ -x /usr/bin/grep ]; then
  export GREP=/usr/bin/grep
fi

export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/share/npm/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.notion/bin:$PATH
export PATH=$HOME/.notion/shim:$PATH
export PATH=$HOME/.dotfiles/bin:$path
export PATH=$HOME/bin:$PATH

# vim:set tw=0:
