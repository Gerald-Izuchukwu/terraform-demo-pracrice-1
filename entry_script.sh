#!/bin/bash

sudo yum update -y

sudo yum install -y docker

# sudo yum remove docker-compose-plugin  
# sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo yum install docker-ce-cli-plugin-docker-compose


sudo systemctl start docker

sudo usermod -aG docker $USER

sudo chmod +x docker_pull_script.sh

sudo ./docker_pull_script.sh