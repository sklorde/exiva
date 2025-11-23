"""
Object Detection Service using YOLO
"""
from ultralytics import YOLO
from typing import List, Dict
import cv2
import numpy as np
from pathlib import Path
import torch


class ObjectDetectionService:
    """Service for detecting objects in images using YOLO"""
    
    def __init__(self, model_name: str = "yolov8n.pt"):
        """
        Initialize the object detection service.
        
        Args:
            model_name: YOLO model to use (default: yolov8n.pt - nano model)
        """
        # Fix for PyTorch 2.6+ weights_only=True default
        # Add ultralytics classes to safe globals to allow model loading
        try:
            from ultralytics.nn.tasks import DetectionModel, SegmentationModel, ClassificationModel, PoseModel, OBBModel
            torch.serialization.add_safe_globals([
                DetectionModel,
                SegmentationModel, 
                ClassificationModel,
                PoseModel,
                OBBModel
            ])
        except (ImportError, AttributeError):
            # If add_safe_globals doesn't exist (older PyTorch), continue without it
            pass
        
        self.model = YOLO(model_name)
        
    async def detect_objects(self, image_path: str, confidence_threshold: float = 0.5) -> List[Dict]:
        """
        Detect objects in an image.
        
        Args:
            image_path: Path to the image file
            confidence_threshold: Minimum confidence score for detections
            
        Returns:
            List of detected objects with their properties
        """
        # Run inference
        results = self.model(image_path, conf=confidence_threshold, verbose=False)
        
        detections = []
        
        # Process results
        for result in results:
            boxes = result.boxes
            for box in boxes:
                # Get detection information
                class_id = int(box.cls[0])
                confidence = float(box.conf[0])
                bbox = box.xyxy[0].tolist()  # [x1, y1, x2, y2]
                
                # Get class name
                class_name = self.model.names[class_id]
                
                detections.append({
                    "name": class_name,
                    "confidence": round(confidence, 3),
                    "bbox": [round(coord, 2) for coord in bbox]
                })
        
        return detections
    
    def get_available_classes(self) -> List[str]:
        """Get list of object classes the model can detect"""
        return list(self.model.names.values())
