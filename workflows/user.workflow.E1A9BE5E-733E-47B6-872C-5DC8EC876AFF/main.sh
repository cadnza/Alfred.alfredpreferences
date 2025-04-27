#!/usr/bin/env bash

# Enable exit on error
set -e

# Find and delete launchpad configurations
find 2>/dev/null /private/var/folders/ -type d -name com.apple.dock.launchpad -exec rm -rf {} + # TODO: This needs to be run with sudo

# Reset dock
killall Dock
