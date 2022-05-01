#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Grab and save user icon
userJson=$(curl -s -H "Authorization: token $githubToken" \
	https://api.github.com/users/$githubUsername)
iconURL=$(echo $userJson | jq -r '.avatar_url')
userIcon="$alfred_workflow_data/user.png"
[[ $iconURL = null ]] || curl -s -o $userIcon $iconURL

# Set db paths
dbOpen=$1
dbClosed=$2

# Create prod table
sqlite3 $dbOpen "CREATE TABLE IF NOT EXISTS prod (name TEXT NOT NULL, json TEXT NOT NULL);"

# Pull repos
jsonRaw=$(curl -s -H "Authorization: token $githubToken" \
	"https://api.github.com/search/repositories?q=user:$githubUsername")

# Validate pull and delete database if bad
[[ $(echo $jsonRaw | jq -r -c '.message') = "Bad credentials" ]] && {
	[[ -f $dbOpen ]] && rm $dbOpen
	osascript -e "display alert \"Bad credentials\" message \"Please check your username and access token.\" as critical"
	exit 0
}

# Open loop for repos
jsonSubsets=$(echo $jsonRaw | jq -c '.items | to_entries[]')
echo $jsonSubsets | while read -r jsonSubsetRaw
do

	# Subset JSON
	jsonSubset=$(echo $jsonSubsetRaw | jq -r '.value')

	# Get name
	repoName=$(echo $jsonSubset | jq -r '.name')

	# Get description
	repoDescr=$(echo $jsonSubset | jq -r '.description')
	[[ $repoDescr = "null" ]] && repoDescr=""

	# Get visibility and set appropriate icon
	repoVis=$(echo $jsonSubset | jq -r '.visibility')
	[[ $repoVis = private ]] && {
		repoIcon=locked.png
	} || {
		repoIcon=""
		[[ -f $userIcon ]] && repoIcon=$userIcon
	}

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

	# Insert into prod
	repoNameEscaped=$(echo $repoName | sed 's/"/\\"/g')
	newItemEscaped=$(echo $newItem | sed 's/"/\\"/g')
	sqlite3 $dbOpen -cmd ".param clear" -cmd ".parameter init" -cmd ".parameter set @reponame \"$repoNameEscaped\"" -cmd ".parameter set @newitem \"$newItemEscaped\"" "INSERT INTO prod VALUES (@reponame,@newitem);"

# Close loop
done

# Close database
openssl des3 -in $dbOpen -out $dbClosed -pass pass:githubToken

# Exit
exit 0
