#!/usr/bin/env zsh

# Clone repo in background
screen -dm git -C $reposDirectory clone -q $repoClone

# Synthesize repo directory
repoDirectory=$reposDirectory/$repoName

# Open repo directory when available
screen -dm ./openDirectory.sh $repoDirectory

# Exit
exit 0
