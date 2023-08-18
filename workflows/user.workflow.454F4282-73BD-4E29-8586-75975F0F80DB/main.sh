#!/usr/bin/env zsh

# Set screen session name for caching routine
sessionName=com.cadnza.alfredManPageOpener.cacheRoutine

# Check for existing caching screen session and start caching routine if not found
[ $(screen -ls | grep -c $sessionName) = 0 ] && screen -S $sessionName -dm ./cache.sh

# Show options if cached or notice if not
cacheFile="$alfred_workflow_cache/cache.json"
[ -f $cacheFile ] && cat $cacheFile || {
	#TEMP
}

# Exit
exit 0