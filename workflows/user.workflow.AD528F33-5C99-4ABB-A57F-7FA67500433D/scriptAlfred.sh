# Get Alfred directory
dirAlfred=~/Repos/Alfred.alfredpreferences

# Get workflows directory
dirWorkflows=$dirAlfred/workflows

# Get Alfred icon path
iconPathAlfred="/Applications/Alfred 4.app/Contents/Resources/appicon.icns"

# Open JSON variable
json=""

# Add item to modify entire repo
repoItem="{
	\"title\": \"Alfred.alfredpreferences\",
	\"subtitle\": \"$dirAlfred\",
	\"arg\": \"$dirAlfred\",
	\"icon\": {\"path\":\"$iconPathAlfred\"},
	\"autocomplete\": \"$dirAlfred\",
	\"text\": \"$dirAlfred\",
	\"quicklookurl\": \"$dirAlfred\"
}"
json=$json,$repoItem

# Open main loop through workflows
ls -1 ~/Repos/Alfred.alfredpreferences/workflows | while read -r dirWkflw
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
