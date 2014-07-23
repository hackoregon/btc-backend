To install the backend:
Virtual box and vagrant must be installed.
Unzip hackOregonBackEnd.zip 
Make the unzipped folder your working directory
these files are in the folder:
	install2.sh
	install3.sh
	appendTo_bash.bashrc
	install.sql
	nginx.conf
	Vagrantfile.final
Run
	vagrant init https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box
	vagrant up
	vagrant ssh
	sudo /vagrant/install2.sh
	sudo /vagrant/install3.sh
enter ctrl + d
	vagrant reload
	vagrant ssh
	sudo /usr/local/openresty/nginx/sbin/nginx
enter ctrl + d

Go to:
	http://localhost:8080/ 
on the host machine’s browser, the nginx welcome page should be seen.
Go to:
	http://localhost:8080/hackoregon/http/one_committee/blank/
on the host machine’s browser,  JSON output should be seen. 



