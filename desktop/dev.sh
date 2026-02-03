#!/bin/bash

# Quick start script for BestSub Desktop (Development)
# This script starts the backend and opens the desktop app in development mode

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Starting BestSub Desktop in development mode..."

# Check if binary exists
if [ ! -f "$SCRIPT_DIR/bestsub" ]; then
    echo "Backend binary not found. Building..."
    cd "$PROJECT_ROOT"
    go build -o bestsub ./cmd/bestsub
    cp bestsub "$SCRIPT_DIR/"
fi

# Install npm dependencies if needed
if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
    echo "Installing npm dependencies..."
    cd "$SCRIPT_DIR"
    npm install
fi

echo "Starting desktop application..."
cd "$SCRIPT_DIR"
npm run dev
