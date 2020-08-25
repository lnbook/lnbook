#!/bin/bash

echo Getting node IDs
alice_address=$(docker-compose exec -T Alice bash -c "lncli -n regtest getinfo | jq .identity_pubkey")
bob_address=$(docker-compose exec -T Bob bash -c "lightning-cli getinfo | jq .id")
wei_address=$(docker-compose exec -T Wei bash -c "eclair-cli -s -j -p eclair getinfo| jq .nodeId")
gloria_address=$(docker-compose exec -T Gloria bash -c "lncli -n regtest getinfo | jq .identity_pubkey")

# The jq command returns JSON strings enclosed in double-quote characters
# These will confuse the shell later, because double-quotes have special
# meaning in a bash script.

# We remove the double-quote character by using the shell string manipulation
# expression: // removes the " character. Even here, we have to escape the "
# character with a backslash because otherwise bash will interpret it as a
# string closure.
# A bit messy, but it works!
alice_address=${alice_address//\"}
bob_address=${bob_address//\"}
wei_address=${wei_address//\"}
gloria_address=${gloria_address//\"}

# Let's tell everyone what we found!
echo Alice: ${alice_address}
echo Bob: ${bob_address}
echo Wei: ${wei_address}
echo Gloria: ${gloria_address}

echo Setting up channels...
echo Alice to Bob
docker-compose exec -T Alice lncli -n regtest connect ${bob_address}@Bob
docker-compose exec -T Alice lncli -n regtest openchannel ${bob_address} 1000000

echo Bob to Wei
docker-compose exec -T Bob lightning-cli connect ${wei_address}@Wei
docker-compose exec -T Bob lightning-cli fundchannel ${wei_address} 1000000

echo Wei to Gloria
docker-compose exec -T Wei eclair-cli -p eclair connect --uri=${gloria_address}@Gloria
docker-compose exec -T Wei eclair-cli -p eclair open --nodeId=${gloria_address} --fundingSatoshis=1000000

echo Get 10k sats invoice from Gloria
gloria_invoice=$(docker-compose exec -T Gloria bash -c "lncli -n regtest addinvoice 10000 | jq .payment_request")

# Remove quotes
gloria_invoice=${gloria_invoice//\"}
echo Gloria invoice ${gloria_invoice}

echo Wait for channel establishment - 60 seconds for 6 blocks
sleep 60

echo Alice pays Gloria 10k sats, routed around the network
docker-compose exec -T Alice lncli -n regtest payinvoice --json --inflight_updates -f ${gloria_invoice}
