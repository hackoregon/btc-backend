#!/usr/bin/env bash
echo "running postSchemaInstallationEndpoints.sh"

sudo -u postgres psql hackoregon < ~/data_infrastructure/endpoints/fuzzyMatch/installFuzzyStringMatchEndpoint.sql

#time slider endpoints
echo "Running ./endpoints/sliderEndPoint/sliderEndPointTableCreation.sql"
echo "The script that produces data for the time slider"
sudo -u postgres psql hackoregon < ./endpoints/sliderEndPoint/sliderEndPointTableCreation.sql


#get transactions endpoint

echo "Adding get transactions endpoint"
sudo -u postgres psql hackoregon < ./endpoints/getTransactions/get_current_candidate_transactions.sql

echo "Building all Oregon aggregate summary tables and endpoints"
sudo -u postgres psql hackoregon < ./endpoints/all_oregon_summary/all_oregon.sql

#get donors endpoint
#transactionsByContributorPayee
echo "Running ./endpoints/getDonors/get_transactions_by_contributor_payee.sql"
echo "Script allows accumulating donation data for donors"
sudo -u postgres psql hackoregon < ./endpoints/getDonors/get_transactions_by_contributor_payee.sql

#get donors with transactions count endpoint
echo "Running ./endpoints/getTransactionCount/get_oregon_transaction_count.sql"
echo "Script allows us to see the count of total transactions by donors in descending order"
sudo -u postgres psql hackoregon < ./endpoints/getTransactionCount/get_oregon_transaction_count.sql

#endpoints for all transactions by date, current candidate's week, latest with limit
echo "Running ./endpoints/getNewTransactions/get_new_transactions.sql"
echo "Allows us to see all transactions on a certain date, a candidate's week's transactions, and certain number of transactions on lates filed date"
sudo -u postgres psql hackoregon < ./endpoints/getNewTransactions/get_new_transactions.sql
