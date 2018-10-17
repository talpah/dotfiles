#!/bin/bash
if [ ! -e /usr/lib/apt/methods/https ]; then
	sudo apt-get update
	sudo apt-get install -y apt-transport-https
fi
sudo apt-get install python-pip python-yaml
sudo -H pip install -U pip
curl -sSL https://get.docker.com/ | sh
sudo pip install docker-compose
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo service docker start

sudo add-apt-repository -y ppa:webupd8team/terminix
sudo apt-get update

sudo apt-get install -y \
terminix \
dos2unix \
mc \
htop \
vim \
build-essential \
libmysqlclient-dev 

