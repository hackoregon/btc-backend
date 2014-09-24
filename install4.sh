#!/bin/bash
#R installation
#using instructions from here: http://cran.r-project.org/bin/linux/ubuntu/README
#cran mirror: http://ftp.osuosl.org/pub/cran/

#add this entry to the /etc/apt/sources.list file: deb http://http://ftp.osuosl.org/pub/cran/bin/linux/ubuntu lucid/


#node scraper installation

sudo apt-get -y install nodejs
sudo apt-get -y install 
sudo apt-get install -y npm

sudo ./buildScraper.sh
# cd orestar_scrape
# sudo npm install 
# cd orestar_scrape_committees
# sudo npm install

