#!/bin/bash
# Deployment script for WIFE application
# Usage: ./deploy.sh [environment]
# Example: ./deploy.sh production

set -e  # Exit on error

ENVIRONMENT=${1:-production}
COMPOSE_FILE="docker-compose.yml"

if [ "$ENVIRONMENT" == "production" ]; then
    COMPOSE_FILE="docker-compose.prod.yml"
fi

echo "=========================================="
echo "WIFE Application Deployment"
echo "Environment: $ENVIRONMENT"
echo "Compose File: $COMPOSE_FILE"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    exit 1
fi

echo "✓ Docker is running"

# Check if docker compose is available
if ! docker compose version > /dev/null 2>&1; then
    echo "❌ Error: Docker Compose is not installed"
    exit 1
fi

echo "✓ Docker Compose is available"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found"
    echo "   Creating from .env.docker template..."
    cp .env.docker .env
    echo "   Please edit .env with your configuration"
    exit 1
fi

echo "✓ Environment file found"

# Pull latest images (for production)
if [ "$ENVIRONMENT" == "production" ]; then
    echo ""
    echo "Pulling latest images from registry..."
    docker compose -f $COMPOSE_FILE pull || {
        echo "⚠️  Warning: Could not pull images, using local builds"
    }
fi

# Stop existing services
echo ""
echo "Stopping existing services..."
docker compose -f $COMPOSE_FILE down --remove-orphans

# Start services
echo ""
echo "Starting services..."
docker compose -f $COMPOSE_FILE up -d

# Wait for services to be ready
echo ""
echo "Waiting for services to be ready..."
sleep 15

# Check service health
echo ""
echo "Checking service health..."

FAILED=0

# Check FastAPI
if curl -f -s "http://localhost:8000/health" > /dev/null 2>&1; then
    echo "✓ wife-api is healthy"
else
    echo "❌ wife-api health check failed"
    FAILED=1
fi

# Check Baileys
if curl -f -s "http://localhost:3000/health" > /dev/null 2>&1; then
    echo "✓ baileys-service is healthy"
else
    echo "❌ baileys-service health check failed"
    FAILED=1
fi

# Check Portainer
if curl -f -s "http://localhost:9000/api/status" > /dev/null 2>&1 || \
   curl -f -s "http://localhost:9000/" > /dev/null 2>&1; then
    echo "✓ portainer is healthy"
else
    echo "❌ portainer health check failed"
    FAILED=1
fi

# Show container status
echo ""
echo "Container Status:"
docker compose -f $COMPOSE_FILE ps

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ Deployment Successful!"
    echo "=========================================="
    echo ""
    echo "Services are available at:"
    echo "  - FastAPI:   http://localhost:8000"
    echo "  - Baileys:   http://localhost:3000"
    echo "  - Portainer: http://localhost:9000"
    echo ""
    echo "View logs: docker compose -f $COMPOSE_FILE logs -f"
    echo "Stop services: docker compose -f $COMPOSE_FILE down"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "⚠️  Deployment completed with warnings"
    echo "=========================================="
    echo ""
    echo "Some services may not be healthy."
    echo "Check logs: docker compose -f $COMPOSE_FILE logs"
    echo ""
fi
