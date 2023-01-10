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

# Calculate amounts ----
ptrnC <- "c"
amtBase <- ifelse(
	grepl(ptrnC,vars$n,ignore.case=TRUE),
	vars$p*exp(vars$r*vars$t),
	vars$p*(1+vars$r/vars$n)^(vars$n*vars$t)
)
amts <- c(
	`Amount`=amtBase,
	`Per period`=amtBase*vars$r
)

# Define function to format currency ----
curr <- function(x)
	paste0(
		"$",
		formatC(
			x,
			big.mark=",",
			format="f",
			digits=2
		)
	)

# Round amounts ----
for(x in names(amts))
	amts[x] <- round(amts[x])

# Assemble JSON ----
reportSep <- " | "
accumulateString <- ifelse(
	grepl(ptrnC,vars$n,ignore.case=TRUE),
	"Accumulates continuously",
	glue::glue("Accumulates {vars$n} times per period")

)
report <- glue::glue("{curr(vars$p)}{reportSep}{vars$r*100}%{reportSep}{vars$t} periods{reportSep}{accumulateString}")
final <- jsonlite::toJSON(
	list(
		items=lapply(
			names(amts),
			function(x)
				list(
					title=curr(amts[x]),
					subtitle=glue::glue("{x}{reportSep}{report}"),
					arg=amts[x],
					icon=list(
						path=ifelse(
							x=="Amount",
							"stack.png",
							"wings.png"
						)
					),
					match=x,
					autocomplete=x,
					text=list(
						copy=amts[x],
						largetype=curr(amts[x])
					)
				)
		)
	),
	auto_unbox=TRUE
)

# Return ----
cat(final)

# Exit ----
quit("no",0)
