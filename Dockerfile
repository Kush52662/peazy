FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VIRTUALENVS_CREATE=false

# ─── Build context ───────────────────────────────
WORKDIR /app

# Python deps
COPY requirements.lock .
RUN pip install --no-cache-dir -r requirements.lock

# Application code
#   repo path:   agent/server/…
#   image path:  /app/server/…
COPY agent/server/ ./server/

# launch FastAPI app
CMD ["python", "agent/server/sesame.py", "run", "--host", "0.0.0.0", "--port", "8080"] 