#!/bin/bash

create_ccloud_topics(){
    CONFIG_FILE=/ccloud.properties
    TOPICS=$1
    DC=$2
    # Create topics in Confluent Cloud
    for topic in ${TOPICS//,/ }
    do
        echo "Creating: ${USER}-${topic}"
        kafka-topics --bootstrap-server `grep "^\s*bootstrap.server" $CONFIG_FILE | tail -1` --command-config $CONFIG_FILE --create --topic "${DC}_${topic}" --partitions 1 --replication-factor 3
    done
}

create_onprem_topics(){
    TOPICS=$1
    BOOTSTRAP_SERVERS=$2
    # Create topics in Confluent Server (On-prem)
    for topic in ${TOPICS//,/ }
    do
        echo "Creating: ${topic}"
        kafka-topics --bootstrap-server $BOOTSTRAP_SERVERS --create --topic "${topic}"
    done
}

preload_onprem_topics(){
    TOPICS=$1
    BOOTSTRAP_SERVERS=$2
    FILES_FOLDER=$3
    # Create topics in Confluent Server (On-prem)
    for topic in ${TOPICS//,/ }
    do
        echo "Producing to topic: ${topic}"
        cat $FILES_FOLDER/${topic}.json | kafka-console-producer --topic ${topic} --broker-list $BOOTSTRAP_SERVERS  --property "parse.key=true" --property "key.separator=:"
    done
}

