# Docker Build Optimization Guide

This guide explains how to optimize Docker builds for the WIFE application to reduce build times and avoid re-downloading large dependencies.

## Problem Statement

The WIFE application uses YOLO (via Ultralytics) for object detection, which requires:
- Large deep learning models (YOLO weights)
- PyTorch and various dependencies

Without optimization, every `docker compose up -d` or container rebuild would:
- Re-download YOLO model weights at runtime
- Take significant time to initialize
- Waste bandwidth and time

## Solutions Implemented

### 1. Pre-Download YOLO Models During Build

The Dockerfile now includes a step that pre-downloads YOLO models during the image build:

```dockerfile
# Pre-download YOLO models to avoid downloading at runtime
RUN python3 -c "from ultralytics import YOLO; YOLO('yolov8n.pt')" && \
    echo "YOLO model downloaded successfully"
```

**Benefits:**
- Model is baked into the image
- No download needed at container startup
- Faster container initialization
- Works offline after initial build

### 2. Persistent Model Cache Volume

A Docker volume is added to cache YOLO models and other ultralytics data:

```yaml
volumes:
  - model-cache:/root/.cache/ultralytics
```

**Benefits:**
- Models persist across container recreations
- Shared cache if multiple containers use the same models
- Easy to backup and restore
- Reduces redundant downloads

### 3. Docker Layer Caching Strategy

The Dockerfile is structured to maximize layer caching:

1. System dependencies (rarely change)
2. Python requirements (change occasionally)
3. Model download (only when requirements change)
4. Application code (changes frequently)

**Benefits:**
- Only rebuild layers that changed
- Skip expensive model downloads if dependencies haven't changed
- Faster iterative development

## Usage Instructions

### Standard Build

```bash
# First time build (downloads everything)
docker compose build

# Start services
docker compose up -d
```

The first build will take time to download PyTorch, models, etc. Subsequent builds will be much faster due to Docker layer caching.

**To use a different YOLO model:**

```bash
# Build with a larger model (better accuracy, slower)
docker compose build --build-arg YOLO_MODEL=yolov8s.pt

# Or modify docker-compose.yml to add build args:
services:
  wife-api:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        YOLO_MODEL: yolov8s.pt
```

Available YOLO models (nano to extra-large):
- `yolov8n.pt` - Nano (fastest, default)
- `yolov8s.pt` - Small
- `yolov8m.pt` - Medium
- `yolov8l.pt` - Large
- `yolov8x.pt` - Extra Large (best accuracy)

### Managing Model Cache

#### View cached models
```bash
docker volume inspect exiva_model-cache
```

#### Backup model cache
```bash
docker run --rm \
  -v exiva_model-cache:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/model-cache-backup.tar.gz -C /data .
```

#### Restore model cache
```bash
docker run --rm \
  -v exiva_model-cache:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/model-cache-backup.tar.gz -C /data
```

#### Clear model cache (force re-download)
```bash
docker compose down
docker volume rm exiva_model-cache
docker compose up -d
```

## Build Time Optimization Tips

### 1. Use BuildKit

Enable Docker BuildKit for better caching and parallel builds:

```bash
export DOCKER_BUILDKIT=1
docker compose build
```

Or add to `~/.docker/config.json`:
```json
{
  "features": {
    "buildkit": true
  }
}
```

### 2. Build-Time Cache Mounts

For even faster builds, you can use BuildKit cache mounts. Create a `Dockerfile.buildkit`:

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libglib2.0-0 libsm6 libxext6 libxrender-dev \
    libgomp1 libgl1 curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Use cache mount for pip
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --trusted-host pypi.org \
    --trusted-host pypi.python.org \
    --trusted-host files.pythonhosted.org \
    -r requirements.txt

# Use cache mount for ultralytics models
RUN --mount=type=cache,target=/root/.cache/ultralytics \
    python3 -c "from ultralytics import YOLO; YOLO('yolov8n.pt')"

COPY . .
RUN mkdir -p uploads data

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build with:
```bash
DOCKER_BUILDKIT=1 docker build -f Dockerfile.buildkit -t wife-api .
```

### 3. Multi-Stage Builds

For production, consider a multi-stage build to reduce final image size:

```dockerfile
# Build stage
FROM python:3.11 as builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

# Runtime stage
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /install /usr/local
# ... rest of the Dockerfile
```

## Performance Comparison

| Scenario | Without Optimization | With Optimization |
|----------|---------------------|-------------------|
| First build | ~15-20 minutes | ~15-20 minutes |
| Rebuild (code change only) | ~15-20 minutes | ~30 seconds |
| Container restart | ~2-3 minutes (model download) | ~10 seconds |
| Offline operation | ❌ Fails | ✅ Works |

## Troubleshooting

### Build is still slow

1. **Check Docker BuildKit is enabled:**
   ```bash
   docker version
   # Look for BuildKit support
   ```

2. **Clear build cache if needed:**
   ```bash
   docker builder prune
   ```

3. **Ensure no proxy/VPN issues affecting downloads**

### Model not found at runtime

If the model isn't found despite being downloaded during build:

1. **Check the model cache volume exists:**
   ```bash
   docker volume ls | grep model-cache
   ```

2. **Verify model is in the image:**
   ```bash
   docker compose run --rm wife-api ls -la /root/.cache/ultralytics
   ```

3. **Rebuild without cache:**
   ```bash
   docker compose build --no-cache wife-api
   ```

## Best Practices

1. **Keep dependencies stable:** Only update requirements.txt when necessary
2. **Use specific versions:** Pin versions in requirements.txt to avoid surprises
3. **Regular backups:** Backup model-cache volume periodically
4. **Monitor image size:** Use `docker images` to track image size growth
5. **Clean unused resources:** Run `docker system prune` periodically

## Additional Resources

- [Docker BuildKit Documentation](https://docs.docker.com/build/buildkit/)
- [Ultralytics YOLO Documentation](https://docs.ultralytics.com/)
