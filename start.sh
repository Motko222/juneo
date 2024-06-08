#!/bin/bash

sudo systemctl restart juneod.service
sudo journalctl -u juneod.service -f --no-hostname -o cat
