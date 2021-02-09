#!/bin/bash

echo pay in a loop

start=$(date +"%T")

for i in {1..2}
do	
	echo A pays B
	INV=$(docker-compose exec -T Bb bash -c "lightning-cli invoice 10000sat inva{$i} desc | jq -r .bolt11")
	docker-compose exec -T Aa bash -c "lightning-cli pay $INV"                         
                                                                                                 
	echo B pays C                                                                            
	INV=$(docker-compose exec -T Cc bash -c "lightning-cli invoice 10000sat invb{$i} desc | jq -r .bolt11")
	docker-compose exec -T Bb bash -c "lightning-cli pay $INV"                         
                                                                                                 
	echo C pays D                                                                            
	INV=$(docker-compose exec -T Dd bash -c "lightning-cli invoice 10000sat invc{$i} desc | jq -r .bolt11")
	docker-compose exec -T Cc bash -c "lightning-cli pay $INV"                         
                                                                                                 
	echo D pays E                                                                            
	INV=$(docker-compose exec -T Ee bash -c "lightning-cli invoice 10000sat invd{$i} desc | jq -r .bolt11")
	docker-compose exec -T Dd bash -c "lightning-cli pay $INV"                        
                                                                                                
	echo E pays F                                                                           
	INV=$(docker-compose exec -T Ff bash -c "lightning-cli invoice 10000sat inve{$i} desc | jq -r .bolt11")
	docker-compose exec -T Ee bash -c "lightning-cli pay $INV"

	echo F pays A                                                                           
	INV=$(docker-compose exec -T Aa bash -c "lightning-cli invoice 10000sat invf{$i} desc | jq -r .bolt11")
	docker-compose exec -T Ff bash -c "lightning-cli pay $INV"
done
stop=$(date +"%T")

echo time to finish
echo start $start
echo stop  $stop
