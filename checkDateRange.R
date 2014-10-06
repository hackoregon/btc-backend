library("ggplot2")

kitzRich = c(13920,4155)

jt = read.table(file="joinedTablesInc2012_8_12.tsv", 
								header=T, sep="\t", stringsAsFactors=F)

jt$tran_date<-as.Date(jt$tran_date, format="%m/%d/%Y")

range(jt$tran_date)

tpd = read.table(file="transactionsPerDateKitzDennis.txt", header=T)


tpd$tran_date = as.Date(tpd$tran_date, format="%Y-%m-%d")

ggplot(data=tpd, aes(y=count, x=tran_date))+geom_point()


joinedTab2DateGraph<-function(fileName="./orestar_scrape/transConvertedToTsv/joinedTables.tsv"){
	
	kitzRich = c(13920,4155)
	if(grepl(pattern=".csv$", x=fileName)){
		jt2 = read.csv(file=fileName, stringsAsFactors=F, strip.white=T)
	}else{
		jt2 = read.table(file=fileName, 
										 header=T, sep="\t", stringsAsFactors=F)
	}
	cat("\nRead in",nrow(jt2),"rows of finance data.\n")
	
	jt2 = jt2[jt2$filer_id%in%kitzRich,]
	cat("\nFound",nrow(jt2), "rows with contributions for Kitzhaber or Richardson.\n")
	
	da2 = aggregate(x=jt2$amount, by=list(jt2$tran_date), FUN=length)
	
	head(da2)
	colnames(da2)<-c("tran_date","count")
	
	tran_date = as.Date(da2$tran_date, format="%m/%d/%Y")
	if(is.na(tran_date[1])) tran_date = as.Date(da2$tran_date, format="%Y-%m-%d")
	da2$tran_date = tran_date
	ggplot(data=da2, aes(y=count, x=tran_date))+geom_point()+ggtitle(fileName)
	# 	ggplot(data=da2[da2$tran_date>as.Date(x="2014-3-1", format="%Y-%m-%d"),], aes(y=count, x=tran_date))+geom_point()
	
}

AllNeededTables = c("joinedTablesInc2012_8_12.tsv",
										"joinedOnMicroMiaInScrapeFolder.tsv",
										"joinedTables_with_2014throughSep.tsv")

joinedTab2DateGraph(fileName="joinedTablesInc2012_8_12.tsv")

joinedTab2DateGraph(fileName="joinedTables_from2011.tsv")

joinedTab2DateGraph(fileName="./orestar_scrape/transConvertedToTsv/joinedTables.tsv")

joinedTab2DateGraph(fileName="./joinedOnActual.tsv")
joinedTab2DateGraph(fileName="./joinedOnMicroMia.tsv")
joinedTab2DateGraph(fileName="./joinedOnMicroMiaInScrapeFolder.tsv")

joinedTab2DateGraph(fileName="joinedTables_with_2014throughSep.tsv")

joinedTab2DateGraph(fileName="joinedTablesFullCamp.tsv")
joinedTab2DateGraph(fileName="./raw_committee_transactions.csv")


