#!/bin/bash

#
# Helper functions
#


# run-in-node: Run a command inside a docker container, using the bash shell
function run-in-node () {
	docker exec "$1" /bin/bash -c "${@:2}"
}

# wait-for-cmd: Run a command repeatedly until it completes/exits successfuly
function wait-for-cmd () {
		until "${@}" > /dev/null 2>&1
		do
			echo -n "."
			sleep 1
		done
		echo
}

# wait-for-node: Run a command repeatedly until it completes successfully, inside a container
# Combining wait-for-cmd and run-in-node
function wait-for-node () {
	wait-for-cmd run-in-node $1 "${@:2}"
}


# Start the demo
echo "Starting Payment Demo"

echo "======================================================"
echo
echo "Waiting for nodes to startup"
echo -n "- Waiting for bitcoind startup..."
wait-for-node bitcoind "cli getblockchaininfo | jq -e \".blocks > 101\""
echo -n "- Waiting for bitcoind mining..."
wait-for-node bitcoind "cli getbalance | jq -e \". > 50\""
echo -n "- Waiting for Alice startup..."
wait-for-node Alice "cli getinfo"
echo -n "- Waiting for Bob startup..."
wait-for-node Bob "cli getinfo"
echo -n "- Waiting for Chan startup..."
wait-for-node Chan "cli getinfo"
echo -n "- Waiting for Dina startup..."
wait-for-node Dina "cli getinfo"
echo "All nodes have started"

echo "======================================================"
echo
echo "Getting node IDs"
alice_address=$(run-in-node Alice "cli getinfo | jq -r .identity_pubkey")
bob_address=$(run-in-node Bob "cli getinfo | jq -r .id")
chan_address=$(run-in-node Chan "cli getinfo| jq -r .nodeId")
dina_address=$(run-in-node Dina "cli getinfo | jq -r .identity_pubkey")

# Show node IDs
echo "- Alice:  ${alice_address}"
echo "- Bob:    ${bob_address}"
echo "- Chan:   ${chan_address}"
echo "- Dina:	${dina_address}"

echo "======================================================"
echo
echo "Waiting for Lightning nodes to sync the blockchain"
echo -n "- Waiting for Alice chain sync..."
wait-for-node Alice "cli getinfo | jq -e \".synced_to_chain == true\""
echo -n "- Waiting for Bob chain sync..."
wait-for-node Bob "cli getinfo | jq -e \".blockheight > 100\""
echo -n "- Waiting for Chan chain sync..."
wait-for-node Chan "cli getinfo | jq -e \".blockHeight > 100\""
echo -n "- Waiting for Dina chain sync..."
wait-for-node Dina "cli getinfo | jq -e \".synced_to_chain == true\""
echo "All nodes synched to chain"

echo "======================================================"
echo
echo "Setting up connections and channels"
echo "- Alice to Bob"

# Connect only if not already connected
run-in-node Alice "cli listpeers | jq -e '.peers[] | select(.pub_key == \"${bob_address}\")' > /dev/null" \
&& {
	echo "- Alice already connected to Bob"
} || {
	echo "- Open connection from Alice node to Bob's node"
	wait-for-node Alice "cli connect ${bob_address}@Bob"
}

# Create channel only if not already created
run-in-node Alice "cli listchannels | jq -e '.channels[] | select(.remote_pubkey == \"${bob_address}\")' > /dev/null" \
&& {
	echo "- Alice->Bob channel already exists"
} || {
	echo "- Create payment channel Alice->Bob"
	wait-for-node Alice "cli openchannel ${bob_address} 1000000"
}
echo "Bob to Chan"
run-in-node Bob "cli listpeers | jq -e '.peers[] | select(.id == \"${chan_address}\")' > /dev/null" \
&& {
	echo "- Bob already connected to Chan"
} || {
	echo "- Open connection from Bob's node to Chan's node"
	wait-for-node Bob "cli connect ${chan_address}@Chan"
}
run-in-node Bob "cli listchannels | jq -e '.channels[] | select(.destination == \"${chan_address}\")' > /dev/null" \
&& {
	echo "- Bob->Chan channel already exists"
} || {
	echo "- Create payment channel Bob->Chan"
	wait-for-node Bob "cli fundchannel ${chan_address} 1000000"
}
echo "Chan to Dina"
run-in-node Chan "cli peers | jq -e '.[] | select(.nodeId == \"${dina_address}\" and .state == \"CONNECTED\")' > /dev/null" \
&& {
	echo "- Chan already connected to Dina"
} || {
	echo "- Open connection from Chan's node to Dina's node"
	wait-for-node Chan "cli connect --uri=${dina_address}@Dina"
}
run-in-node Chan "cli channels | jq -e '.[] | select(.nodeId == \"${dina_address}\" and .state == \"NORMAL\")' > /dev/null" \
&& {
	echo "- Chan->Dina channel already exists"
} || {
	echo "- Create payment channel Chan->Dina"
	wait-for-node Chan "cli open --nodeId=${dina_address} --fundingSatoshis=1000000"
}
echo "All channels created"
echo "======================================================"
echo
echo "Waiting for channels to be confirmed on the blockchain"
echo -n "- Waiting for Alice channel confirmation..."
wait-for-node Alice "cli listchannels | jq -e '.channels[] | select(.remote_pubkey == \"${bob_address}\" and .active == true)'"
echo "- Alice->Bob connected"
echo -n "- Waiting for Bob channel confirmation..."
wait-for-node Bob "cli listchannels | jq -e '.channels[] | select(.destination == \"${chan_address}\" and .active == true)'"
echo "- Bob->Chan connected"
echo -n "- Waiting for Chan channel confirmation..."
wait-for-node Chan "cli channels | jq -e '.[] | select (.nodeId == \"${dina_address}\" and .state == \"NORMAL\")' > /dev/null"
echo "- Chan->Dina connected"
echo "All channels confirmed"


echo "======================================================"
echo -n "Check Alice's route to Dina: "
run-in-node Alice "cli queryroutes --dest \"${dina_address}\" --amt 10000" > /dev/null 2>&1 \
&& {
	echo "Alice has a route to Dina"
} || {
	echo "Alice doesn't yet have a route to Dina"
	echo "Waiting for Alice graph sync. This may take a while..."
	wait-for-node Alice "cli describegraph | jq -e '.edges | select(length >= 1)'"
	echo "- Alice knows about 1 channel"
	wait-for-node Alice "cli describegraph | jq -e '.edges | select(length >= 2)'"
	echo "- Alice knows about 2 channels"
	wait-for-node Alice "cli describegraph | jq -e '.edges | select(length == 3)'"
	echo "- Alice knows about all 3 channels!"
	echo "Alice knows about all the channels"
}

echo "======================================================"
echo
echo "Get 10k sats invoice from Dina"
dina_invoice=$(run-in-node Dina "cli addinvoice 10000 | jq -r .payment_request")
echo "- Dina invoice: "
echo ${dina_invoice}

echo "======================================================"
echo
echo "Attempting payment from Alice to Dina"
run-in-node Alice "cli payinvoice --json --force ${dina_invoice} | jq -e '.failure_reason == \"FAILURE_REASON_NONE\"'" > /dev/null && {
	echo "Successful payment!"
} ||
{
	echo "Payment failed"
}
