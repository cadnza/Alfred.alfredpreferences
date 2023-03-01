#!/usr/bin/env sh

# Run OCR
result=$(tesseract $1 - -l rus 2> /dev/null) || exit 1

# Return result
echo $result

# Exit
exit 0
