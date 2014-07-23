#!/bin/bash
if [ -e /vagrant/hackoregon.sql.bz2 ]
then
	echo "hackoregon.sql.bz2 found"
else
	echo "hackoregon.sql.bz2 not found, downloading..."
	wget  http://s3-us-west-2.amazonaws.com/mp-orestar-dump/hackoregon.sql.bz2
	sudo mv hackoregon.sql.bz2 /vagrant/hackoregon.sql.bz2
fi

sudo bunzip2 /vagrant/hackoregon.sql.bz2
sudo -u postgres psql -c 'CREATE DATABASE hackoregon;'
sudo -u postgres psql hackoregon < /vagrant/hackoregon.sql
sudo -u postgres createlang plpgsql

sudo -u postgres psql hackoregon <  /vagrant/install.sql

sudo -u postgres psql -c "alter user postgres password 'points';"
