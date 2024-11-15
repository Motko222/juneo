#!/bin/bash
folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')

sudo systemctl restart $folder.service
sleep 5s
sudo journalctl -u $folder.service -f --no-hostname -o cat
