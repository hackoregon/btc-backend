#run scraper
cat("\nInside runScraper.R\nThis file must be run from the /orestar_scrape/ directory.\n")
source("./finDataImport.R")
source("./dbi.R")
source("./scrapeAffiliation.R")
DBNAME="hack_oregon"
ERRORLOGFILENAME="affiliationScrapeErrorlog.txt"

# Several scraping scenerios exists, 
# first, filling in historic data
# second, filling in data for the most recent activity

# dates should be entered as strings in in the format:
# 07/01/2014 (month/day/year)
# sdate = "07/01/2014"
# edate = "07/12/2014"
#
# endDate = "05/21/2014"
# dateRangeControler(startDate="05/21/2014", endDate="07/01/2014", tableName="test_raw_transactions")
# dateRangeControler(startDate="6/22/2014", endDate="6/30/2014")
# dateRangeControler(startDate="1/1/2013", endDate="12/31/2013", dbname="hack_oregon") #stopped; last date range: 09-01-2013_08-25-2013
# dateRangeControler(startDate="9/2/2013", endDate="12/31/2013", dbname="hack_oregon") #stopped at 10/2/2013
# dateRangeControler(startDate="10/2/2013", endDate="12/31/2013", dbname="hack_oregon")
# dateRangeControler(startDate="12/2/2013", endDate="3/14/2014", dbname="hack_oregon") #error at 1/2/2014
# dateRangeControler(startDate="1/2/2014", endDate="3/14/2014", dbname="hack_oregon")
# dateRangeControler(startDate="12/2/2013", endDate="12/9/2013", dbname="hack_oregon")
# dateRangeControler(startDate="1/1/2012", endDate="6/1/2012", dbname="hack_oregon") #didn't get past 5/1/12, had issue with 05-01-2012_04-24-2012 range: 4999 records
# dateRangeControler(startDate="4/24/2012", endDate="5/1/2012", dbname="hack_oregon") 
# dateRangeControler(startDate="5/2/2012", endDate="6/1/2012", dbname="hack_oregon")
# dateRangeControler(startDate="6/2/2012", endDate="7/1/2012", dbname="hack_oregon")
# dateRangeControler(startDate="7/2/2012", endDate="8/1/2012", dbname="hack_oregon")
# dateRangeControler(startDate="1/1/2011", endDate="12/31/2011", dbname="hackoregon") #run on hack oregon my micro #crashed cause it was out of memory.
# dateRangeControler(startDate="12/1/2011", endDate="12/31/2011", dbname="hackoregon") #had issue/crash with additional record download.
# dateRangeControler(startDate="8/1/2012", endDate="1/3/2013", dbname="hackoregon") #run inside of local vagrant instance
# dateRangeControler(startDate="1/1/2010", endDate="1/1/2011", dbname="hackoregon") #run inside of local vagrant instance; stopped at 2010/09/20 2010/09/16 because of cell containing "\"
# dateRangeControler(startDate="9/16/2010", endDate="1/1/2011", dbname="hackoregon") #run inside of local vagrant instance
# dateRangeControler(startDate="3/1/2014", endDate="10/1/2014", dbname="hackoregon")
# dbname = "hack_oregon"
# tableName="raw_committee_transactions"

# startDate="1/1/1983"
# endDate="10/30/2014"
# neededIds = c(17040, 17044, 17015, 17007)

dateRangeIdControler<-function(neededIds,
															 tranTableName="raw_committee_transactions", 
														 startDate=NULL, 
														 endDate=NULL, 
														 dbname="hackoregon", 
														 workingComTabName="working_committees"){
	
	DBNAME=dbname #a check for the DBNAME artifact
	
	transactionsFolder="./transConvertedToTsv/"
	
	if( is.null(startDate) ){
		#first get the most recent record
		q1=paste0("select distinct tran_date 
							from ",tranTableName," 
							order by tran_date desc limit 1")
		sd = dbiRead(query=q1, dbname=dbname)[,1,drop=T]
	}else{ 
		sd=as.Date(startDate, format="%m/%d/%Y") 
	}
	
	if(is.null(endDate)){
		#second, get the max date
		ed = Sys.Date()
	}else{ 
		ed=as.Date(endDate, format="%m/%d/%Y") 
	}
	
	#get one month at a time
	# 	dseq = c(seq.Date(from=sd, to=ed, by="month"),ed)
	
	for(i in 1:length(neededIds) ){
		cat("\n_________________________________________________\n")
		cat("Current committee:",neededIds[i],". Number", i, "of", length(neededIds) )
		cat("\n_________________________________________________\n")
		cat("\nGetting data range",as.character(sd),"to",as.character(ed)," for committee",neededIds[i],"\n")
		gc()
		scrapeIdDateRange(startDate=sd, endDate=ed, destDir=transactionsFolder, id=neededIds[i])
		gc()
		scrapedTransactionsToDatabase(tsvFolder=transactionsFolder, tableName=tranTableName, dbname=dbname)
	}
	
}

readme<-function(){
	
	cat("The readme:\n",
			" To run this scraper, you should have the node scraper\n",
			" installed and placed in a subfolder named 'orestar_scrape'.\n",
			" In that folder, this script will place the .xls file from\n",
			" the initial scraping, then attempt to convert all these files\n",
			" to .tsv/tab-delimited tables.\n",
			" Any spreadsheets which could not be converted will be placed\n",
			" in a folder named ./orestar_scrape/problemSpreadsheets/\n",
			" along with any applicable error log output. Attempt to deal\n",
			" with the errors by normalizing the the document syntax,\n",
			" then run the function retryXLSImportWithIds() to retry the import.\n",
			" Spreadsheets successfully converted to .tsv documents will be\n",
			" placed in the folder ./orestar_scrape/transConvertedToTsv/")
	
}

logWarnings<-function(wns,warningSource=""){
	# 	write.table(x=wns, file=paste0("./",warningSource,"warnings.txt"), quote=F )
	mess = paste(as.character(Sys.time())," ",warningSource,"\n",names(wns))
	message("Warnings found in committee data import, see error log: ",ERRORLOGFILENAME)
	print(mess)
	write.table(file=ERRORLOGFILENAME, x=mess, 
							append=TRUE, 
							col.names=FALSE, 
							row.names=FALSE, 
							quote=FALSE)
}

# raw_committee_transactions="transactionsTable"
# comTabName = raw_committee_transactions
getMissingCommittees<-function(transactionsTable, 
															 workingComTabName, 
															 dbname, 
															 appendTo=T, 
															 rawCommitteeDataFolder = "raw_committee_data", 
															 rawScrapeComTabName = "raw_committees_scraped"){
	# 	wdtmp = getwd()
	#find ids missing from working_committees
	q1 = paste("select distinct filer_id from",transactionsTable,
						 "where filer_id not in (select distinct committee_id from", 
						 workingComTabName,")")
	dbres = dbiRead(query=q1, dbname=dbname)
	if(nrow(dbres)){
		dbres = dbres[,1,drop=TRUE]
	}else{ dbres = c() }
	
	#find ids missing from raw_committees_scraped
	q2 = paste("select distinct filer_id from",transactionsTable,
						 "where filer_id not in (select distinct id from", 
						 rawScrapeComTabName,")")
	dbres2 = dbiRead(query=q2, dbname=dbname)
	
	if(nrow(dbres2)){
		dbres2 = dbres2[,1,drop=TRUE]
	}else{ dbres2 = c() }
	
	#find committees missing from both
	missingCommittees = intersect(dbres, dbres2)
	
	#scrape committees missing from both
	if(length(missingCommittees)){
		cat("\n",length(missingCommittees),"committee IDs found to be in transaction records but not in committee records...\n")
		scrapeTheseCommittees(committeeNumbers=missingCommittees, commfold=rawCommitteeDataFolder)
		logWarnings(warnings())
		rectab = rawScrapeToTable(committeeNumbers=missingCommittees, rawdir=rawCommitteeDataFolder)
		sendCommitteesToDb( comtab=rectab, dbname=dbname, appendTo=appendTo , rawScrapeComTabName=rawScrapeComTabName)
	}else{
		cat("\nNo missing committees found\n")
	}
	
	# 	setwd(wdtmp)
}

sendCommitteesToDb<-function(comtab, dbname, rawScrapeComTabName="raw_committees_scraped", appendTo=T){
	if( is.null(nrow(comtab)) ){
		cat("\nNo new committee Records to send to database!\n")
	}else{
		cat("\nPreping scraped committee data for entry into database.\n")
		comtab = prepCommitteeTableData(comtab=comtab)
		cat("\nUploading committee data from scraping to the database,",dbname,"\n")
		writeCommitteeDataToDatabase(comtab=comtab, 
																 rawScrapeComTabName=rawScrapeComTabName, 
																 dbname=dbname, 
																 appendTo=appendTo)
		cat("\ncommittee data uploaded\n")
		makeRawCommitteesUnique(dbname=dbname,rawScrapeComTabName=rawScrapeComTabName)
		cat(".")
	}
}

makeRawCommitteesUnique<-function(dbname, rawScrapeComTabName){
	
	dbr = dbiRead(query=paste('select * from',rawScrapeComTabName), dbname=dbname)
	dbr = unique(dbr)
	dbiWrite(tabla=dbr, name=rawScrapeComTabName, appendToTable=F, dbname=dbname)
	
}

writeCommitteeDataToDatabase<-function(comtab, rawScrapeComTabName, dbname, appendTo){
	
	#check that committee data is unique
	#check if the table exists
	if(dbTableExists(tableName=rawScrapeComTabName, dbname=dbname)){
		cat("\nTable",rawScrapeComTabName,"already exists, rebuilding.. .\n")
		#get the current set of records
		fromdb = dbiRead(query=paste("select * from",rawScrapeComTabName), dbname=dbname)
		#remove records whos ids are found in the incoming raw scrapes
		fromdb = fromdb[ !fromdb$id %in% comtab$id, ,drop=FALSE]
		#merge, filling in columns
		fulltab = rbind.fill(fromdb, comtab)
		
		# 		idc = table(fulltab$id)
		# 		duprec = names(idc[idc==2])
		#delete any from the database that are in the current set
		# 		alreadyInDb = intersect(fromdb$id, comtab$id)
		# 		if(length(alreadyInDb)) dropRecordsFromDb(tname=rawScrapeComTabName, dbname=dbname, colname="id", ids=alreadyInDb)
		
	}
	dbiWrite(tabla=comtab, name=rawScrapeComTabName, appendToTable=FALSE, dbname=dbname)
}

dropRecordsFromDb<-function(tname, dbname, colname, ids){
	dropq = paste("DELETE FROM", tname, "WHERE", colname, "IN", "(", paste(ids, collapse=", "), ")") 
	dbCall(sql=dropq, dbname=dbname)
}

prepCommitteeTableData<-function(comtab){
	comtab = as.data.frame(comtab, stringsAsFactors=F)
	#first fix the column names
	colnames(comtab)<-fixColumnNames(cnames=colnames(comtab))
	#fix the cell values
	comtab = unifyNAs(tab=comtab)
	#second fix the column data types
	comtab = setColumnDataTypesForCommittees(tab=comtab)
	#add committee type (pac or cc)
	comtab2 = addCommitteeTypeColumn(tab=comtab)
	return(comtab2)
}

fixCellValues<-function(comtab){
	
	for(i in 1:ncol(comtab)){
		comtab[,i] = gsub(pattern="^(\\s)+|(\\s)+$", replacement="", x=comtab[,i] )
	}
	return(comtab)
}

addCommitteeTypeColumn<-function(tab){
	committee_type = rep("CC", times=nrow(tab))
	pacRows = is.na(tab$candidate_name)
	committee_type[pacRows] = "PAC"
	tab = cbind.data.frame(tab, committee_type, stringsAsFactors=FALSE)
	return(tab)
}

getMostRecentMissingTransactions<-function(){
	dateRangeControler(tranTableName="raw_committee_transactions")
}

#08-12-2014_09-12-2014
scrapeIdDateRange<-function(startDate, 
														endDate, 
														id, 
														destDir = "./transConvertedToTsv/", 
														indir="./scrape_by_filed_date_and_id/"){
	
	if(!file.exists(destDir)) dir.create(path=destDir)
	scrapeByDateAndId(sdate=startDate, edate=endDate, id=id)
	# 	grepPattern="^[0-9]+(-)[0-9]+(-)[0-9]+(_)[0-9]+(-)[0-9]+(-)[0-9]+(.xls)$"
	converted = importAllXLSFiles(remEscapes=T,
																grepPattern="(.xls)$",
																remQuotes=T,
																forceImport=T,
																indir=indir,
																destDir=destDir)
	checkHandleDlLimitForId(converted=converted)
	
}



retryXLSImportWithIds<-function(){
	#first copy the xls documents from the problemSpreadsheets folder to the root folder
	errorDocs = dir("./orestar_scrape/problemSpreadsheets/")
	errorXLS = errorDocs[grepl(pattern=".xls$", x=errorDocs)]
	if(!length(errorXLS)){
		warning("Could not find any .xls documents in the problemSpreadsheets folder.")	
	}else{
		for(ss in errorXLS) file.rename(ss, gsub("problemSpreadsheets/","", x=ss))
	}
	converted = importAllXLSFiles(remEscapes=T,
																grepPattern="[.]xls$",
																remQuotes=T,
																forceImport=T,
																indir="./orestar_scrape/",
																destDir=destDir)

	checkHandleDlLimitForId(converted=converted)
	
	storeConvertedXLS(converted=converted)
	
}



storeConvertedXLSForId<-function(converted){
	convxls = gsub(pattern=".txt$", replacement=".xls", x=converted)
	convxls = gsub(pattern="/transConvertedToTsv",replacement="/scrape_by_filed_date_and_id",x=convxls)
	if(!file.exists("./originalXLSdocs/")) dir.create("./originalXLSdocs/")
	for(fn in convxls){
		cat("Moving\n",fn,"\nto\n ./originalXLSdocs/\n")
		file.rename(from=fn, to=paste0("./originalXLSdocs/", basename(fn) ) )
	}
}
# setwd("..")

# converted = paste0(destDir,dir(path=destDir))

#check each of the converted to see if they have 4999 rows
checkHandleDlLimitForId<-function(converted){
	
	# 	cat("Getting ids from file names.\n")
	# 	stop("not yet implamented: retryXLSImportWithIds/get ids from file names")

	if(!length(converted)) return()
	oldestRecs = c()
	maxedFn = c()
	
	for(cf in converted){
		# 	cf = converted[1]
		tab = read.table(cf, header=T, stringsAsFactors=F)
		cat("file:",cf,"rows:",nrow(tab),"\n")
		
		if(nrow(tab)==4999){
			cat("Found exactly 4999 records, this may indicate the record return limit was reached...\n")
			oldestRecs = c(oldestRecs, as.character(min(as.Date(x=tab$Filed.Date, format="%m/%d/%Y"))))
			maxedFn = c(maxedFn, cf)
		}
	}
	#move the converted xls documents to another folder so they don't clutter.  
	storeConvertedXLSForId(converted=converted)
	
	if( length(maxedFn) ){
		for( mi in 1:length(maxedFn) ){
			cfn = maxedFn[mi]
			cold = oldestRecs[mi]
			id = getIdFromFileName(cfn)
			getAdditionalRecordsWithIds(fname=cfn, oldestRec=cold, id=id)
		}
	}
	
}

getIdFromFileName<-function(fname="./transConvertedToTsv/275_10-30-2014_01-01-2010.txt"){
	fname = basename(fname)
	id = as.numeric(gsub(pattern="_[0-9_-]+[.](txt|tsv)", replacement="", x=fname))
	return(id)
}

getAdditionalRecordsWithIds<-function(fname, oldestRec, id){
	
	cat("\nAttempting to get remaining records in the date range that should be found in the file named\n",fname,"\n")
	#get the date range that would be expected
	fnameNoId = gsub(pattern=paste0("^",id,"_"), replacement="", x=basename(fname))
	drange = getStartAndEndDates(fname=fnameNoId)
	
	#figure out the new date range
	sdate = drange$start
	edate = drange$end
	
	#find oldest record that was retreived
	
	cat("\nRe-scraping to fill in date range.\nScrape limits:",as.character(sdate), as.character(oldestRec),"\n")
	scrapeIdDateRange(startDate=sdate, 
										endDate=as.Date(oldestRec), 
										id=id)
	
}

getStartAndEndDates<-function(fname){
	bname = basename(fname)
	bname =gsub(pattern=".txt$", replacement="", x=bname)
	drange = strsplit(x=bname, split="_")[[1]]
	drange = as.Date(x=gsub(pattern="-",replacement="/", x=drange), format="%m/%d/%Y")
	return(list(start=drange[2], end=drange[1]))
}


# dates should be entered in in the format:
# 07/01/2014 (month/day/year)
# sdate = "07/01/2014"
# edate = "07/12/2014"
#
scrapeByDateAndId<-function(sdate, edate, id){
	delay=sample(x=10:30, size=1)
	sdate = gsub(pattern="-",replacement="/",x=sdate)
	edate = gsub(pattern="-",replacement="/",x=edate)
	wdtmp = getwd()
	setwd("./scrape_by_filed_date_and_id/")	
	
	nodeString = "/usr/local/bin/node"
	
	if(!file.exists(nodeString)) nodeString = "/usr/bin/nodejs"
	
	comString = paste(nodeString," scraper", edate, sdate, 10, id) #"node scraper 08/1/2014 07/1/2014 5 13920"
	cat("\nCalling the scraper with this string:\n",comString,"\n")
	sysres = system(command=comString, wait=T, intern=T)
	Sys.sleep(delay)
	setwd(wdtmp)
}



