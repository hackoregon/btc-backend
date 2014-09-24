#!/usr/bin/Rscript
cat("\nRunning bulkLoadScrapedCommitteeData.R\n",
		"from working directory:\n",
		getwd(),"\n")

setwd("./orestar_scrape/")
source('./runScraper.R')
dbname="hackoregon"
# dbname = "hack_oregon"

bulkLoadScrapedCommitteeData(committeefolder="raw_committee_data", 
														 dbname=dbname, 
														 comTabName="raw_committees_scraped")
cat("\n..\n")