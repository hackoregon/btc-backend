#!/usr/bin/env bash
echo "running postSchemaInstallationEndpoints.sh"

sudo -u postgres psql hackoregon < ~/data_infrastructure/endpoints/fuzzyMatch/installFuzzyStringMatchEndpoint.sql