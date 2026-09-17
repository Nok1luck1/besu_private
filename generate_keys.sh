#!/bin/bash

set -e

NODE_NAME="${1:-node1}"
DATA_DIR="$NODE_NAME/data"

mkdir -p "$DATA_DIR"

echo "Generating key for $NODE_NAME..."

besu \
    --data-path="$DATA_DIR" \
    public-key export \
    --to="$DATA_DIR/public-key"

besu \
    --data-path="$DATA_DIR" \
    public-key export-address \
    --to="$DATA_DIR/address"

echo
echo "Done!"
echo "Node:    $NODE_NAME"
echo "Private: $DATA_DIR/key"
echo "Public:  $DATA_DIR/public-key"
echo "Address: $DATA_DIR/address"