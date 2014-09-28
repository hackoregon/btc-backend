hackOregonBackEnd
=================

Scripts to build Hack Oregon's back end in a vagrant virtual machine.

To install the backend:

1) Virtual box and vagrant must be installed.

		See https://www.virtualbox.org/ for virtual box.
	
		See http://www.vagrantup.com/ for vagrant.
		
Important notes on vagrant usage:

a) never run vagrant commands from your home machine as root. 
ie, if you run anything with the pattern 

	host machine prompt> sudo vagrant xxx
	
you will probably need to read this: http://stackoverflow.com/questions/25652769/should-vagrant-require-sudo-for-each-command

Running code as root from inside of the vagrant machine, ( ex: after >vagrant ssh and before ctrl-d ), is fine. 

b) If you are re-installing the back end and wish to re-install the vagrant instance (the first two commands in step 3), you need to first destroy the previously installed vagrant box
	> vagrant destroy
Then remove the vagrant config file found in the installation directory. 
	> rm Vagrantfile

	
2) Copy this git repository to a folder on your computer and make that folder your working directory.
These files should be in the folder:

	install2.sh : installation of openresty and other configurations
	install3.sh : installation of the Hack Oregon database
	appendToBash.bashrc
	install.sql : Connection of restful requests to postgres functions / postgres side
	nginx.conf : Connection of restful requests to postgres functions / nginx side
	Vagrantfile.final : Adds mapping of vagrant port 80 to host port 8080 so that web pages are available outside the vagrant machine
	
3) Run these commands (note: you may have to run chmod 777 installx.sh on each of the installx.sh scripts so that they can be executed. Also, you may have to enter Y partway through the installation of postgres; haven't found what option I need to use to skip that):

	#note: if there is already a file named Vagrantfile in the directory, 
	#the command "vagrant destroy" must be run and the Vagrantfile must be removed 
	#before executing the following steps.
	host machine prompt> vagrant box add ubuntu14 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box
	host machine prompt> vagrant init ubuntu14
	host machine prompt> vagrant up
	host machine prompt> vagrant ssh
	guest machine prompt> sudo /vagrant/install2.sh
	guest machine prompt> sudo /vagrant/install3.sh

4) enter ctrl + d then run these commands:

	host machine prompt> vagrant reload
	host machine prompt> vagrant ssh
	guest machine prompt> sudo /usr/local/openresty/nginx/sbin/nginx
5) Enter ctrl + d to exit ssh

Go to:
	http://localhost:8080/ 
on the host machine’s browser, the nginx welcome page should be seen.
Go to:

	http://localhost:8080/hackoregon/http/top_committee_data/4/
	
on the host machine’s browser,  JSON output should be seen. 


Interacting with the back end once it is installed
=================
All interaction with the vagrant virtual machine (VM) containing the Hack Oregon back end server must be done from the folder where the back end was installed -- the folder to which this back end git repo was cloned. (this is critical)

To log on to the vagrant VM: 
From a new command prompt/terminal window, navigate to the directory where vagrant is installed. 
enter:

	host machine prompt > vagrant ssh
	
This will put you into the guest machine (the Hack Oregon back end). 
To log out of the guest machine and return to the host, press 'control + d'

To turn off the back end server/vagrant machine, from the back end folder, host machine prompt, enter:

	host machine prompt> vagrant halt

To turn the server back on, enter:

	host machine prompt> vagrant up

Sometimes when the vagrant the nginx server will stop running when vagrant is stopped/started. If this happens, the nginx server may need to be restarted. Use this command to restart the nginx server after logging in to the hack oregon server:

	guest machine prompt> sudo /usr/local/openresty/nginx/sbin/nginx 

or, if that gives error:

	guest machine prompt> sudo /usr/local/openresty/nginx/sbin/nginx -s reload

To check if the nginx server is running, you can use this command:

	guest machine prompt> ps aux | grep nginx

If all is working this will show three lines of output. If only one line is seen, the nginx server is not running.

The nginx error log can be found here, in the VM:

/usr/local/openresty/nginx/logs/error.log

If I want to look at it, I generally run:

	guest machine prompt> sudo cp /usr/local/openresty/nginx/logs/error.log /vagrant/nginx.error.log

This will copy the error log to the installation folder, so that I can view the log with my favorite txt editor. 



