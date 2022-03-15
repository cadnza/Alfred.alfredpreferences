#!/usr/local/bin/Rscript --vanilla

# Go ----
f <- commandArgs(TRUE)
tryCatch(
	{
		ocr <- tesseract::ocr(f,"rus")
		ocr <- gsub("'","\\'",ocr,fixed=TRUE)
	},
	error=function(x){
		if(grepl("Failed loading language",x,fixed=TRUE))
			quit(1,save="no")
		if(grepl("Failed to read image",x,fixed=TRUE))
			quit(2,save="no")
	}
)

# Return ----
cat(ocr)

# Exit ----
quit(0,save="no")
