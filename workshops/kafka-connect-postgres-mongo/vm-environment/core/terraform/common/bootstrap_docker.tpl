#!/bin/bash

cd ~/.workshop/docker

# Create .env file for Docker
echo "EXT_IP=${ext_ip}" >> .env
echo "HOSTNAME"=$HOSTNAME >> .env
echo "DC"=${dc} >> .env
echo "PASS"=${participant_password} >> .env
echo "CONFLUENT_DOCKER_TAG"=7.3.0 >> .env
echo "DC"=${dc} >> .env.dev

# Generate html file for the hosted instructions
cd ~/.workshop/docker/asciidoc
asciidoctor index.adoc -o index.html -a stylesheet=stylesheet.css -a externalip=${ext_ip} -a dc=${dc} -a imagesdir=./images
asciidoctor kafka-connect-workshop.adoc -o kafka-connect-workshop.html -a stylesheet=stylesheet.css -a externalip=${ext_ip} -a dc=${dc}  -a imagesdir=./images

# Inject c&p functionality into rendered html file.
sed -i -e '/<title>/r clipboard.html' kafka-connect-workshop.html

# Creating empty folder to host aws configs later
mkdir ~/.workshop/docker/.aws

# startup the containers
cd ~/.workshop/docker/
docker-compose up -d

