#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Make workflow data directory
[[ -d $alfred_workflow_data ]] || mkdir $alfred_workflow_data

# Search for part
./partsearch.R $alfred_workflow_data $1
[[ $? = 127 ]] && {
	rMessage=$(
		jq -nc \
			--arg link "https://www.r-project.org/" \
			'{
				"items": [
					{
						"title": "R installation not found",
						"subtitle": "Please install R to continue.",
						"arg": $link,
						"icon": {"path": "images/R.png"},
						"quicklookurl": $link
					}
				]
			}'
	)
	echo $rMessage
}
