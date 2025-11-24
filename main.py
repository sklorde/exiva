"""
WIFE - Where Is For Everyone
Main FastAPI application entry point
"""
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
from typing import Optional, List
from datetime import datetime
import os
import uuid
from pathlib import Path
from contextlib import asynccontextmanager

from app.services.object_detection import ObjectDetectionService
from app.services.database import DatabaseService
from app.models.schemas import (
    DetectionResponse,
    ObjectInfo,
    LastSeenResponse,
    HealthResponse
)

# Create uploads directory
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

# Initialize services
detection_service = ObjectDetectionService()
db_service = DatabaseService()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifespan (startup and shutdown)"""
    # Startup
    await detection_service.initialize()
    await db_service.initialize()
    yield
    # Shutdown
    await db_service.close()


# Initialize FastAPI app
app = FastAPI(
    title="WIFE - Where Is For Everyone",
    description="Object recognition and tracking microservice",
    version="1.0.0",
    lifespan=lifespan
)


@app.get("/", tags=["Root"])
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Welcome to WIFE - Where Is For Everyone",
        "description": "Object recognition and tracking API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health", response_model=HealthResponse, tags=["Health"])
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        timestamp=datetime.now().isoformat(),
        service="WIFE API"
    )


@app.post("/api/detect", response_model=DetectionResponse, tags=["Detection"])
async def detect_objects(
    file: UploadFile = File(..., description="Image file to analyze"),
    location: str = Form(..., description="Location identifier (e.g., 'living_room', 'bedroom')")
):
    """
    Detect objects in an uploaded image and store their location.
    
    - **file**: Image file (JPEG, PNG)
    - **location**: Location where the photo was taken
    """
    # Validate file type from content
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    # Generate secure filename using UUID
    file_extension = Path(file.filename).suffix if file.filename else ".jpg"
    secure_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = UPLOAD_DIR / secure_filename
    
    try:
        # Save uploaded file
        contents = await file.read()
        
        # Additional validation: try to verify it's actually an image
        try:
            from PIL import Image
            import io
            Image.open(io.BytesIO(contents)).verify()
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid image file")
        
        with open(file_path, "wb") as f:
            f.write(contents)
        
        # Detect objects
        detections = await detection_service.detect_objects(str(file_path))
        
        # Store detections in database
        timestamp = datetime.now()
        for detection in detections:
            await db_service.add_detection(
                object_name=detection["name"],
                location=location,
                confidence=detection["confidence"],
                timestamp=timestamp
            )
        
        return DetectionResponse(
            success=True,
            objects_detected=len(detections),
            detections=detections,
            location=location,
            timestamp=timestamp.isoformat()
        )
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")
    finally:
        # Clean up file in all cases
        if file_path.exists():
            os.remove(file_path)


@app.get("/api/objects", response_model=List[str], tags=["Objects"])
async def list_objects():
    """
    Get a list of all unique objects that have been detected.
    """
    objects = await db_service.get_all_objects()
    return objects


@app.get("/api/objects/{object_name}/last-seen", response_model=LastSeenResponse, tags=["Objects"])
async def get_last_seen(object_name: str):
    """
    Get the last known location and timestamp for a specific object.
    
    - **object_name**: Name of the object to query
    """
    detection = await db_service.get_last_seen(object_name)
    
    if not detection:
        raise HTTPException(
            status_code=404,
            detail=f"Object '{object_name}' has not been detected yet"
        )
    
    return LastSeenResponse(
        object_name=object_name,
        location=detection["location"],
        timestamp=detection["timestamp"],
        confidence=detection["confidence"]
    )


@app.get("/api/objects/{object_name}/history", response_model=List[ObjectInfo], tags=["Objects"])
async def get_object_history(
    object_name: str,
    limit: Optional[int] = 10
):
    """
    Get detection history for a specific object.
    
    - **object_name**: Name of the object to query
    - **limit**: Maximum number of records to return (default: 10)
    """
    history = await db_service.get_object_history(object_name, limit)
    
    if not history:
        raise HTTPException(
            status_code=404,
            detail=f"No history found for object '{object_name}'"
        )
    
    return [
        ObjectInfo(
            object_name=record["object_name"],
            location=record["location"],
            confidence=record["confidence"],
            timestamp=record["timestamp"]
        )
        for record in history
    ]


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
