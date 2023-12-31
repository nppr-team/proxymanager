#!/bin/bash

mkdir /proxy

apt update

apt upgrade -y

apt install -y curl gpg

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io


curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

systemctl stop rsyslog

systemctl stop syslog.socket

systemctl disable syslog.socket

systemctl disable rsyslog

cat > /proxy/docker-compose.yml << EOL

version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    environment:
#      - DB_SQLITE_FILE='/data/database.sqlite'
      - DISABLE_IPV6='false'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOL




cd /proxy/

docker-compose up -d
