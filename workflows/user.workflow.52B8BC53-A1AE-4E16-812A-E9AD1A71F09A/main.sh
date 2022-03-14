#!/usr/bin/env zsh

# Go
f=$(./capture.sh)
final=$(./OCR.R $f)
succeeded=$?

# Show notification and exit on failure
[[ $succeeded = 1 ]] && {
	osascript -e "display alert \"Tesseract Not Configured\" message \"Please install the tesseract package for R with the 'rus' engine.\" as critical"
	exit 1
}

# Send results
echo $final

# Exit
exit 0
