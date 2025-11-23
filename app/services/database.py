"""
Database Service for storing object detections
"""
import aiosqlite
from typing import List, Dict, Optional
from datetime import datetime
from pathlib import Path


class DatabaseService:
    """Service for managing object detection database"""
    
    def __init__(self, db_path: str = "wife_detections.db"):
        """
        Initialize the database service.
        
        Args:
            db_path: Path to SQLite database file
        """
        self.db_path = db_path
        self.db = None
        
    async def initialize(self):
        """Initialize database and create tables"""
        self.db = await aiosqlite.connect(self.db_path)
        await self._create_tables()
        
    async def _create_tables(self):
        """Create database tables if they don't exist"""
        await self.db.execute("""
            CREATE TABLE IF NOT EXISTS detections (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                object_name TEXT NOT NULL,
                location TEXT NOT NULL,
                confidence REAL NOT NULL,
                timestamp TEXT NOT NULL
            )
        """)
        
        # Create index for faster queries
        await self.db.execute("""
            CREATE INDEX IF NOT EXISTS idx_object_name 
            ON detections(object_name)
        """)
        
        await self.db.execute("""
            CREATE INDEX IF NOT EXISTS idx_timestamp 
            ON detections(timestamp DESC)
        """)
        
        await self.db.commit()
        
    async def add_detection(
        self,
        object_name: str,
        location: str,
        confidence: float,
        timestamp: datetime
    ):
        """
        Add a new object detection to the database.
        
        Args:
            object_name: Name of the detected object
            location: Location where object was detected
            confidence: Detection confidence score
            timestamp: Detection timestamp
        """
        await self.db.execute(
            """
            INSERT INTO detections (object_name, location, confidence, timestamp)
            VALUES (?, ?, ?, ?)
            """,
            (object_name, location, confidence, timestamp.isoformat())
        )
        await self.db.commit()
        
    async def get_last_seen(self, object_name: str) -> Optional[Dict]:
        """
        Get the last known location of an object.
        
        Args:
            object_name: Name of the object to query
            
        Returns:
            Dictionary with location, timestamp, and confidence, or None if not found
        """
        async with self.db.execute(
            """
            SELECT location, timestamp, confidence
            FROM detections
            WHERE object_name = ?
            ORDER BY timestamp DESC
            LIMIT 1
            """,
            (object_name,)
        ) as cursor:
            row = await cursor.fetchone()
            
        if row:
            return {
                "location": row[0],
                "timestamp": row[1],
                "confidence": row[2]
            }
        return None
        
    async def get_object_history(
        self,
        object_name: str,
        limit: int = 10
    ) -> List[Dict]:
        """
        Get detection history for an object.
        
        Args:
            object_name: Name of the object
            limit: Maximum number of records to return
            
        Returns:
            List of detection records
        """
        async with self.db.execute(
            """
            SELECT object_name, location, confidence, timestamp
            FROM detections
            WHERE object_name = ?
            ORDER BY timestamp DESC
            LIMIT ?
            """,
            (object_name, limit)
        ) as cursor:
            rows = await cursor.fetchall()
            
        return [
            {
                "object_name": row[0],
                "location": row[1],
                "confidence": row[2],
                "timestamp": row[3]
            }
            for row in rows
        ]
        
    async def get_all_objects(self) -> List[str]:
        """
        Get list of all unique objects that have been detected.
        
        Returns:
            List of object names
        """
        async with self.db.execute(
            """
            SELECT DISTINCT object_name
            FROM detections
            ORDER BY object_name
            """
        ) as cursor:
            rows = await cursor.fetchall()
            
        return [row[0] for row in rows]
        
    async def close(self):
        """Close database connection"""
        if self.db:
            await self.db.close()
