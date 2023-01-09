#!/usr/bin/env -S Rscript --vanilla

# Read and format variables ----
vars <- list()
varsVector <- c(
	"p",
	"r",
	"t",
	"n"
)
for(x in varsVector){
	varVal <- Sys.getenv(x)
	tryCatch(
		vars[[x]] <- as.numeric(varVal),
		warning=function(w)
			vars[[x]] <<- varVal
	)
}

# Calculate amount ----
amount <- ifelse(
	grepl("c",vars$n,ignore.case=TRUE),
	vars$p*exp(vars$r*vars$t),
	vars$p*(1+vars$r/vars$n)^(vars$n*vars$t)
)

# Round amount ----
amount <- round(amount,2)

# Cast amount ----
amount <- as.character(amount)

# Add trailing zero if missing ----
if(grepl("^\\d+\\.\\d$",amount))
	amount <- paste0(amount,"0")

# Return ----
cat(amount)

# Exit ----
quit("no",0)
