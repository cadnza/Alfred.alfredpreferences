#!/usr/bin/env bash

# Add to path
PATH=/usr/local/bin:$PATH
PATH=/opt/homebrew/bin:$PATH

# Get repo directory
dirRepos=$1

# Open JSON variable
json=""

# Open main loop through repos
allRepos=$(eval "$(echo ls -d "$(echo "$dirRepos" | sed 's/\/*$//')"/\*/)")
while read -r repoRaw
do
	newItem=$(
		jq -nc \
			--arg repo "$(basename "$repoRaw")" \
			--arg fullpath "$repoRaw" \
			'{
				"title": $repo,
				"subtitle": $fullpath,
				"arg": $fullpath,
				"icon": {"path": $fullpath, "type": "fileicon"},
				"autocomplete": $repo,
				"type": "file:skipcheck",
				"text": $fullpath,
				"quicklookurl": $fullpath
			}'
	)
	json="$json,$newItem"
done < <(echo "$allRepos")

# Remove leading comma
json="${json:1}"

# Frame final JSON
final="{\"items\": [$json]}"
printf "%s" "$final"

# Exit
exit 0
