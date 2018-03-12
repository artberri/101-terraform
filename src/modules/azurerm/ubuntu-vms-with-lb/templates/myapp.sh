#!/bin/bash
export HOME=/root
apt-get update
apt-get upgrade -y
apt-get install -y wget curl build-essential libssl-dev git unattended-upgrades
cd /root
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.4/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 6.11.3
npm install pm2 -g
git clone https://github.com/heroku/node-js-sample.git
cd node-js-sample
npm install
pm2 start index.js
