#run scraper

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
# dbname = "hack_oregon"
# tableName="raw_committee_transactions"
dateRangeControler<-function(tranTableName="raw_committee_transactions", startDate=NULL, endDate=NULL, dbname="hackoregon", commTabName="working_committees"){

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
	cat("\nGetting data range",as.character(sd),"to",as.character(ed),"\n")
	#get one month at a time
	dseq = c(seq.Date(from=sd, to=ed, by="month"),ed)
	
	for(i in 1:(length(dseq)-1) ){
		scrapeDateRange(startDate=dseq[i], endDate=dseq[i+1], destDir=transactionsFolder)
		scrapedTransactionsToDatabase(tsvFolder=transactionsFolder, tableName=tranTableName, dbname=dbname)
		getMissingCommittees(transactionsTable=tranTableName, dbname=dbname, comtabName=commTabName)
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
	warning("Warnings found in committee data import, see error log: ",ERRORLOGFILENAME)
	write.table(file=ERRORLOGFILENAME, x=mess, 
							append=TRUE, 
							col.names=FALSE, 
							row.names=FALSE, 
							quote=FALSE)
}

# raw_committee_transactions="transactionsTable"
# commTabName = raw_committee_transactions
getMissingCommittees<-function(transactionsTable, commTabName, dbname, appendTo=T, rawCommitteeDataFolder = "raw_committee_data"){
	# 	wdtmp = getwd()
	
	q1 = paste("select distinct filer_id from",transactionsTable,
						 "where filer_id not in (select distinct committee_id from", 
						 commTabName,")")
	dbres = dbiRead(query=q1, dbname=dbname)
	dbres = dbres[,1,drop=TRUE]

	scrapeTheseCommittees(committeeNumbers=dbres, commfold=rawCommitteeDataFolder)
	logWarnings(warnings())
	rectab = rawScrapeToTable(committeeNumbers=dbres, rawdir=rawCommitteeDataFolder)
	sendCommitteesToDb( comtab=rectab, dbname=dbname, appendTo=appendTo )
	# 	setwd(wdtmp)
}

sendCommitteesToDb<-function(comtab, dbname, comTabName="raw_committees_scraped", appendTo=T){
	cat("\nPreping scraped committee data for entry into database.\n")
	comtab = prepCommitteeTableData(comtab=comtab)
	cat("\nUploading committee data from scraping to the database,",dbname,"\n")
	uploadCommitteeDataToDatabase(comtab=comtab, comTabName=comTabName, dbname=dbname, appendTo=appendTo)
	cat(".")
}

uploadCommitteeDataToDatabase<-function(comtab, comTabName, dbname, appendTo){
	
	dbiWrite(tabla=comtab, name=comTabName, appendToTable=appendTo, dbname=dbname)
	
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
scrapeDateRange<-function(startDate, endDate, destDir = "./transConvertedToTsv/", indir="./"){
	
	if(!file.exists(destDir)) dir.create(path=destDir)
	scrapeByDate(sdate=startDate, edate=endDate)
	converted = importAllXLSFiles(remEscapes=T,
																remQuotes=T,
																forceImport=T,
																indir=indir,
																destDir=destDir)
	checkHandleDlLimit(converted=converted)
	#move the converted xls documents to another folder so they don't clutter.  
	storeConvertedXLS(converted=converted)	
	
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
	
	fins = mergeTxtFiles(folderName=tsvFolder)
	finfile = paste0(tsvFolder,"joinedTables.tsv")
	tab = readFinData(fname=finfile)
	tab = fixTextFiles(tab=tab)
	tab = unique(tab)
	cat("Re-writing repaired file\n")
	write.finance.txt(dat=tab, fname=finfile)
	importTransactionsTableToDb(tab=tab, tableName=tableName, dbname=dbname)

}

importTransactionsTableToDb<-function(tab, tableName, dbname){
	
	tab = setColumnDataTypesForDB(tab=tab)
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

checkAmmendedTransactions<-function(tableName, dbname){
	#get all the original ids for the ammended transactions
	tids = getAmmendedTransactionIds(tableName=tableName, dbname=dbname)
	if(!length(tids)) return()
	message("Ammended transaction issue found!")
	#copy the originals to the ammended to the ammended_transactions table
	amendedTableName = paste0(tableName,"_ammended_transactions")
	if( !dbTableExists( tableName=amendedTableName, dbname=dbname ) ){
		cat(" .. ")
		dbCall(dbname=dbname, sql=paste0("create table ", amendedTableName, " as
																							 select * from ",tableName,"
																							 where filer='abraham USA lincoln';") )
	}
	cat(" . ")
	q2 = paste("insert into", amendedTableName,
							"select * from ",tableName,
						 "where tran_id in (",paste(tids,collapse=", "), ")")
	dbCall(sql=q2, dbname=dbname)
	#remove the originals from the tableName table
	cat(" . ")
	q2 = paste("delete from",tableName,
						 "where tran_id in (",paste(tids,collapse=", "), ")")
	dbCall(sql=q2, dbname=dbname)
	cat(" . ")
	return()
}

getAmmendedTransactionIds<-function(tableName,dbname){
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

removeDuplicateRecords<-function(tableName, dbname, keycol="tran_id"){
	cat("\nChecking and removing duplicate transactions")
	queryString1 = paste0("DELETE FROM ",tableName,"
									WHERE ctid IN (SELECT min(ctid)
										FROM ",tableName,"
										GROUP BY ",keycol,"
										HAVING count(*) > 1);")
	queryString2 = paste0( "select count(*)
												 from ",tableName,"
												 group by tran_id
												 order by count(*) desc
												 limit 1;")
	
	while( dbiRead( query=queryString2, dbname=dbname )[1,1] > 1){
		cat(".")
		dbCall(sql=queryString1, dbname=dbname)
	}
	cat("\n")
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

#check each of the converted to see if they have 4999 rows
checkHandleDlLimit<-function(converted){
	for(cf in converted){
		# 	cf = converted[1]
		tab = read.table(cf, header=T, stringsAsFactors=F)
		print(nrow(tab))
		if(nrow(tab)==4999){
			cat("\nFound exactly 4999 records, this may indicate the record return limit was reached...")
			getAdditionalRecords(fname=cf, tb=tab)
		}
	}
}

getStartAndEndDates<-function(fname){
	bname = basename(fname)
	bname =gsub(pattern=".txt$", replacement="", x=bname)
	drange = strsplit(x=bname, split="_")[[1]]
	drange = as.Date(x=gsub(pattern="-",replacement="/", x=drange), format="%m/%d/%Y")
	return(list(start=drange[2], end=drange[1]))
}

# getAdditionalRecords(fname=fname, tb=tab)

getAdditionalRecords<-function(fname, tb){
	
	cat("\nAttempting to get remaining records in date range from file\n",fname,"\n")
	#get the date range that would be expected
	drange = getStartAndEndDates(fname=fname)
	
	#figure out the new date range
	sdate = drange$start
	edate = drange$end
	
	#find oldest record that was retreived
	oldest = min(as.Date(x=tb$Tran.Date, format="%m/%d/%Y"))

	#if there is a gap, oldest will be newer than sdate
	if(oldest>sdate){
		
		scrapeDateRange(startDate=sdate, endDate=oldest, destDir=)
		
	}else{
		#it is possible there were exactly 4999 records in the originally requested date range
		#if this was the case, warn the user it happened
		warning("A rare case seems to have occured -- there were exactly 4999 records in one of the requested date ranges\n",
						"(start: ",sdate, " end: ", edate,")\n",
						"Though though it is possible for this to happen under normal circumstances, it would be",
						"prudent to manually\ndownload transactions that date range from ORESTAR and check the number of records.")
		
	}
	
}

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
	cat("\nCalling the scraper with this string:\n",comString,"\n")
	sysres = system(command=comString, wait=T, intern=T)
	
	setwd(wdtmp)
}


getDupRecs<-function(tb){
	tt = table(tb[,1,drop=TRUE])
	if(max(tt)==1) return(data.frame())
	dups = tb[ tb[,1,drop=TRUE] %in% names(tt)[tt>1], ,drop=FALSE]
	dups = dups[order(dups[,1,drop=TRUE]),,drop=FALSE]
	return(dups)
}

handleDupRecs<-function(tab){
	#get all the records
	dr = getDupRecs(tab)
	if(!nrow(dr)) return(tab)
	cat(nrow(dr),"transaction ids were found multiple times.")
	#remove the transactions from the main set
	udtran = unique(dr[,1])
	tabminus = tab[!tab[,1]%in%udtran,]
	#select the transactions to keep
	keepers = filterDupRecs(dr=dr)
	#merge the kept transactions with the main set
	tabout = rbind.data.frame(tabminus, keepers)
	
}

filterDuplicates<-function(dr){
	udtran = unique(dr[,1])
	dr = unique(dr)
	keepers = NULL 
	cat("Filtering",nrow(dr),"to",length(udtran),"unique transaction ids.")
	for(i in 1:length(udtran)){
		tid = udtran[i]#select a transaction id
		cat(".",i,"of",length(udtran),".")
		trows = dr[dr[,1]==tid,]#select the rows with that transaction id
		rowtots = apply(X=is.na(trows), MARGIN=1, sum)#see how many NAs are in each of the rows with identical ids. 
		toKeep =  trows[rowtots==min(rowtots),,drop=F]#keep the row with the least number of NAs
		keepers = rbind.data.frame(keepers, toKeep)
	}
	
	return(keepers)
}

logProblemDuplicates<-function(pd){
	cat("\nCould not automatically resolve duplicates.\nSelecting last.\n")
	cat("These are the transaction ids and the\ncolumn(s) which could not be resolved:")
	acols = apply(X=pd, MARGIN=2, FUN=function(x){length(unique(x))>1})
	pcols = names(acols)[acols]
	print(pd[,c(1,which(colnames(pd)==pcols)),drop=F])
}

filterDupTransFromDB<-function(tableName, dbname){
	
	#get the duplicated records
	q1 = paste0("select * 
								from ",tableName,"
							where tran_id in
							(select tran_id
							 from ",tableName,"
							 group by tran_id
							 having count(*) > 1)")
	dbires = dbiRead(query=q1,dbname=dbname)
	if( !nrow(dbires) )	 return(FALSE)
	write.finance.txt(dat=dbires, fname="./duplicatedTransactionRecordsFound.txt")
	cat(nrow(dbires), "unique transaction ids were found multiple times in the database.\nAttempting to repair..\n")
	#figure out the correct set
	udbires = unique(dbires)
	eluent = filterDuplicates(dr=dbires)
	recheck = getDupRecs(tb=eluent)
	if(nrow(recheck)){
		dupRows = duplicated(x=eluent$tran_id)
		eluent = eluent[dupRows,,drop=FALSE]
		message("WARNING: could not remove all duplicate records!!!")
		warning("Could not remove all duplicate transactions!!!")
	}
	uids = unique(eluent[,1])
	#remove applicable transactions from the db
	q2 = paste("DELETE FROM ",tableName,"
				 			WHERE tran_id in (",paste0(uids, collapse=", "),")")
	dbCall(sql=q2, dbname=dbname)
	#add the fixed set of transactions to the db
	dbiWrite(tabla=eluent, name=tableName, appendToTable=T, dbname=dbname)
	return(TRUE)
}



