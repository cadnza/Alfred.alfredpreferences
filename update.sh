# This script updates the readme and packages workflows into package files for
# download from Github. The idea's to run it after every update.

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
imageDirName=images
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

# Set icon width (unitless)
iconWidth=100

# Open workflow loop
echo $workflows | while read -r workflow
do

	# Set workflow directory
	dirWorkflow=$dirWorkflows/$workflow

	# Get plist
	plist=$dirWorkflow/info.plist

	# Get workflow metadata
	name=$(defaults read $plist name)
	createdby=$(defaults read $plist createdby)
	webaddress=$(defaults read $plist webaddress)
	version=$(defaults read $plist version) 2> /dev/null
	description=$(defaults read $plist description)
	bundleid=$(defaults read $plist bundleid)

	# Get asset name
	[[ ${#bundleid} = 0 ]] && assetName=$(echo $name | sed 's/[^A-z0-9]//g') || assetName=$bundleid

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
			iconFileNew=$assetName.$iconExtensionTarget
			iconPathNew=$imageDir/$iconFileNew
			sips -s format $iconExtensionTarget $iconSource --out $iconPathNew 1> /dev/null
		else
			iconFileNew=$assetName.$iconExtension
			iconPathNew=$imageDir/$iconFileNew
			cp $iconSource $iconPathNew
		fi
		iconPathRelative=$imageDirName/$iconFileNew
		icon="<img src=\"$iconPathRelative\" width=\"$iconWidth\"></img>"
	else
		icon=""
	fi

	# Format version
	if [[ ${#version} -gt 0 ]]
	then
		version=\`$version\`
	fi

	# Add https prefix to web address if not present
	if [[ $(echo $webaddress | grep -Ec ^https?://) = 0 && ${#webaddress} != 0 ]]
	then
		webaddress=https://$webaddress
	fi

	# Sort author
	if [[ ${#createdby} = 0 ]]
	then
		[[ ${#webaddress} = 0 ]] && author="" || author=[*Unlisted*]($webaddress)
	else
		[[ ${#webaddress} = 0 ]] && author=$createdby || author=[$createdby]($webaddress)
	fi

	# Add row to markdown table
	md=$md'\n'
	newRow="| $icon | **$name** | $version | $author | $description |"
	md=$md$newRow

# Close workflow loop
done

# Write updates to readme
wildcard="%workflows%"
echo $template | while read -r line
do
	if [[ $line = $wildcard ]]
	then
		echo $md >> $readme
	else
		echo $line >> $readme
	fi
done
