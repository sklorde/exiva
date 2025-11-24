FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    libgl1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt

# Pre-download YOLO models to avoid downloading at runtime
# This significantly speeds up container startup and enables offline usage
# Default model can be overridden with --build-arg YOLO_MODEL=yolov8s.pt
ARG YOLO_MODEL=yolov8n.pt
RUN python3 -c "from ultralytics import YOLO; YOLO('${YOLO_MODEL}')" && \
    echo "YOLO model ${YOLO_MODEL} downloaded successfully"

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p uploads data /var/log /app/logs

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application with logging (tee to both file and stdout)
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port 8000 --log-level info 2>&1 | tee /var/log/uvicorn.log"]
