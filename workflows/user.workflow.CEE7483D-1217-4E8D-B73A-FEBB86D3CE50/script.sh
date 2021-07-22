/Library/Frameworks/R.framework/Resources/bin/Rscript partsearch.R $1 2> /dev/null || {
	title="Install R via Homebrew"
	link="https://www.r-project.org/"
	rMessage="{\"items\": [{
		\"title\": \"$title\",
		\"subtitle\": \"R installation not found\",
		\"arg\": \"noR\",
		\"icon\": {\"path\":\"$dirAlfred\",\"type\":\"fileicon\"},
		\"autocomplete\": \"$title\",
		\"text\": \"$title\",
		\"quicklookurl\": \"$dirAlfred\"
	}]}"
	echo $rMessage
}
