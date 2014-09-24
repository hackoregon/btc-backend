#!/usr/bin/Rscript

#bulkAddTransactions.R

#make sure this is run from the correct directory
if(basename(getwd())!="orestar_scrape") setwd("orestar_scrape")

source("./productionLoadCandidateFilings.R")
source("./productionCandidateCommitteeDataWithGrassroots.R")
source("./runScraper.R")
DBNAME="hackoregon"

args <- commandArgs(trailingOnly=TRUE)
fname = args[1]
skipDbUpdate = args[2]
cat("\nAttempting to load transactions in bulk from the file\n",fname,"\n")
cat("\nRebuild working tables?", skipDbUpdate!="skipRebuild", "\n")
#import to raw tables
cat("Current working directory:",getwd(),"\n")
bulkImportTransactions(dbname=DBNAME, tablename="raw_committee_transactions", fname=fname)

if(skipDbUpdate!="skipRebuild"){
	#rebuild working tables
	
	#make base working tables
	setwd(".building out database to include the recently imported raw tables.")
	system("sudo ./buildOutDBFromRawTables.sh")
	#if this is run from the hackoregonbackend dir (from the mac), buildOutDBFromRawTables.sh will be in the parent dir.
	#if this is run from the data_infrastructure folder, (from an ubuntu install) buildOutDBFromRawTables.sh will
	#be in the parent dir.
	#make special tables
	
	
	#make working_candidate_committees
	#!!! created immediately before campaign_detail, in the same SQL script
	#make campaign_detail
	
}

