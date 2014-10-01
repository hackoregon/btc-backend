#!/usr/bin/env bash

echo "Bulk import raw committee data."
echo "This script will attempt to copy all committee data from directory"
echo "~/raw_committee_data/"
echo "to"
echo "~/data_infrastructure/orestar_scrape/raw_committee_data"
echo "then run bulkLoadScrapedCommitteeData.R"
echo "to import all the committee data into the database."

cp ~/raw_committee_data/* ~/data_infrastructure/orestar_scrape/raw_committee_data/

cd ~/data_infrastructure/

sudo ./orestar_scrape/bulkLoadScrapedCommitteeData.R