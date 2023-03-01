#!/usr/bin/env sh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Get repo directory
dirRepos=$1

# Open JSON variable
json=""

# Open main loop through repos
allRepos=$(eval $(echo ls -d $(echo $dirRepos | sed 's/\/*$//')/\*/))
echo $allRepos | while read -r repoRaw
do
	newItem=$(
		jq -nc \
			--arg repo "$(basename $repoRaw)" \
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
	json=$json,$newItem
done

# Remove leading comma
json="${json:1}"

# Frame final JSON
final="{\"items\": [$json]}"
echo -n $final

# Exit
exit 0
