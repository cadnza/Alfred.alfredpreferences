#!/usr/bin/env zsh

# Assign repo directory from argument
repoDirectory=$1

# Wait for repo to be available
while [[ ! -d $repoDirectory ]]
do
	sleep 0.5
done

# Open repo directory
open $repoDirectory
