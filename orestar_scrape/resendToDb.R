#!/usr/bin/Rscript
cat("\nRe-sending txt files to db\n")

source('~/data_infrastructure/orestar_scrape/runScraper.R')

scrapedTransactionsToDatabase(tableName="raw_committee_transactions", dbname="hackoregon", tsvFolder="transConvertedToTsv")