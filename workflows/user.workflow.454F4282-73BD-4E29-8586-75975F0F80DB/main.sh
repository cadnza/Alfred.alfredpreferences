#!/usr/bin/env bash

# Link common
[ -d common ] || ln -s "$(realpath ../common)" .

# Link icon
./common/link.sh icon.png /System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns

# Set cache file
# shellcheck disable=SC2154
cacheFile="$alfred_workflow_cache/cache.json"

# Show options if cached or notice if not
if [ -f "$cacheFile" ]; then
    cat "$cacheFile"
else
    ./recache.sh >/dev/null
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
    echo -n "$final"
fi

# Exit
exit 0
