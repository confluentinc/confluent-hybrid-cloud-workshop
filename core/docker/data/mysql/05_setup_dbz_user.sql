# In production you would almost certainly limit the replication user must be on the follower (slave) machine,
# to prevent other clients accessing the log from other machines. For example, 'replicator'@'follower.acme.com'.
#
# 1) 'replicator' - all privileges required by the binlog reader (setup through 'readbinlog.sql')
# 2) 'snapper' - all privileges required by the snapshot reader AND binlog reader
#
\! echo Creating replication users...
CREATE USER 'replicator' IDENTIFIED BY 'replpass';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replicator';
CREATE USER 'debezium' IDENTIFIED WITH mysql_native_password BY 'dbzpass';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT, LOCK TABLES  ON *.* TO 'debezium'@'%';
