#!/usr/bin/env bash
#scripts to create the working tables and run the data workup
echo "----------------------------------------------"
echo "Running buildOutDBFromRawTables.sh"
echo "This script adds the documentation table"
echo "rebuilds the working tables and the endpoint tables"
echo "then reloads the actual endpoint handling functions."
echo "----------------------------------------------"

sudo -u postgres psql hackoregon <  ~/data_infrastructure/addDocumentationTable.sql

sudo ~/data_infrastructure/workingTableCreation.sh


sudo ~/data_infrastructure/buildEndpointTables.sh

sudo -u postgres psql hackoregon <  ~/data_infrastructure/install.sql

sudo ~/data_infrastructure/postSchemaInstallationEndpoints.sh




