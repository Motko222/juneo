#!/bin/bash

sudo journalctl -u juneod.service -f --no-hostname -o cat
