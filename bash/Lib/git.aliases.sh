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

_git_camm() {
  _git_commit $@
}

__git_pull_refs() {
	local dir="$(__gitdir)"
	if [ -d "$dir" ]; then
		git --git-dir="$dir" for-each-ref --format='%(refname:short)' \
			refs/pull-requests | sed 's/^pull-requests\///'
		return
	fi
}

_git_cpr() {
  __gitcomp_nl "$(__git_pull_refs)"
}
