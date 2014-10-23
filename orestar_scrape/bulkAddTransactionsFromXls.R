#!/usr/bin/Rscript
setwd("~/data_infrastructure/orestar_scrape/")

cat("This script should be run with one argument:
		The absolute (or relative to ~) path of the
		folder containing the .xls files to be imported.")
source("./runScraper.R")
args <- commandArgs(trailingOnly=TRUE)
indir = args[1]
cat("Argument passed:",indir,"\n")
destDir="./specialXlsImport/"
tableName="raw_committee_transactions"
dbname="hackoregon"

if( !file.exists(destDir) ) dir.create(path=destDir, showWarnings=FALSE, recursive=T )

converted = importAllXLSFiles(remEscapes=T,
															remQuotes=T,
															forceImport=T,
															indir=indir,
															destDir=destDir)

scrapedTransactionsToDatabase(tsvFolder=destDir, 
															tableName=tableName, 
															dbname=dbname)

system(command="sudo ../buildOutDBFromRawTables.sh")

system(command=paste("sudo ~/hackOregonDbStatusLogger.R 'bulkAddTransactionsFromXls.R",indir,"'"))