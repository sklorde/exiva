"""
WIFE - Where Is For Everyone
Main FastAPI application entry point
"""
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
from typing import Optional, List
from datetime import datetime
import os
from pathlib import Path

from app.services.object_detection import ObjectDetectionService
from app.services.database import DatabaseService
from app.models.schemas import (
    DetectionResponse,
    ObjectInfo,
    LastSeenResponse,
    HealthResponse
)

# Initialize FastAPI app
app = FastAPI(
    title="WIFE - Where Is For Everyone",
    description="Object recognition and tracking microservice",
    version="1.0.0"
)

# Initialize services
detection_service = ObjectDetectionService()
db_service = DatabaseService()

# Create uploads directory
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)


@app.on_event("startup")
async def startup_event():
    """Initialize database on startup"""
    await db_service.initialize()


@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    await db_service.close()


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
    # Validate file type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    # Save uploaded file temporarily
    file_path = UPLOAD_DIR / f"{datetime.now().timestamp()}_{file.filename}"
    try:
        contents = await file.read()
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
        
        # Clean up file
        os.remove(file_path)
        
        return DetectionResponse(
            success=True,
            objects_detected=len(detections),
            detections=detections,
            location=location,
            timestamp=timestamp.isoformat()
        )
    
    except Exception as e:
        # Clean up file on error
        if file_path.exists():
            os.remove(file_path)
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")


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
