if [[ -n "$__PATH_RESET" ]]; then
  path=$__PATH_RESET
else
  path=$PATH
  export __PATH_RESET=$path
fi
export PATH=$HOME/.dotfiles/bin:$HOME/bin:/usr/local/bin:/usr/local/share/npm/bin:$path

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

# vim:set tw=0:
