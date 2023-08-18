#!/usr/bin/env zsh

# Set cache file
cacheFile="$alfred_workflow_cache/cache.json"

# Show options if cached or notice if not
[ -f $cacheFile ] && cat $cacheFile || {
	./recache.sh > /dev/null
	final=$(
		echo '
			{"items":
				[
					{
						"title": "Caching man pages, please wait...",
						"subtitle": "This initial caching only happens once.",
						"valid": false
					}
				]
			}
		' | jq
	)
	echo -n $final
}

# Exit
exit 0
