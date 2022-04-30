#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Pull repos
jsonRaw=$(curl -s -H "Authorization: token $githubToken" \
	"https://api.github.com/search/repositories?q=user:$githubUsername")

# Validate pull
[[ $(echo $jsonRaw | jq -r -c '.message') = "Bad credentials" ]] && {
	osascript -e "display alert \"Bad credentials\" message \"Please check your username and access token.\" as critical"
	exit 0
}

# Open variable for JSON items
jsonItems=""

# Open loop for repos
jsonSubsets=$(echo $jsonRaw  | jq -c '.items | to_entries[]')
echo $jsonSubsets | while read -r jsonSubsetRaw
do

	# Subset JSON
	jsonSubset=$(echo $jsonSubsetRaw | jq -r '.value')

	# Get name
	repoName=$(echo $jsonSubset | jq -r '.name')

	# Skip if repo already exists in repos directory
	[[ -d $reposDirectory/$repoName ]] && continue

	# Get description
	repoDescr=$(echo $jsonSubset | jq -r '.description')

	# Get visibility and set appropriate icon
	repoVis=$(echo $jsonSubset | jq -r '.visibility')
	[[ $repoVis = private ]] && \
		repoIcon=locked.png || \
		repoIcon=""

	# Get URL
	repoURL=$(echo $jsonSubset | jq -r '.html_url')

	# Get clone url
	[[ $useSSH = "1" ]] && \
		repoClone=$(echo $jsonSubset | jq -r '.ssh_url') \
	|| {
		prfx="https\:\/\/"
		repoClone=$(echo $jsonSubset | jq -r '.clone_url' | sed "s/$prfx/$prfx$githubToken@/")
	}

	# Format new JSON item
	newItem=$(
		jq -nc \
			--arg repoName "$repoName" \
			--arg subtitle "$repoDescr" \
			--arg repoClone "$repoClone" \
			--arg icon "$repoIcon" \
			--arg match "$repoName $repoDescr" \
			--arg autocomplete "$repoName" \
			--arg text "$repoName: $repoDescr" \
			--arg quicklookurl "$repoURL" \
			'{
				"title": $repoName,
				"subtitle": $subtitle,
				"arg": "",
				"icon": {"path": $icon},
				"match": $match,
				"autocomplete": $autocomplete,
				"text": $text,
				"quicklookurl": $quicklookurl,
				"variables": {
					"repoClone": $repoClone,
					"repoName": $repoName
				}
			}'
	),
	jsonItems=$jsonItems$newItem

# Close loop
done

# Remove trailing comma
jsonItems=$(echo $jsonItems | sed 's/,$//')

# Echo items
echo $jsonItems

# Exit
exit 0
