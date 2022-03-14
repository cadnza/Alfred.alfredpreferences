#!/usr/bin/env zsh

# Screenshot to temporary file
f=$(mktemp)
screencapture -ix $f

# Return file
echo $f

# Exit
exit 0
