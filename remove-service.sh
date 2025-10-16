#!/bin/bash

folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')

systemctl stop $folder
systemctl disable $folder
rm /etc/systemd/system/$folder.service 
