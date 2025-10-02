#!/usr/bin/env bash

# shellcheck disable=SC2164

# Get icon
fIcon="$(readlink "$PWD/icon.png")"

# Go to stickies directory
dirStickies="$HOME/Library/Containers/com.apple.Stickies/Data/Library/Stickies"
cd "$dirStickies"

# Open JSON
final=$(echo '{
	"items": []
}' | jq)

# Open loop through stickies
while read -r dirSticky; do

    # Validate file
    fTxt="$dirSticky/TXT.rtf"
    [ -f "$fTxt" ] || continue

    # Get text of sticky and remove extra lines
    txtSticky="$(textutil -convert txt "$fTxt" -stdout)"
    txtStickyTrimmed="$(echo "$txtSticky" | sed '/^$/d')"

    # Create and add object
    firstLine="$(echo "$txtStickyTrimmed" | sed '1q;d')"
    final="$(
        echo "$final" | jq \
            --arg uid "$dirSticky" \
            --arg title "$firstLine" \
            --arg subtitle "$(echo "$txtStickyTrimmed" | sed '2q;d')" \
            --arg arg "$dirSticky" \
            --arg iconPath "$fIcon" \
            --arg match "$txtStickyTrimmed" \
            --arg autocomplete "$firstLine" \
            --arg type "default" \
            --arg actionText "$txtSticky" \
            --arg actionFile "$fTxt" \
            --arg textCopy "$txtSticky" \
            --arg textLargetype "$txtSticky" \
            --arg quicklookurl "$fTxt" \
            '
				.items += [
					{
						"uid": $uid,
						"title": $title,
						"subtitle": $subtitle,
						"arg": $arg,
						"icon": {
							"path": $iconPath
						},
						"match": $match,
						"autocomplete": $autocomplete,
						"type": $type,
						"action": {
							"text": $actionText,
							"file": $actionFile
						},
						"text": {
							"copy": $textCopy,
							"largetype": $textLargetype
						},
						"quicklookurl": $quicklookurl
					}
				]
			'
    )"

done <<<"$(find ~+ -type d -mindepth 1 -maxdepth 1)"

# Echo result
echo "$final"
