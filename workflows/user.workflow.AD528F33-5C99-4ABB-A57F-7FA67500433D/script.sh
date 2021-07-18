# Get repo directory
dirRepos=$1

# Get icon paths
iconPathDefault="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericFolderIcon.icns" # Folder
iconPathAlfred="/Applications/Alfred 4.app/Contents/Resources/appicon.icns" # Alfred logo

# Open JSON variable
json=""

# Open main loop through repos
ls $dirRepos | while read -r repo
do
	fullpath=$dirRepos/$repo
	if [ $repo = "Alfred.alfredpreferences" ]
	then
		title="Alfred workflows"
		iconPath=$iconPathAlfred
	else
		title=$repo
		iconPath=$iconPathDefault
	fi
	subtitle=$fullpath
	arg=$fullpath
	autocomplete=$repo
	text=$fullpath
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
