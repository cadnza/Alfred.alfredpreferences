#!/usr/bin/env zsh

# Get bookmark preference file
bkPrefsFile=$alfred_preferences/preferences/features/webbookmarks/prefs.plist

# Open in either default or native browser
defaults read $bkPrefsFile browsermode 2> /dev/null && \
	open -a "Brave Browser" $1 \
|| \
	open $1

# Exit
exit 0
