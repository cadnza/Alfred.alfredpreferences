#!/usr/bin/env -S Rscript --vanilla

# Clean house ----
rm(list=ls())

# Get part number from user ----
arguments <- commandArgs(TRUE)
if(!length(arguments)){
	alfred_workflow_data <- "~" # Testing
	part <- "93792" # Testing
}else{
	alfred_workflow_data <- arguments[1]
	part <- arguments[2]
}

# Set filename ----
filename <- file.path(alfred_workflow_data,"index.rds")

# Set base URL ----
baseURL <- "https://www.bricklink.com"

# Set output function ----
send <- function(x){
	output <- jsonlite::toJSON(list(items=x),pretty=TRUE)
	output <- gsub("\\[\"","\"",as.character(output))
	output <- gsub("\"\\]","\"",as.character(output))
	cat(output)
}

# Set function to synthesize links ----
getUrlById <- function(partID,type){
	if(!type%in%c("specific","specific2","general"))
		stop("Please use either 'specific' or 'general' for the link type.")
	if(type=="specific")
		returnLink <- paste0(
			"https://www.bricklink.com/v2/catalog/catalogitem.page?P=",
			partID
		)
	else if(type=="specific2")
		returnLink <- paste0(
			"https://www.bricklink.com/catalogList.asp?searchMethod=searchNo&q=",
			partID,
			"&catType=P"
		)
	else if(type=="general")
		returnLink <- paste0(
			"https://www.bricklink.com/v2/search.page?q=",
			partID,
			"#T=P"
		)
	return(returnLink)
}

# Set main function ----
getCandidates <- function(part){

	# Set function to refresh data ----
	pullData <- function(){

		# Get part data ----
		parts <- read.delim(
			"/Applications/Studio 2.0/data/StudioPartDefinition2.txt",
			header=FALSE
		)
		colnames(parts) <- as.character(as.matrix(parts[1,]))
		parts <- parts[-1,1:ncol(parts)-1]
		parts <- parts[parts$EasyModeIndex>0,]
		parts <- parts[order(parts$EasyModeIndex,parts$`BL ItemNo`),]
		parts$Lookup <- paste(
			parts$EasyModeIndex,
			parts$BLCatalogIndex,
			parts$BLCatalogSubIndex,
			sep="_"
		)
		parts <- parts[,
									 c(
									 	"BL ItemNo",
									 	"Description",
									 	"Lookup"
									 )
		]
		colnames(parts) <- c(
			"ID",
			"Description",
			"Lookup"
		)
		parts$ID <- as.character(parts$ID)
		parts$Description <- as.character(parts$Description)
		rownames(parts) <- 1:nrow(parts)
		parts <- parts[!grepl("p",parts$ID),]

		# Get category data ----
		categories <- read.delim(
			"/Applications/Studio 2.0/data/StudioCategoryDefinition.txt"
		)
		categories <- unique(categories)
		categories <- categories[
			order(
				categories$easymode,
				categories$BL.CatalogName
			),
		]
		categories$BL.CatalogName <- trimws(categories$BL.CatalogName)
		categories$BL.CatalogName <- sapply(
			categories$BL.CatalogName,
			function(x) gsub(intToUtf8(160),"",x)
		)
		categories <- categories[!is.na(categories$easymode),]
		categories$Lookup <- paste(
			categories$easymode,
			categories$BL.Index,
			categories$subIndex,
			sep="_"
		)
		categories$sub <- as.numeric(
			ave(categories$Lookup,categories$easymode,FUN=seq_along)
		)
		categories <- categories[
			,
			c(
				"Lookup",
				"easymode",
				"sub",
				"Shape.Name",
				"BL.CatalogName"
			)
		]
		colnames(categories) <- c(
			"Lookup",
			"Index",
			"SubIndex",
			"Name",
			"SubName"
		)
		for(i in 1:nrow(categories)){
			if(!nchar(categories$Name[i])){
				testSet <- categories[
					categories$Index==categories$Index[i]&
						nchar(categories$Name),
				]
				if(length(unique(testSet$Name))>1)
					stop(
						paste(
							"The function that's supposed to",
							"fill in empty supercategory names broke.",
							"Sorry. :-/"
						)
					)
				categories$Name[i] <- unique(testSet$Name)[1]
			}
		}
		rownames(categories) <- NULL

		# Merge tables ----
		lookup <- merge(parts,categories,"Lookup")
		lookup$Lookup <- NULL

		# Save RDS ----
		saveRDS(lookup,filename)

		# Return ----
		return(lookup)
	}

	# Refresh part data if needed ----
	tryCatch(
		expr={
			lookup <<- readRDS(filename)
			cdate <- as.Date(file.info(filename)$ctime)
			margin <- as.integer(Sys.Date()-cdate)
			if(margin!=0){warning()}
		},
		warning=function(x){
			lookup <<- pullData()
		}
	)

	# Get part candidates ----
	rmsp <- function(x){
		return(gsub(" *","",x))
	}
	getCandidates2 <- function(partID,strictID,imageFile){

		# Collect candidates ----
		candidates <- rbind(
			lookup[lookup$ID==partID,],
			if(!strictID)
				lookup[grepl(paste0("^","(",paste(partID,collapse="|"),")"),lookup$ID),],
			if(!strictID)
				lookup[
					grepl(
						paste(
							rmsp(partID),collapse="|"
						),
						rmsp(lookup$Description),ignore.case=TRUE
					),
				]
		)
		candidates <- candidates[!is.na(candidates$ID),]
		candidates <- unique(candidates)

		# Sort part candidates ----
		if(nrow(candidates)){
			sort1 <- c()
			sort2 <- c()
			for(i in 1:nrow(candidates)){
				sort1[i] <- regmatches(
					candidates[i,"ID"],
					regexpr("^\\d*",candidates[i,"ID"])
				)
				sort2[i] <- regmatches(
					candidates[i,"ID"],
					regexpr("\\d*",candidates[i,"ID"])
				)
			}
			candidates$sort1 <- as.integer(sort1)
			candidates$sort2 <- as.integer(sort2)
			candidates[is.na(candidates$sort1),"sort1"] <- max(
				candidates$sort1,na.rm=TRUE
			)+1
			candidates[is.na(candidates$sort2),"sort2"] <- max(
				candidates$sort2,na.rm=TRUE
			)+1
			candidatesorder <- order(
				candidates$Index,
				candidates$sort1,
				candidates$sort2,
				candidates$ID
			)
			candidates <- candidates[candidatesorder,]
			rownames(candidates) <- 1:nrow(candidates)
			candidates$sort1 <- NULL
			candidates$sort2 <- NULL
		}

		# Add image file
		if(nrow(candidates))
			candidates$icon <- imageFile

		# Return candidates ----
		return(candidates)
	}

	# Search strict IDs ----
	candidates <- getCandidates2(part,strictID=TRUE,imageFile="images/red.png")

	# Search alternate IDs ----
	if(!nrow(candidates))
		if(grepl("^\\d*$",part)){
			partSearchHTML <- xml2::read_html(getUrlById(part,"specific2"))
			partTrueId <- xml2::xml_text(
				xml2::xml_find_all(partSearchHTML,"//*[@class='innercontent']//td")[1]
			)
			if(length(partTrueId)){
				partTrueId <- system(
					paste("echo",partTrueId,"| grep -o '\\d*$'"),
					intern=TRUE
				)
				candidates <- rbind(
					candidates,
					getCandidates2(partTrueId,strictID=TRUE,imageFile="images/green.png")
				)
			}
		}

	# Add non-strict candidates ----
	candidates <- rbind(
		candidates,
		getCandidates2(part,strictID=FALSE,imageFile="images/blue.png")
	)

	# Filter for uniques ----
	if(nrow(candidates))
		candidates <- candidates[
			sapply(
				1:nrow(candidates),
				function(x)
					length(candidates[1:x,]$ID[candidates[1:x,]$ID==candidates$ID[x]])
			)==1,
		]

	# Default to no results ----
	if(!nrow(candidates)){
		output <- list()
		output[[1]] <- list(
			title="Nothing here.",
			subtitle=paste(
				"Different search term, maybe?",
				"Or press Enter to search the BrickLink site."
			),
			text=list(
				copy=part,
				largetype="¯\\_(ツ)_/¯"
			),
			arg=getUrlById(part,"general"),
			icon=list(
				path="images/white.png"
			)
		)
		return(output)
	}

	# Output candidates ----
	output <- list()
	for(i in 1:nrow(candidates)){
		categoryText <- paste0(
			"[",
			candidates[i,"Name"],
			"]",
			" — ",
			candidates[i,"SubName"]
		)
		output[[i]] <- list(
			title=paste0("",candidates[i,"ID"],": ",candidates[i,"Description"]),
			subtitle=categoryText,
			arg=getUrlById(candidates[i,"ID"],"specific"),
			mods=list(
				command=list(
					subtitle="Perform a general search",
					arg=getUrlById(candidates[i,"ID"],"general")
				),
				alt=list(
					subtitle="Assign ⌥ action"
				)
			),
			text=list(
				copy=candidates[i,"ID"],
				largetype=paste0(
					candidates[i,"ID"],
					"\n",
					"\n",
					candidates[i,"Description"],
					"\n",
					"\n",
					categoryText
				)
			),
			quicklookurl=paste0(
				"https://img.bricklink.com/ItemImage/PL/",
				candidates[i,"ID"],
				".png"
			),
			icon=list(
				path=candidates[i,"icon"]
			)
		)
	}

	# Return ----
	return(output)
}

# Forward output ----
send(getCandidates(part))

# Exit ----
if(length(arguments))
	quit(status=0)
