#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Get Alfred directory
dirAlfred=$1

# Get workflows directory
dirWorkflows=$dirAlfred/workflows

# Open JSON variable
json=""

# Add item to modify entire repo
repoItem="{
	\"title\": \"Alfred.alfredpreferences\",
	\"subtitle\": \"$dirAlfred\",
	\"arg\": \"$dirAlfred\",
	\"icon\": {\"path\":\"$dirAlfred\",\"type\":\"fileicon\"},
	\"autocomplete\": \"$dirAlfred\",
	\"type\": \"file:skipcheck\",
	\"text\": \"$dirAlfred\",
	\"quicklookurl\": \"$dirAlfred\"
}"
json=$json,$repoItem

# Open main loop through workflows
ls -1 $dirAlfred/workflows | while read -r dirWkflw
do
	fullpath=$dirWorkflows/$dirWkflw
	plist=$fullpath/info.plist
	title=$(defaults read $plist name)
	subtitle=$(defaults read $plist description)
	arg=$fullpath
	iconPath=$fullpath/icon.png
	autocomplete=$title
	text=$title
	quicklookurl=$fullpath
	newItem="{
		\"title\": \"$title\",
		\"subtitle\": \"$subtitle\",
		\"arg\": \"$arg\",
		\"icon\": {\"path\":\"$iconPath\"},
		\"autocomplete\": \"$autocomplete\",
		\"type\": \"file:skipcheck\",
		\"text\": \"$text\",
		\"quicklookurl\": \"$quicklookurl\"
	}"
	json=$json,$newItem
done

# Remove leading comma
json="${json:1}"

# Frame final JSON
final="{\"items\": [$json]}"
echo -n $final

# Return
exit 0
