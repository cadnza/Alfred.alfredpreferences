#!/usr/bin/env zsh

# Details here:
# https://developer.apple.com/forums/thread/651829?page=4

# Kill iCloud service
killall bird

# If running hardcore, get rid of the entire directory and kill iCloud service again
[ $hardcore = 1 ] && {
	rm -rf "~/Library/Application Support/CloudDocs"
	killall bird
}

# Exit
exit 0
