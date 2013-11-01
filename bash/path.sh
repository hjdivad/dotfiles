export PATH=$HOME/.dotfiles/bin:$HOME/bin:/usr/local/bin:/usr/local/share/python:/usr/local/share/npm/bin:$PATH

# Android SDK
if [ -d /opt/adt/sdk/platform-tools ]; then
  export PATH=$PATH:/opt/adt/sdk/platform-tools
fi

if [ -d /opt/adt/sdk/tools ]; then
  export PATH=$PATH:/opt/adt/sdk/tools
fi
