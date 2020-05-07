#!/bin/bash

### START docker, docker-compose, jq
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
sudo apt-get update 
sudo apt-get install -y docker-ce
sudo apt-get install -y docker-compose
sudo service docker restart
sudo docker --version
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install -y jq
sudo apt-get install -y nginx
### docker, docker-compose, jq, nginx END
