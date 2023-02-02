#!/usr/bin/env zsh

# This script updates the readme and packages workflows into package files for
# download from Github. The idea's to run it after every update.

# Go to top directory
cd $(git -C $(dirname $0:A) rev-parse --show-toplevel)

# Set readme title
readme=README.md

# Set preferences filename
prefsName="com.cadnza.alfredWorkflowShowcaseUpdater.plist"

# Check whether the preferences file exists
prefsNeedWritten=$(defaults read $prefsName &> /dev/null && echo 0 || echo 1)

# Ask whether to edit settings if they've already been written
[[ $prefsNeedWritten = 0 ]] && {
	editSettings=2
	while [ $editSettings = 2 ]
	do
		echo "Rewrite settings? [y/n]:"
		read editSettingsRaw
		[[ "$editSettingsRaw" == [Yy]* ]] && editSettings=1
		[[ "$editSettingsRaw" == [Nn]* ]] && editSettings=0
	done
}

# Read or write preferences file
if [ $prefsNeedWritten = 1 ] || [ $editSettings = 1 ]
then
	echo "This script updates a README.md file based on an Alfred preferences directory and a template."
	echo -e "\e[3mPlease be sure the script is inside your Alfred.alfredpreferences directory before running!\e[0m"
	echo "Org name:"
	echo -e "(\e[3me.g.\e[0m com.\e[1morgname\e[0m.oranges)"
	read orgNameProprietary
	echo "README template (choose from dialog):"
	echo -e "\e[3mThis should be a markdown file with a line somewhere reading %workflows%.\e[0m"
	echo -e "\e[3mThis script replaces %workflows% with a markdown table showcasing your workflows\e[0m"
	echo -e "\e[3mand saves the results to a file called $readme.\e[0m"
	fileDialogPrompt="README template (see shell prompt)"
	readmeTemplate=$(osascript -e "set directory to POSIX path of (choose file with prompt \"$fileDialogPrompt\")" 2> /dev/null || echo "")
	[[ ${#readmeTemplate} = 0 ]] && return
	[[ $(echo $readmeTemplate | grep -c "\.md$") = 0 ]] && {
		echo "Template file must be in markdown format."
		return
	}
	defaults write $prefsName orgNameProprietary $orgNameProprietary
	defaults write $prefsName readmeTemplate $readmeTemplate
else
	orgNameProprietary=$(defaults read $prefsName orgNameProprietary)
	readmeTemplate=$(defaults read $prefsName readmeTemplate)
fi

# Get repo directory (current directory)
repo=$(greadlink -f ./)

# Set readme path
readmePath=$repo/$readme

# Reset readme file
rm $readmePath 2> /dev/null

# Read in template
template=$(cat $readmeTemplate)

# Get workflows directories
dirWorkflows=$repo/workflows
workflows=$(ls -1 $dirWorkflows)

# Reset images directory (for readme images)
imageDirName=images
imageDir=$repo/$imageDirName
rm -rf $imageDir 2> /dev/null
mkdir $imageDir

# Reset exports directory (for workflow exports)
exportDirName=exports
exportDir=$repo/$exportDirName
rm -rf $exportDir 2> /dev/null
mkdir $exportDir

# Reset details directory (for workflow readme text files)
detailDirName=details
detailDir=$repo/$detailDirName
rm -rf $detailDir 2> /dev/null
mkdir $detailDir

# Open markdown table variable and add header
md="| | Workflow | Version | Author | Description | Link |"
md=$md'\n'
md=$md"|-|-|-|-|-|-|"

# Set target icon file and extension
iconFileTarget=icon.png
iconExtensionTarget=png

# Set icon width (unitless)
iconWidth=100

# Open workflow loop
ptrnLocal="LOCAL$"
echo $workflows | grep -i -v $ptrnLocal | while read -r workflow
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
	descriptionLong=$(defaults read $plist readme)
	bundleid=$(defaults read $plist bundleid)

	# Get asset name
	[[ ${#bundleid} = 0 ]] && assetName=$(echo $name | sed 's/[^A-z0-9]//g') || assetName=$bundleid

	# Get author or organization name from bundle ID
	orgName=$(echo $bundleid | sed 's/^[^\.]*\.//g' | sed 's/\.[^\.]*$//g')

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
		iconPathAbsolute=$imageDir/$iconFileNew
		icon="<img src=\"$iconPathRelative\" width=\"$iconWidth\"></img>"
	else
		iconPathAbsolute=""
		icon=""
	fi

	# Format version
	if [[ ${#version} -gt 0 ]]
	then
		version=\`$version\`
	fi

	# Add https prefix to web address if not present
	if [[ $(echo $webaddress | grep -Ec '^https?://') = 0 && ${#webaddress} != 0 ]]
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

	# Write long description to text file if it exists
	if [[ ${#descriptionLong} != 0 ]]
	then
		descriptionLongFileExtension=md
		descriptionLongFileName=$assetName.$descriptionLongFileExtension
		descriptionLongFilePathAbsolute=$detailDir/$descriptionLongFileName
		descriptionLongFilePathRelative=$detailDirName/$descriptionLongFileName
		echo $descriptionLong > $descriptionLongFilePathAbsolute
		descriptionLongLinkText="*More info*"
		descriptionLongLink=[$descriptionLongLinkText]($descriptionLongFilePathRelative)
		[[ ${#description} = 0 ]] && descriptionBreak="" || descriptionBreak="<br/>"
		description=$description$descriptionBreak$descriptionLongLink
	fi

	# Check whether workflow belongs to user (to decide whether to provide download link)
	if [[ $orgName = $orgNameProprietary ]]
	then

		# Copy workflow to temporary directory for image replacement pending export
		dirTemp=$(mktemp -d)
		cp -r $dirWorkflow/. $dirTemp

		# Copy new image to temporary directory
		[[ ${#iconPathAbsolute} != 0 ]] && cp $iconPathAbsolute $dirTemp/$iconFileTarget

		# Export temporary directory to Alfred workflow file
		alfredFileName=$assetName.alfredworkflow
		alfredFilePath=$exportDir/$alfredFileName
		cd $dirTemp
		zip -qr $alfredFilePath .

		# Remove temporary directory
		rm -rf $dirTemp

		# Get relative path to new Alfred workflow for download link
		alfredFilePathRelative=$exportDirName/$alfredFileName

		# Assign relative file path to workflow address
		workflowAddress=$alfredFilePathRelative

		# Set link text to download
		linkText=Download

	# Add logic for workflows that don't belong to the user
	else

		# Assign web address to workflow address
		workflowAddress=$webaddress

		# Set link text to visit site
		linkText="Visit site"

	# End workflow link synthesis logic
	fi

	# Get formatted link
	if [[ ${#workflowAddress} = 0 ]]
	then
		link=""
	else
		link="[$linkText]($workflowAddress)"
	fi

	# Add row to markdown table
	md=$md'\n'
	newRow="| $icon | **$name** | $version | $author | $description | $link |"
	md=$md$newRow

# Close workflow loop
done

# Write updates to readme
wildcard="%workflows%"
echo $template | while read -r line
do
	if [[ $line = $wildcard ]]
	then
		echo $md >> $readmePath
	else
		echo $line >> $readmePath
	fi
done

# Exit
exit 0
