#!/bin/bash
folder=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')

sudo systemctl stop $folder.service
