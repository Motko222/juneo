#!/bin/bash

source ~/.bash_profile

service=$(sudo systemctl status juneod --no-pager | grep "active (running)" | wc -l)
pid=$(pidof /root/juneogo-binaries/juneogo)
type="validator"
network="mainnet"
host=$(cat ~/juneogo/config.json | jq -r '."http-host"')
chain=$(curl -sX POST --data '{ "jsonrpc":"2.0", "id" :1, "method" :"info.getNetworkName" }' -H 'content-type:application/json;' $host:9650/ext/info | jq -r .result.networkName)
id=$JUNEO_ID
group=node

is_bootstrapped=$(curl -sX POST --data '{ "jsonrpc": "2.0", "id":1, "method":"info.isBootstrapped", "params": {"chain" : "JUNE" } }' \
   -H 'content-type: application/json; ' 127.0.0.1:9650/ext/info | jq .result.isBootstrapped)
json=$(curl -sX POST --data '{ "jsonrpc":"2.0", "id" :1, "method" :"info.getNodeID" }' -H 'content-type:application/json' 127.0.0.1:9650/ext/info)
node_id=$(echo $json | jq -r .result.nodeID)
public_key=$(echo $json | jq -r .result.nodePOP.publicKey)
proof_of_possession=$(echo $json | jq -r .result.nodePOP.proofOfPossession)
version=$(cat ~/.juneogo/logs/main.log | grep "initializing node" | tail -1 | awk -F "initializing node " '{print $NF}' | jq -r .version | awk -F "/" '{print $NF}')

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

cat << EOF
{
  "id":"$id",
  "machine":"$MACHINE",
  "network":"$network"
  "chain":"$chain",
  "type":"node",
  "version":"$version",
  "status":"$status",
  "message":"$message",
  "service":$service,
  "pid":$pid,
  "is_bootstrapped":"$is_bootstrapped",
  "node_id":"$node_id",
  "public_key":"$public_key",
  "proof_of_possession":"$proof_of_possession",
  "updated":"$(date --utc +%FT%TZ)"
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,id=$id,machine=$MACHINE,grp=$group status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",network=\"$network\" $(date +%s%N) 
    "
fi
