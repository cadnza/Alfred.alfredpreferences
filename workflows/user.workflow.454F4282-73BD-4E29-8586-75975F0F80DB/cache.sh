#!/usr/bin/env zsh

# Initialize JSON
final=$(echo '[]' | jq)

# Get raw man paths
manpathsRaw=$(cat /etc/man.conf | grep "^MANPATH")

# Build JSON by parsing available man pages
echo $manpathsRaw | while read -r manpathRaw
do
	manpath=$(echo $manpathRaw | sed -E 's/^MANPATH[[:space:]]//g')
	[ -d $manpath ] || continue
	pages=$(find $manpath -mindepth 1 -type f)
	echo $pages | while read -r page
	do
		pageName="$(basename $page | sed "s/\.[^\.]*$//g")"
		categoryNumber=$(basename $(dirname $page) | sed 's/^man//g')
		[ -z "$page" ] && continue
		final=$(
			echo $final | \
			jq \
			--arg page $page \
			--arg pageName $pageName \
			--arg pageNameFull "$pageName($categoryNumber)" \
			--arg categoryNumber $categoryNumber \
			--arg mpath $manpath \
			'
				. |= . + [
					{
						title: $pageNameFull,
						subtitle: $mpath,
						arg: $pageName,
						icon: {
							type: "fileicon",
							path: $page
						},
						type: "default",
						text: $pageName,
						quicklookurl: $page
					}
				]
			'
		)
	done
done

# Finalize JSON
final=$(echo $final | jq '{items: .}')

# Save JSON file
destJSON="$alfred_workflow_cache/cache.json"
echo $destJSON > DESTINATION #TEMP
echo $final > $destJSON

# Exit
exit 0
