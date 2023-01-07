#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Create cache directory
[[ -d $alfred_workflow_cache ]] || mkdir $alfred_workflow_cache

# Set cache file
f=$alfred_workflow_cache/$cachefilename

# Write JSON to cache file
jq --null-input \
	--arg p $p \
	--arg r $r \
	--arg t $t \
	--arg n $n \
	--arg timestamp $(date +%s) \
	'{
		p: $p,
		r: $r,
		t: $t,
		n: $n,
		timestamp: $timestamp
	}' \
	> $f

# Exit
exit 0
