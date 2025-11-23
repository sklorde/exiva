"""
Configuration settings for WIFE application
"""
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings"""
    
    # API settings
    API_TITLE: str = "WIFE - Where Is For Everyone"
    API_VERSION: str = "1.0.0"
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    
    # Model settings
    YOLO_MODEL: str = "yolov8n.pt"  # Nano model for faster inference
    CONFIDENCE_THRESHOLD: float = 0.5
    
    # Database settings
    DATABASE_PATH: str = "wife_detections.db"
    
    # Upload settings
    UPLOAD_DIR: str = "uploads"
    MAX_UPLOAD_SIZE: int = 10 * 1024 * 1024  # 10 MB
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
