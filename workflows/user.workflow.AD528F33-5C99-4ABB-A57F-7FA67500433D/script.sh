# Get repo directory
dirRepos=$1

# Open JSON variable
json=""

# Open main loop through repos
allRepos=$(eval $(echo ls -d $(echo $dirRepos | sed 's/\/*$//')/\*/))
echo $allRepos | while read -r repoRaw
do
	repo=$(basename $repoRaw)
	fullpath=$repoRaw
	#if [ $repo = "Alfred.alfredpreferences" ]
	#then
	#	title="Alfred workflows"
	#else
		title=$repo
	#fi
	subtitle=$fullpath
	arg=$fullpath
	autocomplete=$repo
	text=$fullpath
	quicklookurl=$fullpath
	newItem="{
		\"title\": \"$title\",
		\"subtitle\": \"$subtitle\",
		\"arg\": \"$arg\",
		\"icon\": {\"path\":\"$fullpath\",\"type\":\"fileicon\"},
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
