# WIFE - Where Is For Everyone

<p align="center">
   <a href="https://www.python.org/" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/python-3.8+-blue.svg?style=for-the-badge&logo=python"></a>
   <a href="https://fastapi.tiangolo.com/"><img src="https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi"></a>
   <a href="https://nodejs.org/"><img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white"></a>
   <a href="https://www.docker.com/"><img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white"></a>
</p>

<p align="center">A microservices-based object recognition and tracking system with WhatsApp integration</p>

<p align="center">
  <a href="#about">About</a> •
  <a href="#features">Features</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#api-endpoints">API Endpoints</a> •
  <a href="#ci-cd-pipeline">CI/CD Pipeline</a> •
  <a href="#license">License</a>
</p>

## About

WIFE (Where Is For Everyone) is a microservices-based system built with Python FastAPI and Node.js that provides object recognition and tracking capabilities with WhatsApp integration using Baileys. The system can analyze photos to detect objects and track where each object was last seen, making it perfect for home monitoring, inventory management, and personal item tracking.

## Features

- 🔍 **Object Recognition**: Detect and identify objects in uploaded photos using advanced computer vision
- 📍 **Location Tracking**: Track where each object was last seen with timestamp information
- 💬 **WhatsApp Integration**: Send notifications and interact via WhatsApp using Baileys
- 🚀 **FastAPI**: High-performance API built with modern Python async framework
- 📷 **Photo Upload**: Support for uploading photos from cameras or devices
- 🔎 **Query System**: REST API to query when and where objects were last detected
- 🐳 **Fully Containerized**: Docker and Docker Compose setup for easy deployment
- 🔄 **CI/CD Pipeline**: Automated testing and deployment with GitHub Actions
- 🗄️ **PostgreSQL Database**: Robust data persistence (with SQLite fallback)

## Architecture

The system consists of four main services orchestrated with Docker Compose:

```
┌──────────────────────────────────────────────────────────────────┐
│                        WIFE System                                │
├──────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   FastAPI    │  │   Baileys    │  │  PostgreSQL  │           │
│  │   Service    │◄─┤   Service    │  │   Database   │           │
│  │  (Python)    │  │  (Node.js)   │  │              │           │
│  │  Port: 8000  │  │  Port: 3000  │  │  Port: 5432  │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│         │                 │                  │                    │
│         │                 │                  │                    │
│         └─────────────────┴──────────────────┘                    │
│                      Docker Network                               │
│                            │                                      │
│                   ┌────────┴────────┐                            │
│                   │   Portainer     │                            │
│                   │ Management UI   │                            │
│                   │  Port: 9000     │                            │
│                   └─────────────────┘                            │
└──────────────────────────────────────────────────────────────────┘
```

### Services

1. **FastAPI Service** (`wife-api`): Object detection and tracking REST API
2. **Baileys Service** (`baileys-service`): WhatsApp Web API integration
3. **PostgreSQL Database** (`postgres`): Data persistence layer
4. **Portainer** (`portainer`): Docker container management web UI

## Getting Started

### Prerequisites

- Docker 20.10 or higher
- Docker Compose 2.0 or higher
- Git

### Quick Start with Docker Compose

1. **Clone the repository**
   ```bash
   git clone https://github.com/sklorde/exiva
   cd exiva
   ```

2. **Configure environment variables**
   ```bash
   cp .env.docker .env
   # Edit .env if you want to customize settings
   ```

3. **Build and start all services**
   ```bash
   docker compose build
   docker compose up -d
   ```

4. **Check service health**
   ```bash
   docker compose ps
   curl http://localhost:8000/health  # FastAPI health check
   curl http://localhost:3000/health  # Baileys health check
   ```

5. **Access Portainer (Docker Management UI)**
   
   Open your browser and navigate to:
   - **HTTP**: http://localhost:9000
   - **HTTPS**: https://localhost:9443
   
   On first access:
   - Create an admin user and password
   - Select "Docker" as the environment type
   - Click "Connect" to manage your local Docker instance
   
   Portainer allows you to:
   - Monitor container status and resource usage
   - View logs and console access
   - Manage volumes, networks, and images
   - Start/stop/restart containers
   - View container statistics in real-time

6. **View logs**
   ```bash
   docker compose logs -f
   # Or for a specific service
   docker compose logs -f wife-api
   docker compose logs -f baileys-service
   ```

7. **Stop services**
   ```bash
   docker compose down
   # To remove volumes as well
   docker compose down -v
   ```

### Local Development (Without Docker)

#### FastAPI Service

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the application
uvicorn main:app --reload
```

#### Baileys Service

```bash
cd baileys-service

# Install dependencies
npm install

# Run in development mode
npm run dev

# Or run in production mode
npm start
```

## API Endpoints

### FastAPI Service (Port 8000)

#### Health & Info
- `GET /` - Root endpoint with API information
- `GET /health` - Health check endpoint

#### Object Detection
- `POST /api/detect` - Upload and analyze a photo to detect objects
  ```bash
  curl -X POST "http://localhost:8000/api/detect" \
    -F "file=@photo.jpg" \
    -F "location=living_room"
  ```

#### Object Queries
- `GET /api/objects` - List all detected objects
- `GET /api/objects/{object_name}/last-seen` - Get last seen location and time
  ```bash
  curl "http://localhost:8000/api/objects/chair/last-seen"
  ```
- `GET /api/objects/{object_name}/history` - Get detection history
  ```bash
  curl "http://localhost:8000/api/objects/chair/history?limit=10"
  ```

### Baileys WhatsApp Service (Port 3000)

#### Connection & Status
- `GET /` - Service information
- `GET /health` - Health check endpoint
- `GET /qr` - Get QR code for WhatsApp authentication
  ```bash
  curl "http://localhost:3000/qr"
  ```
- `GET /status` - Get authentication status
  ```bash
  curl "http://localhost:3000/status"
  ```

#### Messaging
- `POST /send-message` - Send a WhatsApp message
  ```bash
  curl -X POST "http://localhost:3000/send-message" \
    -H "Content-Type: application/json" \
    -d '{"number": "1234567890", "message": "Hello!"}'
  ```

#### Authentication
- `POST /logout` - Logout from WhatsApp
  ```bash
  curl -X POST "http://localhost:3000/logout"
  ```

### Interactive API Documentation

Once services are running, access the interactive API documentation:

- FastAPI Swagger UI: http://localhost:8000/docs
- FastAPI ReDoc: http://localhost:8000/redoc

## CI/CD Pipeline

The project includes a comprehensive GitHub Actions CI/CD pipeline that:

### 1. Build & Test Phase
- ✅ Builds and tests Python FastAPI service
- ✅ Builds and tests Node.js Baileys service
- ✅ Runs linting (flake8 for Python)
- ✅ Executes unit tests
- ✅ Validates Docker builds

### 2. Integration Test Phase
- ✅ Tests full Docker Compose stack
- ✅ Validates service health endpoints
- ✅ Checks database connectivity
- ✅ Verifies inter-service communication

### 3. Package & Deploy Phase (on main branch)
- ✅ Builds production Docker images
- ✅ Pushes images to GitHub Container Registry
- ✅ Creates deployment artifacts
- ✅ Demonstrates deployment process

### Pipeline Triggers

The CI/CD pipeline runs on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Manual workflow dispatch

### Viewing Pipeline Results

1. Go to the repository's **Actions** tab
2. Click on the latest workflow run
3. View logs for each job
4. Download deployment artifacts if needed

### Manual Deployment

To deploy manually using the pipeline artifacts:

1. Download the deployment package from GitHub Actions artifacts
2. Extract the package on your server
3. Configure `.env` file with your settings
4. Pull the latest images:
   ```bash
   docker compose pull
   ```
5. Start the services:
   ```bash
   docker compose up -d
   ```

## Configuration

### Environment Variables

#### Docker Compose (.env or .env.docker)
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

#### FastAPI Service (.env.example)
```bash
API_HOST=0.0.0.0
API_PORT=8000
YOLO_MODEL=yolov8n.pt
CONFIDENCE_THRESHOLD=0.5
DATABASE_PATH=wife_detections.db
```

#### Baileys Service (baileys-service/.env.example)
```bash
PORT=3000
HOST=0.0.0.0
LOG_LEVEL=info
```

## Volumes and Data Persistence

The Docker Compose setup uses named volumes for data persistence:

- `wife-data`: FastAPI application data and SQLite database
- `postgres-data`: PostgreSQL database files
- `baileys-auth`: WhatsApp authentication session data
- `portainer-data`: Portainer configuration and settings
- `./uploads`: Mounted directory for uploaded images

To backup your data:
```bash
docker compose down
docker run --rm -v wife-data:/data -v $(pwd):/backup alpine tar czf /backup/wife-data-backup.tar.gz -C /data .
docker run --rm -v postgres-data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-data-backup.tar.gz -C /data .
docker run --rm -v portainer-data:/data -v $(pwd):/backup alpine tar czf /backup/portainer-data-backup.tar.gz -C /data .
```

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Change ports in .env file
   API_PORT=8001
   BAILEYS_PORT=3001
   POSTGRES_PORT=5433
   PORTAINER_PORT=9001
   ```

2. **Container fails to start**
   ```bash
   # Check logs
   docker compose logs [service-name]
   
   # Rebuild containers
   docker compose build --no-cache
   docker compose up -d
   ```

3. **WhatsApp QR code not appearing**
   ```bash
   # Check Baileys service logs
   docker compose logs baileys-service
   
   # Get QR code via API
   curl http://localhost:3000/qr
   ```

4. **Database connection issues**
   ```bash
   # Verify PostgreSQL is running
   docker compose ps postgres
   
   # Check PostgreSQL logs
   docker compose logs postgres
   ```

### Resetting Everything

To completely reset the application and remove all data:
```bash
docker compose down -v
docker compose up -d
```

## Technologies

This project uses the following technologies:

### Backend
- [FastAPI](https://fastapi.tiangolo.com/) - Modern web framework for building APIs
- [Ultralytics YOLO](https://github.com/ultralytics/ultralytics) - State-of-the-art object detection
- [OpenCV](https://opencv.org/) - Computer vision library
- [Pillow](https://python-pillow.org/) - Image processing
- [SQLite](https://www.sqlite.org/) - Embedded database
- [aiosqlite](https://aiosqlite.omnilib.dev/) - Async SQLite driver

### WhatsApp Integration
- [Baileys](https://github.com/WhiskeySockets/Baileys) - WhatsApp Web API library
- [Express.js](https://expressjs.com/) - Web framework for Node.js
- [QRCode](https://www.npmjs.com/package/qrcode) - QR code generation

### Infrastructure
- [Docker](https://www.docker.com/) - Containerization platform
- [Docker Compose](https://docs.docker.com/compose/) - Multi-container orchestration
- [PostgreSQL](https://www.postgresql.org/) - Relational database
- [GitHub Actions](https://github.com/features/actions) - CI/CD automation

## License

This project is licensed under the MIT License - see the LICENSE file for details.
