#!/usr/bin/env -S Rscript --vanilla

# Read argument ----
x <- commandArgs(TRUE)[1]

# Remove percent sign ----
x <- gsub("%","",x)

# Cast ----
x <- as.numeric(x)

# Multiply ----
x <- x/100

# Return ----
cat(x)

# Exit ----
quit("no",0)
