## Add a new peer to an existing organization 

The steps that needs to be followed to add a new peer named `peer1` to `Org1` is given below.

**Note**: Make sure you have a working network (belnetwork) with all the certificates generated, and the containers are up and running. Also, ensure that the chaincode is deployed successfully. If the network is not up and running then execute `./startNetwork.sh`.

Execute all the commands from `network-docker`

```bash
cd network-docker
```

### Register and enroll new peer

The commands to register and enroll new peer is given in the `registerEnrollPeer1Org1.sh` file. Run this script file to register and enroll `peer1` under `Org1`.

Give execute permission to script file.
```bash
chmod +x registerEnrollPeer1Org1.sh
```

Execute the script file. 
```bash
./registerEnrollPeer1Org1.sh
```
### Build docker-compose for new peer and run it

The `docker-compose-peer1org1.yaml` is used to run the new peer.


```bash
docker compose -f docker/docker-compose-peer1org1.yaml up -d
```


### Set the environment variables

```bash
export FABRIC_CFG_PATH=./peercfg
export CHANNEL_NAME=belchannel
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.ai.com/users/Admin@org1.ai.com/msp
export CORE_PEER_ADDRESS=localhost:10051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/ai.com/orderers/orderer.ai.com/msp/tlscacerts/tlsca.ai.com-cert.pem
export BEL_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/bel.ai.com/peers/peer0.bel.ai.com/tls/ca.crt
export ORG1_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/tls/ca.crt
export ORG2_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/org2.ai.com/peers/peer0.org2.ai.com/tls/ca.crt
```

### Join the new peer to channel

```bash
peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
```

### List the channels

```bash
peer channel list
```

### Install chaincode

```bash
peer lifecycle chaincode install basic.tar.gz
```

```bash
peer lifecycle chaincode queryinstalled
```

### Invoke

Invoke the `CreateAsset` transaction.
```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.ai.com --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n basic --peerAddresses localhost:7051 --tlsRootCertFiles $BEL_PEER_TLSROOTCERT --peerAddresses localhost:10051 --tlsRootCertFiles $ORG1_PEER_TLSROOTCERT --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_PEER_TLSROOTCERT -c '{"function":"CreateAsset","Args":["asset8", "white", "15", "Ben", "600"]}'
```
### Query

Query the ledger with `ReadAsset` function
```bash
peer chaincode query -C $CHANNEL_NAME -n basic -c '{"Args":["ReadAsset", "asset8"]}'
```