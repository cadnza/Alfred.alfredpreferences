#!/usr/bin/env sh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Get display variable
[ "$showpct" = 1 ] && disp=$(./decimaltopercent.R "$1") || disp="$1"
[ "$disp" = C -o "$disp" = c ] && disp='Continuous'

# Validate
[ ${#1} -gt 0 ] && echo "$1" | grep -Eq "$ptrn" && {
	jq --null-input \
		--arg name "$name" \
		--arg prompt "$prompt" \
		--arg disp "$disp" \
		--arg x "$1" \
		'{
			"items": [
				{
					"title": $disp,
					"subtitle": $name,
					"arg": $x
				}
			]
		}'
} || {
	jq --null-input \
		--arg name "$name" \
		--arg prompt "$prompt" \
		'{
			"items": [
				{
					"title": $name,
					"subtitle": $prompt,
					"valid": false
				}
			]
		}'
}

# Exit
exit 0
