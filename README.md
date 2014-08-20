# MongoDB Replication Demo

A demo configuration and 3-vm setup for MongoDB replication. Requires [Vagrant 1.6+](http://www.vagrantup.com/)

## Try it

    git clone https://github.com/cbednarski/mongodb-repl
    cd mongodb-repl
    vagrant up

### Watch the logs to see leader election

    vagrant ssh db1 -c 'tail -f /var/log/mongodb/mongod.log'
    vagrant ssh db2 -c 'tail -f /var/log/mongodb/mongod.log'
    vagrant ssh db3 -c 'tail -f /var/log/mongodb/mongod.log'
    vagrant provision

### See the replica set status

    open http://10.7.0.2:28017/_replSet # db1
    open http://10.7.0.3:28017/_replSet # db2
    open http://10.7.0.4:28017/_replSet # db3

## How it works

MongoDB's replica sets have a few requirements:

1. Each node must be referenced by hostname (not ip address). See `etc.hosts`.
2. Each node must share the same `keyFile` which contains a passphrase. See `keyfile`.
3. Each node must share the same `replSet` name. See `mongod.conf`.
4. The demo will bring up 3 nodes. On one node, we call `rs.initialize()` to create a replica set and then call `rs.add()` for the other two nodes. See `Vagrantfile` and `replica-*.js`.

Replication has two essential components. First, you must configure nodes in your replica set to communicate with each other, as in 1, 2, and 3 above. Second, you must perform some orchestration to initiate the replica set and add members, as in 4. When you initially add members, a leader election will happen and after the dust settles you can read / write to your replica set.

### Some notes about failover and production environments

This demo is simplistic and many variables like network latency, load, and data volume are not present. In production, these factors may contribute to poor performance, slow leader elections, eventual consistency in secondary reads, and sometimes a [rollback scenario](http://docs.mongodb.org/manual/core/replica-set-rollbacks/). The latter two scenarios can be (mostly) avoided using the ["replica acknowledged" write concern](http://docs.mongodb.org/manual/core/write-concern/#write-concern-replica-acknowledged).

Write operations made to the replica set are stored in the primary node's [oplog](http://docs.mongodb.org/manual/core/replica-set-oplog/), which is then replicated to secondary nodes. If a node fails it may be able to use the oplog to catch up. If entries in the oplog expire the failed node becomes stale and must be [resynced](http://docs.mongodb.org/manual/tutorial/resync-replica-set-member/). If you add a completely fresh node you will need to perform an [initial sync](http://docs.mongodb.org/manual/core/replica-set-sync/).

When a primary node fails, failover may take [up to 60 seconds](http://docs.mongodb.org/manual/faq/replica-sets/#how-long-does-replica-set-failover-take). During this time the replica set is not available for writes, but may be available for reads depending on your [read preference](http://docs.mongodb.org/manual/reference/read-preference/).

Note: Most config file settings can be set as mongod startup params instead. See the mongo docs for more info. [config files](http://docs.mongodb.org/manual/reference/configuration-options/) | [mongod params](http://docs.mongodb.org/manual/reference/program/mongod/)

## Play around

### Replication

Write some data to the primary. Query it from a secondary node.

### Leader Election

Stop the primary. Bring it back up. Watch what happens. (Your primary may not be `db3`.) See the replica set status via <http://10.7.0.2:28017/_replSet>.

    vagrant ssh db3 -c 'sudo service stop mongod'
    vagrant ssh db3 -c 'sudo service start mongod'

### Rebuild a node

    vagrant destroy -f db3
    vagrant up db3
    vagrant ssh db2
    mongo
    cluster1:PRIMARY> rs.add('db3')

## Warning

The demo configuration is not secure and is not tuned for production. Please do not copy-paste this `mongod.conf` onto production systems.