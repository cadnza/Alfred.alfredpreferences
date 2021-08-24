#!/usr/bin/env zsh

# Identify target directory
braveDir="/Users/cadnza/Library/Application Support/BraveSoftware/Brave-Browser" # Change to ~ #TEMP

# Get metadata file
braveFile="$braveDir/Local State"

# Convert to JSON
jsonMaster=$(cat $braveFile | jq .)

# Subset JSON for profiles
jsonSubsets=$(cat $braveFile | jq -c '.profile.info_cache | to_entries[]')

# Open loop for profiles
echo $jsonSubsets | while read -r jsonSubset
do

	# Get profile directory
	profileDir=$(echo $jsonSubset | jq -r '.key')

	# Subset JSON for profile directory
	jsonProfile=$(echo $jsonSubset | jq "select(.key == \"$profileDir\")")

	# Get profile name
	d_profile=$(echo $jsonProfile | jq -r '.value.name')

	# Get icon
	d_icon=$(echo $jsonProfile | jq -r '.value.avatar_icon')

	# Get directory for focus profile
	profileDir=$braveDir/$profileDir

	# Get bookmarks file
	bookmarks=$profileDir/bookmarks

	# Convert bookmarks file to JSON
	jsonBm=$(cat $bookmarks | jq .)

	# Get root node
	jsonRoot=$(echo $jsonBm | jq -r '.roots')

	# Get nodes containing url attributes
	urlPaths=$(echo $jsonRoot | jq -rc 'paths | select(.[-1] == "url") | del(. | last) | join(".")')

	# Open paths loop
	echo $urlPaths | while read -r urlPath
	do

		# Format node path
		urlPath=$(
			echo .$urlPath |
			sed 's/\s*$//g' |
			perl -pe 's/\.(?=\d+)/[/g' |
			perl -pe 's/(?<=\d)(?=\.)/]/g' |
			perl -pe 's/(?<=\d)$/]/g'
		)

		# Get bookmark name
		selector=$urlPath".name"
		d_name=$(echo $jsonRoot | jq -r $selector)

		# Get URL
		selector=$urlPath".url"
		d_url=$(echo $jsonRoot | jq -r $selector)

		# Get display path
		urlPathSplit=$(echo $urlPath | perl -pe 's/(?<=.)\./\n./g')
		urlPath=""
		displayPath=""
		echo $urlPathSplit | while read -r emt
		do
			urlPath=$urlPath$emt
			emtName=$(echo $jsonRoot | jq -r $urlPath | jq -r '.name')
			emtType=$(echo $jsonRoot | jq -r $urlPath | jq -r '.type')
			[[ $emtType = folder ]] && displayPath="$displayPath / $emtName"
		done
		displayPath="[ $(echo $displayPath | perl -pe 's/^\s*\/\s*//') ]"

		# Get subtitle
		d_subtitle="$displayPath $d_url"

		# Create JSON element
		# Do we need to specify 'action', or does 'arg' take care of that? #TEMP
		newItem="{
			\"title\": \"$d_name\",
			\"subtitle\": \"$d_subtitle\",
			\"arg\": \"$d_url\",
			\"icon\": {\"path\":\"$d_icon\"},
			\"autocomplete\": \"$d_name\",
			\"text\": \"$d_url\",
			\"quicklookurl\": \"$d_url\"
		}"

		echo $newItem, #TEMP

	# Close paths loop
	done

# Close profiles loop
done
