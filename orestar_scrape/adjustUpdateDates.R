#!/usr/bin/Rscript
setwd("~/data_infrastructure/orestar_scrape/")
source("./dbi.R")
source("runIdScraper.R")
dbname="hackoregon"
# dbname = "hack_oregon"

#get all file names
args <- commandArgs(trailingOnly=TRUE)
indir = args[1]
# indir = "./transConvertedToTsv/successfullyImportedXlsFiles/"
cat("Argument passed:",indir,"\n")

fnames = dir(indir)
#get dates
fdates = file.info( paste0(indir,fnames) )$mtime
#get committee ids
ids = getIdFromFileName(fname=fnames)

tab = data.frame(id=ids, scrape_date=fdates, file_name=fnames)
#remove rows where id is null
tab = tab[!is.na(tab$id),]

#adjust dates in actual table

dbiWrite(tabla=tab, name="import_dates", appendToTable=T, dbname=dbname)
#rebuild db