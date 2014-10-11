#!/bin/bash
echo "install2.sh and all install<x>.sh scripts must be run from the"
echo "directory containing the cloned git repo."
echo "if this is a Vagrant install, the cloned git repo will be found"
echo "in the directory"
echo " /vagrant/ "

sudo mkdir /process_logs
sudo chmod 777 /process_logs

packageDir=$(pwd)
echo "Original directory:"
echo "${packageDir}"
sudo aptitude update
sudo aptitude install postgresql postgresql-contrib postgis postgresql-9.3-postgis-scripts postgi_tiger_geocoder git

sudo cat /etc/bash.bashrc ./appendToBash.bashrc > /etc/bash.bashrc
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales
sudo pg_createcluster 9.3 main —start


sudo /etc/init.d/postgresql restart
echo "Installing open resty... "
#install openresty
wget http://openresty.org/download/ngx_openresty-1.7.0.1.tar.gz
tar xzvf ngx_openresty-1.7.0.1.tar.gz
cd ngx_openresty-1.7.0.1/
sudo apt-get -y install build-essential libpq-dev libpcre3-dev
./configure  --with-http_postgres_module
make
sudo make install

echo "Current directory:"
pwd
echo "Switching to directory ${packageDir}"
cd $packageDir
echo "Current directory:"
pwd

echo "Installing nginx... "
#configure nginx
sudo mkdir /process_logs/nginx
sudo chmod 777 /process_logs/nginx
sudo mv  /usr/local/openresty/nginx/conf/nginx.conf  /usr/local/openresty/nginx/conf/nginx.conf.old
sudo cp ./nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
cd /usr/local/openresty/nginx
cd $packageDir

ps aux | grep nginx
sudo apt-get remove apache
sudo apt-get remove nginx
sudo /usr/local/openresty/nginx/sbin/nginx
ps aux | grep nginx

echo "Testing nginx... "
wget localhost
cat index.html

echo "Updating Vagrantfile... "
sudo mv ./Vagrantfile ./Vagrantfile.initial
sudo cp ./Vagrantfile.final ./Vagrantfile