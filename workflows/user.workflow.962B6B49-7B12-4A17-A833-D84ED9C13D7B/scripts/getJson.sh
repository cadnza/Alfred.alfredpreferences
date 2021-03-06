#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Set rerun interval, 0.1 to 5 seconds
rerun=1

# Get function to prep and echo JSON
echoJSON() {
	echo "{
		\"rerun\": $rerun,
		\"items\": [
			$@
		]
	}"
}

# Create workflow data directory if needed
[[ -d $alfred_workflow_data ]] || mkdir $alfred_workflow_data

# Set db paths
dbClosed="$alfred_workflow_data/idx"
dbOpen=$(mktemp)

# Set screen key of indexing process
screenKeyName=githubCloneIndexingRoutine

# Get function to reindex
reindex() {
	[[ $(screen -ls | grep -Fc $screenKeyName) = 0 ]] && \
		screen -S $screenKeyName -dm ./scripts/reindex.sh $dbOpen $dbClosed
}

# Set routine to reindex and display wait
showPleaseWait() {
	reindex
	waitItem=$(
		jq -nc '{
			"title": "Indexing repos...",
			"subtitle": "This only happens once. Please come back in a few minutes.",
			"valid": false
		}'
	)
	echoJSON $waitItem
}

# Wait if there's no database
[[ -f $dbClosed ]] || {
	showPleaseWait
	exit 0
}

# Open database
openssl des3 -d -in $dbClosed -out $dbOpen -pass pass:githubToken

# Start background reindexing if not already running
reindex

# Validate non-zero count in prod table
sbtl="No repos were found for $githubUsername."
[[ $(sqlite3 $dbOpen 'SELECT COUNT(1) FROM prod') = 0 ]] && {
	noRepos=$(
		jq -nc \
			--arg subtitle $sbtl \
			'{
				"title": "No repos found",
				"subtitle": $subtitle,
				"valid": false
			}'
	)
	echoJSON $noRepos
	exit 0
}

# Format final JSON
final=$(echo $queryResult | perl -pe 's/\n/,/g' | sed 's/,$//g')

# Query databasesqlDirArray=""
ls $reposDirectory | while read -r singleDir
do
	newDirElement=\'$(echo $singleDir | sed "s/'/''/g")\'
	[[ $sqlDirArray = "" ]] && \
		sqlDirArray=$newDirElement \
	|| \
		sqlDirArray=$sqlDirArray,$newDirElement
done
sqlDirArray=\($sqlDirArray\)
final=$(sqlite3 $dbOpen "SELECT json FROM prod WHERE name NOT IN $sqlDirArray ORDER BY lower(name)")

# Echo final JSON
echoJSON $final

# Remove open database
rm $dbOpen

# Exit
exit 0
