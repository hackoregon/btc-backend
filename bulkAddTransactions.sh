#!/usr/bin/env bash
echo "Loading committee transactions in bulk..."

echo "This script takes two arguments:"
echo "First argument:"
echo "The absolute path to the file containing the transactions to be added."
echo "Second argument (optional):"
echo "If the string 'skipRebuild' is included the script will not attempt to"
echo "rebuild the working tables and endpoint tables."

cd ~/data_infrastructure/orestar_scrape/
sudo ./bulkAddTransactions.R $1 $2