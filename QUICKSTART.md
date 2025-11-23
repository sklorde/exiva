# Quick Start Guide

This guide will help you get the WIFE application running in minutes.

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Git

## Option 1: Local Development (Fastest)

### Step 1: Clone and Configure

```bash
# Clone the repository
git clone https://github.com/sklorde/exiva.git
cd exiva

# Create environment file
cp .env.docker .env

# Optional: Edit .env to customize settings
nano .env
```

### Step 2: Start Services

```bash
# Build and start all services
docker compose up -d

# Wait about 30 seconds for services to start
```

### Step 3: Verify

```bash
# Check container status
docker compose ps

# Test API endpoints
curl http://localhost:8000/health    # FastAPI
curl http://localhost:3000/health    # Baileys
```

### Step 4: Access Services

Open your browser to:

- **FastAPI Documentation**: http://localhost:8000/docs
- **Baileys WhatsApp Service**: http://localhost:3000
- **Portainer Dashboard**: http://localhost:9000

On first Portainer access:
1. Create an admin username and password
2. Select "Docker" environment
3. Click "Connect"

## Option 2: Using the Deployment Script

```bash
# Clone repository
git clone https://github.com/sklorde/exiva.git
cd exiva

# Create environment file
cp .env.docker .env

# Run deployment script
./deploy.sh

# The script will:
# - Verify Docker is running
# - Check configuration
# - Start all services
# - Perform health checks
# - Display service URLs
```

## Option 3: Production Deployment

### Prerequisites
- Server with Docker installed
- Domain name (optional but recommended)
- GitHub Personal Access Token (for pulling images)

### Steps

```bash
# 1. SSH into your server
ssh user@your-server.com

# 2. Create deployment directory
mkdir -p /opt/wife-app
cd /opt/wife-app

# 3. Download configuration files
curl -O https://raw.githubusercontent.com/sklorde/exiva/main/docker-compose.prod.yml
curl -O https://raw.githubusercontent.com/sklorde/exiva/main/.env.docker

# 4. Configure environment
cp .env.docker .env
nano .env  # Edit with production values

# 5. Login to GitHub Container Registry (if using pre-built images)
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# 6. Deploy
docker compose -f docker-compose.prod.yml up -d

# 7. Verify
docker compose -f docker-compose.prod.yml ps
curl http://localhost:8000/health
curl http://localhost:3000/health
```

## Common Tasks

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f wife-api
docker compose logs -f baileys-service

# Last 100 lines
docker compose logs --tail=100 wife-api
```

### Restart a Service

```bash
docker compose restart wife-api
docker compose restart baileys-service
```

### Stop All Services

```bash
# Stop but keep data
docker compose down

# Stop and remove all data (⚠️ CAUTION)
docker compose down -v
```

### Update Services

```bash
# Pull latest code
git pull

# Rebuild and restart
docker compose build
docker compose up -d
```

### WhatsApp Setup (Baileys)

1. Start the services
2. Get QR code:
   ```bash
   curl http://localhost:3000/qr
   ```
3. The response will include a QR code data URL
4. Open the data URL in your browser or scan with WhatsApp
5. Once scanned, check authentication status:
   ```bash
   curl http://localhost:3000/status
   ```

### Send Test Message

```bash
curl -X POST http://localhost:3000/send-message \
  -H "Content-Type: application/json" \
  -d '{
    "number": "1234567890",
    "message": "Hello from WIFE!"
  }'
```

### Test Object Detection

```bash
# Upload an image
curl -X POST http://localhost:8000/api/detect \
  -F "file=@/path/to/image.jpg" \
  -F "location=living_room"

# Query detected objects
curl http://localhost:8000/api/objects

# Find where an object was last seen
curl http://localhost:8000/api/objects/chair/last-seen
```

## Troubleshooting

### Services Won't Start

**Check Docker status:**
```bash
docker info
docker compose version
```

**Check logs for errors:**
```bash
docker compose logs
```

**Rebuild from scratch:**
```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

### Port Already in Use

Edit `.env` and change ports:
```bash
API_PORT=8001
BAILEYS_PORT=3001
POSTGRES_PORT=5433
PORTAINER_PORT=9001
```

Then restart:
```bash
docker compose down
docker compose up -d
```

### Cannot Connect to Database

```bash
# Check PostgreSQL is running
docker compose ps postgres

# Check PostgreSQL logs
docker compose logs postgres

# Test connection
docker compose exec postgres psql -U wife -d wife_db -c "\l"
```

### Baileys QR Code Not Appearing

```bash
# Check Baileys logs
docker compose logs baileys-service

# Restart Baileys
docker compose restart baileys-service

# Wait 10 seconds and try getting QR again
sleep 10
curl http://localhost:3000/qr
```

### Services Showing as Unhealthy

```bash
# Give services more time (especially on first run)
sleep 30

# Check specific service
docker compose ps wife-api

# Inspect container
docker compose exec wife-api bash

# Check health endpoint manually
docker compose exec wife-api curl http://localhost:8000/health
```

## Next Steps

1. **Read the Documentation**
   - [README.md](README.md) - Full project documentation
   - [DOCKER_COMPOSE_GUIDE.md](DOCKER_COMPOSE_GUIDE.md) - Docker Compose details
   - [CI_CD_GUIDE.md](CI_CD_GUIDE.md) - CI/CD pipeline information

2. **Explore the APIs**
   - Visit http://localhost:8000/docs for FastAPI interactive documentation
   - Try the example endpoints for object detection
   - Test WhatsApp messaging through Baileys

3. **Use Portainer**
   - Access http://localhost:9000
   - Monitor container resources
   - View real-time logs
   - Manage volumes and networks

4. **Customize**
   - Modify environment variables in `.env`
   - Adjust Docker Compose configuration
   - Add your own services

5. **Deploy to Production**
   - Follow the production deployment guide
   - Set up SSL certificates
   - Configure firewall rules
   - Set up backups

## Getting Help

- **Issues**: Open an issue on GitHub
- **Documentation**: Check the docs in the repository
- **Logs**: Always check logs when troubleshooting
- **Portainer**: Use for visual debugging and monitoring

## Environment Variables Reference

### PostgreSQL
```bash
POSTGRES_USER=wife              # Database username
POSTGRES_PASSWORD=wife_password  # Database password (change in production!)
POSTGRES_DB=wife_db             # Database name
POSTGRES_PORT=5432              # Database port
```

### FastAPI
```bash
API_PORT=8000                   # API port
```

### Baileys
```bash
BAILEYS_PORT=3000               # Baileys service port
LOG_LEVEL=info                  # Log level (info, debug, warn, error)
```

### Portainer
```bash
PORTAINER_PORT=9000             # HTTP port
PORTAINER_HTTPS_PORT=9443       # HTTPS port
```

## Security Notes

1. **Change default passwords** in production
2. **Use strong passwords** for PostgreSQL
3. **Don't commit `.env`** file with real credentials
4. **Use HTTPS** in production
5. **Keep Docker images updated**
6. **Regularly backup data**

## Performance Tips

1. **Resource Limits**: Adjust in docker-compose.prod.yml
2. **Log Rotation**: Configure in Docker daemon settings
3. **Volume Management**: Regularly clean unused volumes
4. **Image Pruning**: Remove old images periodically

```bash
# Clean up system
docker system prune -a --volumes

# View disk usage
docker system df
```

## Support

For more detailed information, see:
- [README.md](README.md)
- [DOCKER_COMPOSE_GUIDE.md](DOCKER_COMPOSE_GUIDE.md)
- [CI_CD_GUIDE.md](CI_CD_GUIDE.md)
