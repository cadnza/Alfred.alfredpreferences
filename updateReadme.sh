# Set readme title
readme=./README.md

# Get repo directory
repo=$(greadlink -f ./)

# Reset readme file
rm $readme 2> /dev/null

# Read in template
template=$(cat ./READMEtemplate.md)

# Get workflows directories
dirWorkflows=$repo/workflows
workflows=$(ls -1 $dirWorkflows)

# Reset images directory
imageDir=$repo/readmeImages
rm -rf $imageDir 2> /dev/null
mkdir $imageDir

# Open markdown table variable and add header
md="| | Workflow | Version | Author | Description |"
md=$md'\n'
md=$md"|-|-|-|-|-|"

# Get workflow metadata
echo $workflows | while read -r workflow
do
	# Set workflow directory
	dirWorkflow=$dirWorkflows/$workflow
	# Get plist
	plist=$dirWorkflow/info.plist
	# Get workflow icon
	iconPre=$dirWorkflow/icon.png
	if [[ -f "$iconPre" ]]
	then
		if [[ -L "$iconPre" ]]
		then
			iconSource=$(greadlink $iconPre)
			iconName=$(basename $iconSource)
			iconPath=$imageDir/$iconName
			cp $iconSource $iconPath
		else
			iconPath=$iconPre
		fi
		icon="![]($iconPath)"
	else
		icon=""
	fi
	# Get workflow metadata
	name=$(defaults read $plist name)
	createdby=$(defaults read $plist createdby)
	webaddress=$(defaults read $plist webaddress)
	version=$(defaults read $plist version)
	description=$(defaults read $plist description)
	# Add row to markdown table
	md=$md'\n'
	newRow="| $icon | $name | $version | $createdby | $description |"
	md=$md$newRow
done

echo $template | while read -r line
do
	if [[ $line = "%workflows%" ]]
	then
		echo $md >> $readme
	else
		echo $line >> $readme
	fi
done
