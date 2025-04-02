#!/bin/bash

# To run a different chaincode, give the reative path of the chaincode.
CHAINCODE_PATH=${PWD}/asset-transfer-basic/chaincode-java/
CHAINCODE_LANG=java
CHAINCODE_NAME=basic

# To run JavaScript chaincode
# CHAINCODE_PATH=${PWD}/asset-transfer-basic/chaincode-javascript/
# CHAINCODE_LANG=node
# CHAINCODE_NAME=basic


echo "------------Register the ca admin for Org1----------------"

docker compose -f docker/docker-compose-ca-org3.yaml up -d
sleep 3

sudo chmod -R 777 organizations/

echo "------------Register and enroll the users for Org3—-----------"

chmod +x registerEnrollOrg3.sh

./registerEnrollOrg3.sh
sleep 2

echo "—-------------Bring up Org3—-----------------"

docker compose -f docker/docker-compose-org3.yaml up -d
sleep 2

echo "-------------Generate the configuration for Org3—-------------------------------"

export FABRIC_CFG_PATH=$PWD/configOrg3

configtxgen -printOrg Org3MSP > organizations/peerOrganizations/org3.ai.com/org3.json
sleep 1

export FABRIC_CFG_PATH=${PWD}/peercfg
export CHANNEL_NAME=belchannel
export CORE_PEER_LOCALMSPID=BelMSP
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/bel.ai.com/peers/peer0.bel.ai.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bel.ai.com/users/Admin@bel.ai.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/ai.com/orderers/orderer.ai.com/msp/tlscacerts/tlsca.ai.com-cert.pem


echo "Fetch the latest config block"

peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.ai.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

## Convert the Configuration to JSON and Trim It Down

cd channel-artifacts


configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

jq ".data.data[0].payload.data.config" config_block.json > config.json

jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ../organizations/peerOrganizations/org3.ai.com/org3.json > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org3_update.pb

configtxlator proto_decode --input org3_update.pb --type common.ConfigUpdate --output org3_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json

configtxlator proto_encode --input org3_update_in_envelope.json --type common.Envelope --output org3_update_in_envelope.pb


echo "Sign and Submit the Config Update"

cd ..

peer channel signconfigtx -f channel-artifacts/org3_update_in_envelope.pb
sleep 1

export CORE_PEER_LOCALMSPID=Org1MSP 
export CORE_PEER_ADDRESS=localhost:8051 
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer0.org1.ai.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.ai.com/users/Admin@org1.ai.com/msp

peer channel update -f channel-artifacts/org3_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.ai.com --tls --cafile $ORDERER_CA
sleep 1


export CORE_PEER_LOCALMSPID=Org3MSP 
export CORE_PEER_ADDRESS=localhost:11051 
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.ai.com/peers/peer0.org3.ai.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.ai.com/users/Admin@org3.ai.com/msp

peer channel fetch 0 channel-artifacts/$CHANNEL_NAME.block -o localhost:7050 --ordererTLSHostnameOverride orderer.ai.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
sleep 2

echo "Join Org3 to the Channel"

peer channel join -b channel-artifacts/$CHANNEL_NAME.block
sleep 2

peer channel list


echo "—-------------Org3 anchor peer update—-----------"

peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.ai.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
sleep 1

cd channel-artifacts

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

jq ".data.data[0].payload.data.config" config_block.json > config.json

jq '.channel_group.groups.Application.groups.Org3MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org3.ai.com","port": 11051}]},"version": "0"}}' config.json > modified_anchor_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input modified_anchor_config.json --type common.Config --output modified_anchor_config.pb

configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_anchor_config.pb --output anchor_update.pb

configtxlator proto_decode --input anchor_update.pb --type common.ConfigUpdate --output anchor_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat anchor_update.json)'}}}' | jq . > anchor_update_in_envelope.json

configtxlator proto_encode --input anchor_update_in_envelope.json --type common.Envelope --output anchor_update_in_envelope.pb

cd ..

peer channel update -f ${PWD}/channel-artifacts/anchor_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050  --ordererTLSHostnameOverride orderer.ai.com --tls --cafile $ORDERER_CA
sleep 1


echo "—---------------install chaincode in Org3 peer—-------------"

peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz
sleep 3

peer lifecycle chaincode queryinstalled
sleep 1

export CC_PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CHAINCODE_NAME}.tar.gz)
sleep 1

echo "—---------------Approve chaincode in Org3 peer—-------------"

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.ai.com --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
sleep 1


