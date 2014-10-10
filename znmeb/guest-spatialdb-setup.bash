#! /bin/bash
#
# Copyright (C) 2013 by M. Edward (Ed) Borasky
#
# This program is licensed to you under the terms of version 3 of the
# GNU Affero General Public License. This program is distributed WITHOUT
# ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING THOSE OF NON-INFRINGEMENT,
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. Please refer to the
# AGPL (http://www.gnu.org/licenses/agpl-3.0.txt) for more details.
#

# install the core extensions
sudo su - postgres -c \
  "psql -c 'CREATE EXTENSION IF NOT EXISTS adminpack;'"
sudo su - postgres -c \
  "psql -c 'CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;'"

# create a non-root user - can can log in and create schemas/tables only!
sudo su - postgres -c "dropdb ${USER}"
sudo su - postgres -c "dropdb or_geocoder"
sudo su - postgres -c "dropdb us_geocoder"
sudo su - postgres -c "dropdb districts"
sudo su - postgres -c "dropuser ${USER}"
sudo su - postgres -c "createuser ${USER}"

# create a 'home' database for the user
sudo su - postgres -c "createdb --owner=${USER} ${USER}"

# create the geocoder databases in the 'spatial' tablespace
for j in or us
do
  for i in \
    "DROP DATABASE IF EXISTS ${j}_geocoder;" \
    "CREATE DATABASE ${j}_geocoder WITH OWNER ${USER} TABLESPACE spatial;"
  do
    sudo su - postgres -c "psql -d postgres -c '${i}'"
  done
done

# add the extensions to the geocoder databases
for j in or us
do
  for i in \
    "CREATE EXTENSION IF NOT EXISTS postgis;" \
    "CREATE EXTENSION IF NOT EXISTS postgis_topology;" \
    "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;" \
    "CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;" \
    "GRANT USAGE ON SCHEMA tiger TO PUBLIC;" \
    "GRANT USAGE ON SCHEMA tiger_data TO PUBLIC;" \
    "GRANT SELECT, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA tiger TO PUBLIC;" \
    "GRANT SELECT, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA tiger_data TO PUBLIC;" \
    "GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA tiger TO PUBLIC;" \
    "ALTER DEFAULT PRIVILEGES IN SCHEMA tiger_data GRANT SELECT, REFERENCES ON TABLES TO PUBLIC;"
  do
    sudo su - postgres -c "psql -d ${j}_geocoder -c '${i}'"
  done
done

# create the 'districts' database in the 'spatial' tablespace
for i in \
  "DROP DATABASE IF EXISTS districts;" \
  "CREATE DATABASE districts OWNER ${USER} TABLESPACE spatial;"
do
  sudo su - postgres -c "psql -d postgres -c '${i}'"
done

# just add basic geo extensions to 'districts'
for i in \
  "CREATE EXTENSION IF NOT EXISTS postgis;" \
  "CREATE EXTENSION IF NOT EXISTS postgis_topology;" \
  "CREATE SCHEMA districts AUTHORIZATION ${USER};"
do
  sudo su - postgres -c "psql -d districts -c '${i}'"
done

# VACUUM!
time sudo su - postgres -c "vacuumdb --all --analyze"

# show our work
psql -d postgres -c "\\l+"
