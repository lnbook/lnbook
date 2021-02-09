#!/bin/bash

#docker-compose exec -T Aa lightning-cli getinfo
#docker-compose exec -T Bb lightning-cli getinfo
#docker-compose exec -T Cc lightning-cli getinfo
#docker-compose exec -T Ee lightning-cli getinfo
#docker-compose exec -T Dd lightning-cli getinfo
#docker-compose exec -T Ff lightning-cli getinfo

echo getting addresses
a=$(docker-compose exec -T Aa bash -c "lightning-cli newaddr | jq -r .bech32")
echo $a
b=$(docker-compose exec -T Bb bash -c "lightning-cli newaddr | jq -r .bech32")
echo $b
c=$(docker-compose exec -T Cc bash -c "lightning-cli newaddr | jq -r .bech32")
echo $c
d=$(docker-compose exec -T Dd bash -c "lightning-cli newaddr | jq -r .bech32")
echo $d
e=$(docker-compose exec -T Ee bash -c "lightning-cli newaddr | jq -r .bech32")
echo $e
f=$(docker-compose exec -T Ff bash -c "lightning-cli newaddr | jq -r .bech32")
echo $f

echo funding wallets
ba=$(docker-compose exec -T bitcoind bash -c "bitcoin-cli -regtest -rpcport=18443 -rpcuser=regtest -rpcpassword=regtest sendtoaddress $a 10")
echo $ba
bb=$(docker-compose exec -T bitcoind bash -c "bitcoin-cli -regtest -rpcport=18443 -rpcuser=regtest -rpcpassword=regtest sendtoaddress $b 10")
echo $bb
bc=$(docker-compose exec -T bitcoind bash -c "bitcoin-cli -regtest -rpcport=18443 -rpcuser=regtest -rpcpassword=regtest sendtoaddress $c 10")
echo $bc
bd=$(docker-compose exec -T bitcoind bash -c "bitcoin-cli -regtest -rpcport=18443 -rpcuser=regtest -rpcpassword=regtest sendtoaddress $d 10")
echo $bd
be=$(docker-compose exec -T bitcoind bash -c "bitcoin-cli -regtest -rpcport=18443 -rpcuser=regtest -rpcpassword=regtest sendtoaddress $e 10")
echo $be
bf=$(docker-compose exec -T bitcoind bash -c "bitcoin-cli -regtest -rpcport=18443 -rpcuser=regtest -rpcpassword=regtest sendtoaddress $f 10")
echo $bf
