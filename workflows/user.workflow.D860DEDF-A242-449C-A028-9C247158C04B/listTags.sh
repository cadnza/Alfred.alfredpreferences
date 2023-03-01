#!/usr/bin/env sh

# Add to path
PATH=/usr/local/bin:$PATH
PATH=$HOME/.local/bin:$PATH

# List tags
bookmarks list-tags -j | jq '
	{
		"items": [
			(
				.[] | {
					"title": .tag,
					"subtitle": (.count | tostring + " tags"),
					"arg": .tag,
					"autocomplete": .tag,
				}
			),
			{
				"title": "Add a new tag",
				"arg": "addtag",
				"icon": {
					"path": "./plus.png"
				},
				"match": "add new",
				"text": {
					"copy": "Add a new tag",
					"largetype": "Add a new tag"
				},
				"quicklookurl": "https://github.com/cadnza/bookmarks"
			}
		]
	}
'

# Exit
exit 0
