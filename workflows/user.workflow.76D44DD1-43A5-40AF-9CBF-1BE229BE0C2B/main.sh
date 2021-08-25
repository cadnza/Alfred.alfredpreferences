#!/usr/bin/env zsh

# Set maximum database age in minutes
dbMaxAgeMinutes=1

# Identify target directory
braveDir="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"

# Get metadata file
braveFile="$braveDir/Local State"

# Get last used profile directory
lastProfile=$(cat $braveFile | jq -r '.profile.last_used')

# Create workflow data directory
[[ -d $alfred_workflow_data ]] || mkdir $alfred_workflow_data

# Set db path
db="$alfred_workflow_data/db.sqlite"

# Get function to update database
updateDB() {
	screenKeyName=braveBookmarksScreenIdJonDayley
	[[ $(screen -ls | grep -Fc $screenKeyName) = 0 ]] && \
		screen -S $screenKeyName  -dm ./updateDatabase.sh $db
}

# Create database if needed and return placeholder JSON
[[ -f $db ]] || {
	updateDB
	waitItem="{
		\"title\": \"Indexing bookmarks...\",
		\"subtitle\": \"This only happens once. Please come back in a few minutes.\",
		\"valid\": false
	}"
	echo $waitItem #This needs formatted, probably by a function #TEMP
	return
}

# Update database if due for refresh
nMinsOld=$((($(date +%s)-$(date -r $db +%s))/60))
[[ $nMinsOld -ge $dbMaxAgeMinutes ]] && updateDB
