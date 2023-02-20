#!/bin/sh
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release tilix mc htop vim build-essential

sudo mkdir -m 0755 -p /etc/apt/keyrings

test -f "/etc/apt/keyrings/docker.gpg" || curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
