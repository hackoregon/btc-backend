#!/bin/bash
echo "install2.sh and all install<x>.sh scripts must be run from the"
echo "directory containing the cloned git repo."
echo "if this is a Vagrant install, the cloned git repo will be found"
echo "in the directory"
echo " /vagrant/ "
sudo aptitude update
sudo aptitude install postgresql
sudo cat /etc/bash.bashrc ./appendToBash.bashrc > /etc/bash.bashrc
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales
sudo pg_createcluster 9.3 main —start

sudo apt-get install postgresql-contrib
sudo /etc/init.d/postgresql restart

#install openresty
wget http://openresty.org/download/ngx_openresty-1.7.0.1.tar.gz
tar xzvf ngx_openresty-1.7.0.1.tar.gz
cd ngx_openresty-1.7.0.1/
sudo apt-get -y install build-essential libpq-dev libpcre3-dev
./configure  --with-http_postgres_module
make
sudo make install

#configure nginx
sudo mv  /usr/local/openresty/nginx/conf/nginx.conf  /usr/local/openresty/nginx/conf/nginx.conf.old
sudo cp ./nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
cd /usr/local/openresty/nginx
cd
ps aux | grep nginx
sudo apt-get remove apache
sudo apt-get remove nginx
sudo /usr/local/openresty/nginx/sbin/nginx
ps aux | grep nginx

wget localhost
cat index.html

sudo mv ./Vagrantfile ./Vagrantfile.initial
sudo cp ./Vagrantfile.final ./Vagrantfile