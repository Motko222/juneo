#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')

tee /etc/systemd/system/$folder.service > /dev/null <<EOF 
[Unit]
Description=juneo node
After=network.target

[Service]
User=root
Type=simple
ExecStart=/root/juneogo/juneogo --config-file="/root/scripts/$folder/config.json"
Restart=on-failure
RestartSec=60
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable $folder
