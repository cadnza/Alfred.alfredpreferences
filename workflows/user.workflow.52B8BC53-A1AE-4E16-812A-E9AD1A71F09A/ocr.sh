#!/usr/bin/env sh

# Run OCR
result=$(tesseract "$1" - -l rus 2>/dev/null) || exit 1

# Return result
[ "$lowercase" = 1 ] && result="$(echo "$result" | awk '{print tolower($0)}')"
echo "$result"

# Exit
exit 0
