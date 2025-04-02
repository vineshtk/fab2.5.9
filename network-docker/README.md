# Hyperledger Fabric Network (Version 2.5.9)

The `network-docker` provides a Docker Compose based  network with three Organization peers and an ordering service node. The Hyperledger Fabric network can be set up on a local machine, and the chaincode can be deployed and tested.

## Install the pre-requisites 

Note: If any of the following dependencies are available on your laptop, then no need to install it.

### cURL
Install curl using the command
```bash
sudo apt install curl -y
```

```bash
curl -V
```

### Download Hyperledger Fabric v2.5.9

Download the script to install the fabric binaries, fabric images and fabric samples
``` bash
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
```
Install the fabric version 2.5.9 and ca version 1.5.12

``` bash
./install-fabric.sh -f 2.5.9 -c 1.5.12
```
Copy the fabric binaries to usr/local/bin to use it in the whole system.

``` bash
sudo cp fabric-samples/bin/* /usr/local/bin
```


### Docker

Download the script
```bash
curl -fsSL https://get.docker.com -o install-docker.sh
```A command
Run the script either as root, or using sudo to perform the installation.
```bash
sudo sh install-docker.sh
```
To manage Docker as a non-root user
```bash
sudo chmod 777 /var/run/docker.sock
```

``` bash
sudo usermod -aG docker $USER
```

To verify the installtion enter the following commands


```bash
docker compose version
```

```bash
docker -v
```

Execute the following command to check whether we can execute docker commands without sudo

```bash
docker ps -a
```

### JQ
Install JQ using the following command
```bash
sudo apt install jq -y
```

To verify the installtion enter the following command


```bash
jq --version
```

### Build Essential
Install Build Essential uisng the commnad
```bash
sudo apt install build-essential -y
```
To verify the installtion enter the following command


```bash
dpkg -l | grep build-essential
```

### Java

Note: Java is needed to run Java chaincode.

```bash
sudo apt install openjdk-21-jdk
```
```bash
java --version
```

### NVM

Install NVM (Node Version Manager), open a terminal and execute the following command.
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```
Close the current terminal and open a new one.

In the new terminal execute this command to verify nvm has been installed

```bash
nvm -v
```

### NodeJS (Ver 22.x)

Note: NodeJS is needed to run JavaScript chaincode.

Execute the following command to install NodeJs
```bash
nvm install 22
```  

Check  the version of nodeJS installed
```bash
node -v
```

Check  the version of npm installed
```bash
npm -v
```
Thus we completed the intallation of all dependencies to run Hyperledger Fabric.

## Build the network using `startNetwork.sh` script

A script file `startNetwork.sh` is provided to build the network and deploy the `asset-transfer-basic`  `java` chaincode. If you want to run another chaincode, change  the `CHAINCODE_PATH`, `CHAINCODE_LANG`, and `CHAINCODE_NAME` variables at the beginning of the `startNetwork.sh` script file.

Execute the following commands to build the network and deploy the chaincode :

Navigate to `network-docker` directory
```bash
cd network-docker
```

Give execute permission to script file
```bash
chmod +x startNetwork.sh
```

Execute the script file. Enter the password of the system, when prompted
```bash
./startNetwork.sh
```

### Invoke the chaincode

Execute the following commands to run the chaincode.


Set the environment variables
```bash
export CHANNEL_NAME=belchannel
export FABRIC_CFG_PATH=./peercfg
export CORE_PEER_LOCALMSPID=BelMSP
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/bel.ai.com/peers/peer0.bel.ai.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bel.ai.com/users/Admin@bel.ai.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/ai.com/orderers/orderer.ai.com/msp/tlscacerts/tlsca.ai.com-cert.pem
export BEL_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/bel.ai.com/peers/peer0.bel.ai.com/tls/ca.crt
export ORG1_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer0.org1.ai.com/tls/ca.crt
export ORG2_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/org2.ai.com/peers/peer0.org2.ai.com/tls/ca.crt
```

Invoke the `InitLedger` transaction
```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.ai.com --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n basic --peerAddresses localhost:7051 --tlsRootCertFiles $BEL_PEER_TLSROOTCERT --peerAddresses localhost:8051 --tlsRootCertFiles $ORG1_PEER_TLSROOTCERT --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_PEER_TLSROOTCERT -c '{"function":"InitLedger","Args":[]}'
```

Query the ledger with `GetAllAssets` function
```bash
peer chaincode query -C $CHANNEL_NAME -n basic -c '{"Args":["GetAllAssets"]}'
```

### Stop the network

Execute the `stopNetwork.sh` script to stop the network.

```bash
chmod +x stopNetwork.sh
```

```bash
./stopNetwork.sh
```
