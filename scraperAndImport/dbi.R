#dbi

dbiWrite<-function(tabla, 
									 name="test_table", 
									 appendToTable=F, 
									 dbname="interactome", 
									 port=5432, clean = T ){
	library("DBI")
	library("RPostgreSQL")
	
	if(name =="test_table")
  {
    print("warning, writing table data to test_table")
  }
  
  if(clean) colnames(tabla) = gsub(pattern="[.]", replacement="_", x=colnames(tabla))

  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname=dbname, password="points", port=port, user="postgres")
  tabla = as.data.frame(tabla)
  #write the table
  res = try(expr=dbWriteTable(conn=con, 
  														name=name, 
  														row.names = 0, 
  														value=tabla, 
  														overwrite=!appendToTable, 
  														append=appendToTable), silent=T)
  if(length(res)){
  	if(sum(grepl(pattern="error", x=class(res), ignore.case=T))){
  		dbDisconnect(con)
  		return(res)
  	}
  	print(dbExistsTable(con, name=name))
  	dbDisconnect(con)
  	return(res)
  }
	print(dbExistsTable(con, name=name))
	dbDisconnect(con)
}

# addForeignKey<-function(tableName, dbName, keyColumns=c()){
# 	
# }

test.dbiFastWrite<-function(){
	fname = "./orestar/fins/joinedTables.tsv"
	ftab = openFundingTable()
	
	which(is.na(ftab$Contributor.Payee.Committee.ID))
	
}

dbiFastWrite<-function(ftab, tabname="fins", dbname="contributions"){
	# first, write a table with no rows
	tmpTab = ftab[c(),]
	# make the table skeleton in postgres
	dbiWrite(tabla=tmpTab, name="fins", appendToTable=F, dbname=dbname)
	# save the table to a temp file
	tmpFname = paste0(getwd(), "/tmpDbTab.tsv")
	write.table(x=ftab, file=tmpFname, sep="\t", row.names=F, col.names=F, fileEncoding="UTF-8")
	# load the table via postgres
	sql1 = paste0("copy ",tabname," from \' ", tmpFname,"\'")
	dbCall(sql=sql1, dbname=dbname)
}

dbiRead<-function(query,dbname="metagenomics"){
	library("RPostgreSQL")
	drv <- dbDriver("PostgreSQL")
	con <- dbConnect(drv, 
									 dbname=dbname, 
									 password="points", 
									 port=5432, 
									 user="postgres")
	rs <- dbSendQuery(con,query)
	resset = fetch(rs,n=-1)
	dbDisconnect(con)
	return(resset)
} #database interface, returns table


dbCall<-function(sql, dbname="interactome", port="5432"){
	library("DBI")
	#library("RMySQL")
	#drv <- dbDriver("MySQL")
	#con <- dbConnect(drv, dbname="HNSCCdb", port=3306, user="root")
	library("RPostgreSQL")
	drv <- dbDriver("PostgreSQL")
	con <- dbConnect(drv, dbname=dbname, password="soyyo", port=port, user="postgres")
	dbSendQuery(conn=con, statement=sql)
	dbDisconnect(con)
}


test.FileToDb<-function(){
	
	fname="../orestar/fins/RecordsConvertedToTxt/joinedTables.tsv"
	
	tableName="fins"
	sep="\t"
	header=T
	quote="\""
	dbname = "contributions"
	port=5432
	app=F
	delim="\t"
	copyFromFile=F
	

	fileToDb(tableName=tableName, app=app, dbname=dbname, fname=fname, sep=sep, header=header, quote=quote, port=port, delim=delim)
	
}

fileToDb<-function(tableName, dbname,  fname, copyFromFile=F, app=F, port=5432, delim=","){
	
	# 	tab = read.table(file=fname, sep=",", header=T, quote="\"")
	#first open the file
	tab = read.finance.txt(fname=fname)#   file=fname, sep=sep, header=header, quote=quote, stringsAsFactors=F, )
	
	if(copyFromFile){
		#now make a shell out of it--ie, just the column names and types
		tshell = tab[c(),]
		dbiWrite(tabla=tshell, name=tableName, dbname=dbname, port=port, appendToTable=app)
		if(Sys.info()['sysname']=='Darwin'){
			tmpFile = tempfile(pattern="dbtmp", tmpdir="/Users/Shared", fileext="")
			file.copy(from=fname, to=tmpFile)
		}else{
			tmpFile = fname
		}
		#now copy from the file to the table
		query = paste("copy ", tableName, " from '", tmpFile, "' DELIMITER '", delim, "' NULL 'NA'", sep="")
		#COPY genes FROM '/Users/samhiggins2001_worldperks/tprog/main_131219/drugDB/drugbank/all_target_ids_all.csv' DELIMITER ',' CSV;
		dbCall(sql=query, dbname=dbname, port=port)
	}else{
		safeWrite(tab=tab, tableName=tableName, dbname=dbname, port=port)
	}

}

#safeWrite will write a table to a postgres database, while attempting to fix non-standard/latin characters.
safeWrite<-function(tab, tableName, dbname, port=5432, append=F){
	cat("\nWriting table",tableName,"to database",dbname,"...")
	exRows = c()
	goodRows = 1:nrow(tab)
	badRows = NULL
	res = try(expr=dbiWrite(tabla=tab, name=tableName, dbname=dbname, port=port, appendToTable=append), silent=T)
	if(!length(grep(pattern="error", x=class(res)))) return(NULL)
	
	badline=-1
	if(class(res)=="try-error"){
		while(T){
				cat("error:\n")
				cat(res)
				cat("\nAttempting to fix problem..\n")
				#handle error: try to extract the line and skip it
				res = as.character(res)
				if(grepl(pattern="line [0-9]+", x=res)){
					badlineTmp = findBadLineFromError(errmess=res)
					if(badlineTmp!=badline){
						badline=badlineTmp
						cat("attempting to remove latin characters...")
						tab[badline,] = removeLatin(bad=tab[badline,])
						res = try(expr=dbiWrite(tabla=tab[goodRows,], name=tableName, dbname=dbname, port=port, appendToTable=append), silent=T)
					} else {
						cat("could not remove latin characters.\nThis line will not be added to the data base:",
								tab[badline,],"\n")
						exRows=c(exRows, badline)
						goodRows = setdiff(goodRows, exRows)
						badRows = rbind.data.frame(badRows, tab[badline,])
					}
				}else if(grepl(pattern="TRUE", as.character(res))){
					cat("\nSuccess!!\n")
					break
				}else{
					cat("Could not resolve error:\n", 
							res,"\n")
					return(badRows)
				}
		}
	}else{
			cat("\nSuccess!!\n")
	}
	return(badRows)
}


findBadLineFromError<-function(errmess){
	errmess = as.character(errmess)
	sError = strsplit(x=errmess, split="\n")[[1]]
	index = grep(pattern="line", x=sError)
	pl1 = strsplit(x=sError[index], split="line ")[[1]][2]
	pl2 = as.numeric(gsub(pattern="[a-zA-Z(){}\n]",replacement="",x=pl1))
	return(pl2)
}

removeLatin<-function(bad){
	iconv(x=bad, from="latin1", to="UTF-8")
}

makeStacked<-function(dfin){
	
	ltmp = list()
	#first make a list out of it
	for(i in 1:nrow(dfin)){
		ltmp[[dfin[i,1]]] = strsplit(x=dfin[i,2], split="; ")[[1]]
	}
	tabd = list_to_table(pth=ltmp)
	
	#now, make the output data frame and fill it
	dfout = data.frame(matrix(ncol=2,nrow=sum(tabd), dimnames=list(1:sum(tabd), c("geneID","drugID"))))
	
	curi = 1
	for(i in 1:nrow(tabd)){
		if(sum(tabd[i,])){
			lindex = curi + sum(tabd[i,]) - 1
			if(lindex == curi){
				dfout[curi,1] = rownames(tabd)[i]
				dfout[curi,2] = colnames(tabd)[tabd[i,]]
			}else{
				dfout[curi:lindex,1] = rownames(tabd)[i]
				dfout[curi:lindex,2] = colnames(tabd)[tabd[i,]]
			}
			curi=lindex + 1
		}
	}
	return(dfout)
}

# fname="./drugDB/drugbank/all_target_ids_all.csv"
# tab = read.table(file=fname, sep=sep, header=header, quote=quote, stringsAsFactor=F)
# 
# 
# #findHGNC
# #processAllTargetIds
# #first, select only the human genes: 
# 
# htab = tab[tab$Species == "Homo sapiens",]
# hugo = STUDY@studyMetaData@paths$HUGOtable
# # > dim(tab)
# # [1] 4141   15
# # > dim(htab)
# # [1] 2106   15
# 
# #next, attempt-correction of gene Name column 
# tmpName = corsym(symbol_set=htab$Gene.Name,verbose=F, hugoref=hugo)
# htab$Gene.Name = tmpName
# ################################# check
# 
# notHugoIndex = which(!tmpName%in%hugo$Approved.Symbol)
# notHugo= htab[notHugoIndex,]
# 
# hextract = hugo[hugo$HGNC.ID%in%notHugo$HGNC.ID,]
# rownames(hextract)<-hextract$HGNC.ID
# 
# #now obtain the hugo symbols by their row names
# htab$Gene.Name[notHugoIndex] = hextract[notHugo$HGNC.ID,]$Approved.Symbol
# 
# sum(htab$Gene.Name=="")
# 
# htab$Gene.Name[is.na(htab$Gene.Name)] = ""
# 
# #gene names are now fixed
# 
# #extract the GSEA format lines now: 
# targetTable = htab[,c("Gene.Name", "Drug.IDs")]
# 
# 
# 
# 
# targetTable = makeStacked(dfin=targetTable)
# 
# dbiWrite(tabla=targetTable, name="targets", append=F, dbname="drugs")
# 
# drugFname = "./drugDB/drugbank/drug_links.csv"
# drugTab = read.table(drugFname, sep=",", header=T)
# 
# dbiWrite(tabla=drugTab, name="drug", append=F, dbname="drugs")
# #what am I doing?
# #just got the targeting table writen, 
# #now check that the gene and drug tables are being made
# 
# #now load the
# 
# #load data into pisces database
# #source('./dbi.R')
# 
# 
# # dbiWrite(tabla=results$somatic_mutation_aberration_summary$unfiltered_data,
# # 				 name="somatic_mutation_data", 
# # 				 dbname="pisces")
# 
# 
# 
# 
