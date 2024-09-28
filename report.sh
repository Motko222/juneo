#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

service=$(sudo systemctl status juneod --no-pager | grep -a "active (running)" | wc -l)
type="validator"
network="mainnet"
host=$(cat ~/juneogo/config.json | jq -r '."http-host"')
chain=$(curl -sX POST --data '{ "jsonrpc":"2.0", "id" :1, "method" :"info.getNetworkName" }' -H 'content-type:application/json;' $host:9650/ext/info | jq -r .result.networkName)
is_bootstrapped=$(curl -sX POST --data '{ "jsonrpc": "2.0", "id":1, "method":"info.isBootstrapped", "params": {"chain" : "JUNE" } }' \
   -H 'content-type: application/json; ' $host:9650/ext/info | jq .result.isBootstrapped)
status_json=$(curl -sX POST --data '{ "jsonrpc":"2.0", "id" :1, "method" :"info.getNodeID" }' -H 'content-type:application/json' $host:9650/ext/info)
node_id=$(echo $status_json | jq -r .result.nodeID)
public_key=$(echo $status_json | jq -r .result.nodePOP.publicKey)
proof_of_possession=$(echo $status_json | jq -r .result.nodePOP.proofOfPossession)
version=$(cat ~/.juneogo/logs/main.log | grep -a "initializing node" | tail -1 | awk -F "initializing node " '{print $NF}' | jq -r .version | awk -F "/" '{print $NF}')

if [ $service -ne 1 ]
then 
  status="error";
  message="service not running"
elif $is_bootstrapped
  then 
   status="ok"
  else
   status="warning"
   message="not bootstrapped"
fi

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
         "id":"$folder",
         "machine":"$MACHINE",
         "grp":"node",
         "owner":"$OWNER"
  },
  "fields": {
        "network":"$network",
        "chain":"$chain",
        "version":"$version",
        "status":"$status",
        "message":"$message",
        "service":$service,
        "is_bootstrapped":"$is_bootstrapped",
        "node_id":"$node_id",
        "public_key":"$public_key",
        "proof_of_possession":"$proof_of_possession"
  }
}
EOF

cat $json | jq
