"""
Example script demonstrating how to use the WIFE API
"""
import requests
import json
from pathlib import Path


def test_api():
    """Test the WIFE API with example requests"""
    
    BASE_URL = "http://localhost:8000"
    
    # 1. Check health
    print("1. Checking API health...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"   Status: {response.json()['status']}")
    print()
    
    # 2. Upload an image for detection
    print("2. Uploading image for detection...")
    print("   Note: Replace 'test_image.jpg' with an actual image file")
    print("   Example curl command:")
    print(f'   curl -X POST "{BASE_URL}/api/detect" \\')
    print(f'     -F "file=@test_image.jpg" \\')
    print(f'     -F "location=living_room"')
    print()
    
    # 3. List all detected objects
    print("3. Listing all detected objects...")
    print(f"   GET {BASE_URL}/api/objects")
    print()
    
    # 4. Query last seen location
    print("4. Querying last seen location for an object...")
    print("   Example for 'chair':")
    print(f'   GET {BASE_URL}/api/objects/chair/last-seen')
    print()
    
    # 5. Get object history
    print("5. Getting object detection history...")
    print("   Example for 'chair' with limit of 5:")
    print(f'   GET {BASE_URL}/api/objects/chair/history?limit=5')
    print()
    
    print("API Documentation available at:")
    print(f"   {BASE_URL}/docs (Swagger UI)")
    print(f"   {BASE_URL}/redoc (ReDoc)")


if __name__ == "__main__":
    print("=" * 60)
    print("WIFE API - Usage Examples")
    print("=" * 60)
    print()
    print("Make sure the API is running with:")
    print("  uvicorn main:app --reload")
    print()
    print("=" * 60)
    print()
    
    test_api()
