#!/usr/bin/Rscript
#check all files for dl limit
setwd("~/data_infrastructure/orestar_scrape/")
source('./runScraper.R')

fileDir = "./transConvertedToTsv/"
converted = dir(fileDir)
converted = converted[grepl(pattern=".txt$|.tsv$", x=converted)]
converted = paste0(fileDir, converted)
checkHandleDlLimit(converted=converted)

