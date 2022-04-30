#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Set db path
db=$1

# Create stage table if needed
sqlite3 $db "CREATE TABLE IF NOT EXISTS stage (name TEXT NOT NULL, json TEXT NOT NULL);"

# Pull repos
jsonRaw=$(curl -s -H "Authorization: token $githubToken" \
	"https://api.github.com/search/repositories?q=user:$githubUsername")

# Validate pull and delete database if bad
[[ $(echo $jsonRaw | jq -r -c '.message') = "Bad credentials" ]] && {
	osascript -e "display alert \"Bad credentials\" message \"Please check your username and access token.\" as critical"
	[[ -f $db ]] && rm $db
	exit 0
}

# Open loop for repos
jsonSubsets=$(echo $jsonRaw  | jq -c '.items | to_entries[]')
echo $jsonSubsets | while read -r jsonSubsetRaw
do

	# Subset JSON
	jsonSubset=$(echo $jsonSubsetRaw | jq -r '.value')

	# Get name
	repoName=$(echo $jsonSubset | jq -r '.name')

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
	newItem=${newItem//$'\n'/}

	# Insert into stage
	sqlite3 $db "INSERT INTO stage VALUES ('$repoName','$newItem');"

# Close loop
done

# Create prod table if needed
sqlite3 $db "CREATE TABLE IF NOT EXISTS prod (name TEXT NOT NULL, json TEXT NOT NULL);"

# Replace prod with stage
sqlite3 $db "DELETE FROM prod;"
sqlite3 $db "INSERT INTO prod SELECT * FROM stage;"

# Truncate stage
sqlite3 $db "DELETE FROM stage;"

# Exit
exit 0
