#! /bin/bash

TIME_TO_WAIT_FOR_TOPIC_CREATION=300 # seconds
DELAY_FOR_START=10 # seconds to wait after resource creation before moving on, giving time for systems to actually process the resource being created
CURL_RETRY_COUNT=10
CURL_RETRY_DELAY=5

## Lab 2: Getting Started - Starting the Orders Application

echo "Starting the Orders Simulator..."
docker exec -dit db-trans-simulator sh -c "python -u /simulate_dbtrans.py > /proc/1/fd/1 2>&1"
echo "Started"

sleep $DELAY_FOR_START

## Lab 3: Stream Events to Confluent Platform Edge - Create the MySQL source connector

curl -i -X POST -H "Accept:application/json" \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  -H  "Content-Type:application/json" http://localhost:18083/connectors/ \
  -d '{
    "name": "mysql-source-connector",
    "config": {
          "connector.class": "io.debezium.connector.mysql.MySqlConnector",
          "database.hostname": "mysql",
          "database.port": "3306",
          "database.user": "mysqluser",
          "database.password": "mysqlpw",
          "database.server.id": "12345",
          "database.server.name": "'$DC'",
          "database.whitelist": "orders",
          "table.blacklist": "orders.'$DC'_out_of_stock_events",
          "database.history.kafka.bootstrap.servers": "broker:29092",
          "database.history.kafka.topic": "debezium_dbhistory" ,
          "include.schema.changes": "false",
          "snapshot.mode": "when_needed",
          "transforms": "unwrap,sourcedc,TopicRename,extractKey",
          "transforms.unwrap.type": "io.debezium.transforms.UnwrapFromEnvelope",
          "transforms.sourcedc.type":"org.apache.kafka.connect.transforms.InsertField$Value",
          "transforms.sourcedc.static.field":"sourcedc",
          "transforms.sourcedc.static.value":"'$DC'",
          "transforms.TopicRename.type": "org.apache.kafka.connect.transforms.RegexRouter",
          "transforms.TopicRename.regex": "(.*)\\.(.*)\\.(.*)",
          "transforms.TopicRename.replacement": "$1_$3",
          "transforms.extractKey.type": "org.apache.kafka.connect.transforms.ExtractField$Key",
          "transforms.extractKey.field": "id",
          "key.converter": "org.apache.kafka.connect.converters.IntegerConverter"
      }
  }'

sleep $DELAY_FOR_START

curl --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY  -s localhost:18083/connectors/mysql-source-connector/status | jq

## Lab 4: Stream Events to Confluent Platform HQ - Setup the Cluster Link

## create the first half [of the cluster link] on Confluent Platform (HQ)
curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''${HQ_EXT_IP}:8090'/kafka/v3/clusters/'${ONPREM_HQ_CLUSTER_ID}'/links?link_name=clusterlink-'$DC'-to-cp-hq' \
  --header 'Content-Type: application/json' \
  --data '{
  "source_cluster_id": "'$ONPREM_CLUSTER_ID'",
  "configs": [
    {
      "name": "link.mode",
      "value": "DESTINATION"
    },
    {
      "name": "connection.mode",
      "value": "INBOUND"
    },
    {
      "name": "acl.sync.enable",
      "value": "false"
    },
+   {
+     "name": "metadata.max.age.ms",
+     "value": "15000"
+   },      
    {
      "name": "auto.create.mirror.topics.enable",
      "value": "true"
    },
    {
      "name": "auto.create.mirror.topics.filters",
      "value": "{\"topicFilters\": [{\"name\": \"'$DC'_\", \"patternType\": \"PREFIXED\", \"filterType\": \"INCLUDE\"}, {\"name\": \"'$DC'_out_of_stock_events\", \"patternType\": \"LITERAL\", \"filterType\": \"EXCLUDE\"}]}"
    }
  ]
}'

sleep $DELAY_FOR_START

##  create the second half [of the cluster link on] Confluent Platform (Edge)

curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url 'http://localhost:8090/kafka/v3/clusters/'$ONPREM_CLUSTER_ID'/links?link_name=clusterlink-'$DC'-to-cp-hq' \
  --header 'Content-Type: application/json' \
  --data '{
    "destination_cluster_id": "'${ONPREM_HQ_CLUSTER_ID}'",
    "configs": [
      {
        "name": "bootstrap.servers",
        "value": "'${HQ_EXT_IP}:9092'"
      },
      {
        "name": "link.mode",
        "value": "SOURCE"
      },
      {
        "name": "connection.mode",
        "value": "OUTBOUND"
      },
      {
        "name": "local.bootstrap.servers",
        "value": "localhost:9092"
        }
      ]
    }'

sleep $DELAY_FOR_START

curl --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY  -s --request GET --url http://localhost:8090/kafka/v3/clusters/${ONPREM_CLUSTER_ID}/links|jq .

## Wait for topics to populate
echo "Waiting "$(($TIME_TO_WAIT_FOR_TOPIC_CREATION/60))" mins for topics to populate"
sleep $TIME_TO_WAIT_FOR_TOPIC_CREATION

## Lab 5: Mirror Topics to Confluent Cloud

curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''${CCLOUD_REST_ENDPOINT}'/kafka/v3/clusters/'${CCLOUD_CLUSTER_ID}'/links?link_name=clusterlink-hq-to-cc' \
  --header 'Authorization: Basic '$ENCODED_API_KEY_SECRET'' \
  --header 'Content-Type: application/json' \
  --data '{
  "source_cluster_id": "'$ONPREM_HQ_CLUSTER_ID'",
  "configs": [
    {
      "name": "link.mode",
      "value": "DESTINATION"
    },
    {
      "name": "connection.mode",
      "value": "INBOUND"
    },
+   {
+     "name": "metadata.max.age.ms",
+     "value": "15000"
+   },  
    {
      "name": "acl.sync.enable",
      "value": "false"
    },
    {
      "name": "auto.create.mirror.topics.enable",
      "value": "false"
    }
  ]
}'

sleep $DELAY_FOR_START

curl --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY  -s --request GET   --url ''${CCLOUD_REST_ENDPOINT}'/kafka/v3/clusters/'${CCLOUD_CLUSTER_ID}'/links/clusterlink-hq-to-cc' --header 'Authorization: Basic '$ENCODED_API_KEY_SECRET''|jq .

curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''${HQ_EXT_IP}:8090'/kafka/v3/clusters/'${ONPREM_HQ_CLUSTER_ID}'/links?link_name=clusterlink-hq-to-cc' \
  --header 'Content-Type: application/json' \
  --data '{
    "destination_cluster_id": "'${CCLOUD_CLUSTER_ID}'",
    "configs": [
      {
        "name": "bootstrap.servers",
        "value": "'${CCLOUD_CLUSTER_ENDPOINT}'"
      },
      {
        "name": "link.mode",
        "value": "SOURCE"
      },
      {
        "name": "connection.mode",
        "value": "OUTBOUND"
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
      },
      {
        "name": "local.bootstrap.servers",
        "value": "localhost:9092"
        }
      ]
    }'

sleep $DELAY_FOR_START

curl --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY -s --request GET --url http://${HQ_EXT_IP}:8090/kafka/v3/clusters/${ONPREM_HQ_CLUSTER_ID}/links/clusterlink-hq-to-cc|jq .

## Wait for topics to populate
echo "Waiting "$(($TIME_TO_WAIT_FOR_TOPIC_CREATION/60))" mins for topics to populate"
sleep $TIME_TO_WAIT_FOR_TOPIC_CREATION

## Lab 6: Stream Events to Confluent Cloud

curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''${CCLOUD_REST_ENDPOINT}'/kafka/v3/clusters/'${CCLOUD_CLUSTER_ID}'/links/clusterlink-hq-to-cc/mirrors' \
  --header 'Authorization: Basic '$ENCODED_API_KEY_SECRET'' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_topic_name": "'$DC'_customers",
    "configs": [
    ]
}'
curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''${CCLOUD_REST_ENDPOINT}'/kafka/v3/clusters/'${CCLOUD_CLUSTER_ID}'/links/clusterlink-hq-to-cc/mirrors' \
  --header 'Authorization: Basic '$ENCODED_API_KEY_SECRET'' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_topic_name": "'$DC'_products",
    "configs": [
    ]
}'
curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''${CCLOUD_REST_ENDPOINT}'/kafka/v3/clusters/'${CCLOUD_CLUSTER_ID}'/links/clusterlink-hq-to-cc/mirrors' \
  --header 'Authorization: Basic '$ENCODED_API_KEY_SECRET'' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_topic_name": "'$DC'_purchase_order_details",
    "configs": [
    ]
}'
curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''${CCLOUD_REST_ENDPOINT}'/kafka/v3/clusters/'${CCLOUD_CLUSTER_ID}'/links/clusterlink-hq-to-cc/mirrors' \
  --header 'Authorization: Basic '$ENCODED_API_KEY_SECRET'' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_topic_name": "'$DC'_purchase_orders",
    "configs": [
    ]
}'
curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''${CCLOUD_REST_ENDPOINT}'/kafka/v3/clusters/'${CCLOUD_CLUSTER_ID}'/links/clusterlink-hq-to-cc/mirrors' \
  --header 'Authorization: Basic '$ENCODED_API_KEY_SECRET'' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_topic_name": "'$DC'_sales_order_details",
    "configs": [
    ]
}'
curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''${CCLOUD_REST_ENDPOINT}'/kafka/v3/clusters/'${CCLOUD_CLUSTER_ID}'/links/clusterlink-hq-to-cc/mirrors' \
  --header 'Authorization: Basic '$ENCODED_API_KEY_SECRET'' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_topic_name": "'$DC'_sales_orders",
    "configs": [
    ]
}'
curl --request POST \
  --retry $CURL_RETRY_COUNT --retry-delay $CURL_RETRY_DELAY \
  --url ''${CCLOUD_REST_ENDPOINT}'/kafka/v3/clusters/'${CCLOUD_CLUSTER_ID}'/links/clusterlink-hq-to-cc/mirrors' \
  --header 'Authorization: Basic '$ENCODED_API_KEY_SECRET'' \
  --header 'Content-Type: application/json' \
  --data '{
    "source_topic_name": "'$DC'_suppliers",
    "configs": [
    ]
}'