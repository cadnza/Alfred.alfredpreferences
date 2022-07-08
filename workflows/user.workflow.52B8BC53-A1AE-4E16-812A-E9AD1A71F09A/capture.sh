#!/usr/bin/env zsh

# Screenshot to temporary file
f=$(mktemp)
screencapture -ix $f

# Exit on zero-size file
[ -s $f ] || exit 1

# Return file
echo $f

# Exit
exit 0
