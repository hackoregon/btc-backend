#finDataImport.R


if(!require("gdata")){
	install.packages("gdata")
	library("gdata")
}

if(!require("R.utils")){
	install.packages("R.utils")
	library("R.utils")
}
library("dplyr")
library("ggplot2")

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
	return(read.table(file=fname,
										allowEscapes=T,
										strip.white=T,
										comment.char="",
										check.names=F,
										header=T, 
										sep="\t", 
										stringsAsFactors=F))
}

write.finance.txt<-function(dat,fname){
	write.table(x=dat,
							file=fname, 
							append=F, 
							quote=T, 
							sep="\t", 
							row.names=F, 
							col.names=T, 
							qmethod="escape")
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

run.importAllXLSFiles<-function(){
	 
	importAllXLSFiles(indir="../orestar/comms/", remEscapes=T,
										forceImport=T, 
										remQuotes=T)
	comms = mergeTxtFiles(folderName="../orestar/comms/RecordsConvertedToTxt")
	
	commfname="../orestar/comms/RecordsConvertedToTxt/joinedTables.tsv"
	fixTextFiles(fnames=commfname)
	#now send it to the database
	fileToDb(tableName="comms", dbname="contributions", fname=commfname, delim="\t")
	
	
	importAllXLSFiles(indir="../orestar/fins/", 
										remEscapes=T,
										forceImport=T, 
										remQuotes=T)
	
	fins = mergeTxtFiles(folderName="../orestar/fins/RecordsConvertedToTxt")
	finfname="../orestar/fins/RecordsConvertedToTxt/joinedTables.tsv"
	
	tab = readFinData(fname=finfname)
	tab = fixTextFiles(tab=tab)
	cat("Fixing columns\n")
	tab = fixColumns(tab=tab)
	
	cat("Re-writing file\n")
	write.finance.txt(dat=tab, fname=finfname)
# 	fileToDb(tableName="fins", dbname="contributions", fname=finfname, delim="\t")
	safeWrite(tab=tab, tableName="fins", dbname="contributions")
}

fixColumns<-function(tab){
	cat("\nMaking all column names all lower case..\n")
	colnames(tab) = tolower(colnames(tab))
	#fix amount column
	cat("\nConverting 'amount' column to numeric...\n")
	tab$Amount = makeNumericColumn(colVals=tab$amount, tab=tab)
	cat("\nConverting 'aggregate_amount' column to numeric..\n")
	tab$Aggregate_Amount = makeNumericColumn(colVals=tab$aggregate_amount, tab=tab)
	tab = makeDateColumns(tab=tab)
	tab = makeBoolcolumns(tab=tab, boolcols=c("employ_ind","tran_stsfd_ind","self_employ_ind"))
	return(tab)
}

makeBoolcolumns<-function(tab, boolcols=c("employ_ind","tran_stsfd_ind","self_employ_ind")){
	map = c(T,F)
	names(map) = c("Y","N")
	for(bc in boolcols){
		if(class(tab[,bc])=="logical"){
			cat("\nColumn",bc,"is already boolean..\n")
		}else{
			cat("\nConverting column",bc,"to boolean..\n")
			tab[,bc] = map[tab[,bc]]
		}
	}
	return(tab)
}
makeDateColumns<-function(tab){
	datecols = colnames(tab)[grep(pattern="date", x=colnames(tab))]
	for(d in datecols){
		cat("\nconverting column",d,"to date data type..\n")
		tab[,d] = as.Date(x=tab[,d], format="%m/%d/%Y")
	}
	return(tab)
}

makeNumericColumn<-function(colVals, tab){
	
	uam2 = as.numeric(colVals)
	errorIndexes = which(is.na(uam2))
	#display error indexes
	if(length(errorIndexes)){
		cat(length(errorIndexes), "values could not easily be coorsed to numeric\n")
		View(tab[errorIndexes,])	
	}else{
		cat("\nColumns transformed to numeric data type..\n")
	}

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
	xres = xls2sep(xls=xlsName, 
								 sheet=1, 
								 verbose=F, 
								 method="tab")
	retval = read.delim(file=summary(xres)$description, 
										 stringsAsFactors=F,
										 header=T, 
										 sep="\t", 
										 comment.char="", 
										 allowEscapes=T)
	close(xres)
	return(retval)
}

importAllXLSFiles<-function(indir="~/prog/hack_oregon/orestar/fins", 
														destDir=NULL, 
														forceImport=F, 
														remQuotes=F, 
														remEscapes=T){
	
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
	
	files = files[grepl(pattern=".xls$", files)]
	convertedFileNames = gsub(pattern=".xls",replacement=".txt",x=files)
	convertedFiles = c()
	
	for(i in 1:length(files)){	
		
		srce = paste(indir, files[i], sep="/") 
		dest = paste(destDir, convertedFileNames[i], sep="/")
		cat("checking #",i,"of",length(files),"files:",files[i],"..")
		if(!file.exists(dest)|forceImport){
			curtab = try(expr=special.read.xls(xlsName=srce), silent=TRUE)
			
			if(is.null(nrow(curtab))){
				cat("..error while reading file\n")
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
				
				if(is.null(nrow(testread))|sum(dim(testread)!=dim(curtab))){
					cat("..error while reading file\n",srce,"\n")
					addToErrorLog(errorLogFname=paste0(errorDir,"/","errorLog.txt"),vals=c(paste("re read error:", testread), 
																																								 files[i]))
					#move files to error folder
					file.rename(from=dest, to=paste(errorDir, basename(path=dest), sep="/"))
					file.rename(from=srce, to=paste(errorDir, basename(path=srce), sep="/"))
				}else{
					convertedFiles = c(convertedFiles, dest)
					cat("successfull read..\n")
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


mergeTxtFiles<-function(folderName="../orestar/fins/RecordsConvertedToTxt"){
	
	filesWithBlankTranIds = c()
	
	allFiles = dir(folderName)
	txtFiles = allFiles[grepl(pattern=".txt$", x=allFiles, ignore.case=F, perl=T)]
	txtFiles = txtFiles[txtFiles!="problemSpreadsheetserrorLogTable.txt"]
	txtfilesfp = paste0(folderName,"/",txtFiles)
	
	totalLines = countLinesAllFiles(folderName=folderName)
	totalLines = totalLines-length(txtfilesfp)
	
	#make output data frame
	testRead = read.finance.txt(txtfilesfp[1])
	
	tabout = data.frame(matrix(data="", nrow=totalLines, ncol=ncol(testRead), dimnames=list(NULL, colnames(testRead))), stringsAsFactors=F)
	curline = 1
	for(i in 1:length(txtfilesfp)){
		#open the file
		tabin = read.finance.txt(txtfilesfp[i])
		if(sum(is.na(tabin$X.Tran.Id.))){
			filesWithBlankTranIds = c(filesWithBlankTranIds, txtfilesfp[i])
		}
		#add contents of file to tabout
		if(nrow(tabin)){
			cat(i, txtfilesfp[i],"rows:",nrow(tabin),"\n")
			if( ( nrow(tabin)==1 & (sum(is.na(tabin[1,]))==ncol(tabin)) ) ) {
				cat("\nBlank table:",txtfilesfp[i],"\n")
			}else{
				tabout[curline:(curline+nrow(tabin)-1),] = tabin
				curline = curline + nrow(tabin)
			}
		}else{
			cat("\nBlank table:",txtfilesfp[i],"\n")
		}
	}
	#now cut off the data frame so that no blank rows are included
	tabout = tabout[1:curline-1,]
	
	cat("Total dimensions of merged file:", dim(tabout)[1],"rows", dim(tabout)[2],"columns")
	
	write.table(x=tabout, sep="\t",col.names=T, row.names=F, qmethod="escape",quote=T,
							file=paste0(folderName, "/joinedTables.tsv"))
	
	return(tabout)
}

countLinesAllFiles<-function(folderName, sep="\t"){
	cat("Counting lines in files...")
	allFiles = dir(folderName)
	txtFiles = allFiles[grepl(pattern=".txt$", x=allFiles, ignore.case=F, perl=T)]
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
	tab[tab==""]  = NA
	return(tab)
	
}

fixHeaders<-function(tab){
	#strip leading ".X"
	colnames(tab)<-gsub(pattern="^X.", replacement="", x=colnames(tab))
	colnames(tab)<-gsub(pattern="[.]$", replacement="", x=colnames(tab))
	colnames(tab)<-gsub(pattern="[.]", replacement="_", x=colnames(tab))
	return(tab)
}

