#!/bin/bash

CONFIG_FILE=/ccloud.properties
TOPICS=$1
DC=$2
# Create topics in Confluent Cloud
for topic in ${TOPICS//,/ }
do
    echo "Creating: ${USER}-${topic}"
    kafka-topics --bootstrap-server `grep "^\s*bootstrap.server" $CONFIG_FILE | tail -1` --command-config $CONFIG_FILE --create --topic "${DC}_${topic}" --partitions 1 --replication-factor 3
done
