hackOregonBackEnd
=================

Scripts to build hack oregon's back end in a vagrant virtual machine.

To install the backend:

1) Virtual box and vagrant must be installed.

		See https://www.virtualbox.org/ for virtual box.
	
		See http://www.vagrantup.com/ for vagrant.

	
2) Unzip hackOregonBackEnd.zip, or copy git repository to your computer, make the folder your working directory
Fhese files should be in the folder:

	install2.sh
	install3.sh
	appendTo_bash.bashrc
	install.sql
	nginx.conf
	Vagrantfile.final
	
3) Run thesse commands (note: you may have to run chmod 777 installx.sh on each of the installx.sh scripts so that they can be executed):


	host machine prompt> vagrant init https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box
	host machine prompt> vagrant up
	host machine prompt> vagrant ssh
	guest machine prompt> sudo /vagrant/install2.sh
	guest machine prompt> sudo /vagrant/install3.sh

4) enter ctrl + d then run these commands from the host machine's command prompt:

	host machine prompt> vagrant reload
	host machine prompt> vagrant ssh
	guest machine prompt> sudo /usr/local/openresty/nginx/sbin/nginx
5) Enter ctrl + d to exit ssh

Go to:
	http://localhost:8080/ 
on the host machine’s browser, the nginx welcome page should be seen.
Go to:
	http://localhost:8080/hackoregon/http/one_committee/blank/
on the host machine’s browser,  JSON output should be seen. 


