#!/usr/bin/env zsh

# Check existence of repos directory
[[ -d $reposDirectory ]] || {
	osascript -e "display alert \"The directory $reposDirectory does not exist.\" message \"Please adjust the \$reposDirectory variable in Alfred.\" as critical"
	exit 1
}

# Echo all clear
echo 0

# Exit
exit 0