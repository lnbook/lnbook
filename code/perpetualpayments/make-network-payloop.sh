#!/bin/bash

#docker-compose up -d && bash make-network-payloop.sh
echo Wait for network to load for 180 sec
sleep 180

echo Funding all nodes
source fund-all-nodes.sh
sleep 60
echo Making topology
source make-topology.sh
sleep 60
echo Entering the payment loop
source payment-loop.sh

#docker-compose exec -T Aa lightning-cli 
#docker-compose exec -T Bb lightning-cli 
#docker-compose exec -T Cc lightning-cli 
#docker-compose exec -T Ee lightning-cli 
#docker-compose exec -T Dd lightning-cli 
#docker-compose exec -T Ff lightning-cli 

exit 0
