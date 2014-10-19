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

echo "adding sub_type_from_contributor_payee table, used to determine lumped grassroots donors."
sudo ./endpoints/add_sub_type_from_contributor_payee.sh

echo "making db call to add the working_transactions table"
echo "with script ./workingTransactionsTableCreation.sql"
echo "altering working_transactions table, adding contributor_payee_class column"
sudo -u postgres psql hackoregon < ./workingTransactionsTableCreation.sql
#pwd


echo "calling makeWorkingCandidateFilings.R"
sudo ./makeWorkingCandidateFilings.R

echo "calling workingCommitteesFromInitialRaw.sql"
sudo -u postgres psql hackoregon < ./workingCommitteesFromInitialRaw.sql

echo "calling ./orestar_scrape/bulkLoadScrapedCommitteeData.R"
echo "This script calls bulkLoadScrapedCommitteeData() from the R script"
echo "scrapeAffiliation.R"
echo "That function cleans and loads all the raw committe scrapes into raw_committees_scraped"
echo "then calls updateWorkingCommitteesTableWithScraped(), which"
echo "1) removes from working_committees any committees with ids found in the scraped committees"
echo "2) adds to the working_committees from the raw_committees_scraped table."
sudo ./orestar_scrape/bulkLoadScrapedCommitteeData.R

echo "creating cc_working_transactions"
echo "this operation is kept modular because it will be updated to add"
echo "different campaign cycles for each committee and not give all of them"
echo "the same cycle (currently 2010-11-11 to present)"
sudo ./makeCCWorkingTransactions.sh '2010-11-11'

