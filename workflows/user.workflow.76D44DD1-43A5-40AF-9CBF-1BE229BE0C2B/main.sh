#!/usr/bin/env zsh

# Identify target directory
braveDir="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"

# Get metadata file
braveFile="$braveDir/Local State"

# Get last used profile directory
lastProfile=$(cat $braveFile | jq -r '.profile.last_used')

# Create workflow data directory
[[ -d $alfred_workflow_data ]] || mkdir $alfred_workflow_data
