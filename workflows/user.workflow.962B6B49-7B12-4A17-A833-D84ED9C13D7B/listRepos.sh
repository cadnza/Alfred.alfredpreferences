#!/usr/bin/env zsh

# Get function to prep and echo JSON
echoJSON() {
	echo "{
		\"items\": [
			$@
		]
	}"
}

# Echo final JSON
echoJSON $(./reindex.sh)

# Exit
exit 0
