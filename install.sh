#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y
sudo apt install git docker.io docker-compose -y
cd ~
rm -r juneogo-binaries
git clone https://github.com/Juneo-io/juneogo-binaries
chmod +x ~/juneogo-binaries/juneogo
chmod +x ~/juneogo-binaries/plugins/jevm
chmod +x ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e
mkdir -p ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/jevm ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e ~/.juneogo/plugins
mkdir ~/juneogo
cp ~/juneogo-binaries/juneogo ~/juneogo

tee /etc/systemd/system/juneod.service > /dev/null <<EOF 
[Unit]
Description=juneo node
After=network.target

[Service]
User=root
Type=simple
ExecStart=/root/juneogo/juneogo --config-file="~/juneogo/config.json"
Restart=on-failure
RestartSec=60
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable juneod
