#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENESIS="$BASE_DIR/genesis.json"

NODE1_P2P_PORT=30303

NODE1_PUBLIC_KEY=$(cat "$BASE_DIR/node1/data/public-key" | sed 's/^0x//')
BOOTNODE="enode://${NODE1_PUBLIC_KEY}@127.0.0.1:${NODE1_P2P_PORT}"

start_node() {

    NODE="$1"
    P2P_PORT="$2"
    RPC_PORT="$3"

    NODE_DIR="$BASE_DIR/$NODE"
    DATA_DIR="$NODE_DIR/data"
    LOG_FILE="$NODE_DIR/besu.log"
    PID_FILE="$NODE_DIR/besu.pid"

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "$NODE is already running (PID $PID)"
            return
        fi
        rm -f "$PID_FILE"
    fi

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

    echo "$NODE resumed (PID $PID)"
}

start_node node1 30303 8551
start_node node2 30304 8552
start_node node3 30305 8553
start_node node4 30306 8554
start_node node5 30307 8555