#!/usr/bin/env sh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Get Alfred directory
dirAlfred=$1
dirAlfredName=$(basename $dirAlfred)

# Get workflows directory
dirWorkflows=$dirAlfred/workflows

# Open JSON variable
json=""

# Add item to modify entire repo
repoItem=$(
	jq -nc \
		--arg dirAlfred "$dirAlfred" \
		--arg dirAlfredName "$dirAlfredName" \
		'{
			"title": $dirAlfredName,
			"subtitle": $dirAlfred,
			"arg": $dirAlfred,
			"icon": {"path": $dirAlfred, "type": "fileicon"},
			"autocomplete": $dirAlfred,
			"type": "file:skipcheck",
			"text": $dirAlfred,
			"quicklookurl": $dirAlfred
		}'
)
json=$json,$repoItem

# Open main loop through workflows
ls -1 $dirAlfred/workflows | while read -r dirWkflw
do
	fullpath=$dirWorkflows/$dirWkflw
	plist=$fullpath/info.plist
	newItem=$(
		jq -nc \
			--arg title "$(defaults read $plist name)" \
			--arg subtitle "$(defaults read $plist description)" \
			--arg arg "$fullpath" \
			--arg iconPath "$fullpath/icon.png" \
			--arg fullpath "$dirWorkflows/$dirWkflw" \
			'{
				"title": $title,
				"subtitle": $subtitle,
				"arg": $arg,
				"icon": {"path": $iconPath},
				"autocomplete": $title,
				"type": "file:skipcheck",
				"text": $title,
				"quicklookurl": $fullpath
			}'
	)
	json=$json,$newItem
done

# Remove leading comma
json="${json:1}"

# Frame final JSON
final="{\"items\": [$json]}"
printf "%s" "$final"

# Return
exit 0
