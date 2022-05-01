#!/usr/bin/env zsh

# Get Github access token from security
githubToken=$(security find-internet-password  -w -s $service $keychain || \
	security find-generic-password  -w -s $service $keychain
)

# Abort on cancel
[[ $? = 0 ]] || exit 0

# Validate access token
[[ $? = 0 ]] || {
	osascript -e "display alert \"Item of service $service in the $keychain keychain cannot be found.\" message \"Please review your keychain and Alfred variables.\" as critical"
	exit 0
}

# Pick Alfred back up after authenticating
pickupAction="9181bb23-171d-4d30-8ea5-02b4a67fdfe5"
osascript -e "tell application id \"com.runningwithcrayons.Alfred\" to run trigger \"9181bb23-171d-4d30-8ea5-02b4a67fdfe5\" in workflow \"$alfred_workflow_bundleid\" with argument \"$githubToken\""

# Exit
exit 0
