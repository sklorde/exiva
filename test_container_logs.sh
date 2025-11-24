#!/bin/bash
# Test script to verify container logs are working correctly

set -e

echo "=== Testing Container Logs ==="
echo ""

# Check if containers are running
echo "1. Checking if containers are running..."
if ! docker compose ps | grep -q "wife-api"; then
    echo "❌ wife-api container is not running"
    exit 1
fi

if ! docker compose ps | grep -q "baileys-service"; then
    echo "❌ baileys-service container is not running"
    exit 1
fi

echo "✓ All containers are running"
echo ""

# Test FastAPI log file
echo "2. Testing FastAPI log file..."
if docker exec wife-api test -f /var/log/uvicorn.log; then
    echo "✓ /var/log/uvicorn.log exists"
    echo "Sample content:"
    docker exec wife-api tail -n 5 /var/log/uvicorn.log || echo "  (log file is empty or not readable)"
else
    echo "❌ /var/log/uvicorn.log does not exist"
fi
echo ""

# Test Baileys log file
echo "3. Testing Baileys log file..."
if docker exec baileys-service test -f /app/logs/messages.log; then
    echo "✓ /app/logs/messages.log exists"
    echo "Sample content:"
    docker exec baileys-service tail -n 5 /app/logs/messages.log || echo "  (log file is empty or not readable)"
else
    echo "❌ /app/logs/messages.log does not exist"
fi
echo ""

# Test log directories
echo "4. Testing log directories..."
echo "FastAPI /var/log directory:"
docker exec wife-api ls -la /var/log/ | head -10

echo ""
echo "Baileys /app/logs directory:"
docker exec baileys-service ls -la /app/logs/ | head -10

echo ""
echo "=== Test Complete ==="
echo ""
echo "To view logs in real-time, use:"
echo "  docker exec -it wife-api tail -f /var/log/uvicorn.log"
echo "  docker exec -it baileys-service tail -f /app/logs/messages.log"
