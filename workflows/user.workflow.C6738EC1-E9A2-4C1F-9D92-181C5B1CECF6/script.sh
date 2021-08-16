#!/usr/bin/env zsh

# Get repo directory
dirRepos=$1

# Get folder icon path
iconPath="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericFolderIcon.icns"

# Open JSON variable
json=""

# Open main loop through repos
ls $dirRepos | while read -r repo
do
	fullpath=$dirRepos/$repo
	filterpattern="\.Rproj$"
	candidates=$(ls -1 $fullpath | grep -i $filterpattern)
	hasRproj=$(echo $candidates | grep -c .)
	[ $hasRproj = 0 ] && continue
	title=$repo
	subtitle=$fullpath
	arg=$fullpath/$candidates
	autocomplete=$repo
	text=$fullpath
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

# Remove final comma
json="${json:1}"

# Frame final JSON
final="{\"items\": [$json]}"
echo -n $final
