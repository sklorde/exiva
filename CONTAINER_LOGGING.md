# Container Logging Guide

This document explains how container logging is configured and how to access logs inside running containers.

## Overview

The WIFE application has been configured to write logs to files inside containers, making it easier to debug issues and monitor application behavior.

## Log File Locations

### FastAPI Service (wife-api)
- **Log file**: `/var/log/uvicorn.log`
- **Content**: All uvicorn server logs including access logs, application logs, and error messages

### Baileys WhatsApp Service (baileys-service)
- **Log file**: `/app/logs/messages.log`
- **Content**: All Baileys service logs including WhatsApp connection status, message handling, and errors

## Accessing Logs

### View Logs from Outside Container

```bash
# View FastAPI logs (last 50 lines)
docker exec wife-api tail -n 50 /var/log/uvicorn.log

# Follow FastAPI logs in real-time
docker exec wife-api tail -f /var/log/uvicorn.log

# View Baileys logs (last 50 lines)
docker exec baileys-service tail -n 50 /app/logs/messages.log

# Follow Baileys logs in real-time
docker exec baileys-service tail -f /app/logs/messages.log
```

### Access Container Shell

```bash
# Access FastAPI container
docker exec -it wife-api /bin/bash

# Then inside container:
cd /var/log
tail -f uvicorn.log

# Access Baileys container
docker exec -it baileys-service /bin/sh

# Then inside container:
cd /app/logs
tail -f messages.log
```

## Using Docker Compose Logs

You can still use `docker compose logs` to view stdout/stderr output:

```bash
# View all service logs
docker compose logs -f

# View specific service logs
docker compose logs -f wife-api
docker compose logs -f baileys-service
```

## Testing Log Configuration

A test script is provided to verify log files are created correctly:

```bash
./test_container_logs.sh
```

This script will:
1. Check if containers are running
2. Verify log files exist
3. Display sample log content
4. Show log directory contents

## Architecture Changes

### FastAPI Service

The application startup has been refactored to avoid blocking operations at import time:

1. **Lazy Initialization**: The YOLO model is now loaded during application startup (in the `lifespan` context manager) rather than at module import time
2. **Async Startup**: The `ObjectDetectionService.initialize()` method is called asynchronously during FastAPI startup
3. **Log Redirection**: uvicorn output is redirected to `/var/log/uvicorn.log` via shell redirection in the Docker CMD

### Baileys Service

1. **File Logging**: Pino logger is configured with a file transport to write to `/app/logs/messages.log`
2. **Directory Creation**: The log directory is created programmatically if it doesn't exist

## Troubleshooting

### Log files not appearing

If log files don't appear after starting containers:

1. Check container is actually running:
   ```bash
   docker compose ps
   ```

2. Check for startup errors:
   ```bash
   docker compose logs wife-api
   docker compose logs baileys-service
   ```

3. Verify log directories exist:
   ```bash
   docker exec wife-api ls -la /var/log/
   docker exec baileys-service ls -la /app/logs/
   ```

### Cannot access log files

If you get permission errors:

```bash
# Check file permissions
docker exec wife-api ls -la /var/log/uvicorn.log
docker exec baileys-service ls -la /app/logs/messages.log
```

### Logs not updating

If logs appear frozen:

1. Generate some activity (make API requests)
2. Check if the service is actually running:
   ```bash
   curl http://localhost:8000/health
   curl http://localhost:3000/health
   ```

## Log Rotation

For production deployments, consider implementing log rotation to prevent log files from growing indefinitely:

```bash
# Example: Rotate logs manually
docker exec wife-api sh -c "cat /var/log/uvicorn.log > /var/log/uvicorn.log.1 && > /var/log/uvicorn.log"
```

Or use a log rotation tool like `logrotate` inside the container.

## Integration with External Log Management

To integrate with external log management systems:

1. **Mount log directories as volumes**:
   ```yaml
   volumes:
     - ./logs/api:/var/log
     - ./logs/baileys:/app/logs
   ```

2. **Use log shipping tools** like Filebeat, Fluentd, or Logstash to forward logs to centralized systems

3. **Configure Docker logging drivers** to send logs to external systems
