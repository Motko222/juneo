#!/bin/bash

source ~/.bash_profile

service=$(sudo systemctl status juneod --no-pager | grep "active (running)" | wc -l)
type="validator"
network="testnet"
chain="socotra"
id=juneo-$JUNEO_ID
bucket=node
is_bootstrapped=$(curl -sX POST --data '{ "jsonrpc": "2.0", "id":1, "method":"info.isBootstrapped", "params": {"chain" : "JUNE" } }' \
   -H 'content-type: application/json; ' 127.0.0.1:9650/ext/info | jq .result.isBootstrapped)

json=$(curl -sX POST --data '{ "jsonrpc":"2.0", "id" :1, "method" :"info.getNodeID" }' -H 'content-type:application/json' 127.0.0.1:9650/ext/info)
node_id=$(echo $json | jq -r .result.nodeID)

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
  "updated":"$(date --utc +%FT%TZ)"
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$bucket&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    status,node=$id,machine=$MACHINE status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",network=\"$network\",chain=\"$chain\" $(date +%s%N) 
    "
fi
