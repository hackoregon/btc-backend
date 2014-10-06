#finDataImport.R
cat("\nLoading finDataImport.R .. \n")
cat("Working directory:\n",getwd(),"\n")

if(!require("R.utils")){
	install.packages("R.utils", repos="http://ftp.osuosl.org/pub/cran/")
	library("R.utils")
}
if(!require("xlsx")){
	install.packages("xlsx", repos="http://ftp.osuosl.org/pub/cran/")
	library("xlsx")
}

if(!require("ggplot2")){
	install.packages("ggplot2", repos="http://ftp.osuosl.org/pub/cran/")
	library("ggplot2")
}
if(!require("DBI")){
	install.packages("DBI", repos="http://ftp.osuosl.org/pub/cran/")
	library("DBI")
}

if(basename(getwd())=="orestar_scrape"){
	source("./dbi.R")
}else{
	source("./orestar_scrape/dbi.R")
}

logError<-function(err,additionalData="",errorLogFname=NULL){
	if(!is.null(errorLogFname)) ERRORLOGFILENAME = errorLogFname
	mess = paste(as.character(Sys.time())," ",additionalData,"\n",as.character(err))
	message("Errors found in committee data import, see error log: ",ERRORLOGFILENAME)
	print(mess)
	warning("Errors found in committee data import, see error log: ",ERRORLOGFILENAME)
	write.table(file=ERRORLOGFILENAME, x=mess, 
							append=TRUE, 
							col.names=FALSE, 
							row.names=FALSE, 
							quote=FALSE)
	cat("\nError log written to file '",ERRORLOGFILENAME,"'\n")
}


test.bulkImportTransactions<-function(){
	fname="./transaction_sets/"
	bulkImportTransactions(fname=fname, dbname="hack_oregon", tablename="raw_committee_transactions")
}

bulkImportTransactions<-function(fname, dbname="hackoregon", tablename="raw_committee_transactions"){
	if( file.info(fname)[1,"isdir"] ){
		bulkImportFolder(fname=fname, dbname=dbname, tablename=tablename)
	}else{
		bulkImportSingleFile(fname=fname, dbname=dbname, tablename=tablename)
	}
}

bulkImportFolder<-function(fname, dbname, tablename){
	errorLogFname = paste0(fname,"/importErrors.txt")
	errorLogFname = gsub(pattern="//",replacement="/", x=errorLogFname)
	failedImports=c()
	cat("\nImporting .tsv and .csv files in folder : \n",fname,"\n")
	setwd(fname)
	allFiles = dir()
	allFiles = allFiles[grepl(pattern="[.]tsv$|[.]csv$", x=allFiles, ignore.case=T)]
	if(!length(allFiles)) stop("Could not find any .tsv or .csv files in the directory: ",fname)
	for(fn in allFiles){
		cat("\nCurrent file:",fn,"\n")
		tres = try(expr={
							bulkImportSingleFile(fname=fn, dbname=dbname, tablename=tablename)
						}, silent=TRUE )
		if(grepl(pattern="error", x=class(tres), ignore.case=T)){
			failedImports = c(failedImports, fn)
			logError(err=tres, additionalData=fn, errorLogFname=errorLogFname)
		}
	}
	if(length(failedImports)){
		cat("\n----------------------------------------------------------------------\n")
		cat("\nThere were errors while attempting to import records from these files:\n")
		print(failedImports)
		cat("\nSee file\n",errorLogFname,"\nfor details on import errors\n")
	}
}

bulkImportSingleFile<-function(fname, dbname, tablename){
	#open the table
	tab = read.finance.txt(fname=fname)
	cat("\nOpened transactions table with",nrow(tab),"rows of transactions\n(ncol=",ncol(tab),")\n")
	#adjust column data types
	#add to database
	#check duplicates
	importTransactionsTableToDb(tab=tab, tableName=tablename, dbname=dbname)
	cat("\nImport successfull?\n")
	#test read
	print(dbTableExists(tableName=tablename, dbname=dbname))
	#move the input file to the /loadedTransactions folder?
}

exportTransactionsTable<-function(dbname, destFileName=NULL){

	if(is.null(destFileName)) destFileName = paste0("rawtransactionsdump",gsub(pattern=":|-|[ ]", replacement="_", x=Sys.time()),".txt")
	tab = dbiRead(query="select * from raw_committee_transactions;", dbname=dbname)
	cat("\nTransactions table found with dimensions",dim(tab),".\n")
	write.finance.txt(dat=tab, fname=destFileName)
	
}

checkRemoveNonStandardCharacters<-function(df,encodings=c("latin1","latin2")){
	
	for(enc in encodings){
		cat("Checking for",enc,"characters...\n")
		for(i in 1:ncol(df)){
			df[,i] = iconv(x=df[,i], from=enc,to="ASCII",sub=" ")
		}
	}
	
	return(df)
}


read.finance.txt<-function(fname){
	
	if(grepl(pattern=".csv$", x=fname)){
		return(read.csv(file=fname, 
										stringsAsFactors=F, 
										strip.white=T))
	}else{
		
		return(read.table(file=fname,
											allowEscapes=T,
											strip.white=T,
											comment.char="",
											check.names=F,
											header=T, 
											sep="\t", 
											stringsAsFactors=F))
		
	}
	
}

write.finance.txt<-function(dat,fname){

	if(grepl(pattern=".csv$", x=fname)){
		write.csv(x=dat, 
							file=fname, 
							row.names=F)
	}else{
	
		write.table(x=dat,
								file=fname, 
								append=F, 
								quote=T, 
								sep="\t", 
								row.names=F, 
								col.names=T, 
								qmethod="escape")
	}
	
}

debug.importAllXLSFiles<-function(){
	
	indir="../orestar/fins/problemSpreadsheets/"
	outsuffix=".txt"
	destDir=NULL
	forceImport=F
	remQuotes=T
	indir = gsub(pattern="[/]$", replacement="", x=indir)
	if(is.null(destDir)){
	destDir = paste0(indir,"/RecordsConvertedToTxt")
	dir.create(path=destDir, showWarnings=F, recursive=T)
	}
	destDir = gsub(pattern="[/]$", replacement="", x=destDir)
	errorDir=paste0(indir,"/problemSpreadsheets")
	dir.create(path=errorDir, showWarnings=F,recursive=T)
	curtab=NULL
	fulltab = NULL
	files = dir(indir)
	errorlog = c()
	errorFileNames = c()
	files = files[grepl(pattern=".xls$", files)]
	convertedFileNames = gsub(pattern=".xls",replacement=".txt",x=files)

	
}

# run.importAllXLSFiles<-function(){
# 	 
# 	importAllXLSFiles(indir="../orestar/comms/", remEscapes=T,
# 										forceImport=T, 
# 										remQuotes=T)
# 	comms = mergeTxtFiles(folderName="../orestar/comms/RecordsConvertedToTxt")
# 	
# 	commfname="../orestar/comms/RecordsConvertedToTxt/joinedTables.tsv"
# 	fixTextFiles(fnames=commfname)
# 	#now send it to the database
# 	fileToDb(tableName="comms", dbname="contributions", fname=commfname, delim="\t")
# 	
# 	
# 	importAllXLSFiles(indir="../orestar/fins/", 
# 										remEscapes=T,
# 										forceImport=T, 
# 										remQuotes=T)
# 	
# 	fins = mergeTxtFiles(folderName="../orestar/fins/RecordsConvertedToTxt")
# 	finfname="../orestar/fins/RecordsConvertedToTxt/joinedTables.tsv"
# 	
# 	tab = readFinData(fname=finfname)
# 	tab = fixTextFiles(tab=tab)
# 	cat("Fixing columns\n")
# 	tab = fixColumns(tab=tab)
# 	
# 	cat("Re-writing file\n")
# 	write.finance.txt(dat=tab, fname=finfname)
# 	# 	fileToDb(tableName="fins", dbname="contributions", fname=finfname, delim="\t")
# 	safeWrite(tab=tab, tableName="fins", dbname="contributions")
# }

setColumnDataTypesForCommittees<-function(tab){
	tab$id = makeIntegerColumn(colVals=tab$id, tab=tab, printErrors=F, printErrorValues=T)
	return(tab)
}

setColumnDataTypesForDB<-function(tab){
	#fix amount column
	cat("Converting 'amount' column to numeric...\n")
	tab$amount = makeNumericColumn(colVals=tab$amount)
	cat("Converting 'aggregate_amount' column to numeric..\n")
	tab$aggregate_amount = makeNumericColumn(colVals=tab$aggregate_amount)
	tab = makeDateColumns(tab=tab)
	tab = makeBoolcolumns(tab=tab, boolcols=c("employ_ind","tran_stsfd_ind","self_employ_ind"))
	return(tab)
}

makeBoolcolumns<-function(tab, boolcols=c("employ_ind","tran_stsfd_ind","self_employ_ind")){
	map = c(T,F)
	names(map) = c("Y","N")
	for(bc in boolcols){
		if(class(tab[,bc])=="logical"){
			cat("Column",bc,"is already boolean..\n")
		}else{
			cat("Converting column",bc,"to boolean..\n")
			tab[,bc] = map[tab[,bc]]
		}
	}
	return(tab)
}
makeDateColumns<-function(tab){
	datecols = colnames(tab)[grep(pattern="date", x=colnames(tab))]
	for(d in datecols){
		fmt = checkForDateFormat(dcol = tab[,d])
		cat("Converting column",d,"to date data type using date format",fmt,"..\n")
		tab[,d] = as.Date(x=tab[,d], format=fmt )
	}
	return(tab)
}

checkForDateFormat<-function(dcol){
	
	fmts = c( "%m/%d/%Y", "%Y/%m/%d", "%y/%m/%d", "%Y-%m-%d", "%m-%d-%Y", "%m/%d/%y", "%m-%d-%y", "%d%b%Y", "%d%b%y" )
	fmtsScores = c(rep(0,length(fmts)))
	for(i in 1:length(fmts)){
		fmtsScores[i] = sum(is.na( as.Date(x=dcol, format=fmts[i])))
	}
	winner = fmts[fmtsScores == min(fmtsScores)][1]
	return(winner)
}

makeIntegerColumn<-function(colVals, tab, printErrors=T, printErrorValues=F){
	naIndexes = which(is.na(colVals))
	if(length(naIndexes)) cat(length(naIndexes),"values found to be 'NA' \n")
	uam2 = as.integer(colVals)
	errorIndexes = which(is.na(uam2))
	errorIndexes = setdiff(errorIndexes, naIndexes)
	#display error indexes
	if(length(errorIndexes)){
		
		cat(length(errorIndexes), "values could not easily be coorsed to integer\n")
		if(printErrors) print(tab[errorIndexes,])	
		if(printErrorValues) print(colVals[errorIndexes])
		cat(length(errorIndexes), "values could not easily be coorsed to integer\n")
	
	}else{
		cat("\nColumns transformed to integer data type..\n")
	}
	return(uam2)
}

makeNumericColumn<-function(colVals){
	
	uam2 = as.numeric(colVals)
	errorIndexes = which(is.na(uam2))
	#display error indexes
	if( length(errorIndexes) ){
		cat(length(errorIndexes), "values could not easily be coorsed to numeric\n")
		if(!grepl(file.exists("~/data_infrastructre"))) View(colVals[errorIndexes,])
		cat("These are the indexes:\n")
		print(errorIndexes)
	}else{
		cat("\nColumns transformed to numeric data type..\n")
	}
	cat("Returning converted column values...\n")
	return(uam2)
}

# fixNewLineInField<-function(){
# 	fname = "/private/var/folders/sy/w_z0czvs2nqd2ys0vf_827zc0000gn/T/Rtmpw49UvB/filea108111303fa.tab"
# 	
# 	ttab = read.delim(file=fname, header=T, sep="\t", comment.char="", allowEscapes=T)
# 	
# 	xres = xls2sep(xls="../orestar/comms/2000.xls", sheet=1, verbose=F, method="tab")
# 	ttab = read.delim(file=summary(xres)$description, header=T, sep="\t", comment.char="", allowEscapes=T)
# }

special.read.xls<-function(xlsName){
	# 	xres = xls2sep(xls=xlsName, 
	# 								 sheet=1, 
	# 								 verbose=F, 
	# 								 method="tab")
	# 	retval = read.delim(file=summary(xres)$description, 
	# 										 stringsAsFactors=F,
	# 										 header=T, 
	# 										 sep="\t", 
	# 										 comment.char="", 
	# 										 allowEscapes=T)
	# 	close(xres)
	xlsdat = read.xlsx2(file=xlsName, sheetIndex=1, stringsAsFactors=F)
	return(xlsdat)
}

importAllXLSFiles<-function(indir="~/prog/hack_oregon/orestar/fins", 
														destDir=NULL, 
														forceImport=F, 
														remQuotes=F, 
														remEscapes=T, 
														grepPattern=".xls$"){
	
	indir = gsub(pattern="[/]$", replacement="", x=indir)
	
	if(is.null(destDir)){
		destDir = paste0(indir,"/RecordsConvertedToTxt")
		dir.create(path=destDir, showWarnings=F, recursive=T)
	}
	
	destDir = gsub(pattern="[/]$", replacement="", x=destDir)
	
	errorDir=paste0(indir,"/problemSpreadsheets")
	dir.create(path=errorDir, showWarnings=F,recursive=T)
	
	curtab=NULL
	
	files = dir(indir)
	
	errorlog = c()
	errorFileNames = c()
	
	files = files[grepl(pattern=grepPattern, files)]
	convertedFileNames = gsub(pattern=".xls",replacement=".txt",x=files)
	convertedFiles = c()
	if(!length(files)) return(convertedFiles)
	for(i in 1:length(files)){	
		
		srce = paste(indir, files[i], sep="/") 
		dest = paste(destDir, convertedFileNames[i], sep="/")
		cat("checking #",i,"of",length(files),"files:",files[i],"..")
		if( !file.exists(dest)|forceImport ){
			curtab = try(expr=special.read.xls(xlsName=srce), silent=TRUE)
			
			if( is.null(nrow(curtab)) ){
				cat("\nerror while reading file\n")
				addToErrorLog(errorLogFname=paste0(errorDir,"/","errorLog.txt"),
											vals=c(paste("read.xls error:", curtab), 
														 files[i]))
				#move file to error folder
				file.rename(from=srce, to=paste(errorDir, basename(path=srce), sep="/"))
			}else{
				cat("\nCleaning out quotes and escapes\n")
				if(remQuotes) curtab = scrubQuotes(tab=curtab)
				if(remEscapes) curtab = scrubEscapes(tab=curtab)
				cat("..opened, attempting save..")
				write.finance.txt(dat=curtab, fname=dest)
				testread = try(read.finance.txt(dest), silent=T)
				
				if( is.null(nrow(testread))|sum(dim(testread)!=dim(curtab)) ){
					cat("..error while reading file\n",srce,"\n")
					addToErrorLog(errorLogFname=paste0(errorDir,"/","errorLog.txt"),vals=c(paste("re read error:", testread), 
																																								 files[i]))
					#move files to error folder
					file.rename(from=dest, to=paste(errorDir, basename(path=dest), sep="/"))
					file.rename(from=srce, to=paste(errorDir, basename(path=srce), sep="/"))
				}else{
					convertedFiles = c(convertedFiles, dest)
					cat("successfully read..\n")
				}
			}
		}else{
			cat("the converted file already exists\n")
		}#	if(!file.exists(dest))
	}#for
	return(convertedFiles)
}#importAllXLSFiles()


scrubEscapes<-function(tab){
	for(cr in 1:nrow(tab)){
		tab[cr,]  = gsub(pattern="\n", replacement=" | ", x=tab[cr,])
		tab[cr,] = gsub(pattern="\t", replacement=" ", x=tab[cr,])
		tab[cr,] = gsub(pattern="^[\\]{1}$", replacement="", x=tab[cr,])
	}	
	return(tab)
}



addToErrorLog<-function(vals, errorLogFname){
	
	if(dirname(errorLogFname)!="."&!file.exists(dirname(errorLogFname))){
		dir.create(path=dirname(errorLogFname), showWarnings=F, recursive=T)
	}
	
	if(file.exists(errorLogFname)){
		elog = try(expr=read.table(file=errorLogFname, 
															 header=F, 
															 sep="\t",
															 stringsAsFactors=F, 
															 comment.char=""), silent=T)
		if(is.null(nrow(elog))){
			elog = as.data.frame(matrix(vals, nrow=1, dimnames=list(NULL,NULL)))
		}else{
			elog = rbind.data.frame(elog, vals)
			elog=unique(elog)
		}
		
	}else{
		elog = as.data.frame(matrix(vals, nrow=1, dimnames=list(NULL,NULL)))
		dir.create(path=basename(path=errorLogFname), recursive=T, showWarnings=F)
	}
	print(errorLogFname)
	
	write.table(x=elog,
							sep="\t", 
							col.names=F, 
							row.names=F,
							file=errorLogFname)

}

fixColumnNames<-function(cnames){
	cat("\nMaking all column names all lower case..\n")
	cnames = tolower(cnames)
	cnames = gsub(pattern="[.]", replacement="_", x=cnames)
	cnames = gsub(pattern=" ", replacement="_", x=cnames)
	cnames = gsub(pattern=":", replacement="", x=cnames)
	cnames = gsub(pattern="/", replacement="_", x=cnames)
	cnames = gsub(pattern="[_]+", replacement="_", x=cnames)
	return(cnames)
}

orderFilesByDateFileName<-function(){
	
}

mergeTxtFiles<-function( folderName ){
	
	folderName = gsub("/$","",folderName)
	filesWithBlankTranIds = c()
	
	allFiles = dir(folderName)
	
	#see if they can be ordered by file name

	
	txtFiles = allFiles[grepl(pattern=".txt$|.tsv$", x=allFiles, ignore.case=F, perl=T)]
	txtFiles = txtFiles[txtFiles!="problemSpreadsheetserrorLogTable.txt"]
	txtfilesfp = paste0(folderName,"/",txtFiles)
	joinedTableName = paste0(folderName, "/joinedTables.tsv")
	totalLines = countLinesAllFiles(folderName=folderName)
	totalLines = totalLines-length(txtfilesfp)
	cat("Expected total lines:",totalLines,"\n")
	# 	if(file.exists(joinedTableName)) txtfilesfp = c(txtfilesfp, joinedTableName)
	#make output data frame
	testRead = read.finance.txt(txtfilesfp[1])
	colnames(testRead)<-fixColumnNames(colnames(testRead))
	tabout = data.frame(matrix(data="", 
														 nrow=totalLines, 
														 ncol=ncol(testRead), 
														 dimnames=list(NULL, colnames(testRead))), 
											stringsAsFactors=F)
	curline = 1
	successfullyMerged = c()
	
	for(i in 1:length(txtfilesfp)){
		
		#open the file
		tabin = read.finance.txt( txtfilesfp[i] )
		colnames(tabin)<-fixColumnNames(colnames(tabin))
		if( sum(is.na(tabin[,1,drop=T])) ){
			filesWithBlankTranIds = c(filesWithBlankTranIds, txtfilesfp[i])
		}
		#add contents of file to tabout
		if( nrow(tabin) ){
			cat(i, txtfilesfp[i],"rows:",nrow(tabin),"\n")
			
			if( ( nrow(tabin)==1 & (sum(is.na(tabin[1,]))==ncol(tabin)) ) ) {
				cat("\nBlank table:", txtfilesfp[i], "\n\n")
			}else{
				tabout[curline:(curline+nrow(tabin)-1),] = tabin
				curline = curline + nrow(tabin)
			}
		}else{
			cat("\nBlank table:",txtfilesfp[i],"\n")
		}
		successfullyMerged = c(successfullyMerged, txtfilesfp[i])
		
	}
	successfullyMerged = successfullyMerged[!grepl(".tsv$",successfullyMerged)]
	#now cut off the data frame so that no blank rows are included
	cat("After raw merge:", dim(tabout),"\n")
	tabout = unique(tabout)
	cat("After filtering to unique records:", dim(tabout),"\n")
	remrows = is.na(tabout[,1])|is.null(tabout[,1])
	if( sum(remrows) ) tabout = tabout[!remrows,]
	cat("After removing records with NA values for transaction ids:", dim(tabout),"\n")
	# 	tabout = tabout[1:curline-1,]
	
	cat("Total dimensions of final merged file:", dim(tabout)[1],"rows", dim(tabout)[2],"columns\n")

	write.table(x=tabout, sep="\t",col.names=T, row.names=F, qmethod="escape",quote=T,
							file=joinedTableName)
	
	tmp = read.finance.txt(fname=joinedTableName)
	cat("Dimensions of data after it was saved and re-opened:",dim(tmp),"\n")
	successfullyMerged = successfullyMerged[grep(pattern=".txt$", x=successfullyMerged)]
	moveMerged(successfullyMerged, folderName)
	
	return(tmp)
}

moveMerged<-function(fnames,sourceDir=NULL){
	sourceDir = gsub(pattern="/$", replacement="",x=sourceDir)
	destDir = paste0(sourceDir,"/successfullyMerged/")
	if(!file.exists(destDir)) dir.create(destDir)
	for(fn in fnames){
		newfn = paste0(destDir,basename(fn))
		cat("Moving\n",fn,"\nto\n",newfn,"\n")
		file.rename(from=fn, to=newfn )
	}
}

countLinesAllFiles<-function(folderName, sep="\t"){
	cat("Counting lines in files...")
	allFiles = dir(folderName)
	txtFiles = allFiles[grepl(pattern=".txt$|.tsv$", x=allFiles, ignore.case=F, perl=T)]
	txtFiles = txtFiles[txtFiles!="problemSpreadsheetserrorLogTable.txt"]
	txtfilesfp = paste0(folderName,"/",txtFiles)
	
	#find the size of the needed data frame
	totalLines = 0
	lpf = c()
	for(i in 1:length(txtfilesfp)){
		
		clen = try(expr=countLines(txtfilesfp[i]), silent=T)
		if(sum(grepl(pattern="error", x=class(clen), ignore.case=T))){
			cat("trouble with the file",txtfilesfp[i], "trying another approach")
			tmp = read.table(file=txtfilesfp[i], header=T, sep=sep)
			clen = nrow(tmp)
		}
		lpf = c(lpf, clen)
		totalLines = totalLines + clen
		cat("file",i,":", txtfilesfp[i], "length", clen, "....\n")
	}
	cat("Warning: this function can only provide a conservative estimate of the number of lines in a file. It")
	cat("counts the number of lines in a text file by counting the number of occurances of platform-independent\n",
			"newlines (CR, LF, and CR+LF [1]), including a last line with neither. An empty file has zero lines.\n")
	
	return(totalLines)
}

readFinData<-function(fname){
	tabin = read.table(file=fname,
										 strip.white=T,
										 comment.char="",
										 check.names=F,
										 header=T, 
										 sep="\t", 
										 stringsAsFactors=F)	
	return(tabin)
}

hbarplot<-function(barDict, maxLevels=5, barPlotTitle="Counts across types", left_margin_factor=1){
	
	if(length(barDict)>maxLevels){
		barDict = barDict[order(barDict,decreasing=T)]
		barDict  = barDict[1:maxLevels]
	}
	
	oldmar <- par()$mar
	while(T){
		res = try({
			par(mar=c(5.1, max(4.1,max(left_margin_factor*nchar(names(barDict)))/2.5) ,4.1 ,2.1))
			#	try(displayGraph(w), silent=T)
			barplot(barDict, horiz=T, las=2, main = barPlotTitle, xlab="Number found in data set", names.arg=names(barDict))
			par(oldmar)
		}, silent=T)
		# 			if(!grepl(pattern="Error", x=res)) break
		if(is.null(res)) break
		par(oldmar)
		readline(prompt="There seems to have been an error with plotting the bar graph.\nPlease increase the size of the plot window, the press enter")
	}
	par(oldmar)
}

getTopAggregate<-function(agdf,numberPer,colname="Book.Type"){
	
	rownames(agdf)<-1:nrow(agdf)
	uVal = unique(agdf[,colname])
	
	dfout = data.frame(matrix(nrow=0,ncol=ncol(agdf), dimnames=list(NULL,colnames(agdf))))
	
	histSet = list()
	distSet = list()
	for(i in 1:length(uVal)){
		
		cat("\nCurrent book type: \"", uVal[i],"\"\n")
		#pull all the rows out
		cursub = agdf[agdf[,colname] == uVal[i],]
		#save the hist for latter
		histSet[[uVal[i]]] = hist(log(cursub$Aggregate.Amount, base=10), plot=F)
		distSet[[uVal[i]]] = log(cursub$Aggregate.Amount,base=10)
		#figure out which are the 25 top rows
		cursub = cursub[order(cursub$Aggregate.Amount, decreasing=T),]
		top25 = cursub[1:min(numberPer,nrow(cursub)),]
		if(nrow(cursub)>numberPer){#if there are more than numberPer records of the current colname type
			#then aggregate all the rest into an entity of type "remaining"+number
			#get everything not in rownames(top25)
			remSet = cursub[!rownames(cursub)%in%rownames(top25),]
			remRow = c(uVal[i], paste("Remaining ",nrow(cursub)-25," ",uVal[i],"(s)", sep=""),sum(remSet$Aggregate.Amount))
			dfout = rbind(dfout, top25, remRow)
		}else{
			dfout = rbind(dfout, top25)
		}
		
	}
	boxplot(x=distSet, 
					varwidth=T, 
					notch=T, 
					las=2, 
					horizontal=T, 
					xlab="log10(contribution amount)", 
					main="Distributions of contribution amounts per book type\n box height = number of different contributions")
	
	return(dfout)
}

test.getTopAggregate<-function(){
	
	colname="Book.Type"
	forR = aggregate(x=cleanFins$Amount, by=list(cleanFins[,colname],cleanFins$Contributor.Payee), FUN=sum)
	colnames(forR)<-c(colname,"Entity","Aggregate.Amount")
	numberPer=25
	topBookType1 = getTopAggregate(agdf=forR, numberPer=numberPer, colname=colname)
	
	ag2 = aggregate(x=cleanFins$Amount, by=list(cleanFins[,colname]), FUN=sum)
	
	write.table(x=topBookType1, 
							file="./aggregatedTopBooktypes.txt", 
							sep="\t", 
							col.names=T,
							row.names=F,
							quote=T)
	
	write.table(x=forR, 
							file="./aggregatedBooktypes.txt", 
							sep="\t", 
							col.names=T,
							row.names=F,
							quote=T)
	
	colname2="Purpose.Codes"
	numberPer=25
	forR2 = aggregate(x=cleanFins$Amount, by=list(cleanFins$Filer,cleanFins[,colname2]), FUN=sum)
	colnames(forR2)<-c(colname2,"Aggregate.Amount")
	
	topPurposeCodes1 = getTopAggregate(agdf=forR2, numberPer=numberPer, colname=colname2)
	
}


scrubQuotes<-function(tab){
	for(i in 1:nrow(tab)){
		tab[i,]  = gsub(pattern="[\"\'`]*", replacement="", x=tab[i,])
	}
	return(tab)
}

fixTextFiles<-function(tab){
	
	cur = tab

	cat("unifying NAs..\n")
	cur = unifyNAs(tab=cur)
	cat("Fixing headers..\n")
	cur = fixHeaders(tab=cur)
	return(cur)
	
}

unifyNAs<-function(tab){
	
	tab[is.na(tab)] = NA
	tab[tab=="NA"] = NA
	tab[tab=="<NA>"] = NA
	tab[tab=="N/A"]  = NA
	tab[tab=="n/a"]  = NA
	tab[tab==""]  = NA
	tab[tab==" "]  = NA
	tab[tab=="  "]  = NA
	return(tab)
	
}


fixHeaders<-function(tab){
	#strip leading ".X"
	colnames(tab)<-gsub(pattern="^X.", replacement="", x=colnames(tab))
	colnames(tab)<-gsub(pattern="[.]$", replacement="", x=colnames(tab))
	colnames(tab)<-gsub(pattern="[.]", replacement="_", x=colnames(tab))
	colnames(tab)<-tolower(x=colnames(tab))
	return(tab)
}

