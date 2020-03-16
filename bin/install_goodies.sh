#!/bin/bash
if [ ! -e /usr/lib/apt/methods/https ]; then
	sudo apt-get update
	sudo apt-get install -y apt-transport-https
fi
sudo apt-get install python-pip python-yaml
sudo -H pip install -U pip
curl -sSL https://get.docker.com/ | sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo service docker start

sudo add-apt-repository -y ppa:webupd8team/terminix
sudo apt-get update

sudo apt-get install -y \
tilix \
mc \
htop \
vim \
build-essential
