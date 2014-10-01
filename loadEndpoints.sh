#!/usr/bin/env bash

echo "Installing new endpoints.."
echo "This script will:"
echo "-Rebuild the endpoint tables"
echo "-Enter the endpoints in install.sql"
echo "-Run the post schema installation endpoints found in postSchemaInstallationEndpoints.sh"
echo "If the argument 'nt' is passed, endpoint tables will not be rebuilt"
cd ~/data_infrastructure/

if [ $1 == "nt" ]
then
	echo "Skipping table rebuild.."
else
	sudo ~/data_infrastructure/buildEndpointTables.sh
fi

sudo -u postgres psql hackoregon <  ./install.sql

sudo ~/data_infrastructure/postSchemaInstallationEndpoints.sh

echo "Endpoints (re) loaded."
echo "To skip table rebuild, run this script with this argument: nt"