#!/usr/bin/env bash
echo "---------------------------------"
echo "Running workingTableCreation.sh"
echo "---------------------------------"
echo "Working directory:"
pwd
#this file must be found in and run from ~/data_infrastructure/
cd ~/data_infrastructure
echo "calling addDirectionCodes.sh"
sudo ./addDirectionCodes.sh 
echo "making db call to add the working_transactions table"
echo "with script ./workingTransactionsTableCreation.sql"
sudo -u postgres psql hackoregon < ./workingTransactionsTableCreation.sql
echo "calling makeWorkingCandidateFilings.R"
sudo ./makeWorkingCandidateFilings.R
echo "calling workingCommitteesFromInitialRaw.sql"
sudo -u postgres psql hackoregon < ./workingCommitteesFromInitialRaw.sql
echo "calling ./orestar_scrape/bulkLoadScrapedCommitteeData.R"
sudo ./orestar_scrape/bulkLoadScrapedCommitteeData.R
echo "creating cc_working_transactions"
sudo ./makeCCWorkingTransactions.sh '2010-11-11'