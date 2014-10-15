#!/usr/bin/env bash
echo "---------------------------------"
echo "buildOutFromGitRepo.sh"
echo "---------------------------------"
echo "This script should be run by entering the command: "
echo "buildOutFromGitRepo.sh"
echo "from the backend git repo's directory."
echo "If the hack oregon back end is in a Vagrant machine, the git directory will be:"
echo " /vagrant "
echo "Current working directory:"
pwd

if [ -e ~/data_infrastructure ]
then
	echo "data_infrastructure folder already exists"
else
	echo "creating data_infrastructure folder"
	sudo mkdir ~/data_infrastructure
fi

echo "current working directory inside buildOutFromGitRepo:"
pwd

sudo chmod 755 hackOregonDbStatusLogger.R
sudo chmod 755 exportTableToTsv.R
sudo chmod 755 orestar_scrape/getMissingCommittees.R
sudo chmod 755 addDirectionCodes.sh
sudo chmod 755 buildEndpointTables.sh
sudo chmod 755 buildOutDBFromRawTables.sh
sudo chmod 755 buildScraper.sh
sudo chmod 755 workingTableCreation.sh
sudo chmod 755 makeWorkingCandidateFilings.R
sudo chmod 755 endpoints/makeGrassState.R
sudo chmod 755 postSchemaInstallationEndpoints.sh
sudo chmod 755 orestar_scrape/bulkLoadScrapedCommitteeData.R
sudo chmod 755 endpoints/candidateByState/buildCandidateByStateEndpoint.sh
sudo chmod 755 makeCCWorkingTransactions.sh
sudo chmod 755 ./orestar_scrape/bulkAddTransactions.R
sudo chmod 755 ./orestar_scrape/getMostRecentTransactions.R


#core raw database files
sudo cp -vu ./.Rprofile ~/.Rprofile
sudo cp -vu ./trimTransactionsTable.sql ~/data_infrastructure/trimTransactionsTable.sql
sudo cp -vu ./install.sql ~/data_infrastructure/install.sql
sudo cp -avru ./successfullyMerged ~/data_infrastructure/
sudo cp -vu ./addDocumentationTable.sql ~/data_infrastructure/

#control script
sudo cp -vu ./buildOutDBFromRawTables.sh ~/data_infrastructure/buildOutDBFromRawTables.sh
sudo chmod 755 getMissingCommittees.sh
sudo cp -vu getMissingCommittees.sh ~/getMissingCommittees.sh
sudo chmod 755 loadEndpoints.sh
sudo cp -vu loadEndpoints.sh ~/loadEndpoints.sh
sudo chmod 755 bulkAddTransactions.sh
sudo cp -vu bulkAddTransactions.sh ~/bulkAddTransactions.sh
sudo chmod 755 ./bulkLoadCommitteeData.sh
sudo cp -vu bulkLoadCommitteeData.sh ~/bulkLoadCommitteeData.sh
sudo chmod 755 loadCandidateFilings.sh
sudo cp -vu loadCandidateFilings.sh ~/loadCandidateFilings.sh
sudo cp -vu exportTableToTsv.R ~/exportTableToTsv.R
sudo chmod 544 dailycron.txt
sudo cp -vu dailycron.txt ~/dailycron.txt
sudo cp -vu hackOregonDbStatusLogger.R ~/hackOregonDbStatusLogger.R
sudo chmod 755 ./setPermissionsForCronTab.sh
sudo cp -vu setPermissionsForCronTab.sh ~/setPermissionsForCronTab.sh


#scraper infrastructure
sudo cp -avru ./endpoints ~/data_infrastructure/ 
sudo cp -avru ./orestar_scrape ~/data_infrastructure/
sudo chmod 755 orestar_scrape/bulkAddTransactions.R


#working tables
sudo cp -vu ./addDirectionCodes.sh ~/data_infrastructure/addDirectionCodes.sh
sudo cp -vu ./moneyDirectionCodes.txt ~/data_infrastructure/moneyDirectionCodes.txt 
sudo cp -vu ./workingTableCreation.sh ~/data_infrastructure/workingTableCreation.sh
sudo cp -vu ./workingTransactionsTableCreation.sql ~/data_infrastructure/workingTransactionsTableCreation.sql
sudo cp -vu ./makeWorkingCandidateFilings.R ~/data_infrastructure/makeWorkingCandidateFilings.R
sudo cp -vu ./buildEndpointTables.sh ~/data_infrastructure/buildEndpointTables.sh
sudo cp -vu ./makeCCWorkingTransactions.sh ~/data_infrastructure/makeCCWorkingTransactions.sh

#endpoints
sudo cp -vu ./postSchemaInstallationEndpoints.sh ~/data_infrastructure/postSchemaInstallationEndpoints.sh
sudo cp -vu ./workingCommitteesFromInitialRaw.sql ~/data_infrastructure/workingCommitteesFromInitialRaw.sql

cd
sudo ./setPermissionsForCronTab.sh