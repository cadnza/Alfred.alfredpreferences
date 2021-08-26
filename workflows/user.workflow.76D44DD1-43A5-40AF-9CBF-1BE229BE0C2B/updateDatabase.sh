#!/usr/bin/env zsh

# Add /usr/local/bin to path
PATH=/usr/local/bin:$PATH

# Get database path and table creation function
db=$1
safeCreate() {
	sqlite3 $db "CREATE TABLE IF NOT EXISTS $1 (profile TEXT NOT NULL, json TEXT NOT NULL);"
}

# Create stage if needed
safeCreate stage

# Truncate stage for good measure (should already be empty)
sqlite3 $db "DELETE FROM stage;"

# Identify target directory
braveDir="$HOME/Library/Application Support/BraveSoftware/Brave-Browser"

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

	# Get profile identifier
	d_profile=$(basename $profileDir)

	# Subset JSON for profile directory
	jsonProfile=$(echo $jsonSubset | jq "select(.key == \"$profileDir\")")

	# Get profile name
	d_profileName=$(echo $jsonProfile | jq -r '.value.name') # Use this #TEMP

	# Get icon
	d_icon=$(echo $jsonProfile | jq -r '.value.avatar_icon') # This returns a URL scheme that only Chromium browsers can read. We need to find a way to turn it into either a usable URL or a file (preferably a file). #TEMP

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

		# Get bookmark path
		urlPathSplit=$(echo $urlPath | perl -pe 's/(?<=.)\./\n./g')
		urlPath=""
		bookmarkPathRaw=$d_profileName
		echo $urlPathSplit | while read -r emt
		do
			urlPath=$urlPath$emt
			emtName=$(echo $jsonRoot | jq -r $urlPath | jq -r '.name')
			emtType=$(echo $jsonRoot | jq -r $urlPath | jq -r '.type')
			[[ $emtType = folder ]] && bookmarkPathRaw="$bookmarkPathRaw"'_/_'"$emtName"
		done
		bookmarkPath=$(echo $bookmarkPathRaw | sed 's/_\/_/ /g')

		# Format display path
		displayPath=$(echo $bookmarkPathRaw | sed 's/_\/_/ \/ /g')
		displayPath="[ $(echo $displayPath | perl -pe 's/^\s*\/\s*//') ]"

		# Get subtitle
		d_subtitle="$displayPath $d_url"

		# Create JSON element
		# The "icon" field is currently not in use (note "_icon" in the JSON)
		newItem=$(
			jq -nc \
				--arg title "$d_name" \
				--arg subtitle "$d_subtitle" \
				--arg arg "$d_url" \
				--arg icon "$d_icon" \
				--arg match "$bookmarkPath $d_name" \
				--arg autocomplete "$d_name" \
				--arg text "$d_url" \
				--arg quicklookurl "$quicklookurl" \
				'{
					"title": $title,
					"subtitle": $subtitle,
					"arg": $arg,
					"_icon": {"path": $icon},
					"match": $match,
					"autocomplete": $autocomplete,
					"text": $text,
					"quicklookurl": $quicklookurl
				}'
		)

		# Format JSON element for sqlite insert
		newItem=$(echo $newItem | sed "s/'/''/g" | perl -pe 's/[\t\n]//g')

		# Insert into stage
		sqlite3 $db "INSERT INTO stage VALUES ('$d_profile','$newItem');"

	# Close paths loop
	done

# Close profiles loop
done

# Create prod if needed
safeCreate prod

# Replace prod with stage
sqlite3 $db "DELETE FROM prod;"
sqlite3 $db "INSERT INTO prod SELECT * FROM stage;"

# Truncate stage
sqlite3 $db "DELETE FROM stage;"
