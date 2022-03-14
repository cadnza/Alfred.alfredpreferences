#!/usr/local/bin/Rscript --vanilla

# Go ----
f <- commandArgs(TRUE)
tryCatch(
	{
		ocr <- tesseract::ocr(f,"rus")
		ocr <- gsub("'","\\'",ocr,fixed=TRUE)
	},
	error=function(x)
		quit(1,save="no")
)

# Return ----
cat(ocr)

# Exit ----
quit(0,save="no")
