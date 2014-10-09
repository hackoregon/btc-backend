1. 'vagrant halt' from the host to shut down the machine.
2. Open the host VirtualBox GUI.
3. Take a snapshot of the guest so you can restore to it if it gets hosed!
4. Go into 'Settings -> Storage'. Add a new VMDK dynamically allocated 100 GB disk called 'tablespace' to the SATA controller. It won't actually use 100 GB; it's all done with pointers, indexes and other magic.
5. Close the VirtualBox GUI.
6. 'vagrant up' and 'vagrant ssh' into the guest system.
7. In the guest, type 'sudo cfdisk /dev/sdb'. You should see a blank disk with about 107 GB of free space. ***If you don't see that, just type 'q' to quit. Othewise you might over-write something else!***
8. If you're on the blank disk, type 'n' for 'New'. Press 'Enter' twice to accept the defaults. Then press capital 'W' to write, type 'yes' when it prompts you. Then press 'q' to quit.
9. Do

```
cd /vagrant/znmeb
./guest-add-tablespace.bash 2>&1 | tee tablespace.log
```

If all goes well you'll have a 100 GB 'spatial' tablespace for PostgreSQL!
