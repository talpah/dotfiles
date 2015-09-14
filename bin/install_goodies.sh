#!/bin/bash
if [ ! -e /usr/lib/apt/methods/https ]; then
	sudo apt-get update
	sudo apt-get install -y apt-transport-https
fi

curl -sSL https://get.docker.com/ | sh
sudo pip install docker-compose
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo service docker start

sudo apt-get install -y \
dos2unix \
mc \
htop \
vim \
build-essential \
libmysqlclient-dev \
git-flow

sudo wget -O /etc/bash_completion.d/git-flow-completion.bash "https://raw.githubusercontent.com/bobthecow/git-flow-completion/master/git-flow-completion.bash"
