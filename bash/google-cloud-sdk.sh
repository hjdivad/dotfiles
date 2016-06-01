if [ -d "$HOME/apps/google-cloud-sdk/" ]; then
	# The next line updates PATH for the Google Cloud SDK.
	source "$HOME/apps/google-cloud-sdk/path.bash.inc"

	# The next line enables shell command completion for gcloud.
	source "$HOME/apps/google-cloud-sdk/completion.bash.inc"
fi

