#!/usr/bin/Rscript

source("./runScraper.R")


tranTableName="raw_committee_transactions"
workingComTabName="working_committees"
dbname="hackoregon"

getMissingCommittees(transactionsTable=tranTableName, 
										 dbname=dbname, 
										 workingComTabName=workingComTabName)