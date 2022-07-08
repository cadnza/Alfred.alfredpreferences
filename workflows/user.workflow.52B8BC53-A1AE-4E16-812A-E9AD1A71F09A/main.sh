#!/usr/bin/env zsh

# Capture screen and exit on cancel
f=$(./capture.sh) || exit 0

# Run OCR and record exit status
final=$(./OCR.sh $f)
succeeded=$?

# Show notification and exit on failure
[[ $succeeded = 1 ]] && {
	osascript -e "display alert \"Tesseract Not Configured\" message \"Please install the tesseract  with the 'rus' engine.\" as critical"
	exit 1
}

# Send results
echo $final

# Exit
exit 0
