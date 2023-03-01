#!/usr/bin/env sh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Get repo directory
dirRepos=$1

# Open JSON variable
json=""

# Open main loop through repos
ls $dirRepos | while read -r repo
do
	fullpath=$dirRepos/$repo
	filterpattern="(\.xcodeproj$|package.swift)"
	candidates=$(ls -1 $fullpath | grep -Ei $filterpattern)
	hasRproj=$(echo $candidates | grep -c .)
	[ $hasRproj = 0 ] && continue
	arg=$fullpath/$(echo $candidates | sed -n 1p)
	newItem=$(
		jq -nc \
			--arg repo $repo \
			--arg fullpath $fullpath \
			--arg arg "$fullpath/$(echo $candidates | sed -n 1p)" \
			'{
				"title": $repo,
				"subtitle": $fullpath,
				"arg": $arg,
				"icon": {"path": $fullpath, "type": "fileicon"},
				"autocomplete": $repo,
				"type": "file:skipcheck",
				"text": $fullpath,
				"quicklookurl": $fullpath
			}'
	)
	json=$json,$newItem
done

# Remove final comma
json="${json:1}"

# Frame final JSON
final="{\"items\": [$json]}"
echo -n $final
