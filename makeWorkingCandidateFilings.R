#!/usr/bin/Rscript
cat("\n\nsourcing ~/data_infrastructure/orestar_scrape/productionLoadCandidateFilings.R ..\n")
cat("For this script to run correctly, there must be a file with the substring 'candidateFilings'\n")
cat("in its name, which should be placed in the ~/data_infrastructure/orestar_scrape/ folder.\n\n")
setwd("~/data_infrastructure/orestar_scrape/")
source("./productionLoadCandidateFilings.R")

#get the file name
args <- commandArgs(trailingOnly=TRUE)
fname = args[1]
if(!is.null(fname)){
	if(is.na(fname)) fname=NULL	
}

#make working_candidate_filings
cat("\ncalling makeWorkingCandidateFilings(dbname=\"hackoregon\")\n")
dbname="hackoregon"
# dbname="hack_oregon"
makeWorkingCandidateFilings(dbname=dbname, fname=fname)

if(is.null(fname)){
	cat("\nCandidate filings loaded from the default location:\n",
			"~/data_infrastructure/orestar_scrape/<.xls file wih substring candidateFilings in name>")
}else{
	cat("\nCandidate filings loaded from file:\n",fname,"\n")
	cat("\nMoving this file to ~/loaded_candidate_filings/\n")
	if(!file.exists("~/loaded_candidate_filings")) dir.create("~/loaded_candidate_filings")
	file.rename( from=fname, to=paste0("~/loaded_candidate_filings/",basename(fname)) )
}
