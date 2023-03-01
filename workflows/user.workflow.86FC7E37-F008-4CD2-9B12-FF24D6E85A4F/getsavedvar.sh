#!/usr/bin/env sh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Set cache file
f="$alfred_workflow_cache/$cachefilename"

# Return blank string if there's no file
[ -f "$f" ] || {
	printf "%s" ""
	exit 0
}

# Echo target variable
cat "$f" | jq -j ".$varname"

# Exit
exit 0
