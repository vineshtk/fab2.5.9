## Add new organization to the network

A script file `addOrg3.sh` is provided to add new organization `Org3` to the channel and install the `asset-transfer-basic`  `java` chaincode. 

**Note**: Make sure you have a working network (belnetwork) with all the certificates generated, and the containers are up and running. Also, ensure that the chaincode is deployed successfully. If the network is not up and running then execute `./startNetwork.sh`.

Execute all the commands from `network-docker`

```bash
cd network-docker
```

Give execute permission to script file
```bash
chmod +x addOrg3.sh
```

Execute the script file. Enter the password of the system, when prompted
```bash
./addOrg3.sh
```

### Invoke the chaincode

Execute the following commands to invoke the chaincode from Org3.


Set the environment variables
```bash
export CHANNEL_NAME=belchannel
export FABRIC_CFG_PATH=./peercfg
export CORE_PEER_LOCALMSPID=Org3MSP
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.ai.com/peers/peer0.org3.ai.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.ai.com/users/Admin@org3.ai.com/msp
export CORE_PEER_ADDRESS=localhost:11051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/ai.com/orderers/orderer.ai.com/msp/tlscacerts/tlsca.ai.com-cert.pem
export BEL_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/bel.ai.com/peers/peer0.bel.ai.com/tls/ca.crt
export ORG1_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer0.org1.ai.com/tls/ca.crt
export ORG2_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/org2.ai.com/peers/peer0.org2.ai.com/tls/ca.crt
export ORG3_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/org3.ai.com/peers/peer0.org3.ai.com/tls/ca.crt

```

Invoke the `CreateAsset` transaction

```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.ai.com --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n basic --peerAddresses localhost:7051 --tlsRootCertFiles $BEL_PEER_TLSROOTCERT --peerAddresses localhost:8051 --tlsRootCertFiles $ORG1_PEER_TLSROOTCERT --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_PEER_TLSROOTCERT -c '{"function":"CreateAsset","Args":["asset9", "red", "15", "Jack", "700"]}'
```

Query the ledger with `ReadAsset` function
```bash
peer chaincode query -C $CHANNEL_NAME -n basic -c '{"Args":["ReadAsset", "asset9"]}'
```