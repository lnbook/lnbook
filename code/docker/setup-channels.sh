#!/bin/bash

echo Getting node IDs
alice_address=$(docker-compose exec -T Alice bash -c "lncli -n regtest getinfo | jq -r .identity_pubkey")
bob_address=$(docker-compose exec -T Bob bash -c "lightning-cli getinfo | jq -r .id")
wei_address=$(docker-compose exec -T Wei bash -c "eclair-cli -s -j -p eclair getinfo| jq -r .nodeId")
gloria_address=$(docker-compose exec -T Gloria bash -c "lncli -n regtest getinfo | jq -r .identity_pubkey")

# Let's tell everyone what we found!
echo Alice:  ${alice_address}
echo Bob:    ${bob_address}
echo Wei:    ${wei_address}
echo Gloria: ${gloria_address}

echo Setting up channels...
echo Alice to Bob
docker-compose exec -T Alice lncli -n regtest connect ${bob_address}@Bob
docker-compose exec -T Alice lncli -n regtest openchannel ${bob_address} 1000000

echo Bob to Chan
docker-compose exec -T Bob lightning-cli connect ${wei_address}@Chan
docker-compose exec -T Bob lightning-cli fundchannel ${wei_address} 1000000

echo Chan to Dina
docker-compose exec -T Chan eclair-cli -p eclair connect --uri=${gloria_address}@Dina
docker-compose exec -T Chan eclair-cli -p eclair open --nodeId=${gloria_address} --fundingSatoshis=1000000

echo Get 10k sats invoice from Gloria
gloria_invoice=$(docker-compose exec -T Gloria bash -c "lncli -n regtest addinvoice 10000 | jq -r .payment_request")

echo Gloria invoice ${gloria_invoice}

echo Wait for channel establishment - 60 seconds for 6 blocks
sleep 60

echo Alice pays Dina 10k sats, routed around the network
docker-compose exec -T Alice lncli -n regtest payinvoice --json --inflight_updates -f ${gloria_invoice}
