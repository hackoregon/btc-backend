#! /bin/bash -v
vagrant box add ubuntu14 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box
vagrant init ubuntu14
vagrant up
