#!/usr/bin/Rscript

#bulkAddTransactions.R

#make sure this is run from the correct directory
if(basename(getwd())!="orestar_scrape") setwd("orestar_scrape")

# source("./productionLoadCandidateFilings.R")
# source("./productionCandidateCommitteeDataWithGrassroots.R")
source("./runScraper.R")
DBNAME="hackoregon"

args <- commandArgs(trailingOnly=TRUE)
fname = args[1]
# fname = "/Users/samhiggins2001_worldperks/prog/hack_oregon/hackOregonBackEnd/raw_committee_transactions.csv"
skipDbUpdate = args[2]
ff = args[3]

rapid = FALSE

cat("\narguments passed:")
print(args)

if(!is.null(ff)){
	cat("ff not null\n")
	if(!is.na(ff)){
		cat("ff not NA")
		if(ff=='quick'){
			cat("argument 'quick' passed!")
			rapid = TRUE
		}
	}
}

if(is.null(skipDbUpdate)|is.na(skipDbUpdate)) skipDbUpdate = "don't skip update"
cat("\nAttempting to load transactions in bulk from the file\n",fname,"\n")
cat("\nRebuild working tables?", skipDbUpdate!="skipRebuild", "\n")
if(rapid){
	cat("\nThe argument 'quick' was passed, thus only missing transactions will be added to the database\n",
			"and transactions which have gained additional information will not be updated.\n")
}else{
	cat("\nTransaction records will be checked to see if additional data is available in imported records.\n")
}
#import to raw tables
cat("Current working directory:",getwd(),"\n")
# fname = "./transConvertedToTsv/successfullyImportedXlsFiles/"
bulkImportTransactions(dbname=DBNAME, tablename="raw_committee_transactions", fname=fname, rapid=rapid)


if(skipDbUpdate!="skipRebuild"){
	#rebuild working tables
	
	#make base working tables
	cat("\nBuilding out database to include data from the the recently imported raw transaction tables.\n")
	setwd("..")
	system("sudo ./buildOutDBFromRawTables.sh")
	#if this is run from the hackoregonbackend dir (from the mac), buildOutDBFromRawTables.sh will be in the parent dir.
	#if this is run from the data_infrastructure folder, (from an ubuntu install) buildOutDBFromRawTables.sh will
	#be in the parent dir.
	#make special tables
	
	#make working_candidate_committees
	#!!! created immediately before campaign_detail, in the same SQL script
	#make campaign_detail
	
}

system(command="sudo ~/hackOregonDbStatusLogger.R bulkLoadScrapedCommitteeData.R")

