#!/usr/bin/env zsh

PATH=/Users/cadnza/Library/Developer/Xcode/DerivedData/bookmarks-hadsndjbwmchoceyscvozdcxlxwi/Build/Products/Debug:$PATH #TEMP

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Show message if bookmarks not installed
which bookmarks &> /dev/null || {
	jq -nc \
		--arg title "Command not found" \
		--arg subtitle "Make sure bookmarks is in \$PATH." \
		--arg arg "notfound" \
		'{"items":[{"title": $title, "subtitle": $subtitle, "arg": $arg}]}'
	exit 0
}

# List bookmarks
bookmarks list -j | jq '
	{
		"items": [
			(
				.[] | {
					"title": .title,
					"subtitle": (if .tag == null then "" else "[" + .tag + "]" + " " end + .url),
					"arg": "open",
					"match": (.tag + " " + .title),
					"autocomplete": .title,
					"mods": {
						"cmd": {
							"subtitle": "Edit this bookmark'"'"'s title",
							"arg": "edittitle",
							"variables": {
								"original": .title
							}
						},
						"alt": {
							"subtitle": "Edit this bookmark'"'"'s tag",
							"arg": "edittag",
							"variables": {
								"original": .tag
							}
						},
						"ctrl": {
							"subtitle": "Edit this bookmark'"'"'s URL",
							"arg": "editurl",
							"variables": {
								"original": .url
							}
						},
						"cmd+alt+ctrl": {
							"subtitle": "REMOVE this bookmark",
							"arg": "remove"
						}
					},
					"text": {
						"copy": .url,
						"largetype": .title
					},
					"quicklookurl": .url,
					"variables": {
						"id": .id
					}
				}
			),
			{
				"title": "Add a new bookmark",
				"arg": "add",
				"icon": {
					"path": "./plus.png"
				},
				"match": "add new",
				"text": {
					"copy": "Add a new bookmark",
					"largetype": "Add a new bookmark"
				},
				"quicklookurl": "https://github.com/cadnza/bookmarks"
			}
		]
	}
'

# Exit
exit 0
