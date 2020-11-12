#!/usr/bin/env bash

_gh_completion_with_aliases() {
  # if gh call super and add extra
  __start_gh
  aliases=$(gh alias list | cut -d: -f 1)
  matching_aliases=$(compgen -W "$aliases" "${COMP_WORDS[1]}")
  COMPREPLY+=($matching_aliases)
}

complete -F _gh_completion_with_aliases gh
