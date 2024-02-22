#!/usr/bin/env sh

# Open captive portal after redirects
open $(curl -Ls -o /dev/null -w %{url_effective} captive.apple.com)

# Exit
exit 0
