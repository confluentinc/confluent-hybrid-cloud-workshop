#!/bin/bash

cd ~/.workshop/docker
# Create ccloud.properties file
echo "ssl.endpoint.identification.algorithm=https" >> ccloud.properties
echo "sasl.mechanism=PLAIN" >> ccloud.properties
echo "request.timeout.ms=20000" >> ccloud.properties
echo "bootstrap.servers=${ccloud_cluster_endpoint}" >> ccloud.properties
echo "retry.backoff.ms=500" >> ccloud.properties
echo "sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${ccloud_api_key}\" password=\"${ccloud_api_secret}\";" >> ccloud.properties
echo "security.protocol=SASL_SSL" >> ccloud.properties

# Create .env file for Docker
echo "EXT_IP=${ext_ip}" >> .env
echo "CCLOUD_CLUSTER_ENDPOINT=${ccloud_cluster_endpoint}" >> .env
echo "CCLOUD_API_KEY=${ccloud_api_key}" >> .env
echo "CCLOUD_API_SECRET=${ccloud_api_secret}" >> .env
echo "HOSTNAME"=$HOSTNAME >> .env
echo "DC"=${dc} >> .env
echo "CCLOUD_TOPICS"=${ccloud_topics} >> .env
echo "ONPREM_TOPICS"=${onprem_topics} >> .env
echo "CONFLUENT_DOCKER_TAG"=6.1.1 >> .env

# select the DC correctly in the database simulator script and schema file.
sed -i 's/dcxx/${dc}/g' ~/.workshop/docker/db_transaction_simulator/simulate_dbtrans.py
sed -i 's/dcxx/${dc}/g' ~/.workshop/docker/data/mysql/mysql_schema.sql

# Generate html file for the hosted instructions
cd ~/.workshop/docker/asciidoc
asciidoctor index.adoc -o index.html -a stylesheet=stylesheet.css -a externalip=${ext_ip} -a dc=${dc} -a imagesdir=./images/hybrid-cloud-ws/${cloud_provider}
asciidoctor hybrid-cloud-workshop.adoc -o hybrid-cloud-workshop.html -a stylesheet=stylesheet.css -a externalip=${ext_ip} -a dc=${dc} -a "feedbackformurl=${feedback_form_url}" -a imagesdir=./images/hybrid-cloud-ws/${cloud_provider}
asciidoctor ksqldb-workshop.adoc -o ksqldb-workshop.html -a stylesheet=stylesheet.css -a externalip=${ext_ip} -a dc=${dc} -a "feedbackformurl=${feedback_form_url}" -a imagesdir=./images/ksqlws
asciidoctor ksqldb-advanced-topics.adoc -o ksqldb-advanced-topics.html -a stylesheet=stylesheet.css -a externalip=${ext_ip} -a dc=${dc} -a "feedbackformurl=${feedback_form_url}" -a imagesdir=./images/ksqlws
asciidoctor ksqldb-usecase-retail.adoc -o ksqldb-usecase-retail.html -a stylesheet=stylesheet.css -a externalip=${ext_ip} -a dc=${dc} -a "feedbackformurl=${feedback_form_url}" -a imagesdir=./images/ksqlws
asciidoctor ksqldb-usecase-finserv.adoc -o ksqldb-usecase-finserv.html -a stylesheet=stylesheet.css -a externalip=${ext_ip} -a dc=${dc} -a "feedbackformurl=${feedback_form_url}" -a imagesdir=./images/ksqlws
asciidoctor ksqldb-usecase-ratings.adoc -o ksqldb-usecase-ratings.html -a stylesheet=stylesheet.css -a externalip=${ext_ip} -a dc=${dc} -a "feedbackformurl=${feedback_form_url}" -a imagesdir=./images/ksqlws

# Inject c&p functionality into rendered html file.
sed -i -e '/<title>/r clipboard.html' hybrid-cloud-workshop.html
sed -i -e '/<title>/r clipboard.html' ksqldb-workshop.html
sed -i -e '/<title>/r clipboard.html' ksqldb-advanced-topics.html
sed -i -e '/<title>/r clipboard.html' ksqldb-usecase-retail.html
sed -i -e '/<title>/r clipboard.html' ksqldb-usecase-finserv.html
sed -i -e '/<title>/r clipboard.html' ksqldb-usecase-ratings.html

# Creating empty folder to host aws configs later
mkdir ~/.workshop/docker/.aws

# startup the containers
cd ~/.workshop/docker/
docker-compose up -d

cd ~/.workshop/docker/extensions
for extension in */ ; do
    if [ -d $extension/docker ]; then
        cd $extension/docker
        echo "" >> .env
        cat ../../../.env >> .env
        docker-compose -f docker-compose.yaml up -d
        cd ../../
    fi
done
