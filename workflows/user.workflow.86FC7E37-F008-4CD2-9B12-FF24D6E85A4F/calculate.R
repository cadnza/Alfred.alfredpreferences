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
ptrnC <- "c"
amount <- ifelse(
	grepl(ptrnC,vars$n,ignore.case=TRUE),
	vars$p*exp(vars$r*vars$t),
	vars$p*(1+vars$r/vars$n)^(vars$n*vars$t)
)

# Calculate amount per period at rate ----
amountPerPeriod <- amount*vars$r

# Define function to format currency ----
curr <- function(x,prty=TRUE)
	paste0(
		ifelse(prty,"$",""),
		formatC(
			x,
			big.mark=ifelse(prty,",",""),
			format="f",
			digits=2
		)
	)

# Format amounts ----
amount <- curr(amount,FALSE)
amountPerPeriod <- curr(amountPerPeriod,FALSE)

# Assemble JSON ----
reportSep <- " | "
accumulateString <- ifelse(
	grepl(ptrnC,vars$n,ignore.case=TRUE),
	"Accumulates continuously",
	glue::glue("Accumulates {vars$n} times per period")

)
report <- glue::glue("{curr(vars$p)}{reportSep}{vars$r}{reportSep}{vars$t} periods{reportSep}{accumulateString}")
final <- jsonlite::toJSON(
	list(
		items=list(
			list(
				title=amount,
				subtitle=glue::glue("Amount{reportSep}{report}")
				# ROAD WORK #TEMP
			),
			list(
				title=amountPerPeriod,
				subtitle=glue::glue("Per period{reportSep}{report}")
				# ROAD WORK #TEMP
			)
		)
	),
	auto_unbox=TRUE
)

# Return ----
cat(final)

# Exit ----
quit("no",0)
