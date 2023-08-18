#!/usr/bin/env zsh

# Set screen session name for caching routine
sessionName=com.cadnza.alfredManPageOpener.cacheRoutine

# Check for existing caching screen session and start caching routine if not found
[ $(screen -ls | grep -c $sessionName) = 0 ] && {
	screen -S $sessionName -dm ./cache.sh
	echo -n 0
} || {
	echo -n 1
}

# Exit
exit 0
