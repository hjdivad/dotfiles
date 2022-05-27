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


install: # install dotfiles into $HOME
	./install.bash

test.nvim: # Run plenary tests
	@cd $(NvimDir)
	@pwd
	nvim --headless --noplugin -u tests/runner_init.vim -c "PlenaryBustedDirectory tests/hjdivad/ {minimal_init = 'tests/test_init.vim'}"

TmpOut := "./tmp/test.out"

test.bootstrap:
	@rm -f $(TmpOut)
	XDG_DATA_HOME=/tmp/no/place/like/home/ nvim --headless -u ./home/.config/nvim.symlink/init.lua +quit 2>&1 | \
		grep -C 100 Error && \
		{
			printf " $(red)\n\ninit.lua errored ungracefully when bootstrapping.${reset} See output above."
		} || true

test: test.nvim test.bootstrap # Run all tests

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
