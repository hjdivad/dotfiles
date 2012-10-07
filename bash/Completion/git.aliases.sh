#!bash
#
# Additional completions for git.  This file must be sourced before standard
# git completion.  Git will look for  _git_<command>

_git_wm() {
  _git_branch $@
}

_git_ca() {
  _git_commit $@
}

_git_cam() {
  _git_commit $@
}
