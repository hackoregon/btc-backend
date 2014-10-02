#!/usr/bin/Rscript

dbname="hackoregon"
#date counts to csv
source("./dbi.R")
q1 = "select tran_date, count(*) from raw_committee_transactions group by tran_date
			order by tran_date"
res1 = dbiRead(query=q1, dbname=dbname)


q2 =  "select tran_date, count(*) 
				from raw_committee_transactions 
				where filer_id = 13920
				or filer_id = 4155
				group by tran_date
				order by tran_date"


res2 = dbiRead(query=q2, dbname=dbname)


write.table(res1, file="./transactionsPerDateAllComs.txt", quote=F, sep="\t", row.names=F, col.names=T)
write.table(res1, file="./transactionsPerDateKitzDennis.txt", quote=F, sep="\t", row.names=F, col.names=T)