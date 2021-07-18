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
	title=$repo
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
