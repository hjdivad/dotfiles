include Makefile.ci

MAKEFILE_HELP_GREP := 'Makefile.ci'

# check https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
NC = \033[0m
ERR = \033[31;1m
TAB := '%-20s' # Increase if you have long commands

# tput colors
red := $(shell tput setaf 1)
green := $(shell tput setaf 2)
yellow := $(shell tput setaf 3)
blue := $(shell tput setaf 4)
cyan := $(shell tput setaf 6)
cyan80 := $(shell tput setaf 86)
grey500 := $(shell tput setaf 244)
grey300 := $(shell tput setaf 240)
bold := $(shell tput bold)
underline := $(shell tput smul)
reset := $(shell tput sgr0)


.PHONY: help
.DEFAULT_GOAL := help

help:
	@printf '\n'
	@printf '    $(underline)$(grey500)Available make commands:$(reset)\n\n'
	@# Print non-check commands with comments
	@grep -E '^([a-zA-Z0-9_-]+\.?)+:.+#.+$$' $(MAKEFILE_HELP_GREP) \
		| grep -v '^check-' \
		| grep -v '^env-' \
		| grep -v '^arg-' \
		| sed 's/:.*#/: #/g' \
		| awk 'BEGIN {FS = "[: ]+#[ ]+"}; \
		{printf " $(grey300)   make $(reset)$(cyan80)$(bold)$(TAB) $(reset)$(grey300)# %s$(reset)\n", \
			$$1, $$2}'
	@grep -E '^([a-zA-Z0-9_-]+\.?)+:( +\w+-\w+)*$$' $(MAKEFILE_HELP_GREP) \
		| grep -v help \
		| awk 'BEGIN {FS = ":"}; \
		{printf " $(grey300)   make $(reset)$(cyan80)$(bold)$(TAB)$(reset)\n", \
			$$1}'
	@echo -e "\n    $(underline)$(grey500)Helper/Checks$(reset)\n"
	@grep -E '^([a-zA-Z0-9_-]+\.?)+:.+#.+$$' $(MAKEFILE_HELP_GREP) \
		| grep -E '^(check|arg|env)-' \
		| awk 'BEGIN {FS = "[: ]+#[ ]+"}; \
		{printf " $(grey300)   make $(reset)$(grey500)$(TAB) $(reset)$(grey300)# %s$(reset)\n", \
			$$1, $$2}' \
		|| true
	@echo -e ""
