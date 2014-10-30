
allTextFilesToDb<-function( folderName, dbname, tableName="raw_committee_transactions" ){
	
	folderName = gsub("/$","",folderName)
	filesWithBlankTranIds = c()
	allFiles = dir(folderName)
	successfullyImported = c()
	
	txtFiles = allFiles[grepl(pattern=".txt$|.tsv$", x=allFiles, ignore.case=F, perl=T)]
	txtFiles = txtFiles[txtFiles!="problemSpreadsheetserrorLogTable.txt"]
	txtfilesfp = paste0(folderName,"/",txtFiles)
	
	totalLines = countLinesAllFiles(folderName=folderName)
	totalLines = totalLines-length(txtfilesfp)
	cat("Expected total lines in all files:",totalLines,"\n")
	
	for(i in 1:length(txtfilesfp)){
		
		#open the file
		tabin = read.finance.txt( txtfilesfp[i] )
		colnames(tabin)<-fixColumnNames(colnames(tabin))
		if( sum(is.na(tabin[,1,drop=T])) ){
			filesWithBlankTranIds = c(filesWithBlankTranIds, txtfilesfp[i])
		}
		#add contents of file to tabin
		if( nrow(tabin) ){#make sure the file is not empty
			
			cat(i, txtfilesfp[i],"rows:",nrow(tabin),"\n")
			
			if( ( nrow(tabin)==1 & (sum(is.na(tabin[1,]))==ncol(tabin)) ) ) {#make sure the file is not just a header
				cat("\nBlank table:", txtfilesfp[i], "\n\n")
			}else{
				#check for blank rows
				remrows = is.na(tabin[,1])|is.null(tabin[,1])
				if( sum(remrows) ) tabin = tabin[!remrows,]
				#send to database.
				tabin = fixTextFiles(tab=tabin)
				tabin = unique(tabin)
				cat("Re-writing repaired file\n")
				write.finance.txt(dat=tabin, fname=txtfilesfp[i])
				importTransactionsTableToDb(tab=tabin, tableName=tableName, dbname=dbname)
				cat("Dimensions of table after blank row check, immediatly prior to entry into database:\n", dim(tabin)[1],"rows", dim(tabin)[2],"columns\n")
				
				successfullyImported = c(successfullyImported, txtfilesfp[i])
			}
		}else{
			cat("\nBlank table:",txtfilesfp[i],"\n")
		}
		
	}

}