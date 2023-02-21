#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Get URL
bookmarks list -j | jq -r ".[] | select(.id == $id).url"

# Exit
exit 0
