#!/bin/bash

echo Getting node IDs
a_ID=$(docker-compose exec -T Aa bash -c "lightning-cli getinfo | jq -r .id")
b_ID=$(docker-compose exec -T Bb bash -c "lightning-cli getinfo | jq -r .id")
c_ID=$(docker-compose exec -T Cc bash -c "lightning-cli getinfo | jq -r .id")
d_ID=$(docker-compose exec -T Dd bash -c "lightning-cli getinfo | jq -r .id")
e_ID=$(docker-compose exec -T Ee bash -c "lightning-cli getinfo | jq -r .id")
f_ID=$(docker-compose exec -T Ff bash -c "lightning-cli getinfo | jq -r .id")

# Let's tell everyone what we found!
#echo A ${a_ID}
#echo B ${b_ID}
#echo C ${c_ID}
#echo D ${d_ID}
#echo E ${e_ID}
#echo F ${f_ID}

echo Setting up channels...
echo A to B
docker-compose exec -T Aa lightning-cli connect ${b_ID}@Bb
docker-compose exec -T Aa lightning-cli -k fundchannel id=${b_ID} amount=1000000sat minconf=0
echo B to C
docker-compose exec -T Bb lightning-cli connect ${c_ID}@Cc
docker-compose exec -T Bb lightning-cli -k fundchannel id=${c_ID} amount=1000000sat minconf=0
echo C to D
docker-compose exec -T Cc lightning-cli connect ${d_ID}@Dd
docker-compose exec -T Cc lightning-cli -k fundchannel id=${d_ID} amount=1000000sat minconf=0
echo D to E
docker-compose exec -T Dd lightning-cli connect ${e_ID}@Ee
docker-compose exec -T Dd lightning-cli -k fundchannel id=${e_ID} amount=1000000sat minconf=0
echo E to F
docker-compose exec -T Ee lightning-cli connect ${f_ID}@Ff
docker-compose exec -T Ee lightning-cli -k fundchannel id=${f_ID} amount=1000000sat minconf=0
echo F to A
docker-compose exec -T Ff lightning-cli connect ${a_ID}@Aa
docker-compose exec -T Ff lightning-cli -k fundchannel id=${a_ID} amount=1000000sat minconf=0

