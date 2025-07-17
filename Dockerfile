# ./Dockerfile
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VIRTUALENVS_CREATE=false

# --- install deps ---
COPY requirements.lock .
RUN pip install --no-cache-dir -r requirements.lock

# --- copy source ---
WORKDIR /app
COPY agent/server ./agent/server
# Debug: list path to confirm we copied the file
RUN echo "🔍 sesame.py location:" && find /app -name sesame.py

# === Runtime section ===
WORKDIR /app/agent/server
CMD ["python","sesame.py","run","--host","0.0.0.0","--port","8080"] 