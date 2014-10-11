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

# create the 'districts' database in the 'spatial' tablespace
for i in \
  "DROP DATABASE IF EXISTS districts;" \
  "CREATE DATABASE districts OWNER ${USER} TABLESPACE spatial;"
do
  sudo su - postgres -c "psql -d postgres -c '${i}'"
done

# create the 'districts' schema
for i in \
  "CREATE SCHEMA districts AUTHORIZATION ${USER};"
do
  sudo su - postgres -c "psql -d districts -c '${i}'"
done

# VACUUM!
time sudo su - postgres -c "vacuumdb --all --analyze"

# show our work
psql -d postgres -c "\\l+"
