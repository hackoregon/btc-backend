#!/bin/bash
sudo aptitude update
sudo aptitude install postgresql postgresql-contrib postgis postgresql-9.3-postgis-scripts git
sudo cat /etc/bash.bashrc /vagrant/appendToBash.bashrc > /etc/bash.bashrc
sudo locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales
sudo pg_createcluster 9.3 main —start

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
sudo cp /vagrant/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
cd /usr/local/openresty/nginx
cd
ps aux | grep nginx
sudo apt-get remove apache
sudo apt-get remove nginx
sudo /usr/local/openresty/nginx/sbin/nginx
ps aux | grep nginx

wget localhost
cat index.html

sudo cp /vagrant/Vagrantfile /vagrant/Vagrantfile.initial
sudo cp /vagrant/Vagrantfile.final /vagrant/Vagrantfile
