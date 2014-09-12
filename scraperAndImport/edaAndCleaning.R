
if(!require("grDevices")){
	install.packages("grDevices")
	library("grDevices")
}

test.fixVals<-function(){
	
	col="years"
	bad="0006"
	correct="2006"
	
}

fixVals<-function(bad, correct, col, tab){
	maptabFname = "./typoMappingTable.txt"
	maptab = NULL
	
	newrow = c(col, bad, correct)
	
	if(file.exists(maptabFname)){
		maptab = read.table(file=maptabFname, header=T, sep="\t", stringsAsFactors=F, comment.char="")
		maptab = rbind.data.frame(maptab, newrow)
		maptab = unique(maptab)
	}else{
		maptab = data.frame(matrix(data = newrow, nrow=1, ncol=3, dimnames=list(NULL, c("columnName", "typo", "correction"))))
	}
	write.table(x=maptab, file=maptabFname, append=F, row.names=F, col.names=T, sep="\t")
	bi = col==bad
	print(tab[bi,])
	
	if(correct==""){
		uin = readline("Please enter the correction:")
		
		col[bi]=uin
		cat("\nFixed", sum(bi), "values.\n")
	}else{
		
		uin = readline("Press enter to accept change; enter n to refuse the change")
		
		if(uin==""){
			
			col[bi]=correct
			cat("\nFixed", sum(bi), "values.\n")
		}
		
	}
	
	return(col)
	
}

cleanData<-function(fin){
	fin = fin[!is.na(fin$Amount),]
	
	years = fixVals(bad="0007", correct="2007", col=years, tab=fin)
	years = fixVals(bad="0008",correct="2008",col=years,tab=fin)
	years= fixVals("0009","2009",years,tab=fin)
	years= fixVals("0029","2009",years,tab=fin)
	years= fixVals("0108","2008",years, tab=fin)
	years = fixVals("0029","2009",years, tab=fin)
	table(years)
	years = fixVals("0200","",years, tab=fin)
	table(years)
	years = fixVals("0207","2007",years, tab=fin)
	table(years)
	years = fixVals("","",years, tab=fin)
	table(years)
	
	daymonth = gsub(pattern="[/][0-9]+$",replacement="",x=fin$Tran.Date)
	fulldate = paste(daymonth, years, sep="/")
	fin$Tran.Date = fulldate
	
	
	write.table(x=fin, sep="\t",col.names=T, row.names=F, 
							file=paste0(folderName, "/joinedTables.tsv"))
	
}


#'@title breakByCont
#'@description Makes matrix describing total political contributions by year from contributions in the ranges provided by the breaks arg.
#'@param breaks: the break points of the contribution bins (provided in descending order)
#'@param fin: the table of political contributions (must have columns "Tran.Date" and "Amount" containing the contribution date and dollar amount, respectively)
#'@return matrix: rows = ranges of contribution amount (demarked as the upper bound of contribution amount); columns=the years
breakByCont<-function(fin, breaks=c(50000,10000, 5000, 1000, 500, 100)){
	
	fin = fin[!is.na(fin$Amount),]
	
	years = gsub(pattern="^[0-9]+[/][0-9]+[/]", replacement="", x=fin$Tran.Date)
	breaks = c(breaks, 0)
	uyears = unique(years)
	outmat = matrix(data=0, nrow=length(breaks), ncol=length(uyears), dimnames=list(breaks, uyears))
	marginals = rep()
	for(y in uyears){#for each year
		cyear = fin[years==y,]
		
		for(i in 1:length(breaks)){
			curi = cyear$Amount>breaks[i]
			print(sum(curi))
			
			overmin = cyear[curi,]
			total = sum(overmin$Amount)
			outmat[as.character(breaks[i]),y] = total
			cyear = cyear[!curi,]
		}
	}
	
	return(outmat)
	
}

makeDonationSizeBarPlot <- function (fins) {
  fin=fins
  outmat = breakByCont(fin=fin)
  # > outmat
  # 2013     2012     2011     2010      2009     2008       2007       2006   2001 1998     2004     2005  2002
  # 10000 7737241.8 48019407 10060205 54641095 8377918.9 68293791 10516806.2 2050769.06    0.0    0 69480.82 18588.00     0
  # 1000  8488698.4 47623363 12713263 40577263 9787408.9 36890155  8209368.2 1737209.74    0.0    0  7500.00 10587.10 16500
  # 100   6153385.8 21135550  9019292 20825367 7138285.7 19563522  5788032.3  913619.30 1064.5    0   873.02  5293.00     0
  # 0      965955.5  2100138  1335687  1833081  899221.3  1532017   721525.4   79955.72    7.0   25   112.00  1332.08     0
  barplot(outmat, main="contributions", 
  				ylab="Dollar amount",
  				xlab="year", col=rainbow(7),
  				legend = paste(rownames(outmat), "and above"))
}


#getFromToAmountTable
getFromToAmountTable<-function(ftab, fromColName="Contributor.Payee.Committee.ID", toColName="Filer.Id", amountColName="Amount"){
	
	outTab = ftab[,c(fromColName, toColName, amountColName)]
	
	colnames(outTab)<-c("from", "to", "amount")
	return(outTab)
}

#getMiddleMen
#takes ftab: the fins table; campaing finance contributions; must have columns: Contributor.Payee.Committee.ID, Filer.Id and Amount 
#returns: a vector of ids for all entities that both give and recieve donations
getMiddleMen<-function(ftab){
	
	tfbyID = getFromToAmountTable(ftab) 
	
	blanki = tfbyID$from=="" | is.na(tfbyID$from)
	
	withFromIds = tfbyID[!blanki,]
	wfrom = ftab[!blanki,]
	
	gs = withFromIds[,c(1,2)]
	
	#how many givers are also recievers?
	
	givers = unique(gs$from)
	
	recievers = unique(gs$to)
	
	gands = intersect(givers, recievers)

	return(gands)
}

#isBlank
#takes: col: vector of values to be checked for ("" or NA)
#				retlv: T/F flag indictaing if a logical vector of blank indexes should be returned
#returns the number of blank  ("" or NA) values or logical index of NA values
isBlank<-function(col, retlv=F){
	li = (is.na(col))|(col=="")
	if(retlv) return(li)
	return(sum(li, na.rm=T))
}

#get simple interaction format going

tfbyID = getFromToAmountTable(ftab) 

blanki = tfbyID$from=="" | is.na(tfbyID$from)

withFromIds = tfbyID[!blanki,]
wfrom = ftab[!blanki,]

gs = withFromIds[,c(1,2)]

#how many givers are also recievers?

givers = unique(gs$from)

recievers = unique(gs$to)

gands = intersect(givers, recievers)

length(gands)
# > length(gands)
# [1] 693 givers are also recievers

#find the rows where they are givers

grows = ftab[ftab$Contributor.Payee.Committee.ID%in%gands,] 
#find the rows where they are recievers
rrows = ftab[ftab$Filer.ID%in%gands,] 

#check an individual value, 73
#filer 73 is "Regence Oregon Political Action Committee"
#look at the records of 73 recieving
dim(ftab[ftab[,11]==73,])
head(ftab[ftab[,11]==73,])
#look at the records of them giving
dim(ftab[ftab[,10]==73,])
head(ftab[ftab$Contributor.Payee.Committee.ID=="73",])

73%in%wfrom$Contributor.Payee.Committee.ID
head(wfrom[wfrom$Contributor.Payee.Committee.ID==73,])














