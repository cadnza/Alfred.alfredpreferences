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
imageDirName=readmeImages
imageDir=$repo/$imageDirName
rm -rf $imageDir 2> /dev/null
mkdir $imageDir

# Open markdown table variable and add header
md="| | Workflow | Version | Author | Description |"
md=$md'\n'
md=$md"|-|-|-|-|-|"

# Set target icon file and extension
iconFileTarget=icon.png
iconExtensionTarget=png

# Set icon width and unit
iconWidth=1
iconWidthUnit=in

# Get workflow metadata
echo $workflows | while read -r workflow
do
	# Set workflow directory
	dirWorkflow=$dirWorkflows/$workflow
	# Get plist
	plist=$dirWorkflow/info.plist
	# Get workflow icon
	iconPre=$dirWorkflow/$iconFileTarget
	if [[ -f "$iconPre" ]]
	then
		if [[ -L "$iconPre" ]]
		then
			iconSource=$(greadlink $iconPre)
		else
			iconSource=$iconPre
		fi
		iconExtension=$(file -b "$iconSource" --extension)
		if [[ $iconExtension = icns ]]
		then
			iconFileNew=$(uuidgen).$iconExtensionTarget
			iconPathNew=$imageDir/$iconFileNew
			sips -s format $iconExtensionTarget $iconSource --out $iconPathNew 1> /dev/null
		else
			iconFileNew=$(uuidgen).$iconExtension
			iconPathNew=$imageDir/$iconFileNew
			cp $iconSource $iconPathNew
		fi
		iconPathRelative=$imageDirName/$iconFileNew
		icon="<img src=\"$iconPathRelative\" width=\"$iconWidth$iconWidthUnit\"></img>"
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
