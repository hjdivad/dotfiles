# Use vi-mode (escape to go into “normal” mode and j,k to scroll through
# history, navigate lines with bw, &c.)
set -o vi

# Make bash check its window size after each command, to keep $LINES and
# $COLUMNS correct.
shopt -s checkwinsize
