#!/bin/bash
# Usage: ./scripts/setup-local.sh
# Installs backend/frontend dependencies and starts Docker Compose.

set -e

cd "$(dirname "$0")/.."

echo "Installing backend dependencies..."
cd backend
npm install

cd ../frontend
echo "Installing frontend dependencies..."
npm install

cd ..
echo "Starting Docker Compose..."
docker-compose up --build
