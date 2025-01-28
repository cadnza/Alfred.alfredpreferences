#!/usr/bin/env bash

# Set Steam games directory
gamesDir="$HOME/Library/Application Support/Steam/steamapps/common"

# Validate directory
[[ -d $gamesDir ]] || {
	final=$(
		jq -n --arg gamesDir "$gamesDir" '{
			items: [
				{
					title: "Directory not found",
					subtitle: $gamesDir,
					valid: false
				}
			]
		}'
	)
	echo "$final"
	exit 0
}

# Initialize JSON
final=$(echo '[]' | jq)

# Build JSON
while read -r f
do
	final=$(
		echo "$final" | \
		jq \
		--arg title "$(basename "$f" | sed 's/\.app$//g')" \
		--arg original "$f" \
		--arg identifier "$(mdls -r "$f" -attr kMDItemCFBundleIdentifier)" \
		'
			. |= . + [
				{
					title: $title,
					subtitle: $identifier,
					arg: $original,
					icon: {
						type: "fileicon",
						path: $original
					},
					type: "file:skipcheck",
					text: $title,
					quicklookurl: $original
				}
			]
		'
	)
done <<< "$(
	find "$gamesDir" \
		-mindepth 2 \
		-maxdepth 2 \
		-type d \
		-name "*.app"
)"

# Finalize JSON
final=$(echo "$final" | jq '{items: .}')

# Return
echo -n "$final"

# Exit
exit 0
