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
echo "CCLOUD_CLUSTER_ENDPOINT=${ccloud_cluster_endpoint}" >> .env
echo "CCLOUD_API_KEY=${ccloud_api_key}" >> .env
echo "CCLOUD_API_SECRET=${ccloud_api_secret}" >> .env
echo "HOSTNAME"=$HOSTNAME >> .env
echo "DC"=${dc} >> .env
echo "CONFLUENT_DOCKER_TAG"=7.3.3 >> .env
echo "HQ_EXT_IP=${hq_ext_ip}" >> .env

# Creating empty folder to host aws configs later
mkdir ~/.workshop/docker/.aws

cd ~/.workshop/docker/
# rename the old and copy the correct docker-compose file
cp ~/.workshop/docker/docker-compose.yaml ~/.workshop/docker/old-docker-compose.yaml
cp ~/.workshop/docker/hq/docker-compose.yaml ~/.workshop/docker/docker-compose.yaml

# startup the containers
docker-compose up -d

# create environment variables for cluster linking commands
cd ~
echo "export DC=${dc}" >> .bashrc
echo "export CCLOUD_CLUSTER_ENDPOINT=`echo ${ccloud_cluster_endpoint}|awk -F "//" '{ print $2 }'`" >> .bashrc
echo "export CCLOUD_REST_ENDPOINT=${ccloud_rest_endpoint}" >> .bashrc
echo "export CCLOUD_API_KEY=${ccloud_api_key}" >> .bashrc
echo "export CCLOUD_API_SECRET=${ccloud_api_secret}" >> .bashrc
echo "export CCLOUD_CLUSTER_ID=${ccloud_cluster_id}" >> .bashrc
echo "export ENCODED_API_KEY_SECRET=`echo -n "${ccloud_api_key}:${ccloud_api_secret}"|base64 -w0`" >> .bashrc
echo "export HQ_EXT_IP=${hq_ext_ip}" >> .bashrc

until $(curl --output /dev/null -sk --head --fail http://localhost:8090/kafka/v3/clusters); do
    printf '. waiting for HQ cluster to be ready.'
    sleep 5
done

echo "export ONPREM_HQ_CLUSTER_ID=`curl -sk http://localhost:8090/kafka/v3/clusters|jq --raw-output .data[].cluster_id`" >> .bashrc

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
