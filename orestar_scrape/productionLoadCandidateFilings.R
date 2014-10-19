
#productionLoadCandidateFilings
# source('./finDataImport.R')

#df = apres
cat("\nInside productionLoadCandidateFilings.R\n")

if(!require("stringr")){
	install.packages("stringr", repos="http://ftp.osuosl.org/pub/cran/")
	library("stringr")
}

cat("\ncurrent working directory:",getwd(),"\n")
source("./finDataImport.R")

findLoadCandidateFilings<-function(cfilingsfname=NULL){
	if(is.null(cfilingsfname)){
		allfiles = dir()
		cfilingsfname = allfiles[grepl(pattern="candidateFilings", x=allfiles)]
	}
	cfilingsfname = returnNewestFileName(fnames=cfilingsfname)
	cat("Loading candidate filings from file:\n",cfilingsfname,"\n")
	txtres = special.read.xls(xlsName=cfilingsfname)
	cat("Dimensions of loaded data:", dim(txtres),"\n")
	return(txtres)
}

returnNewestFileName<-function(fnames){
	nindex = file.info(fnames)$mtime == max(file.info(fnames)$mtime)
	return( fnames[nindex] )
}

cleanCells<-function(rawTab){
	#remove non ascii
	txtres = checkRemoveNonStandardCharacters(df=rawTab)
	#remove carriage returns
	cat("Removing tabs and carriage returns from inside cells..\n")
	noret = apply(X=txtres, MARGIN=2, FUN=function(x){gsub(x=x,
																												 pattern="\n",
																												 replacement="; ")})
	#remove tabs
	noret = apply(X=txtres, MARGIN=2, FUN=function(x){gsub(x=x,
																												 pattern="\t",
																												 replacement="; ")})
	#remove leading and trailing white space
	cat("Triming white space from front and end of cell values..\n")
	apres = apply(X=noret, MARGIN=2, FUN=str_trim)
	cat("Making NAs consistent..\n")
	apres <- unifyNAs(tab=apres)
	
	apres = as.data.frame(apres, stringsAsFactors=F)
	#trasform dates to date type
	cat("standardizing column names...\n")
	colnames(apres) = fixColumnNames(cnames=colnames(apres))
	cat("checking table can be saved and reopened...\n")
	cat("dimensions before save:", dim(apres),"\n")
	write.table(x=apres,sep="\t",row.names=F,
							col.names=T, file="./cleanCandidateFilings.txt")
	reopened = read.table(file="./cleanCandidateFilings.txt", 
												header=T, stringsAsFactors=F, comment.char="")
	cat("dimensions after save:", dim(reopened),"\n")
	return(reopened)
}

setColumnDataTypesForCandidateFilings<-function(tab){
	
	for(cln in grep("_date$|$date_|_date_",colnames(tab), ignore.case=T)) tab[,cln] = as.Date(x=tab[,cln], format="%m/%d/%Y")
	cat("Making id_nbr column into integer data type..\n")
	tab$id_nbr = makeIntegerColumn(colVals=tab$id_nbr, tab=tab)
	cat("Making candidate_file_rsn column into integer data type..\n")
	tab$candidate_file_rsn = makeIntegerColumn(colVals=tab$candidate_file_rsn, tab=tab)
	#order by date
	tab = tab[order(tab$filed_date,decreasing=T),]
	return(tab)
}

candidateFilingsExcelToDb<-function(fname=NULL, 
																		cfTableName="test_candidate_filings", 
																		returnTable=F, 
																		dbname="hackoregon"){
	
	rawTab = findLoadCandidateFilings(cfilingsfname=fname)
	
	cleanTab = cleanCells(rawTab=rawTab)
	cleanTab = setColumnDataTypesForCandidateFilings(tab=cleanTab)
	dbiWrite(tabla=cleanTab, name=cfTableName, dbname=dbname)
	if(returnTable) return(cleanTab)
}

getMostRecent<-function(apres, dfcol="party_descr",dateCol="filed_date"){
	
	unames = unique(apres$cand_ballot_name_txt)
	dfout = data.frame(party=rep("", times=length(unames)), stringsAsFactors=F)
	rownames(dfout)<-unames
	
	for(cname in unames){
		cind = which(apres$cand_ballot_name_txt==cname)
		if(length(cind)>1){
			maxind = cind[apres[cind,dateCol]==max(apres[cind,dateCol])]
			dfout[cname,] = paste(apres[maxind,dfcol],sep=", ",collapse=", ")
		}else{
			dfout[cname,] = apres[cind,dfcol]
		}
	}
	return(dfout)
}


makeWorkingCandidateFilings<-function( dbname, fname=NULL ){
	candidateFilingsExcelToDb(cfTableName="raw_candidate_filings", fname=fname,
														returnTable=FALSE, dbname=dbname)
	cffdb = dbiRead(query="select * from raw_candidate_filings", dbname=dbname)
	cat("Dimensions of retreived raw candidate filings:",dim(cffdb),"\n")
	# 	#these two steps will get the newest for each candidate.
	# 	cffdb = makeCandidateNameNice(cffdb = cffdb0)
	
	#candidate_ballot_name is not unique enough, use first and last name appended to eachother. 
	cffdb = cffdb[order(cffdb$candidate_file_rsn, decreasing=T),] 

	wcf = cffdb[!duplicated(x=cffdb[,c("first_name","last_name")]),,drop=F]
	colnames(wcf)<-tolower(colnames(wcf))
	colnames(wcf)<-gsub(pattern="[.]",replacement="_",x=colnames(wcf))
	
	cat("Dimensions of working candidate filings being sent to the database:",dim(wcf),"\n")
	dbiWrite(tabla=wcf, name="working_candidate_filings", dbname=dbname, appendToTable=FALSE)
}

makeCandidateNameNice<-function(cffdb){
	cat("\nThe makeCandidateNameNice will attempt to use candidate\n",
			"data to make a uniquely identifying name for the candidate.\n",
			"This will include removing the middle initial.. .  .")
	
	#
	
	
}


old_makeWorkingCandidateFilings<-function(dbname){
	
	cat("\nMakeWorkingCandidateFilings() searches the working directory\n'",getwd(),
			"'\nfor a file with the substring 'candidateFilings' in its name,",
			"\ncreates a raw_candidate_filings table, then from that creates the",
			"\nworking_candidate_filings table in the hackoregon database.\n")
	
	apres = candidateFilingsExcelToDb(cfTableName="raw_candidate_filings", returnTable=TRUE, dbname=dbname)
	#deal with those with multiple parties and multiple races
	idpart = apres[,c("cand_ballot_name_txt","party_descr")]
	idpart = unique(idpart)
	all_parties = aggregate(x=idpart$party_descr, by=list(id = idpart$cand_ballot_name_txt), 
													FUN=function(x){paste(x,collapse="; ",sep="; ")})
	colnames(all_parties)<-c("id","all_parties")
	
	all_races = aggregate(x=1:nrow(apres), by=list(id=apres$cand_ballot_name_txt), 
												FUN=function(x){
													paste(paste(apres$filed_date[x], apres$candidate_office[x],sep=", "),collapse="; ")
												})
	colnames(all_races)<-c("id","all_races")
	
	parties = getMostRecent(apres=apres, dfcol="party_descr")
	races 	= getMostRecent(apres=apres, dfcol="candidate_office")
	
	#get the most updated records
	apres = apres[order(apres$"filed_date", decreasing=T),]
	apresFinal = apres[!duplicated(apres$cand_ballot_name_txt),]
	rownames(apresFinal)<-apresFinal$cand_ballot_name_txt
	apresFinal[rownames(parties),"party_descr"] = parties
	apresFinal[rownames(races),"candidate_office"] = races
	
	#put the final data frame together
	apresFinal = merge(x=apresFinal, y=all_parties, by.y="id",by.x="cand_ballot_name_txt")
	apresFinal = merge(x=apresFinal, y=all_races, by.y="id",by.x="cand_ballot_name_txt")
	
	colnames(apresFinal)<-tolower(colnames(apresFinal))
	colnames(apresFinal)<-gsub(pattern="[.]",replacement="_",x=colnames(apresFinal))
	
	dbiWrite(tabla=apresFinal, name="working_candidate_filings", dbname=dbname, appendToTable=FALSE)
	
	# 	View(apres[,c("cand_ballot_name_txt","first_name","mdle_name","last_name","sufx_name")])
	
}



