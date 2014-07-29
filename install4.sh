#!/bin/bash
#R installation
#using instructions from here: http://cran.r-project.org/bin/linux/ubuntu/README
#cran mirror: http://ftp.osuosl.org/pub/cran/

#add this entry to the /etc/apt/sources.list file: deb http://http://ftp.osuosl.org/pub/cran/bin/linux/ubuntu lucid/

echo "deb http://http://ftp.osuosl.org/pub/cran/bin/linux/ubuntu trusty/" >> ./sources.list.appendme
sudo cat /etc/apt/sources.list ./sources.list.appendme  > ./sources.list.tmp
sudo mv ./sources.list.tmp /etc/apt/sources.list
rm ./sources.list.appendme

sudo apt-get update
sudo apt-get install r-base
sudo apt-get install r-base-dev

#create a R library for the user:
echo R_LIBS_USER=\"~/lib/R/library\" > ~/.Renviron
mkdir ~/lib/R/library
sudo cp /vagrant/Rprofile .Rprofile