#!/usr/bin/Rscript
#export table to tsv
cat("This script should be run by passing the arguments:\n",
		"tablename : the name of the table to be exported\n",
		"dbname : the name of the database (defaults to 'hackoregon')",
		"\nExample:\n",
		"exportTableToTsv.R raw_committee_transactions hackoregon",
		"\nTable will be saved to a file named in this pattern:\n",
		"<tablename>.csv\n")

source("~/data_infrastructure/orestar_scrape/dbi.R")
# source("./orestar_scrape/dbi.R")
if(!require("lubridate")){
	install.packages("lubridate",repos="http://ftp.osuosl.org/pub/cran/")
	library("lubridate")
}

args <- commandArgs(trailingOnly=TRUE)
dbname=args[2]
tname=args[1]
small=args[3]
#handle case where user only provides the table name
if(is.null(dbname)) dbname = "hackoregon"
if(is.na(dbname)) dbname = "hackoregon"
if(is.null(small)) small = "big"
if(is.na(small)) small = "big"

q1 = paste("select * from",tname,";")
res1 = dbiRead(query=q1, dbname=dbname)

if(small="small"){
	
	#make folder out of table name and move to that folder
	dir.create(path=tname, showWarnings=F)
	setwd(tname)
	#add files 1 year at a time to the folder
	
		#create an index out of years
	yindex = year(res1$tran_date)
	uyear = unique(yindex)
	for(y in uyear){
		cfname=paste0(y,".csv")
		write.csv(x=res1[yindex==y,,drop=FALSE], file=cfname, row.names=F)
	}
		#select all transactions for each year
		#add to file named <year>.csv
	
}else{
	
	fname = paste0(tname,".tsv")
	cat("\nTable retreived with",nrow(res1), "rows and",ncol(res1),"columns.")
	cat("\nTable being saved to file named:\n",fname,"\n. . . ")
	write.csv(x=res1, file=fname, row.names=F)
	cat("\nChecking that table can be re-opened..\n")
	resNew = read.csv(file=fname, stringsAsFactors=F, strip.white=T)
	cat("Test reopened table dimensions:",nrow(resNew),"rows by", ncol(resNew),"\n")
	
}


cat("done.\n")

