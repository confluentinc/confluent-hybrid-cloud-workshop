#! /bin/bash

DELAY_FOR_START=5 # seconds to wait after resource creation before moving on, giving time for systems to actually process the resource being created
CURL_RETRY_COUNT=10
CURL_RETRY_DELAY=5 # seconds

## Lab 15: Mirror Event from Confluent Cloud to On-Premises Confluent Platform HQ
## Submit the Cluster Linking Config

curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''http://${HQ_EXT_IP}:8090'/kafka/v3/clusters/'${ONPREM_HQ_CLUSTER_ID}'/links?link_name=clusterlink-cloud-to-hq-'$DC'' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_cluster_id": "'${CCLOUD_CLUSTER_ID}'",
    "configs": [
      {
        "name": "bootstrap.servers",
        "value": "'${CCLOUD_CLUSTER_ENDPOINT}'"
      },
      {
        "name": "security.protocol",
        "value": "SASL_SSL"
      },
      {
        "name": "sasl.mechanism",
        "value": "PLAIN"
      },
      {
        "name": "sasl.jaas.config",
        "value": "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"'${CCLOUD_API_KEY}'\" password=\"'${CCLOUD_API_SECRET}'\";"
      }
      ]
    }'

sleep $DELAY_FOR_START

curl --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY -s --request GET   --url http://${HQ_EXT_IP}:8090/kafka/v3/clusters/${ONPREM_HQ_CLUSTER_ID}/links/clusterlink-cloud-to-hq-dc01 | jq .

## Create mirror topic
curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''http://${HQ_EXT_IP}:8090'/kafka/v3/clusters/'${ONPREM_HQ_CLUSTER_ID}'/links/clusterlink-cloud-to-hq-'$DC'/mirrors' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_topic_name": "'$DC'_out_of_stock_events",
    "configs": [
    ]
}'

sleep $DELAY_FOR_START

## Lab 16: Mirror Event from on-premises Confluent Platform HQ to On-premises Confluent Platform Edge
curl --request POST \
  --retry ${CURL_RETRY_COUNT} --retry-delay ${CURL_RETRY_DELAY} \
  --url 'http://localhost:8090/kafka/v3/clusters/'${ONPREM_CLUSTER_ID}'/links?link_name=clusterlink-hq-to-edge' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_cluster_id": "'${ONPREM_HQ_CLUSTER_ID}'",
    "configs": [
      {
        "name": "bootstrap.servers",
        "value": "'${HQ_EXT_IP}:9092'"
      }
      ]
    }'

sleep $DELAY_FOR_START
curl --retry ${CURL_RETRY_COUNT} --retry-delay ${CURL_RETRY_DELAY} -s --request GET --url http://localhost:8090/kafka/v3/clusters/${ONPREM_CLUSTER_ID}/links/clusterlink-hq-to-edge | jq .

## Create mirror topic
curl --request POST \
  --retry ${CURL_RETRY_COUNT} --retry-delay ${CURL_RETRY_DELAY} \
  --url 'http://localhost:8090/kafka/v3/clusters/'${ONPREM_CLUSTER_ID}'/links/clusterlink-hq-to-edge/mirrors' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_topic_name": "'${DC}'_out_of_stock_events",
    "configs": [
    ]
}'

sleep $DELAY_FOR_START

## Lab 17: Sink Events into MySQL

curl -i -X POST -H "Accept:application/json" \
    --retry ${CURL_RETRY_COUNT} --retry-delay ${CURL_RETRY_DELAY} \
    -H  "Content-Type:application/json" http://localhost:18083/connectors/ \
    -d '{
        "name": "jdbc-mysql-sink",
        "config": {
          "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
          "topics": "dc01_out_of_stock_events",
          "connection.url": "jdbc:mysql://mysql:3306/orders",
          "connection.user": "mysqluser",
          "connection.password": "mysqlpw",
          "insert.mode": "INSERT",
          "batch.size": "3000",
          "auto.create": "true",
          "key.converter": "org.apache.kafka.connect.storage.StringConverter"
       }
    }'

echo "\n"