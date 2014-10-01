#!/usr/bin/env bash

echo "Running loadCandidateFilings.sh"
echo "This script takes 1 argument:"
echo "the absolute path to the candidate filings .xls document to be loaded"
echo "Paths given relative to the home directory (ex ~/example.xls ) are acceptable."

#assure candidate filings in ~ directory is copied to orestar_scrape folder
#and that loaded candidate filings are copied from orestar_scrape to 
#orestar_scrape/loaded_filings/ folder

sudo ./data_infrastructure/makeWorkingCandidateFilings.R $1
