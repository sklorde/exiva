# WIFE - Where Is For Everyone

<p align="center">
   <a href="https://www.python.org/" target="_blank" rel="noopener noreferrer"><img src="https://img.shields.io/badge/python-3.8+-blue.svg?style=for-the-badge&logo=python"></a>
   <a href="https://fastapi.tiangolo.com/"><img src="https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi"></a>
</p>

<p align="center">A microservices-based object recognition and tracking system</p>

<p align="center">
  <a href="#about">About</a> •
  <a href="#features">Features</a> •
  <a href="#how-to-use">How to Use</a> •
  <a href="#api-endpoints">API Endpoints</a> •
  <a href="#license">License</a>
</p>

## About

WIFE (Where Is For Everyone) is a microservices-based system built with Python and FastAPI that provides object recognition and tracking capabilities. The system can analyze photos to detect objects and track where each object was last seen, making it perfect for home monitoring, inventory management, and personal item tracking.

## Features

- 🔍 **Object Recognition**: Detect and identify objects in uploaded photos using advanced computer vision
- 📍 **Location Tracking**: Track where each object was last seen with timestamp information
- 🚀 **FastAPI**: High-performance API built with modern Python async framework
- 📷 **Photo Upload**: Support for uploading photos from cameras or devices
- 🔎 **Query System**: REST API to query when and where objects were last detected

## How to Use

### Prerequisites

- Python 3.8 or higher
- pip (Python package installer)

### Installation

```bash
# Clone this repository
$ git clone https://github.com/sklorde/exiva

# Go into the repository
$ cd exiva

# Create a virtual environment
$ python -m venv venv

# Activate virtual environment
# On Windows:
$ venv\Scripts\activate
# On macOS/Linux:
$ source venv/bin/activate

# Install dependencies
$ pip install -r requirements.txt

# Run the application
$ uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

### Quick Start

1. Upload a photo with objects:
```bash
curl -X POST "http://localhost:8000/api/detect" \
  -F "file=@photo.jpg" \
  -F "location=living_room"
```

2. Query where an object was last seen:
```bash
curl "http://localhost:8000/api/objects/chair/last-seen"
```

## API Endpoints

### Object Detection
- `POST /api/detect` - Upload and analyze a photo to detect objects
  - Parameters: 
    - `file`: Image file (jpg, png)
    - `location`: Location identifier (e.g., "living_room", "bedroom")

### Object Queries
- `GET /api/objects` - List all detected objects
- `GET /api/objects/{object_name}/last-seen` - Get last seen location and time for specific object
- `GET /api/objects/{object_name}/history` - Get detection history for an object

### Health Check
- `GET /health` - Check API health status

## Technologies

This project uses the following technologies:
- [FastAPI](https://fastapi.tiangolo.com/) - Modern web framework for building APIs
- [Ultralytics YOLO](https://github.com/ultralytics/ultralytics) - State-of-the-art object detection
- [OpenCV](https://opencv.org/) - Computer vision library
- [Pillow](https://python-pillow.org/) - Image processing
- [SQLite](https://www.sqlite.org/) - Database for tracking object detections

## License

This project is licensed under the MIT License - see the LICENSE file for details.
