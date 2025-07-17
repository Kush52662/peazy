FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VIRTUALENVS_CREATE=false

WORKDIR /app
# install universal deps
COPY requirements.lock .
RUN pip install --no-cache-dir -r requirements.lock

# ⬇️ copy actual backend code
COPY agent/server ./agent/server

# launch FastAPI app
CMD ["python", "agent/server/sesame.py", "run", "--host", "0.0.0.0", "--port", "8080"] 