# ───────── Peazy backend container ─────────
FROM python:3.11-slim

# Prevent Python stdout buffering
ENV PYTHONUNBUFFERED=1

# Set workdir
WORKDIR /app

# Install Python deps
COPY requirements.lock .
RUN pip install --no-cache-dir -r requirements.lock

# Copy entire repo (agent, flows, dashboard assets if needed)
COPY . .

# Default command: run the FastAPI server
CMD ["python", "-m", "uvicorn", "agent.server.webapp.main:app", "--host", "0.0.0.0", "--port", "8080"] 