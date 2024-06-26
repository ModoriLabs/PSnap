#!/usr/bin/env bash

# Usage: ./scripts/print-addresses.sh <network>
NETWORK=$1
if [ -z "$NETWORK" ]; then
  echo "Usage: ./scripts/print-addresses.sh <network>"
  exit 1
fi

# NOTE: EXPLORER must ends with /
if [ "$NETWORK" == "baobab" ]; then
  EXPLORER="https://baobab.klaytnscope.com/account/"
elif [ "$NETWORK" == "cypress" ]; then
  EXPLORER="https://klaytnscope.com/account/"
elif [ "$NETWORK" == "bsc_testnet" ]; then
  EXPLORER="https://testnet.bscscan.com/address/"
elif [ "$NETWORK" == "bsc" ]; then
  EXPLORER="https://bscscan.com/address/"
elif [ "$NETWORK" == "sepolia" ]; then
  EXPLORER="https://sepolia.etherscan.io/address/"
else
  echo "Invalid network: $NETWORK"
fi

yarn hardhat export --network $NETWORK --export temp.json
echo '| Contracts                    | Address                                                                                                                  |'
echo '|------------------------------|--------------------------------------------------------------------------------------------------------------------------|'
jq -r ".contracts | to_entries[] | [.key, \"[\(.value.address)]($EXPLORER\(.value.address))\"] | @tsv" temp.json \
  | sed 's/\t/ | /g; s/^/| /; s/$/ |/' \
  | awk '!(/Implementation/ || /Proxy/)'

rm temp.json
