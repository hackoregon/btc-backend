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
dateRangeControler<-function(tranTableName="raw_committee_transactions", 
														 startDate=NULL, 
														 endDate=NULL, 
														 dbname="hackoregon", 
														 workingComTabName="working_committees"){

	DBNAME=dbname #a check for the DBNAME artifact
	
	transactionsFolder="./transConvertedToTsv/"
	if( is.null(startDate)&is.null(endDate) ){
		
		#get the current date to the current date minus on month.
		ed = Sys.Date()
		m <- as.POSIXlt(ed)
		m$mon <- m$mon - 1
		m <- as.Date(m)
		sd  = m
		dseq = c(sd, ed)
	}else{
		if( is.null(startDate) ){
			#first get the most recent record
			q1=paste0("select distinct filed_date 
			from working_transactions 
			order by filed_date desc limit 1")
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
		dseq = c(seq.Date(from=sd, to=ed, by="month"),ed)
	}

	cat("\nGetting data range",as.character(sd),"to",as.character(ed),"\n")
	#get one month at a time

	
	for(i in 1:(length(dseq)-1) ){
		gc()
		scrapeDateRange( startDate=dseq[i], endDate=dseq[i+1], destDir=transactionsFolder )
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
			" then run the function retryXLSImport() to retry the import.\n",
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
indir = "./testTransactionsXls/"
scrapeDateRange<-function(startDate, endDate, destDir = "./transConvertedToTsv/", indir="./"){
	
	if( !file.exists(destDir) ) dir.create(path=destDir)
	scrapeByDate(sdate=startDate, edate=endDate)
	cat("\nScrape complete... converting xls files..\n")
	converted = importAllXLSFiles(remEscapes=T,
																grepPattern="^[0-9]+(-)[0-9]+(-)[0-9]+(_)[0-9]+(-)[0-9]+(-)[0-9]+(.xls)$",
																remQuotes=T,
																forceImport=T,
																indir=indir,
																destDir=destDir)
	cat("\nxls conversion complete, checking download limit.\n")
	checkHandleDlLimit(converted=converted)
	
}

logFileImport<-function(fname, dbname){
	library(tools)
	fname="originalXLSdocs/01-02-2014_12-26-2013.xls"
	#make table
	dbCall(dbname=dbname, "create table if not exists file_import_log
													(file_name text,
													file_extension text,
													mod_date text,
													size int);")
	
	#get mod/import date
	newrow = data.frame(file_name=basename(fname),
						 file_extension = file_ext(fname),
						 mod_date = file.info(fname)$mtime, 
						 size = file.info(fname)$size)
	
	cat("Logging file import:", fname,"\n")
	dbiWrite(tabla=newrow, 
					 appendToTable=T, 
					 name="file_import_log", 
					 dbname=dbname)
	
}

file.logged<-function(fname, dbname){
	newrow = data.frame(file_name=basename(fname),
											file_extension = file_ext(fname),
											mod_date = file.info(fname)$mtime, 
											size = file.info(fname)$size)
	rows = dbiRead(dbname=dbname, query=paste0("select * from 
											file_import_log 
											where file_name = '",newrow$file_name,"'
											and file_extension = '",newrow$file_extension,"' 
											and mod_date = '",newrow$mod_date,"'
											and size = ",newrow$size,";"))
	
	if(nrow(rows)) return(TRUE)
	return(FALSE)
}

reImportXLS<-function(tableName, dbname, destDir="./transConvertedToTsv/", indir="./"){
	converted = importAllXLSFiles(remEscapes=T,
																remQuotes=T,
																forceImport=T,
																indir=indir,
																destDir=destDir)
	cat("\nImported and converted these .xls files:\n")
	print(converted)
	storeConvertedXLS(converted=converted)
	scrapedTransactionsToDatabase(tsvFolder=destDir, tableName=tableName, dbname=dbname)
}

# tsvFolder = "~/prog/hack_oregon/hackOregonBackEnd/successfullyMerged/"
#main function to put finance data in database
scrapedTransactionsToDatabase<-function(tableName, dbname, tsvFolder="./transConvertedToTsv/"){
	
	# 	fins = mergeTxtFiles(folderName=tsvFolder)
	# 	finfile = paste0(tsvFolder,"joinedTables.tsv")
	# 	tab = readFinData(fname=finfile)
	# 	tab = fixTextFiles(tab=tab)
	# 	tab = unique(tab)
	# 	cat("Re-writing repaired file\n")
	# 	write.finance.txt(dat=tab, fname=finfile)
	# 	importTransactionsTableToDb(tab=tab, tableName=tableName, dbname=dbname)
	allTextFilesToDb(folderName=tsvFolder, tableName=tableName, dbname=dbname)
}

depricated_importTransactionsTableToDb<-function(tab, tableName, dbname){
	
	tab = setColumnDataTypesForDB(tab=tab)
	# 	tabtmp  = tab
	badRows = safeWrite(tab=tab, tableName=tableName, dbname=dbname, append=T)
	if( !is.null(badRows) ){
		badRowFile = "./orestar_scrape/problemSpreadsheets/notPutIntoDb.txt"
		write.finance.txt(dat=badRows, fname=badRowFile)
		em = paste("Some lines could not be read into the database, these lines can be found in this file:\n",
							 badRowFile,"\nTo input this data, please attempt to fix the data, checking for special or\n",
							 "non-standard characters, then run the function retryDbImport()")
		message(em)
		warning(em)
	}
	removeDuplicateRecords(tableName=tableName, keycol="tran_id", dbname=dbname)
	blnk=checkAmmendedTransactions(tableName=tableName, dbname=dbname)
	filterDupTransFromDB(tableName=tableName, dbname=dbname)
	
}

depricated_checkAmmendedTransactions<-function(tableName, dbname){
	#get all the original ids for the ammended transactions
	tids = getAmmendedTransactionIds(tableName=tableName, dbname=dbname)
	if(!length(tids)) return()
	message("Ammended transaction issue found!")
	cat("\nAmmended transaction IDs:\n")
	print(tids)
	#copy the originals to the ammended to the ammended_transactions table
	amendedTableName = paste0(tableName,"_ammended_transactions")
	if( !dbTableExists( tableName=amendedTableName, dbname=dbname ) ){
		cat(" .. ")
		dbCall(dbname=dbname, sql=paste0("create table ", amendedTableName, " as
																							 select * from ",tableName,"
																							 where filer='abraham USA lincoln';") )
	}
	cat(" . adding original trasactions to table '", amendedTableName, "'.\n")
	q2 = paste("insert into", amendedTableName,
							"select * from ",tableName,
						 "where tran_id in (",paste(tids,collapse=", "), ")")
	dbCall(sql=q2, dbname=dbname)
	#remove the originals from the tableName table

	cat(" . deleting original transactions from main transactions table, '",tableName,"'\n")
	q2 = paste("delete from",tableName,
						 "where tran_id in (",paste(tids,collapse=", "), ")")
	dbCall(sql=q2, dbname=dbname)
	cat(" . ")
	return()
}

depricated_getAmmendedTransactionIds<-function(tableName,dbname){
	q1 = paste0("select tran_id 
							from ",tableName," 
							where tran_id in
							(select original_id
							from ",tableName,"
							where tran_status = 'Amended');")
	amdid = dbiRead(dbname=dbname, query=q1)
	if(nrow(amdid)) return(amdid[,1,drop=T])
	return(c())
}


#run this function if there are errors that you corrected
retryDbImport<-function( tableName, dbname ){
	badRowFile = "./orestar_scrape/problemSpreadsheets/notPutIntoDb.txt"
	tab = readFinData(fname=badRowFile)
	tab = fixTextFiles(tab=tab)
	tab = fixColumns(tab=tab)
	cat("Re-writing repaired file\n")
	write.finance.txt(dat=tab, fname=badRowFile)
	badRows = safeWrite(tab=tab, tableName=tableName, dbname=dbname, append=T)
	if(!is.null(badRows)){
		badRowFile = "./orestar_scrape/problemSpreadsheets/notPutIntoDb.txt"
		write.finance.txt(dat=badRows, fname=badRowFile)
		em = paste("Some lines could not be read into the database, these lines can be found in this file:\n",
							 badRowFile,"\nTo input this data, please attempt to fix the data, checking for special or\n",
							 "non-standard characters, then run the function retryDbImport()")
		message(em)
		warning(em)
	}
}

retryXLSImport<-function(){
	#first copy the xls documents from the problemSpreadsheets folder to the root folder
	errorDocs = dir("./orestar_scrape/problemSpreadsheets/")
	errorXLS = errorDocs[grepl(pattern=".xls$", x=errorDocs)]
	if(!length(errorXLS)){
		warning("Could not find any .xls documents in the problemSpreadsheets folder.")	
	}else{
		for(ss in errorXLS) file.rename(ss, gsub("problemSpreadsheets/","", x=ss))
	}
	converted = importAllXLSFiles(remEscapes=T,
																remQuotes=T,
																forceImport=T,
																indir="./orestar_scrape/",
																destDir=destDir)
	checkHandleDlLimit(converted=converted)
	storeConvertedXLS(converted=converted)
}

storeConvertedXLS<-function(converted){
	convxls = gsub(pattern=".txt$", replacement=".xls", x=converted)
	convxls = gsub(pattern="/transConvertedToTsv",replacement="",x=convxls)
	if(!file.exists("./originalXLSdocs/")) dir.create("./originalXLSdocs/")
	for(fn in convxls){
		cat("Moving\n",fn,"\nto\n ./originalXLSdocs/\n")
		file.rename(from=fn, to=paste0("./originalXLSdocs/", basename(fn) ) )
	}
}
# setwd("..")

# converted = paste0(destDir,dir(path=destDir))

checkForMaxInOneDay<-function(fname){
	dr = getStartAndEndDates(fname=fname)
	return(dr$start == dr$end)
}

#check each of the converted to see if they have 4999 rows
checkHandleDlLimit<-function(converted){
	if(!length(converted)) return()
	oldestRecs = c()
	maxedFn = c()
	
	for(cf in converted){
		# 	cf = converted[1]
		tab = read.table(cf, header=T, stringsAsFactors=F)
		print(nrow(tab))

		if(nrow(tab)==4999){
			cat("\nFound exactly 4999 records, this may indicate the record return limit was reached...\n")
			oldestRecs = c(oldestRecs, as.character(min(as.Date(x=tab$Filed.Date, format="%m/%d/%Y"))))
			maxedFn = c(maxedFn, cf)
		}
	}
	#move the converted xls documents to another folder so they don't clutter.  
	storeConvertedXLS(converted=converted)
	
	if(length(maxedFn)){
		for( mi in 1:length(maxedFn) ){
			cfn = maxedFn[mi]
			cold = oldestRecs[mi]
			if(!checkForMaxInOneDay(fname=cfn)){
				getAdditionalRecords( fname=cfn, oldestRec=cold )
			}else{
				warning("ERROR: failed to download all records because the maximum download reached in a one day span. See file: ",cfn)
				handleMaxInOneDay( fname=cfn )
			}
			
		}
	}
	
}

#fname = "./transConvertedToTsv/2012-10-02_2012-10-02.txt"
#fname = "./transConvertedToTsv/09-30-2014_09-30-2014.txt"
handleMaxInOneDay<-function(fname){
	
	cat("When a single day has more than 4999 transactions, 
			getting all transactions required they be downloaded 
			by filed_date and by tran_date
			This function gets two ranges of tran_date 
			(filed_date to (filed_date - 4 days) and (filed_date - 4 days) to (filed_date - 1000 days))
			while using the same filed_date.")
	
	dr = getStartAndEndDates(fname=fname)
	
	fdate = as.Date(dr$start)
	tranStart1 = fdate - 5
	tranStart2 = fdate - 1000
	fdate = as.character(fdate)
	tranStart1 = as.character(tranStart1)
	tranStart2 = as.character(tranStart2)
	
	filedTranDateScrape( filed=fdate, tran_start=tranStart1, tran_end=fdate	)
	filedTranDateScrape( filed=fdate, tran_start=tranStart2, tran_end=tranStart1	)
	
	scraperdir = "./filed_date_and_tran_date/"
	allF = dir(scraperdir)
	allF = allF[grepl(pattern="[.]xls$", x=allF)]
	for(fl in allF) file.rename(from=paste0(scraperdir,fl), to=paste0("./",fl))
	
}

filedTranDateScrape<-function(filed, tran_start, tran_end){
	
	sdate = gsub(pattern="-",replacement="/",x=tran_start)
	edate = gsub(pattern="-",replacement="/",x=tran_end)
	filed = gsub(pattern="-",replacement="/",x=filed)
	wdtmp = getwd()
	setwd("./filed_date_and_tran_date/")
	
	nodeString = "/usr/local/bin/node"
	if(!file.exists(nodeString)) nodeString = "/usr/bin/nodejs"
	
	cat("The scraper should be called with a string like this:\nnode  scraper 2014/09/30 2014/09/25 2014/09/30 20")
	comString = paste(nodeString," scraper", edate, sdate, filed, delay=20) #"node scraper 08/12/2014 07/12/2014 5"
	cat("\nThe scraper is being called with this string:\n",comString,"\n")
	sysres = system(command=comString, wait=T, intern=T)
	
	setwd("..")
	
}



getAdditionalRecords<-function(fname, oldestRec){
	
	cat("\nAttempting to get remaining records in the date range that should be found in the file named\n",fname,"\n")
	#get the date range that would be expected
	drange = getStartAndEndDates(fname=fname)
	
	#figure out the new date range
	sdate = drange$start
	edate = drange$end
	
	#find oldest record that was retreived
	
	cat("\nRe-scraping to fill in date range.\nScrape limits:",as.character(sdate), as.character(oldestRec),"\n")
	scrapeDateRange(startDate=sdate, endDate=as.Date(oldestRec))
	
}

getStartAndEndDates<-function(fname){
	bname = basename(fname)
	bname =gsub(pattern=".txt$|.tsv$|.csv$|.xls$", replacement="", x=bname)
	bname = gsub(pattern="^[0-9]+_", replacement="", x=bname)
	drange = strsplit(x=bname, split="_")[[1]]
	daterange = as.Date(x=gsub(pattern="-",replacement="/", x=drange), format="%m/%d/%Y")
	if( sum(is.na(daterange)) ) daterange = as.Date(x=gsub(pattern="-",replacement="/", x=drange), format="%Y/%m/%d")
	return(list(start=daterange[2], end=daterange[1]))
}

# getAdditionalRecords(fname=fname, tb=tab)



# dates should be entered in in the format:
# 07/01/2014 (month/day/year)
# sdate = "07/01/2014"
# edate = "07/12/2014"
#
scrapeByDate<-function(sdate, edate, delay=10){
	sdate = gsub(pattern="-",replacement="/",x=sdate)
	edate = gsub(pattern="-",replacement="/",x=edate)
	wdtmp = getwd()
	if(basename(wdtmp)!="orestar_scrape"){
		if(!file.exists("orestar_scrape")) dir.create(path="./orestar_scrape/")
		setwd("./orestar_scrape/")	
	}
	nodeString = "/usr/local/bin/node"

	if(!file.exists(nodeString)) nodeString = "/usr/bin/nodejs"

	comString = paste(nodeString," scraper", edate, sdate, delay) #"node scraper 08/12/2014 07/12/2014 5"
	cat("\n:\n",comString,"\n")
	sysres = system(command=comString, wait=T, intern=T)
	
	setwd(wdtmp)
}



