
source('./dbi.R')
if(!require("plyr")){
	install.packages("plyr", repos="http://ftp.osuosl.org/pub/cran/")
	library("plyr")
}

if(!require("rjson")){
	install.packages("rjson", repos="http://ftp.osuosl.org/pub/cran/")
	library("rjson")
}

if(!require("stringr")){
	install.packages("stringr", repos="http://ftp.osuosl.org/pub/cran/")
	library("stringr")
}

ERRORLOGFILENAME="affiliationScrapeErrorlog.txt"

# committeefolder = "raw_committee_data"
# dbname = "hack_oregon"
# comTabName = "raw_committees_scraped"
bulkLoadScrapedCommitteeData<-function(committeefolder, dbname, comTabName){
	allfiles = dir(committeefolder)
	scrapeFiles = allfiles[grepl(pattern="^[0-9]+(.txt)$", x=allfiles)]
	if(length(scrapeFiles)){
		comids = as.integer(gsub(pattern=".txt$", replacement="", x=scrapeFiles))
		cat("Found",length(comids)," download files with likely committee IDs.\n")
		rawScrapeDat = rawScrapeToTable(committeeNumbers=comids, rawdir=committeefolder, 
																		attemptRetry=F, 
																		moveErrantScrapes=T)
		cat("\nLoaded scrape data for",nrow(rawScrapeDat),"committees.\n")
		sendCommitteesToDb( comtab=rawScrapeDat, 
												dbname=dbname, 
												rawScrapeComTabName=comTabName )
	# 		updateWorkingCommitteesTableWithScraped(dbname=dbname)
	}else{
		if(!file.exists(committeefolder)) dir.create(committeefolder)
		message("No scraped committee files found in folder\n'",committeefolder,"'")
		message("Current working directory:", getwd())
	}
	cat("\n..\n")
}


ccidsInComms<-function(){
	q = "select distinct \"Committee_Id\" from comms where \"Committee_Type\" = 'CC'"
	res = dbiRead(query=q, dbname="contributions")
	cuids = unique(res[,1])
	return(cuids)
}

idsInFins<-function(){
	q="select distinct \"Filer_Id\" from fins"
	res1 = dbiRead(query=q, dbname="contributions")
	
	q1 = "select distinct \"Contributor_Payee_Committee_ID\" from fins"
	res2 =  dbiRead(query=q1, dbname="contributions")
	uids = unique(c(res1[,1], res2[,1]))
	return(uids)
}

affiliationsFromFilings<-function(){
	
	q3 = "select * from afcomms" #where \"Party_Descr\" is null;"
	res3 =  dbiRead(query=q3, dbname="contributions")
	return(res3)
}

orestarConnect<-function(commID = 2752){
	
	nodeString = "/Users/samhiggins2001_worldperks/local/bin/node"
	if( !file.exists(nodeString) ) nodeString = "/usr/local/bin/node"
	if( !file.exists(nodeString) ) nodeString = "/usr/bin/nodejs"
	
	sysReq = paste0(nodeString," ./orestar_scrape_committees/scraper ",commID)
	sres = system(command=sysReq, intern=TRUE)
	return(sres)
}

cleanRes<-function(sres){
	gsr = gsub(pattern="[{}']|\\\\n|(\\s)+",replacement=" ", x=sres, perl=TRUE)
	gsr = gsub(pattern="(\\s)+",replacement=" ", x=gsr, perl=TRUE)
	gsr = gsub(pattern=":\\s:\\s",replacement=" : ", x=gsr, perl=TRUE)
	spres  = strsplit(x=gsr, split=" : ")
	i = 2
	vout = rep("", times=length(spres))
	for(i in 1:length(spres)){
		crow = spres[[i]]
		cur = gsub(pattern="^\\s|\\s,$", replacement="", x=crow)
		vout[i] = cur[2]
		names(vout)[i] = cur[1]
	}
	
	vout = vout[!is.na(vout)]
	vout = vout[!vout==","]
	return(vout)
}

cleanRes2<-function(sres){
	library("rjson")
	gsr = gsub(pattern="[']|\\\\n|(\\s)+",replacement=" ", x=sres, perl=TRUE)
	gsr = gsub(pattern="(\\s)+",replacement=" ", x=gsr, perl=TRUE)
	gsr = gsub(pattern=":\\s:\\s",replacement=" : ", x=gsr, perl=TRUE)
	spres  = strsplit(x=gsr, split=" : ")
	i = 2
	vout = rep("", times=length(spres))
	for(i in 1:length(spres)){
		crow = spres[[i]]
		cur = gsub(pattern="^\\s|\\s,$", replacement="", x=crow)
		vout[i] = cur[2]
		names(vout)[i] = cur[1]
	}
	
	vout = vout[!is.na(vout)]
	vout = vout[!vout==","]
	return(vout)
}

convertFromJSON<-function(sres){
	gsr00 = gsub(pattern="\"", replacement="", x=sres)
	gsr0 = gsub(pattern="\\\\n|(\\s)+",replacement=" ", x=gsr00, perl=TRUE)
	gsr1=gsub(perl=TRUE, pattern="\\\\'", replace="<tmp00>", x=gsr0)
	gsr1=gsub(perl=TRUE, pattern="'", replace="\"", x=gsr1)
	gsr1=gsub(fixed=TRUE, pattern="<tmp00>", replace="\'", x=gsr1)
	gsr2 = paste0(gsr1, collapse=" ")
	gsr3 = gsub(pattern="(\\s)+", replacement=" ", x=gsr2 )
	gsr4 = gsub(pattern="\\\\", replacement=" ", x=gsr3)
	gsr5 = gsub(pattern="[", replacement=" ", x=gsr4, fixed=T)
	gsr5 = gsub(pattern="]", replacement=" ", x=gsr5)
	gsr6 = gsub(pattern="{ measures:", replacement="{ \"measures\":", x=gsr5, fixed=T)
	jsl = fromJSON(json_str=gsr6)
	# 	jsl = fromJSON(txt=gsr6, flatten=T, simplifyVector=T)
}

flattenList_depricated<-function(jsl2){
	#first see if some slot names are repeated
	snames=c()
	for(nm in names(jsl2)) snames = c(snames, names(jsl2[[nm]]))
	ntab=table(snames)
	mergers = names(ntab)[ntab>1]
	flattened = c()
	jsl3 = jsl2
	for(nm in names(jsl2)){
		
		tomerge = names(jsl2[[nm]])[names(jsl2[[nm]])%in%mergers]
		merged = paste(nm, tomerge)
		names(jsl3[[nm]])[names(jsl3[[nm]])%in%mergers] = merged
		flattened = c(flattened, jsl3[[nm]])
	}
	return(unlist(flattened))
}

flattenList<-function(jsl2){

	flattened = c()
	#go through each list slot, adding its contents
	for(i in 1:length(jsl2)){
		nm = names(jsl2)[i]
		#if the sub key is already there, append the slot name
		tmp = jsl2[[nm]]
		alreadyIn = names(tmp)%in%names(flattened)
		if(i>1)	names(tmp)= paste(nm, names(tmp))
		flattened = c(flattened, tmp)
	}

	return(unlist(flattened))
}

scrubConvertedJson<-function(jsl){
	
	names(jsl) <- gsub( pattern="Information", replacement="", x=names(jsl) )
	names(jsl) <- rmWhiteSpace(strin=names(jsl))
	names(jsl) <- gsub(pattern=":$", replacement="", x=names(jsl))
	jsout = list()
	for(i in 1:length(jsl)){
		nms = names(jsl)[i]
		subl <- jsl[[nms]] 
		if( ( !is.null(subl) | !nms%in%c(" ","") ) & length(subl) ){ #removes blank slots & assures the list isn't empty
			if( class(subl)=="list" ){
				subl <- scrubConvertedJson(jsl=subl)
			} else {
				subl <- rmWhiteSpace(subl)
			}
			jsout[[nms]] = subl
		} 
	}
	return(jsout)
}

test.rmWhiteSpace<-function(){
	
	rmres = rmWhiteSpace(strin="   test   two   ")
	checkEquals(target="test two", current=rmres)
}

rmWhiteSpace<-function(strin){
	strout <- gsub( pattern="(^[ ]+)|[ ]+$", replacement="", x=strin )
	strout <- gsub( pattern="[ ]+", replacement=" ", x=strout )
	return(strout)
}

tabulateRecs<-function(lout){
	
	if( !length(lout) ) return(NULL)
	ukeys = c()
	
	for(i in names(lout)){
		cur = lout[[i]]
		ukeys = c(ukeys, names(cur))
	}
	ukeys=unique(ukeys)
	omat = matrix(nrow=length(lout), ncol=length(ukeys), dimnames= list( names(lout), ukeys ))
	for(i in names(lout)){
		cur = lout[[i]]
		omat[i,names(cur)] = cur
	}
	omat[,"ID"] = gsub(pattern="[^0-9]", replacement="", x=omat[,"ID"])
	return(omat)
}

scrapeTheseCommittees<-function(committeeNumbers, commfold = "raw_committee_data", forceRedownload=F){
	cat("Attempting to obtain records for these committees:\n")
	print(committeeNumbers)
	
	if( !file.exists(commfold) ) dir.create(path=commfold)
	
	for(cn in committeeNumbers){
		cat("\nCandidate committee ID:",cn,"\n")
		rawCommfile = paste0(commfold,"/", cn, ".txt")
		if( !file.exists(rawCommfile) | forceRedownload ){
			r1 = orestarConnect(commID=cn)
			if( grepl(pattern="Committee", x=r1[1], ignore.case=TRUE) ){
				write.table(x=r1, file=rawCommfile )
			}else{
				Sys.sleep(time=sample(x=5:20, size=1))
				r1 = orestarConnect(commID=cn)
				if(!grepl(pattern="Committee", x=r1[1], ignore.case=TRUE)) logError(err=paste("No committee data returned for committee",cn))
				write.table(x=r1, file=rawCommfile )
			}
			cat("Catnap...\n")
			Sys.sleep(time=sample(x=5:20, size=1))
		}else{
			cat("Record already downloaded\n")
		}
		# 	cleanRecs = cleanRes(sres=r1)
		# 	lout[[as.character(cn)]] = cleanRecs
	}
}


#'@description Open each scrped file and join all the results into a table. 
makeTableFromScrape<-function(committeeNumbers, rawdir=""){
	
	lout = list()
	for(cn in committeeNumbers){
		comfile = paste0(rawdir,"/",cn,".txt")
		# 	r1 = orestarConnect(commID=cn)
		if( file.exists(comfile) ){
			cat("..found:",cn,"..")
			r2 = read.table(file=comfile,stringsAsFactors=F)[,1]
			cleanRecs = cleanRes(sres=r2)
			lout[[as.character(cn)]] = cleanRecs
		}else{
			cat("..comm id not found:",cn,"..")
		}
	}
	rectab = tabulateRecs(lout=lout)
	return(rectab)
	
}

vectorFromRecord<-function(sres){
	listFromJson = convertFromJSON(sres=sres)
	cleanList = scrubConvertedJson(jsl=listFromJson)
	recordVector = flattenList(jsl2=cleanList)
	rvMeasureParsed = parseMeasureData(recvec=recordVector)
}

parseMeasureData<-function(recvec){
	if( !length(grep(pattern="measures", x=names(recvec), fixed=T)) ) return(recvec)
	
	mdat = recvec[grep(pattern="measures", x=names(recvec), fixed=T)]
	mdat = gsub(pattern="[{}]", x=mdat, replacement="")
	mdat2 = strsplit(x=mdat, split=",(?!\\s)", perl=T)[[1]]
	mdat3 = strsplit(split=": ", x=mdat2)
	mvector = unlist(lapply(X=mdat3, 
													FUN=function(x){
														vl = x[2]
														vl = str_trim(string=vl, side="both")
														names(vl) = paste0("measure_", x[1])
														return(vl)
													}))

	recvec = recvec[!grepl(pattern="measures", x=names(recvec), fixed=T)]
	rout = c(recvec, mvector)
	return(rout)
}

addScrapedToWorkingCommitteesTable<-function(dbname){
	
	q1="insert into working_committees
			(select id as committee_id, committee_name, 
			committee_type, pac_type as committee_subtype, 
			party_affiliation, election_office, candidate_name, 
			candidate_email_address, candidate_work_phone_home_phone_fax, 
			candidate_address, treasurer_name, treasurer_work_phone_home_phone_fax, 
			treasurer_mailing_address
			from raw_committees_scraped);"
	dbCall(sql=q1, dbname=dbname)
}

updateWorkingCommitteesTableWithScraped<-function(dbname){
	#first remove all committee ids that are being added from the scrapes
	# 	q0 = "delete from working_committees where committee_id in 
	# 	(select id from raw_committees_scraped)"
	# 	dbCall(sql=q0, dbname=dbname)
	# 	#second, insert the new set of committees from raw committees to working committees. 
	# 	q1="insert into working_committees
	# 	(select id as committee_id, 
	# 		name as committee_name, 
	# 		committee_type, 
	# 		pac_type as committee_subtype, 
	# 		candidate_party_affiliation as party_affiliation, 
	# 		campaign_phone as phone,
	# 		candidate_election_office as election_office, 
	# 		candidate_name, 
	# 		candidate_email_address, 
	# 		candidate_work_phone_home_phone_fax, 
	# 		candidate_candidate_address as candidate_address,  
	# 		treasurer_name, 
	# 		treasurer_work_phone_home_phone_fax, 
	# 		treasurer_mailing_address, 
	# 		NULL as web_address
	# 	from raw_committees_scraped);"
	# 	dbCall(sql=q1, dbname=dbname)

	if( file.exists("~/data_infrastructure") ){ #check this is the ubuntu installation
		setwd("..")
		system("sudo -u postgres psql hackoregon < ./makeWorkingCommittees.sql")
		setwd("./orestar_scrape/")
	}

}

rawScrapeToTable<-function(committeeNumbers, rawdir="", attemptRetry=T, moveErrantScrapes=F){

	lout = list()
	notDownloaded = c()
	for(cn in committeeNumbers){
		comfile = paste0(rawdir,"/",cn,".txt")
		# 	r1 = orestarConnect(commID=cn)
		if( file.exists(comfile) ){
			cat("..found:",cn,"..")
			r2 = read.table(file=comfile,stringsAsFactors=F)[,1]
			if( !grepl(pattern="Committee", x=r2[1], ignore.case=TRUE) ){#r2[1]=="x"){ #if the scraper did not find anything, x will be returned. 
				logError(err=paste("The scraper failed to download data for the committee,",cn,"\n"))
				notDownloaded = c(notDownloaded, cn)
				cat("Error in import, 'Committee' not found. See",ERRORLOGFILENAME,"..")
			}else{
				recvec = try(expr=vectorFromRecord(sres=r2), silent=TRUE)
				if( grepl(pattern="error", x=class(recvec)) ){
					logError(err=recvec, additionalData=paste("committee download file:",comfile) )
					cat("Error in conversion of record to JSON, see",ERRORLOGFILENAME,"..")
				}else if(is.null(recvec)){
					notDownloaded = c(notDownloaded, cn)
				}else{
					lout[[as.character(cn)]] = recvec
				}
			}
		}else{
			notDownloaded = c(notDownloaded, cn)
			message("..comm id not found by rawScrapeToTable() function!!:",cn,"..\n")
			# 			warning("..comm id not found by rawScrapeToTable() function!!:",cn,"..\n")
		}
	}
	
	notDownloaded = unique(notDownloaded)
	rectab = tabulateRecs(lout=lout)
	
	if( length(notDownloaded)&attemptRetry ){
		cat("\n\nData for these committees was not correctly downloaded on the first attempt:\n", 
				paste(notDownloaded, collapse=", "),
				"\nTrying again..\n")
		scrapeTheseCommittees(committeeNumbers=notDownloaded, commfold="raw_committee_data", forceRedownload=TRUE)
		logWarnings(warnings())
		rectab2 = rawScrapeToTable(committeeNumbers=notDownloaded, rawdir="raw_committee_data", attemptRetry=F, moveErrantScrapes=T)
		if(is.null(rectab)){
			rectab = rectab2
		}else if(is.null(rectab2)){
			rectab = rectab
		}else{
			rectab = rbind.fill.matrix(rectab, rectab2)
		}
		
	}
	
	if( length(notDownloaded) & moveErrantScrapes ) moveErrantScrapesFun(comIDs=notDownloaded, rawdir=rawdir)
	
	rectab = unique(rectab)
	
	return(rectab)
	
}

moveErrantScrapesFun<-function(comIDs, rawdir){ #note: rectab cannot just be records from current scrape.. it must be reflect all records from all scrapes

	cat("Attempting to move errant scrape files for these committees:\n", comIDs, "\n")
	if( length(comIDs) ){
		toMove = comIDs[ file.exists(paste0(rawdir, "/", comIDs, ".txt")) ] #find all the files that actually exists. 
		if( length(toMove) ){
			cat("\nThese corresponding files will be moved to the failedScrapes folder:\n")
			print(paste0(rawdir,"/",toMove,".txt"))
			dir.create(paste0(rawdir,"/failedScrapes/"), showWarnings=FALSE)
			for(fi in toMove) file.rename(to=paste0(rawdir,"/failedScrapes/",fi,".txt"), 
																		from=paste0(rawdir,"/",fi,".txt") )
		}
	}
}

moveSuccessfullScrapes<-function(rectab, rawdir){
	cat("\nDimensions of raw committee data from scrape:\n", dim(rectab), "\n")
	#determine which of the committeeNumbers cannot be found in the
	#rectab but can be found as dl file names

	#get the committee numbers from the file names
	allfnms = dir(rawdir)
	comfnms = allfnms[grep(pattern=".txt$", x=allfnms)]
	committeeNumbers = as.integer(gsub(pattern=".txt$",replacement="", x=comfnms))
	
	inrectab = intersect(committeeNumbers, as.integer(rectab[,"ID"]) )
	
	if(length(inrectab)){
		cat("\nThe import succeeded with these committees:\n")
		print(inrectab)
		toMove = inrectab[file.exists(paste0(rawdir,"/" ,inrectab, ".txt"))]
		if( length(toMove) ){
			cat("\nThese corresponding files will be moved to the successfullCommitteeScrapes folder:\n")
			print(paste0(rawdir,"/",toMove,".txt"))
			dir.create(paste0(rawdir,"/successfullCommitteeScrapes/"), showWarnings=FALSE)
			for(fi in toMove) file.rename(to=paste0(rawdir,"/successfullCommitteeScrapes/",fi,".txt"), 
																					 from=paste0(rawdir,"/",fi,".txt") )
		}
	}
}


# 
# #the first block
# q1 = "select * from neededComms"
# res1 = dbiRead(query=q1, dbname="contributions")
# committeeNumbers=res1$Committee_Id#c(2752,16461, 12519, 13866)
# 
# scrapeTheseCommittees(committeeNumbers=committeeNumbers)
# rectab = makeTableFromScrape(committeeNumbers=committeeNumbers)
# View(rectab)
# rectab = as.data.frame(rectab, stringsAsFactors=F)
# 
# #the second block
# cuids = ccidsInComms()
# uids = idsInFins()
# CcInFins = intersect(cuids, uids)
# fromFilings = affiliationsFromFilings()
# ffNoAffil = fromFilings[is.na(fromFilings$Party_Descr),]
# ffNoAffilIds = ffNoAffil$Committee_Id
# 
# affilationTested = rownames(rectab)
# stillNeeded = setdiff(ffNoAffilIds, affilationTested)
# 
# 
# scrapeTheseCommittees(committeeNumbers=stillNeeded)
# tout2 = makeTableFromScrape(committeeNumbers=stillNeeded)
# 
# 
# tout3 = makeTableFromScrape(committeeNumbers=c(stillNeeded,committeeNumbers))
# tout3 = as.data.frame(tout3)
# 
# table(tout3$"Party Affiliation")
# 
# knownComms = fromFilings[!is.na(fromFilings$Party_Descr),c("Committee_Id","Party_Descr")]
# colnames(knownComms)<-c("id","party")
# 
# numAndAffil = tout3[,c("ID","Party Affiliation")]
# numAndAffil$id <-as.character(numAndAffil$id)
# colnames(numAndAffil)<-c("id","party")
# numAndAffil[is.na(numAndAffil$id),"id"]<-rownames(numAndAffil)[is.na(numAndAffil$id)]
# 
# withAffil=rbind.data.frame(knownComms, numAndAffil)
# 
# duprows = withAffil[duplicated(withAffil$id)|duplicated(withAffil$id, fromLast=T),]
# duprows = duprows[order(duprows$id, decreasing=T),]
# 
# library(ggplot2)
# ggplot(data=withAffil, aes(x=party))+geom_bar()
# 
# 
