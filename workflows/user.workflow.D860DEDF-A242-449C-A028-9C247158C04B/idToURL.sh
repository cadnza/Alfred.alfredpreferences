#!/usr/bin/env sh

# Add to path
PATH=/usr/local/bin:$PATH
PATH=$HOME/.local/bin:$PATH

# Get URL
bookmarks list -j | jq -jr ".[] | select(.id == $id).url"

# Exit
exit 0
