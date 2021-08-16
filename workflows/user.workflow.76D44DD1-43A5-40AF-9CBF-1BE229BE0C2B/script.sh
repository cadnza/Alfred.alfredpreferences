#!/usr/bin/env zsh

typeset -F SECONDS=0 #TEMP

# Identify target directory
braveDir="/Users/cadnza/Library/Application Support/BraveSoftware/Brave-Browser" # Change to ~ #TEMP

# Get metadata file
braveFile="$braveDir/Local State"

# Convert to JSON
jsonMaster=$(cat $braveFile | jq .)

# Subset JSON
jsonSubset=$(cat $braveFile | jq '.profile.info_cache | to_entries[]')

# Get profile directories
profileDirs=$(echo $jsonSubset | jq -r '.key')

# Get last used profile directory
profileDirBase=$(echo $jsonMaster | jq -r '.profile.last_used')

# Subset JSON for last used profile directory
jsonProfile=$(echo $jsonSubset | jq "select(.key == \"$profileDirBase\")")

# Get name
name=$(echo $jsonProfile | jq -r '.value.name')

# Get icon
icon=$(echo $jsonProfile | jq -r '.value.avatar_icon')

# Get directory for focus profile
profileDir=$braveDir/$profileDirBase

# Get bookmarks file
bookmarks=$profileDir/bookmarks

# Open variable for final JSON
jsonFinal=""

# Get GUIDs of folder nodes
guids=$(cat $bookmarks | jq -r '.. | objects | select(.type == "folder") | .guid')

# Open loop for folders
echo $guids | while read -r guid
do

	# Get URL nodes belonging to folder
	selector=".. | objects | select(.guid == \"$guid\") | .. | objects | select(has(\"url\")) | .guid"
	guidsURL=$(cat $bookmarks | jq -c $selector)

# Close loop
done




echo
echo "$SECONDS" #TEMP
