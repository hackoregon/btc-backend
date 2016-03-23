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
