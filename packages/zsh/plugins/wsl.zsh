if [ $(umask) = "0000" ]; then
  # set a sane umask for wsl
  umask 0022
fi


if uname -a | grep -q Microsoft; then
  alias pbcopy='clip.exe'
  alias pbpaste='powershell.exe Get-Clipboard'

  # Fix the way colors look by default
  if [ -f "$SRC/seebi/dircolors-solarized/dircolors.256dark" ]; then
    eval $(dircolors -b "$SRC/seebi/dircolors-solarized/dircolors.256dark")
  fi


  # autocomplete is not enabled by default in WSL
  if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
  fi

  # If we don't have an ssh agent running, launch one if we're interactive and
  # if we know how
  if [[ ! -r "$SSH_AUTH_SOCK" && $- =~ "i" ]]; then
    eval $(ssh-agent -s)
    echo "ssh agent started; adding default key"
    ssh-add
  fi
fi
