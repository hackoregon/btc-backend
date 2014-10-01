#!/usr/bin/env bash

echo "Attempting to get missing committee records"
echo "Setting the working directory to ~/data_infrastructure/orestar_scrape"
cd ~/data_infrastructure/orestar_scrape

sudo getMissingCommittees.R