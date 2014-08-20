if ! mongo --version ; then
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' >> /etc/apt/sources.list.d/mongodb.list
  apt-get update
  apt-get install -y mongodb-org
fi

# Disable DNS lookups so SSH is faster
grep DNS /etc/ssh/sshd_config > /dev/null || echo "UseDNS no" >> /etc/ssh/sshd_config
service ssh restart

# Add hostnames for our private network
# MongoDB requires DNS / hostnames to configure replication slaves
cp /vagrant/etc.hosts /etc/hosts

# Add our custom mongodb config
cp /vagrant/mongod.conf /etc/mongod.conf

# Add the replication cluster key
mkdir -p /etc/mongod
cp /vagrant/keyfile /etc/mongod/keyfile
chown mongodb /etc/mongod/keyfile && chmod 0400 /etc/mongod/keyfile

# Restart mongo so our config changes stick
service mongod restart
