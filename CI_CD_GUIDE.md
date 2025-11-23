# CI/CD Deployment Guide

This guide explains how to use the CI/CD pipeline for deploying the WIFE application.

## Overview

The CI/CD pipeline is configured using GitHub Actions and automatically runs on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Manual workflow dispatch

## Pipeline Stages

### 1. Build & Test Phase

#### FastAPI Service (`build-test-api`)
- Sets up Python 3.11 environment
- Installs dependencies
- Runs linting with flake8
- Builds Docker image
- Tests container health endpoints

#### Baileys Service (`build-test-baileys`)
- Sets up Node.js 20 environment
- Installs dependencies
- Runs Jest tests
- Builds Docker image
- Tests container health endpoints

### 2. Integration Test (`docker-compose-test`)
- Builds all services with Docker Compose
- Starts the complete stack
- Waits for services to be ready
- Tests health endpoints for all services
- Validates PostgreSQL connectivity
- Shows logs on failure for debugging

### 3. Build & Push Images (`build-push-images`)
**Only runs on main branch pushes**

- Logs into GitHub Container Registry (ghcr.io)
- Builds production Docker images
- Tags images with:
  - Branch name
  - Semantic version (if tagged)
  - Git commit SHA
- Pushes to GitHub Container Registry

### 4. Deployment (`deploy`)
**Only runs on main branch pushes after successful build**

- Demonstrates deployment process
- Creates deployment artifacts
- Uploads deployment package

## Using the Pipeline

### Automatic Triggers

1. **Push to main or develop**
   ```bash
   git checkout main
   git add .
   git commit -m "Your changes"
   git push origin main
   ```
   - Runs all pipeline stages
   - Builds and pushes images (main only)
   - Creates deployment package (main only)

2. **Create Pull Request**
   - Runs build and test stages
   - Does NOT push images or deploy
   - Validates changes before merge

### Manual Trigger

You can manually trigger the workflow:

1. Go to repository → Actions tab
2. Select "CI/CD Pipeline" workflow
3. Click "Run workflow"
4. Select branch and click "Run workflow"

## Deployment Process

### Using GitHub Container Registry Images

After the pipeline pushes images to ghcr.io, you can deploy them:

1. **Create deployment docker-compose.prod.yml**
   ```yaml
   version: '3.8'
   
   services:
     postgres:
       image: postgres:16-alpine
       # ... configuration
   
     wife-api:
       image: ghcr.io/sklorde/exiva/wife-api:main
       # ... configuration
   
     baileys-service:
       image: ghcr.io/sklorde/exiva/baileys-service:main
       # ... configuration
   
     portainer:
       image: portainer/portainer-ce:latest
       # ... configuration
   ```

2. **Deploy to server**
   ```bash
   # SSH into your server
   ssh user@your-server.com
   
   # Navigate to deployment directory
   cd /opt/wife-app
   
   # Login to GitHub Container Registry
   echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
   
   # Pull latest images
   docker compose -f docker-compose.prod.yml pull
   
   # Start services
   docker compose -f docker-compose.prod.yml up -d
   
   # Check health
   docker compose -f docker-compose.prod.yml ps
   ```

### Using Deployment Artifacts

The pipeline creates deployment artifacts that you can download:

1. Go to Actions tab → Select successful workflow run
2. Scroll down to "Artifacts" section
3. Download "deployment-package"
4. Extract and use the files for deployment

Contents:
- `docker-compose.yml` - Production Docker Compose configuration
- `.env.example` - Environment variables template

## Environment Variables for Deployment

Create a `.env` file on your server with production values:

```bash
# PostgreSQL - Use strong passwords!
POSTGRES_USER=wife_prod
POSTGRES_PASSWORD=<strong-random-password>
POSTGRES_DB=wife_production
POSTGRES_PORT=5432

# FastAPI
API_PORT=8000

# Baileys
BAILEYS_PORT=3000
LOG_LEVEL=warn

# Portainer
PORTAINER_PORT=9000
PORTAINER_HTTPS_PORT=9443
```

## Monitoring Deployments

### Check Pipeline Status

1. **GitHub UI**
   - Go to repository → Actions tab
   - View workflow runs and their status
   - Click on a run to see detailed logs

2. **GitHub CLI**
   ```bash
   gh run list
   gh run view <run-id>
   gh run watch
   ```

### Check Deployed Services

1. **Service Health**
   ```bash
   curl https://your-domain.com/health
   curl https://your-domain.com:3000/health
   ```

2. **Container Status**
   ```bash
   docker compose ps
   docker compose logs -f
   ```

3. **Portainer Dashboard**
   - Access at https://your-domain.com:9443
   - View real-time container metrics
   - Check logs and resource usage

## Troubleshooting

### Pipeline Fails at Build Stage

**Problem**: Docker build fails
**Solution**:
- Check Dockerfile syntax
- Verify all dependencies are available
- Review build logs in Actions tab

### Pipeline Fails at Test Stage

**Problem**: Health check endpoints fail
**Solution**:
- Check application logs in pipeline output
- Verify services start correctly
- Test locally with docker compose

### Pipeline Fails at Integration Test

**Problem**: Services don't communicate
**Solution**:
- Check network configuration in docker-compose.yml
- Verify environment variables
- Check inter-service dependencies

### Deployment Issues

**Problem**: Images won't pull from registry
**Solution**:
```bash
# Make sure you're authenticated
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin

# Verify image exists
docker manifest inspect ghcr.io/sklorde/exiva/wife-api:main

# Try pulling manually
docker pull ghcr.io/sklorde/exiva/wife-api:main
```

**Problem**: Container crashes on startup
**Solution**:
```bash
# Check logs
docker compose logs wife-api

# Inspect container
docker compose exec wife-api bash

# Verify environment variables
docker compose config
```

## Best Practices

### 1. Branch Strategy

- **main**: Production-ready code, triggers full pipeline including deployment
- **develop**: Development code, runs tests but doesn't deploy
- **feature/***: Feature branches, create PRs to develop

### 2. Version Tagging

Tag releases for better version tracking:
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

The pipeline will create images with the tag version.

### 3. Environment Management

- Keep sensitive data in environment variables
- Use different `.env` files for dev/staging/prod
- Never commit `.env` files with real credentials

### 4. Testing

Before pushing:
```bash
# Test locally
docker compose build
docker compose up -d
docker compose ps
curl http://localhost:8000/health
curl http://localhost:3000/health

# Run manual tests
docker compose down
```

### 5. Rollback Strategy

If deployment fails:
```bash
# View available versions
docker image ls | grep wife-api

# Rollback to previous version
docker compose stop wife-api
docker run -d --name wife-api \
  ghcr.io/sklorde/exiva/wife-api:sha-abc123 \
  # ... with same configuration

# Or modify docker-compose.prod.yml to use specific tag
```

## Security Considerations

1. **Registry Access**
   - Use GitHub Personal Access Token (PAT) with read:packages scope
   - Store PAT as GitHub Secret for CI/CD
   - Never expose PAT in logs or code

2. **Production Credentials**
   - Use strong passwords for PostgreSQL
   - Rotate credentials regularly
   - Use environment variables, never hardcode

3. **Container Security**
   - Keep base images updated
   - Scan for vulnerabilities
   - Use minimal base images (alpine, slim)

4. **Network Security**
   - Use HTTPS in production
   - Configure firewall rules
   - Limit exposed ports

## Advanced Topics

### Custom Deployment Scripts

Create a deployment script on your server:

```bash
#!/bin/bash
# deploy.sh

set -e

echo "Starting deployment..."

# Pull latest images
docker compose -f docker-compose.prod.yml pull

# Backup database
docker compose exec postgres pg_dump -U wife_prod wife_production > backup-$(date +%Y%m%d-%H%M%S).sql

# Update services with zero downtime
docker compose -f docker-compose.prod.yml up -d --no-deps --build wife-api
docker compose -f docker-compose.prod.yml up -d --no-deps --build baileys-service

# Wait for health checks
sleep 10

# Verify deployment
curl -f http://localhost:8000/health || exit 1
curl -f http://localhost:3000/health || exit 1

echo "Deployment successful!"
```

### GitHub Actions Secrets

Configure secrets in GitHub for advanced deployments:

1. Go to repository → Settings → Secrets and variables → Actions
2. Add secrets:
   - `DEPLOY_HOST`: Server hostname
   - `DEPLOY_USER`: SSH username
   - `DEPLOY_KEY`: SSH private key
   - `CR_PAT`: GitHub Personal Access Token

### Notifications

Add Slack/Discord notifications to workflow:

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Support

For issues with the CI/CD pipeline:
1. Check GitHub Actions logs
2. Review this documentation
3. Open an issue in the repository
4. Check Docker and Docker Compose documentation
