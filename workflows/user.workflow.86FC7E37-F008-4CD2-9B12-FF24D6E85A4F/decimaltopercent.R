#!/usr/bin/env -S Rscript --vanilla

# Read argument ----
x <- commandArgs(TRUE)[1]

# Check if already percent ----
if(!grepl("%",x)){

	# Cast ----
	x <- as.numeric(x)

	# Multiply ----
	x <- x*100

	# Add percent sign ----
	x <- paste0(x,"%")

}

# Return ----
cat(x)

# Exit ----
quit("no",0)
