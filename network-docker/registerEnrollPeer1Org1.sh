#!/bin/bash

export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.ai.com/

echo "Registering peer1"

fabric-ca-client register --caname ca-org1 --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"

echo "Generating the peer1 msp"

fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"

cp "${PWD}/organizations/peerOrganizations/org1.ai.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/msp/config.yaml"

echo "Generating the peer1-tls certificates"

fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/tls" --enrollment.profile tls --csr.hosts peer1.org1.ai.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/org1/ca-cert.pem"

cp "${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/tls/ca.crt"

cp "${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/tls/server.crt"

cp "${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/org1.ai.com/peers/peer1.org1.ai.com/tls/server.key"
