#!/bin/bash

apt-get update
apt-get install git -y
apt-get install jq -y
apt-get install asciidoctor -y
apt-get install \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common -y
cd /usr/share/nginx/html
asciidoctor index.adoc -o index.html -a stylesheet=stylesheet.css -a externalip=localhost -a dc=${DC} -a pass=${PASS}  -a imagesdir=./images
asciidoctor kafka-connect-workshop.adoc -o kafka-connect-workshop.html -a stylesheet=stylesheet.css -a externalip=localhost -a dc=${DC} -a pass=${PASS} -a imagesdir=./images
sed -i -e '/<title>/r clipboard.html' kafka-connect-workshop.html

