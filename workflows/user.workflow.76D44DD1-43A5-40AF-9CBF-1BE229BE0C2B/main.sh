#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Validate and format max database age
dbMaxAgeMinutesDefault=1
[[ $(echo $dbMaxAgeMinutes | grep -Ec "^(0*[1-9]+0*)+$") = 0 ]] && \
	dbMaxAgeMinutes=$dbMaxAgeMinutesDefault \
|| \
	dbMaxAgeMinutes=$(echo $dbMaxAgeMinutes | sed 's/^0*//g')

# Set rerun interval, 0.1 to 5 seconds
rerun=3

# Get function to prep and echo JSON
echoJSON() {
	echo "{
		\"rerun\": $rerun,
		\"items\": [
			$1
		]
	}"
}

# Check for Brave
[[ $(ls /Applications | grep -Fc "Brave Browser.app") = 0 ]] && {
	braveURL="https://brave.com/download/"
	final=$(
		jq -nc \
			--arg braveURL $braveURL \
			'{
				"title": "It looks like you don'"'"'t have Brave Browser installed.",
				"subtitle": "Hit '"'"'Enter'"'"' to visit the download page.",
				"arg": $braveURL,
				"text": $braveURL,
				"quicklookurl": $braveURL
			}'
	)
	echoJSON $final
	exit 0
}

# Check for jq
[[ -f $(which jq) ]] || {
	jqURL="https://stedolan.github.io/jq/download/"
	final="{
		\"title\": \"Please install jq to continue.\",
		\"subtitle\": \"Hit 'Enter' to visit the download page, or be sure jq is in Alfred's \$PATH.\",
		\"arg\": \"$jqURL\",
		\"text\": \"$jqURL\",
		\"quicklookurl\": \"$jqURL\"
	}"
	echoJSON $final
	exit 0
}

# Get metadata file
braveFile="$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Local State"

# Get last used profile di rectory
lastProfileSQL=$(cat $braveFile | jq -r '.profile.last_used' | sed "s/'/''/g")

# Create workflow data directory if needed
[[ -d $alfred_workflow_data ]] || mkdir $alfred_workflow_data

# Set db path
db="$alfred_workflow_data/index.sqlite"

# Set screen key of indexing process
screenKeyName=braveBookmarksIndexingRoutine

# Get function to reindex
reindex() {
	[[ $(screen -ls | grep -Fc $screenKeyName) = 0 ]] && \
		screen -S $screenKeyName -dm ./reindex.sh $db
}

# Set routine to reindex and display wait
showPleaseWait() {
	reindex
	waitItem=$(
		jq -nc '{
			"title": "Indexing bookmarks...",
			"subtitle": "This only happens once. Please come back in a few minutes.",
			"valid": false
		}'
	)
	echoJSON $waitItem
}

# Wait if there's no database
[[ -f $db ]] || {
	showPleaseWait
	exit 0
}

# Wait if there's no prod table
[[ $(sqlite3 $db "SELECT name FROM sqlite_master WHERE type='table' AND name='prod';" | grep -c .) = 0 ]] && {
	showPleaseWait
	exit 0
}

# Reindex if due for reindexing
nMinsOld=$((($(date +%s)-$(date -r $db +%s))/60))
[[ $nMinsOld -ge $dbMaxAgeMinutes ]] && reindex

# Get query according to setting on whether to retrieve bookmarks from all profiles
[[ $showAllProfiles = 1 ]] && \
	q="SELECT json FROM prod;" \
|| \
	q="SELECT json FROM prod WHERE profile='$lastProfileSQL';"

# Query database
queryResult=$(sqlite3 $db $q)

# Validate non-zero bookmark count and reindex otherwise
[[ $(echo $queryResult | grep -c ".") = 0 ]] && {
	profileName=$(sqlite3 $db "SELECT name FROM prodProf WHERE profile = '$lastProfileSQL'")
	[[ $showAllProfiles = 1 ]] && \
		noBookmarksTitle="No bookmarks found." \
	|| \
		noBookmarksTitle="No bookmarks found for $profileName."
	[[ $(screen -ls | grep -Fc $screenKeyName) = 0 ]] && \
		noBookmarksSubtitle="Add some bookmarks and then check here again." \
	|| \
		noBookmarksSubtitle="Reindexing..."
	final=$(
		jq -nc \
			--arg noBookmarksTitle "$noBookmarksTitle" \
			--arg noBookmarksSubtitle "$noBookmarksSubtitle" \
			'{
				"title": $noBookmarksTitle,
				"subtitle": $noBookmarksSubtitle,
				"valid": false
			}'
	)
	echoJSON $final
	reindex
	exit 0
}

# Format final JSON
final=$(echo $queryResult | perl -pe 's/\n/,/g' | sed 's/,$//g')

# Echo results
echoJSON $final

# Exit
exit 0
