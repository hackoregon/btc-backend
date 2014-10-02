bulkAddTransactions.sh 
----------------------------
Adds a block of transactions in .tsv format.

getMissingCommittees.sh 
----------------------------

Checks the db for missing committees and attempts to scrape them.

loadEndpoints.sh
----------------------------
(Re)Loads all endpoints and and builds endpoint tables (skips table rebuild if the argument nt is passed).

bulkLoadCommitteeData.sh
----------------------------
Loads block of committee data from scrapings.

doover.sh
----------------------------
Erases business part of backend: hackoregon db and the data infrastructure.
install3.sh and install4.sh must be run from the git repo's folder to correctly rebuild everything after doover.sh is run.

loadCandidateFilings.sh
----------------------------
Loads a .xls table of candidate filings. 
