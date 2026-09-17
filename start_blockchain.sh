#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENESIS="$BASE_DIR/genesis.json"

NODE1_P2P_PORT=30303
NODE1_RPC_PORT=8545

echo "========================================"
echo "       Starting Besu private network"
echo "========================================"



for i in 1 2 3 4; do
    KEY="$BASE_DIR/node$i/data/key"

    if [ ! -f "$KEY" ]; then
        echo "ERROR: private key not found:"
        echo "$KEY"
        exit 1
    fi
done

NODE1_PUBLIC_KEY=$(cat "$BASE_DIR/node1/data/public-key" | sed 's/^0x//')

if [ -z "$NODE1_PUBLIC_KEY" ]; then
    echo "ERROR: Node 1 public key is empty"
    exit 1
fi

BOOTNODE="enode://${NODE1_PUBLIC_KEY}@127.0.0.1:${NODE1_P2P_PORT}"

echo
echo "Bootnode:"
echo "$BOOTNODE"
echo


start_node() {

    NODE="$1"
    P2P_PORT="$2"
    RPC_PORT="$3"

    NODE_DIR="$BASE_DIR/$NODE"
    DATA_DIR="$NODE_DIR/data"
    LOG_FILE="$NODE_DIR/besu.log"
    PID_FILE="$NODE_DIR/besu.pid"

    # Don't start duplicate process
    if [ -f "$PID_FILE" ]; then

        PID=$(cat "$PID_FILE")

        if kill -0 "$PID" 2>/dev/null; then
            echo "$NODE is already running (PID $PID)"
            return
        fi

        rm -f "$PID_FILE"
    fi

    echo "Starting $NODE..."
    echo "  P2P: $P2P_PORT"
    echo "  RPC: $RPC_PORT"

    nohup besu \
        --data-path="$DATA_DIR" \
        --genesis-file="$GENESIS" \
        --p2p-host=127.0.0.1 \
        --p2p-port="$P2P_PORT" \
        --rpc-http-enabled \
        --rpc-http-host=127.0.0.1 \
        --rpc-http-port="$RPC_PORT" \
        --rpc-http-api=ETH,NET,WEB3 \
        --bootnodes="$BOOTNODE" \
        > "$LOG_FILE" 2>&1 &

    PID=$!

    echo "$PID" > "$PID_FILE"

    echo "  PID: $PID"
    echo "  LOG: $LOG_FILE"
    echo
}



start_node node1 30303 8551
start_node node2 30304 8552
start_node node3 30305 8553
start_node node4 30306 8554
start_node node5 30307 8555

echo
echo "RPC:"
echo "Node 1: http://127.0.0.1:8551"
echo "Node 2: http://127.0.0.1:8552"
echo "Node 3: http://127.0.0.1:8553"
echo "Node 4: http://127.0.0.1:8554"
echo "Node 5: http://127.0.0.1:8555"

echo
echo "Logs:"
echo "node1/besu.log"
echo "node2/besu.log"
echo "node3/besu.log"
echo "node4/besu.log"
echo "node5/besu.log"

echo
echo "Check processes:"
echo "ps aux | grep besu"