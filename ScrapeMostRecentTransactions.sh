#!/usr/bin/env bash
echo "------------------------------------------------------------------"
echo "running ScrapeMostRecentTransactions.R"
echo "------------------------------------------------------------------"
echo "This should add to the database transactions added to Orestar"
echo "between the tran_time of the lattest transaction currently in the"
echo "backend's database and the current date."
echo "------------------------------------------------------------------"
sudo ~/data_infrastructure/orestar_scrape/getMostRecentTransactions.R
echo "getMostRecentTransactions.R complete"