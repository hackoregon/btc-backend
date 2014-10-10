#! /bin/bash -v

# create the filesystem
sudo mkfs -t ext4 -L tablespace /dev/sdb1

# create the mount point
sudo mkdir -p /tablespace

# add it to /etc/fstab
sudo su - root -c "cat /vagrant/znmeb/tablespace-fstab >> /etc/fstab"

# mount it and assign it to the 'postgres' Linux user
sudo mount -a
sudo chown -R postgres:postgres /tablespace

# check
df -Th

# now do the PostgreSQL commands
for i in \
  "CREATE TABLESPACE spatial LOCATION '/tablespace';" \
  '\db+'
do
  sudo su - postgres -c "psql -d postgres -c \"${i}\""
done

sudo ls -altr /tablespace
