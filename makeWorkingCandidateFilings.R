#!/usr/bin/Rscript
cat("\n\nsourcing ~/data_infrastructure/orestar_scrape/productionLoadCandidateFilings.R ..\n")
cat("For this script to run correctly, there must be a file with the substring 'candidateFilings'\n")
cat("in its name, which should be placed in the ~/data_infrastructure/orestar_scrape/ folder.\n\n")
setwd("~/data_infrastructure/orestar_scrape/")
source("./productionLoadCandidateFilings.R")
#make working_candidate_filings
cat("\ncalling makeWorkingCandidateFilings(dbname=\"hackoregon\")\n")
makeWorkingCandidateFilings(dbname="hackoregon")