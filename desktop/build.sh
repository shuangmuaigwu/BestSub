#!/bin/bash

# BestSub Desktop Build Script
# This script automates the building process for the BestSub desktop application

set -e

echo "=========================================="
echo "BestSub Desktop Build Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Project root: $PROJECT_ROOT"
echo "Desktop directory: $SCRIPT_DIR"
echo ""

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Go is installed
if ! command -v go &> /dev/null; then
    print_error "Go is not installed. Please install Go first."
    exit 1
fi

print_info "Go version: $(go version)"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js first."
    exit 1
fi

print_info "Node.js version: $(node --version)"

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    print_error "Rust is not installed. Please install Rust first."
    exit 1
fi

print_info "Rust version: $(rustc --version)"
echo ""

# Step 1: Build the Go backend
print_info "Step 1: Building Go backend..."
cd "$PROJECT_ROOT"

# Determine the output binary name
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    BINARY_NAME="bestsub.exe"
else
    BINARY_NAME="bestsub"
fi

# Build for the current platform
go build -o "$BINARY_NAME" ./cmd/bestsub

if [ ! -f "$BINARY_NAME" ]; then
    print_error "Failed to build Go backend"
    exit 1
fi

print_info "Go backend built successfully: $BINARY_NAME"
echo ""

# Step 2: Copy binary to desktop directory
print_info "Step 2: Copying binary to desktop directory..."
cp "$BINARY_NAME" "$SCRIPT_DIR/"

if [ ! -f "$SCRIPT_DIR/$BINARY_NAME" ]; then
    print_error "Failed to copy binary to desktop directory"
    exit 1
fi

print_info "Binary copied successfully"
echo ""

# Step 3: Install Node.js dependencies
print_info "Step 3: Installing Node.js dependencies..."
cd "$SCRIPT_DIR"

if [ ! -d "node_modules" ]; then
    npm install
else
    print_info "Node modules already installed"
fi

echo ""

# Step 4: Build the Tauri application
print_info "Step 4: Building Tauri application..."
npm run build

if [ $? -eq 0 ]; then
    print_info "Build completed successfully!"
    echo ""
    print_info "Installers can be found in:"
    print_info "  $SCRIPT_DIR/src-tauri/target/release/bundle/"
    echo ""
else
    print_error "Build failed"
    exit 1
fi

echo "=========================================="
echo "Build process completed!"
echo "=========================================="
