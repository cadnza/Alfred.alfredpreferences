#!/usr/bin/env zsh

# Set cache file
f=$alfred_workflow_cache/$cachefilename

# Exit if cache file doesn't exist
[[ -f $f ]] || exit 0

# Convert wait minutes to seconds
cachelifespanseconds=$(($cachelifespanminutes*60))

# Set name for screen session
sessionname="littleinterest_cashkiller"

# Kill screen session
screen -X -S $sessionname quit > /dev/null

# Start new screen session to eliminate cache after time period
screen -S $sessionname -dm zsh -c "sleep $cachelifespanseconds; rm \"$f\" > /dev/null"

# Exit
exit 0
