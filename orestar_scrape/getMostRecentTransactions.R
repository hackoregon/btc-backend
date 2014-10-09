#!/usr/bin/Rscript
# getMostRecentTransactions.R
#assure the correct working directory is used.
if( !grepl( pattern="orestar_scrape", x=getwd() ) ){
	if( file.exists( "~/data_infrastructure/orestar_scrape/" ) ){ setwd("~/data_infrastructure/orestar_scrape/") 
	}else if( file.exists("orestar_scrape") ){ setwd("orestar_scrape") 
	}else{ message("Warning, cannot find correct working directory!!") }
} 
source('./runScraper.R')
# args <- commandArgs(trailingOnly=TRUE)
# DBNAME=args[2]
DBNAME="hack_oregon"
if( file.exists( "~/data_infrastructure/orestar_scrape/" ) ) DBNAME="hackoregon"
# setwd("orestar_scrape")
cat("\nRunning getMostRecentTransactions.R")
#scrape the transaction data, filling in missing committees. 
dateRangeControler(dbname=DBNAME, tranTableName="raw_committee_transactions", workingComTabName="working_committees")

#rebuild the database working tables
	#first assure the working directory is correct? yes, buildOutFromRaw... seem to require it. 
cat("Inside getMostRecentTransactions.R, setting working directory to the data_infrastructure directory\n",getwd(), "\n")
setwd("..")
cat("Running buildOutDBFromRawTables.sh\n")
system(command="sudo ./buildOutDBFromRawTables.sh")
cat("\ngetMostRecentTransactions.R complete")

system(command="sudo ~/hackOregonDbStatusLogger.R getMostRecentTransactions.R")