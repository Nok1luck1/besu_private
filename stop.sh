#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for i in 1 2 3 4 5; do
    PID_FILE="$BASE_DIR/node$i/data/besu.pid"

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")

        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            echo "node$i stopped (PID $PID)"
        else
            echo "node$i not running"
        fi

        rm -f "$PID_FILE"
    else
        echo "node$i not running"
    fi
done