#productionCandidateCommitteeDataWithGrassroots.R

getCCtrasactions<-function(tranTabName, numCommittees=10, dbname="hackoregon"){
	q1 = paste0("select * 
			from ",tranTabName," 
			where filer_id in 
				(select filer_id
					from ",tranTabName," 
					join working_committees
					on filer_id = committee_id
					and committee_type = 'CC'
					and direction = 'in'
					group by filer_id
					order by sum(amount) desc
					limit ",numCommittees,")
			and direction ='in'")
	
	dbres = dbiRead(query=q1, dbname=dbname)
	return(dbres)
}

getCurrentCycleCCtrasactions<-function(numCommittees=10, dbname="hackoregon"){
	
	q1 = paste0("select * 
			from cc_working_transactions 
			where filer_id in 
				(select filer_id
					from cc_working_transactions 
					join working_committees
					on filer_id = committee_id
					and committee_type = 'CC'
					and direction = 'in'
					group by filer_id
					order by sum(amount) desc
					limit ",numCommittees,")
			and direction ='in'")
	dbres = dbiRead(query=q1, dbname=dbname)
	return(dbres)
}

getAllCycleCCtrasactions<-function( numCommittees=10, dbname="hackoregon"){
	
	q1 = paste0("select * 
			from working_transactions 
			where filer_id in 
				(select filer_id
					from working_transactions 
					join working_committees
					on filer_id = committee_id
					and committee_type = 'CC'
					and direction = 'in'
					group by filer_id
					order by sum(amount) desc
					limit ",numCommittees,")
			and direction ='in'")
	dbres = dbiRead(query=q1, dbname=dbname)
	return(dbres)
}

#'@title Display distributions of contribution amounts. 
#'@description Makes two histograms of contribution amounts, one normal scale, and one log scale. Outputs to screen or file.
#'@param ctran The data frame returned by getCurrentCycleCCtrasactions. Essentially just a subset of the transactions table.
#'@param fname Optional; if provided, the plot will be output to a file. If omitted, the program will attempt to output the plot to the screen.
displayDistContAmount<-function(ctran, fname=NULL){
	require(ggplot2)
	require(gridExtra)
	
	p1 = ggplot(data=ctran, aes(x=amount))+
		geom_histogram(binwidth=50)+
		xlab(label="Amount contributed ($)")+
		ylab("Number of contributions")+
		ggtitle("Distribution of individual contribution amounts")
	
	p2 = ggplot(data=ctran, aes(x=amount))+
		geom_histogram()+
		xlab(label="Amount contributed ($, log scale)")+
		ylab("Number of contributions")+
		ggtitle("Distribution of individual contribution amounts\nlog scale")+
		scale_x_log10(breaks=(10^(0:10)))+
		annotation_logticks(sides="b")
	
	if(is.null(fname)){
		grid.arrange(p1,p2, nrow=2)
	}else{
		ggsave(filename=fname, plot=arrangeGrob(p1,p2))
	}

}

addGrassRootCutCol<-function(ctran){
	
	grassRoots = rep("no", time=nrow(ctran))
	grassRoots[ctran$amount<=200] = "yes"
	out  = cbind.data.frame(ctran,grassRoots)
	return(out)
	
}

getGrassState<-function(ctran){
	
	ctran = addGrassRootCutCol(ctran=ctran)
	# cand = unique(ctran$filer_id)[1]
	candidates = unique(ctran$filer_id)
	percent_grassroots = c()#rep(0,times=length(candidates))
	percent_instate = c()
	total_money = c()
	for(cand in candidates){
		cur = ctran[ctran$filer_id==cand,]
		#get percent grassroots
		cp = sum(cur$amount[cur$grassRoots=="yes"])/sum(cur$amount)
		percent_grassroots = c(percent_grassroots, cp)
		#get percent from instate
		pst = sum(cur$amount[ cur$state=="OR" ], na.rm=T)/sum(cur$amount)
		percent_instate = c(percent_instate,pst)
		total_money = c(total_money, sum(cur$amount))
	}
	
	out = cbind.data.frame(candidates, total_money, percent_grassroots, percent_instate)
	return(out)
}


exeGetCommitteeStatsIncGrass<-function(cycle="current",numCommittees=10000, dbname="hackoregon"){
	
	if(cycle=="current"){
		ttn = "cc_working_transactions"
	}else if(cycle=="all"){
		ttn = "working_transactions"
	}else{
		stop("Campaign cycle not understood (in exeGetCommitteeStatsIncGrass() function.) ")
	}
	
	comms = getUniqueCommittees(tranTabName=ttn,dbname=dbname)
	
	ctran = getCCtrasactions(tranTabName=ttn, numCommittees=numCommittees, dbname=dbname)
	
	grassSum = getGrassState(ctran=ctran)
	
	print("colnames grassSum:")
	print(colnames(grassSum))
	print("colnames comms:")
	print(colnames(comms))
	grassSum = merge(x=comms, y=grassSum, by.x="filer_id", by.y="candidates", all.x=TRUE )
	
	grassSum = addTotalSpent(tin=grassSum, tranTabName=ttn, dbname)
	
	candIds = unique(ctran[,c("filer","filer_id")])
	
	candIds = candIds[!duplicated(candIds$filer_id),]
	colnames(grassSum)[colnames(grassSum)=="filer_id"]<-"candidates"
	
	grassSum = merge(x=candIds, y=grassSum, by.x="filer_id", by.y="candidates")
	
	grassSum = replaceNA(tin=grassSum, replacementValue=0)
	
	return(grassSum)
	
}

replaceNA<-function(tin, replacementValue=0){
	for(ci in 1:ncol(tin)) tin[is.na(tin[,ci]),ci] = replacementValue
	return(tin)
}

getUniqueCommittees<-function(tranTabName,dbname){
	
	q1  = paste("select distinct filer_id, sub1.candidate_name
							from ",tranTabName,"
							join (select committee_id, candidate_name
								from working_committees 
								where committee_type='CC') sub1
							on sub1.committee_id=filer_id;")
	dbres = dbiRead(query=q1, dbname=dbname)
	return(dbres)
	
}

addTotalSpent<-function(tin,tranTabName,dbname){
	
	 q1 = paste("select filer_id, sum(amount) as total_money_out 
	 					 from", tranTabName,
	 					 "where filer_id in", paste("(",paste(tin$filer_id, collapse=", "), ")"), 
	 					 "and direction='out'
	 					 group by filer_id")
	dbr=dbiRead(query=q1, dbname=dbname)
	out = merge(x=tin, y=dbr, by.x="filer_id", by.y="filer_id", all.x=TRUE)
	return(out)
}

# displayDistContAmount(ctran=ctran,fname="./distributionOfContributionAmounts.png")
# 
# write.table(file="./staticDump2GrassState.txt", x=grassSum, row.names=F, col.names=T, sep="\t")
# 
# q2 = "select * from comms where \"Committee_Type\"='CC'"
# committees = dbiRead(query=q2, dbname="contributions")
# colnames(committees)
# excom = committees[committees$Committee_Id%in%grassSum$candidates,c("Committee_Id","Committee_Name","Candidate_Office","Candidate_Office_Group")]
# distinctOffice = unique(excom[,c("Candidate_Office","Candidate_Office_Group")])
# 
# subtypeag = aggregate(x=ctran$amount, by=list(ctran$sub_type), FUN=sum)
# 
# ggplot(data=ctran, aes(x=sub_type, y=amount)) +
# 	geom_bar(stat="identity") +
# 	coord_flip()






