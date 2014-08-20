# MongoDB Replication Demo

A demo configuration and 3-vm setup for MongoDB replication. Requires [Vagrant 1.6+](http://www.vagrantup.com/)

## Try it

    $ vagrant up

### Watch the logs to see leader election

    $ vagrant ssh db1 -c 'tail -f /var/log/mongodb/mongod.log'
    $ vagrant ssh db2 -c 'tail -f /var/log/mongodb/mongod.log'
    $ vagrant ssh db3 -c 'tail -f /var/log/mongodb/mongod.log'

### See the replica set status

    open http://10.7.0.2:28017/_replSet

## How it works

MongoDB requires a few things to run in replication mode.

1. All instances must be reference by hostname (not ip address). See `etc.hosts`.
2. Replication members must share a keyfile which contains a password. See `keyfile`.
3. Replication members must share a configuration file that specifies the `replSet` name. See `mongod.conf`.
4. We bring up 3 nodes. On one node, we call `rs.initialize()` to create a replica set and then `rs.add()` the other two. See `Vagrantfile`.

Note: Most config file settings can be set as mongod startup params instead. See the mongo docs for more info. [config files](http://docs.mongodb.org/manual/reference/configuration-options/) | [mongod params](http://docs.mongodb.org/manual/reference/program/mongod/)

There are two essential pieces to replication. The first is that your nodes must be configured for replication so they can identify and authenticate with eachother. The second is that you have to initiate the replica set and add members. When you do this, a leader election will happen and after the dust settles you can start to read / write to your replica set.

Write operations made to the replica set are stored in the [oplog](http://docs.mongodb.org/manual/core/replica-set-oplog/) (similar to MySQL's binlog). When a leader election occurs and a new primary is elected, it will need to resync its oplog to other slaves. It may take some time for this to happen and until then your cluster will be unavailable for writes. If the max oplog size is reached data will be truncated and in this case you will need to [resync](http://docs.mongodb.org/manual/tutorial/resync-replica-set-member/) to bring a new slave online.

## Play around

### Replication

Write some data. Query it from a secondary node.

### Leader Election

Stop the primary. Bring it back up. Watch what happens. (Your primary may not be `db3`.)

    $ vagrant ssh db3 -c 'sudo service stop mongod'
    $ vagrant ssh db3 -c 'sudo service start mongod'

### Rebuild a node

    $ vagrant destroy -f db3
    $ vagrant up db3
    $ vagrant ssh db2
    $ mongo
    cluster1:PRIMARY> rs.add('db3')

## Warning

The configuration is not secure and is not tuned for production. Please do not copy-paste `mongod.conf` onto production systems.