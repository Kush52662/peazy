# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
COPY webapp/requirements.txt ./webapp/
COPY bots/requirements.txt ./bots/

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port (Cloud Run will override this)
EXPOSE 8080

# Set environment variables
ENV PYTHONPATH=/app

# Run the application using PORT environment variable from Cloud Run
CMD ["python", "sesame.py", "run", "--host", "0.0.0.0", "--port", "$PORT", "--no-reload"] 