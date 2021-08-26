#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Set maximum database age in minutes
dbMaxAgeMinutes=1 # Outsource to Alfred environment variable #TEMP

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
[[ $(mdfind "kMDItemKind == 'Application'" | grep -Fc "Brave Browser.app") = 0 ]] && {
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
	return
}

# Check for jq
[[ -f $(which jq) ]] || {
	jqURL="https://stedolan.github.io/jq/download/"
	final=$(
		jq -nc \
			--arg jqURL $jqURL \
			'{
				"title": "Please install jq to continue.",
				"subtitle": "Hit '"'"'Enter'"'"' to visit the download page, or be sure it'"'"'s in Alfred'"'"'s $PATH.",
				"arg": $jqURL,
				"text": $jqURL,
				"quicklookurl": $jqURL
			}'
	)
	echoJSON $final
	return
}

# Identify target directory
braveDir="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"

# Get metadata file
braveFile="$braveDir/Local State"

# Get last used profile directory
lastProfile=$(cat $braveFile | jq -r '.profile.last_used')

# Create workflow data directory
[[ -d $alfred_workflow_data ]] || mkdir $alfred_workflow_data

# Set db path
db="$alfred_workflow_data/index.sqlite"

# Get function to update database
updateDB() {
	screenKeyName=braveBookmarksScreenIdJonDayley
	[[ $(screen -ls | grep -Fc $screenKeyName) = 0 ]] && \
		screen -S $screenKeyName  -dm ./updateDatabase.sh $db
}

# Set routine to update database and display wait
showPleaseWait() {
	updateDB
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
	return
}

# Wait if there's no prod table
[[ $(sqlite3 $db "SELECT name FROM sqlite_master WHERE type='table' AND name='prod';" | grep -c .) = 0 ]] && {
	showPleaseWait
	return
}

# Update database if due for refresh
nMinsOld=$((($(date +%s)-$(date -r $db +%s))/60))
[[ $nMinsOld -ge $dbMaxAgeMinutes ]] && updateDB

# Query database
final=$(
	sqlite3 $db "SELECT json FROM prod WHERE profile='$lastProfile';" | \
		perl -pe 's/\n/,/g' | \
		sed 's/,$//g'
)

# Echo results
echoJSON $final
