#!/usr/bin/env bash

WG=$(which wg)
if [ $? -ne 0 ]; then
  echo "Error: wireguard utility 'wg' not in path; unable to generate keys"
  exit 1
fi

prv=$(wg genkey)
pub=$(echo ${prv} | wg pubkey)
echo "server keys"
echo "    vpn_private_key = \"${prv}\""
echo "    vpn_public_key  = \"${pub}\""

prv=$(wg genkey)
pub=$(echo ${prv} | wg pubkey)
echo "client keys"
echo "    vpn_private_key = \"${prv}\""
echo "    vpn_public_key  = \"${pub}\""

