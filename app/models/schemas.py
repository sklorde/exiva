"""
Pydantic models for API request/response schemas
"""
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class DetectionResult(BaseModel):
    """Single object detection result"""
    name: str = Field(..., description="Object class name")
    confidence: float = Field(..., description="Detection confidence (0-1)")
    bbox: Optional[List[float]] = Field(None, description="Bounding box coordinates [x1, y1, x2, y2]")


class DetectionResponse(BaseModel):
    """Response for object detection request"""
    success: bool = Field(..., description="Whether detection was successful")
    objects_detected: int = Field(..., description="Number of objects detected")
    detections: List[DetectionResult] = Field(..., description="List of detected objects")
    location: str = Field(..., description="Location where photo was taken")
    timestamp: str = Field(..., description="ISO format timestamp")


class ObjectInfo(BaseModel):
    """Information about a detected object"""
    object_name: str = Field(..., description="Name of the object")
    location: str = Field(..., description="Location where object was seen")
    confidence: float = Field(..., description="Detection confidence")
    timestamp: str = Field(..., description="ISO format timestamp")


class LastSeenResponse(BaseModel):
    """Response for last seen query"""
    object_name: str = Field(..., description="Name of the object")
    location: str = Field(..., description="Last known location")
    timestamp: str = Field(..., description="ISO format timestamp of last detection")
    confidence: float = Field(..., description="Detection confidence")


class HealthResponse(BaseModel):
    """Health check response"""
    status: str = Field(..., description="Service status")
    timestamp: str = Field(..., description="Current timestamp")
    service: str = Field(..., description="Service name")
