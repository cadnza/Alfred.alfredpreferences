#!/usr/bin/env zsh

# Clone repo in background
screen -dm git -C $reposDirectory clone -q $repoClone

# Synthesize repo directory
repoDirectory=$reposDirectory/$repoName

# Open repo directory when available if configured
[[ $openOnClone = 1 ]] && screen -dm ./scripts/openDirectory.sh $repoDirectory

# Exit
exit 0
