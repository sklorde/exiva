# Docker Compose Setup Guide

This guide explains how to use Docker Compose to run the WIFE application stack.

## Services Overview

The docker-compose.yml file defines four services:

### 1. PostgreSQL Database (`postgres`)
- **Image**: postgres:16-alpine
- **Port**: 5432
- **Purpose**: Primary database for application data
- **Health Check**: Automated health monitoring

### 2. FastAPI Service (`wife-api`)
- **Build**: From root Dockerfile
- **Port**: 8000
- **Purpose**: Object detection and tracking REST API
- **Dependencies**: PostgreSQL

### 3. Baileys WhatsApp Service (`baileys-service`)
- **Build**: From baileys-service/Dockerfile
- **Port**: 3000
- **Purpose**: WhatsApp Web API integration
- **Dependencies**: None (standalone)

### 4. Portainer (`portainer`)
- **Image**: portainer/portainer-ce:latest
- **Ports**: 9000 (HTTP), 9443 (HTTPS)
- **Purpose**: Docker container management web interface
- **Dependencies**: Docker socket access

## Quick Start

### 1. Configuration

Copy the environment template:
```bash
cp .env.docker .env
```

Edit `.env` to customize settings if needed:
```bash
# PostgreSQL
POSTGRES_USER=wife
POSTGRES_PASSWORD=wife_password
POSTGRES_DB=wife_db
POSTGRES_PORT=5432

# FastAPI
API_PORT=8000

# Baileys
BAILEYS_PORT=3000
LOG_LEVEL=info

# Portainer
PORTAINER_PORT=9000
PORTAINER_HTTPS_PORT=9443
```

### 2. Build Services

Build all Docker images:
```bash
docker compose build
```

Build a specific service:
```bash
docker compose build wife-api
docker compose build baileys-service
```

Build without cache (clean build):
```bash
docker compose build --no-cache
```

### 3. Start Services

Start all services in detached mode:
```bash
docker compose up -d
```

Start with logs visible:
```bash
docker compose up
```

Start specific services:
```bash
docker compose up -d postgres wife-api
```

### 4. Monitor Services

Check service status:
```bash
docker compose ps
```

View logs:
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f wife-api
docker compose logs -f baileys-service
docker compose logs -f postgres

# Last 100 lines
docker compose logs --tail=100 wife-api
```

### 5. Stop Services

Stop all services:
```bash
docker compose down
```

Stop and remove volumes (⚠️ deletes all data):
```bash
docker compose down -v
```

Stop specific services:
```bash
docker compose stop wife-api
```

## Health Checks

All services include health checks that can be monitored:

```bash
# FastAPI health
curl http://localhost:8000/health

# Baileys health
curl http://localhost:3000/health

# PostgreSQL health
docker compose exec postgres pg_isready -U wife

# Portainer health
curl http://localhost:9000/api/status
```

### Using Portainer for Container Management

Portainer provides a user-friendly web interface for managing Docker containers:

1. **Access Portainer**
   - Open browser to http://localhost:9000 or https://localhost:9443
   - Create admin credentials on first login
   - Select "Docker" environment and connect

2. **Dashboard Features**
   - **Containers**: View, start, stop, restart, and access logs
   - **Images**: Manage Docker images and pull new ones
   - **Volumes**: View and backup volume data
   - **Networks**: Inspect network configurations
   - **Stats**: Real-time resource usage monitoring

3. **Container Actions via Portainer**
   - View live logs with filtering
   - Access container console/shell
   - Inspect container configuration
   - View resource usage graphs
   - Quick restart/stop/start buttons

4. **Useful Portainer Features**
   - **Console Access**: Click on container → Console → Connect
   - **Log Streaming**: Click on container → Logs → Auto-refresh
   - **Stats**: Click on container → Stats for real-time metrics
   - **Duplicate**: Clone container configurations easily

## Volume Management

### Named Volumes

The setup uses four named volumes:
- `wife-data`: FastAPI application data
- `postgres-data`: PostgreSQL database
- `baileys-auth`: WhatsApp authentication data
- `portainer-data`: Portainer configuration and data

List volumes:
```bash
docker volume ls | grep exiva
```

Inspect a volume:
```bash
docker volume inspect exiva_wife-data
docker volume inspect exiva_postgres-data
docker volume inspect exiva_baileys-auth
```

### Backup Volumes

Backup wife-data:
```bash
docker run --rm -v exiva_wife-data:/data -v $(pwd):/backup alpine tar czf /backup/wife-data-backup.tar.gz -C /data .
```

Backup postgres-data:
```bash
docker run --rm -v exiva_postgres-data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-backup.tar.gz -C /data .
```

### Restore Volumes

Restore wife-data:
```bash
docker run --rm -v exiva_wife-data:/data -v $(pwd):/backup alpine tar xzf /backup/wife-data-backup.tar.gz -C /data
```

## Networking

All services are connected via the `wife-network` bridge network.

Services can communicate using their service names:
- `http://wife-api:8000` - FastAPI service
- `http://baileys-service:3000` - Baileys service
- `postgres:5432` - PostgreSQL database

View network details:
```bash
docker network inspect exiva_wife-network
```

## Troubleshooting

### Port Conflicts

If ports are already in use, modify them in `.env`:
```bash
API_PORT=8001
BAILEYS_PORT=3001
POSTGRES_PORT=5433
```

### Service Won't Start

Check logs for errors:
```bash
docker compose logs [service-name]
```

Rebuild the service:
```bash
docker compose build --no-cache [service-name]
docker compose up -d [service-name]
```

### Database Issues

Reset database (⚠️ deletes data):
```bash
docker compose down -v postgres
docker compose up -d postgres
```

Access PostgreSQL shell:
```bash
docker compose exec postgres psql -U wife -d wife_db
```

### Clean Slate

Remove everything and start fresh:
```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

## Advanced Usage

### Environment-Specific Configs

Development:
```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up
```

Production:
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### Scaling Services (if applicable)

```bash
docker compose up -d --scale wife-api=3
```

### Execute Commands in Containers

```bash
# Python shell in wife-api
docker compose exec wife-api python

# Node.js REPL in baileys-service
docker compose exec baileys-service node

# Bash shell
docker compose exec wife-api bash
docker compose exec baileys-service sh
```

### Resource Limits

Add resource limits in docker-compose.yml:
```yaml
services:
  wife-api:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

## Production Considerations

1. **Security**
   - Use strong passwords in `.env`
   - Don't commit `.env` to version control
   - Use secrets management for sensitive data

2. **Performance**
   - Adjust resource limits based on workload
   - Monitor container metrics
   - Use production-optimized images

3. **Reliability**
   - Set appropriate restart policies
   - Implement backup strategies
   - Monitor health checks

4. **Updates**
   - Pull latest images regularly
   - Test updates in staging first
   - Have rollback plan ready
