if [[ -n "$(which android)" ]]; then
  export ANDROID_HOME=$(dirname $(dirname $(which android)))
fi
