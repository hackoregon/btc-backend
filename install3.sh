#!/bin/bash
echo "running install3.sh"
echo "current working directory:"
pwd
echo "deb http://http://ftp.osuosl.org/pub/cran/bin/linux/ubuntu trusty/" >> ./sources.list.appendme
sudo cat /etc/apt/sources.list ./sources.list.appendme  > ./sources.list.tmp
sudo mv ./sources.list.tmp /etc/apt/sources.list
rm ./sources.list.appendme

sudo apt-get update
sudo apt-get -y install r-base
sudo apt-get -y install r-base-dev

#create a R library for the user:
echo R_LIBS_USER=\"~/lib/R/library\" > ~/.Renviron
mkdir ~/lib/R/library
sudo cp ./Rprofile .Rprofile

#install java so that some r packages will work.
#https://www.digitalocean.com/community/tutorials/how-to-install-java-on-ubuntu-with-apt-get

#installing the needed development kit
#for xls import
sudo apt-get -y install default-jdk

if [ -e ./hackoregon.sql.bz2 ]
then
	echo "hackoregon.sql.bz2 found"
else
	echo "hackoregon.sql.bz2 not found, downloading..."
	wget  http://s3-us-west-2.amazonaws.com/mp-orestar-dump/hackoregon.sql.bz2
fi

echo "Current working directory:"
pwd

sudo mkdir ~/data_infrastructure

sudo cp ./hackoregon.sql.bz2 ~/data_infrastructure/hackoregon.sql.bz2
sudo chmod 777 ./buildoutFromGitRepo.sh

sudo ./buildOutFromGitRepo.sh


cd ~
cwd=$(pwd)
datadir="${cwd}/data_infrastructure"
cd $datadir

echo "install3.sh changed the working directory to:"
pwd

sudo bunzip2 ./hackoregon.sql.bz2
sudo -u postgres psql -c 'CREATE DATABASE hackoregon;'

sudo -u postgres psql hackoregon < ./hackoregon.sql

sudo -u postgres psql hackoregon < ./trimTransactionsTable.sql

sudo -u postgres createlang plpgsql


sudo -u postgres psql -c "alter user postgres password 'points';"

sudo chmod 777 ./orestar_scrape/bulkAddTransactions.R
sudo ./orestar_scrape/bulkAddTransactions.R ~/data_infrastructure/successfullyMerged/joinedTables.tsv skipRebuild
sudo chmod 777 ./buildOutDBFromRawTables.sh
sudo ./buildOutDBFromRawTables.sh

