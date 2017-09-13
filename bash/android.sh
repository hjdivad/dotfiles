if [[ -n "$(which android > /dev/null 2>&1)" ]]; then
  export ANDROID_HOME=$(dirname $(dirname $(which android)))
fi
