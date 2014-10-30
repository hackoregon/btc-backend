

#first get data for committees not part of the original scrape
dbname="hackoregon"
# dbname="hack_oregon"
cid = dbiRead(query="select committee_id from raw_committees;", dbname=dbname)
originalIds = cid[,1]
#get the most important ids first, the ones with the most activity and which were not part of the original set:
activeCommittees = dbiRead(query="select filer_id, count(*) 
													 				from cc_working_transactions
													 				group by filer_id
													 				order by count(*) desc", dbname=dbname)

activeAndNeededMost = setdiff(activeCommittees$filer_id, originalIds)
activeAndNeededMost  = setdiff(activeAndNeededMost, c(39, 275, getScrapedIds() ))

#getting the committees active in the current cycle, 
#not found in the originial scraping,
#and not found in the committees already scraped

dateRangeIdControler(neededIds=activeAndNeededMost, 
										 workingComTabName="working_committees",
										 dbname=dbname,
										 startDate='1/1/2010',
										 endDate='10/30/2014',
										 tranTableName="raw_committee_transactions")

#next fill in the ones which were part of the original scrape
#and are active in the current cycle

activeAndNeeded = intersect(activeCommittees$filer_id, originalIds )
activeAndNeeded = setdiff( activeAndNeeded, c(39, 275, getScrapedIds() ) )
dateRangeIdControler(neededIds=activeAndNeeded, 
										 workingComTabName="working_committees",
										 dbname=dbname,
										 startDate='3/1/2014',
										 endDate='10/31/2014',
										 tranTableName="raw_committee_transactions")

#finally, the inactive committees
seemInactive = setdiff( originalIds, activeCommittees$filer_id )

dateRangeIdControler(neededIds=seemInactive, 
										 workingComTabName="working_committees",
										 dbname=dbname,
										 startDate='3/1/2014',
										 endDate=Sys.Date(),
										 tranTableName="raw_committee_transactions")


