HOME=$PWD'/.near/localnet_multi'
SHARDS_COUNT=3
GENESIS_VALIDATORS_COUNT=2
NETWORK_PORT=24567
RPC_PORT=3030

echo "Killing previous validators instances..."
kill $(ps aux | grep 'neard' | grep 'localnet_multi' | awk '{print $2}')

# Wait for node sync port to be free
while nc -z localhost $NETWORK_PORT; do
  sleep 0.1
done

if [ -d "$HOME" ];
then
  echo "Clearing previous state..."
  rm -rf $HOME
fi

echo "Starting blockchain in: $HOME"

trim_json() {
    data=$(echo "$1" | tr -d '[:blank:]' | tr -d '\r\n')
    echo "$data"
}

read_json() {
    data=`cat $1`
    data=$(trim_json "$data")
    echo "$data"
}

neard --home $HOME localnet --shards $SHARDS_COUNT --v $GENESIS_VALIDATORS_COUNT

NODE0_KEY_JSON=$(read_json "$HOME"'/node0/node_key.json')
NODE0_PUBLIC_KEY=$(echo $NODE0_KEY_JSON | jq -r '.public_key')

neard --home $HOME'/node0' run > $HOME'/node0.log' 2>&1 &

# Wait for node to be listening on sync port
while ! nc -z localhost $NETWORK_PORT; do
  sleep 0.1
done

CURRENT_NETWORK_PORT=NETWORK_PORT
for (( i=1; i<$GENESIS_VALIDATORS_COUNT; i++ ))
do
  CURRENT_NETWORK_PORT=$(($CURRENT_NETWORK_PORT+1))
  RPC_PORT=$(($RPC_PORT+1))
  neard --home $HOME'/node'$i run --boot-nodes $NODE0_PUBLIC_KEY@127.0.0.1:$NETWORK_PORT --network-addr='127.0.0.1:'$CURRENT_NETWORK_PORT --rpc-addr='127.0.0.1:'$RPC_PORT > $HOME'/node'$i'.log' 2>&1 &
done

# alias localnet_near='NEAR_ENV="local" NEAR_CLI_LOCALNET_NETWORK_ID="localnet" NEAR_NODE_URL="http://127.0.0.1:3030" NEAR_CLI_LOCALNET_KEY_PATH="/home/avalkov/.near/node0/validator_key.json" near'

# Deploy contracts
