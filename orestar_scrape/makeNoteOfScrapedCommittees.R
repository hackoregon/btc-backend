
# dbname="hack_oregon"
noteScrapedCommittees<-function(folderName="./originalXLSdocs/", dbname="hackoregon"){
	
	allfiles = dir(folderName)
	comscrapefiles = allfiles[grep(pattern="^[0-9]+(_)", x=allfiles)]
	
	ids = as.numeric(gsub(pattern="(_)[0-9_-]+(.xls)$", replacement="", x=comscrapefiles))
	
	scrapeDates = file.info(paste0(folderName,comscrapefiles))$mtime
	scrapeDates = as.Date(scrapeDates)
	
	dbiWrite(tabla=cbind.data.frame(ids, scrapeDates), name="import_dates", appendToTable=T, dbname=dbname)
	
}

getScrapedIds<-function(folderName="./originalXLSdocs/"){
	allfiles = dir(folderName)
	comscrapefiles = allfiles[grep(pattern="^[0-9]+(_)", x=allfiles)]
	
	ids = as.numeric(gsub(pattern="(_)[0-9_-]+(.xls)$", replacement="", x=comscrapefiles))
	
	return(ids)
}


