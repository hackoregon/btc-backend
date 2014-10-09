#!/usr/bin/Rscript
#hackOregonStatusLogger.R
mess <- commandArgs(trailingOnly=TRUE)[1]

source("~/data_infrastructure/orestar_scrape/dbi.R")

dbname = "hackoregon"
# dbname="hack_oregon"

allStats=NULL
if(dbTableExists(tableName="hack_oregon_db_status", dbname=dbname)){
	allStats = dbiRead(query="select * from hack_oregon_db_status", dbname=dbname)
}

allTabRes = dbiRead(query="SELECT table_schema,table_name
							FROM information_schema.tables
							ORDER BY table_schema,table_name;", dbname=dbname)

allTables = allTabRes[allTabRes$table_schema=="public","table_name"]
allTableLengths = c()

for(tn in allTables){
	allTableLengths = c(allTableLengths,
											dbiRead(query=paste("select count(*) from",tn), dbname=dbname)[1,1])
}

newRow = as.data.frame(matrix(data=allTableLengths, nrow=1, dimnames=list(NULL,allTables)))

newRow = cbind(newRow, date=as.Date(Sys.time()))

if(!is.null(mess)) newRow = cbind(newRow, event_at_log_time=mess)

library(plyr)
dfout = rbind.fill(allStats, newRow)

dbiWrite(tabla=dfout, name="hack_oregon_db_status", dbname=dbname, appendToTable=FALSE)
