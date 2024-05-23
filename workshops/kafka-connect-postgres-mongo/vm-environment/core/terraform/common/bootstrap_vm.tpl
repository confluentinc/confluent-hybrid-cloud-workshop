#!/bin/bash

sudo apt-get update
sudo apt-get install openjdk-8-jdk -y
sudo apt-get install git -y
sudo apt-get install jq -y
sudo apt-get install ruby -y
sudo gem install asciidoctor
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y

echo "--- Installing Docker ---"
curl -L https://download.docker.com/linux/static/stable/x86_64/docker-26.0.0.tgz -o docker.tgz
sudo tar xvf docker.tgz -C /usr/bin --wildcards 'docker/*' --strip 1
rm docker.tgz
sudo groupadd docker
sudo usermod -aG docker ${dc}
sudo nohup dockerd >/dev/null 2>&1 &

echo "--- Creating C3 auth files ---"
mkdir /tmp/c3
echo "${dc}: ${participant_password},Administrators" > /tmp/c3/login.properties
echo "disallowed: no_access" >> /tmp/c3/login.properties
echo 'c3 { org.eclipse.jetty.jaas.spi.PropertyFileLoginModule required file="/tmp/c3/login.properties"; };' > /tmp/c3/propertyfile.jaas


echo "--- Installing Docker Compose ---"
DOCKER_CONFIG=$HOME/.docker
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

echo "--- Create workshop staging directory ---"
mkdir .workshop

echo "echo \"\"" >> ~/.bashrc
echo "echo \"\"" >> ~/.bashrc
echo "echo \"\"" >> ~/.bashrc
echo "echo \" __        __     _                                     \"" >> ~/.bashrc
echo "echo \" \ \      / /___ | |  ___  ___   _ __ ___    ___        \"" >> ~/.bashrc
echo "echo \"  \ \ /\ / // _ \| | / __|/ _ \ | '_ \\\` _ \  / _ \      \"" >> ~/.bashrc
echo "echo \"   \ V  V /|  __/| || (__| (_) || | | | | ||  __/       \"" >> ~/.bashrc
echo "echo \"    \_/\_/  \___||_| \___|\___/ |_| |_| |_| \___|       \"" >> ~/.bashrc
echo "echo \"\"" >> ~/.bashrc
echo "echo \"\"" >> ~/.bashrc
echo "echo \"\"" >> ~/.bashrc
