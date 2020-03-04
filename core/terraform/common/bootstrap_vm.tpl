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
curl -L https://download.docker.com/linux/static/stable/x86_64/docker-19.03.4.tgz -o docker.tgz
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
sudo chmod +wx /usr/local/bin/
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

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
echo "echo \"  _           _    _                                    \"" >> ~/.bashrc
echo "echo \" | |_  ___   | |_ | |__    ___                          \"" >> ~/.bashrc
echo "echo \" | __|/ _ \  | __|| '_ \  / _ \                         \"" >> ~/.bashrc
echo "echo \" | |_| (_) | | |_ | | | ||  __/                         \"" >> ~/.bashrc
echo "echo \"  \__|\___/   \__||_| |_| \___|                         \"" >> ~/.bashrc
echo "echo \" __        __            _          _                   \"" >> ~/.bashrc
echo "echo \" \ \      / /___   _ __ | | __ ___ | |__    ___   _ __  \"" >> ~/.bashrc
echo "echo \"  \ \ /\ / // _ \ | '__|| |/ // __|| '_ \  / _ \ | '_ \ \"" >> ~/.bashrc
echo "echo \"   \ V  V /| (_) || |   |   < \__ \| | | || (_) || |_) |\"" >> ~/.bashrc
echo "echo \"    \_/\_/  \___/ |_|   |_|\_\|___/|_| |_| \___/ | .__/ \"" >> ~/.bashrc
echo "echo \"                                                 |_|    \"" >> ~/.bashrc
echo "echo \"\"" >> ~/.bashrc
echo "echo \"\"" >> ~/.bashrc
echo "echo \"\"" >> ~/.bashrc
