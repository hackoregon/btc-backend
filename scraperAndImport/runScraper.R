#run scraper

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
			" then run the function retryXLSImport() to retry the import.",
			" Spreadsheets successfully converted to .tsv documents will be\n",
			" placed in the folder ./orestar_scrape/convertedToTsv/")
	
}

scrapeDateRange<-function(startDate, endDate, destDir = "./orestar_scrape/convertedToTsv/"){
	source('./dataImport/finDataImport.R')
	if(!file.exists(destDir)) dir.create(path=destDir)
	scrapeByDate(sdate=startDate, edate=endDate)
	converted = importAllXLSFiles(remEscapes=T,
																remQuotes=T,
																forceImport=T,
																indir="./orestar_scrape/",
																destDir=destDir)
	checkHandleDlLimit(converted=converted)
	storeConvertedXLS(converted=converted)
	
}

scrapedDataToDatabase<-function(tsvFolder="./orestar_scrape/convertedToTsv/"){
	
	fins = mergeTxtFiles(folderName=tsvFolder)
	finfile = "./orestar_scrape/convertedToTsv/joinedTables.tsv"
	tab = readFinData(fname=finfile)
	tab = fixTextFiles(tab=tab)
	tab = fixColumns(tab=tab)
	cat("Re-writing repaired file\n")
	write.finance.txt(dat=tab, fname=finfile)
	badRows = safeWrite(tab=tab, tableName="raw_committee_transactions", dbname="hack_oregon", append=T)
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

retryDbImport<-function(){
	badRowFile = "./orestar_scrape/problemSpreadsheets/notPutIntoDb.txt"
	tab = readFinData(fname=badRowFile)
	tab = fixTextFiles(tab=tab)
	tab = fixColumns(tab=tab)
	cat("Re-writing repaired file\n")
	write.finance.txt(dat=tab, fname=badRowFile)
	badRows = safeWrite(tab=tab, tableName="raw_committee_transactions", dbname="hack_oregon", append=T)
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
	convxls = gsub(pattern="/convertedToTsv",replacement="",x=convxls)
	if(!file.exists("./orestar_scrape/originalXLSdocs/")) dir.create("./orestar_scrape/originalXLSdocs/")
	for(fn in convxls){
		cat("Moving\n",fn,"\nto\n ./orestar_scrape/originalXLSdocs/\n")
		file.rename(from=fn, to=paste0("./orestar_scrape/originalXLSdocs/", basename(fn) ) )
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

# sdate = "07/01/2014"
# edate = "07/12/2014"
#
scrapeByDate<-function(sdate, edate, delay=10){
	
	wdtmp = getwd()
	if(basename(wdtmp)!="orestar_scrape"){
		if(!file.exists("orestar_scrape")) dir.create(path="./orestar_scrape/")
		setwd("./orestar_scrape/")	
	}
	comString = paste("/usr/local/bin/node scraper", edate, sdate, delay) #"node scraper 08/12/2014 07/12/2014 5"
	cat("\nCalling the scraper with this string:\n",comString,"\n")
	sysres = system(command=comString, wait=T, intern=T)
	
	setwd(wdtmp)
}


