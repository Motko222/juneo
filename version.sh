#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')

host=$(cat ~/scripts/$folder/config.json | jq -r '."http-host"')

curl -sX POST --data '{ "jsonrpc":"2.0", "id" :1, "method" :"info.getNodeVersion" }' -H 'content-type:application/json;' $host:9650/ext/info | jq
