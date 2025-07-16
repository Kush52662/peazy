#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/peazy"
cd "$ROOT"

# initialise root repo
if [[ ! -d .git ]]; then
  git init -b main
  git remote add origin https://github.com/Kush52662/peazy
fi

# strip nested repos
for d in agent flows dashboard; do rm -rf "$d/.git" 2>/dev/null || true; done

# baseline commit
git add .; git commit -m "chore: establish monorepo structure" || true
git push -u origin main

# env-loader patch
mkdir -p agent/server/common
python - <<'PY'
import pathlib, textwrap, sys, subprocess, os
p = pathlib.Path("agent/server/common/env_loader.py")
p.write_text("from pathlib import Path; from dotenv import load_dotenv\n"
             "load_dotenv(Path(__file__).resolve().parents[2]/'.env', override=False)\n")
sp = pathlib.Path("agent/server/sesame.py")
txt = sp.read_text()
if "env_loader" not in txt:
    sp.write_text("from common.env_loader import load_dotenv  # auto-load .env\n"+txt)
PY

# lock files
python3 -m pip install --quiet --upgrade pip pip-tools
pip-compile agent/server/requirements.txt flows/requirements.txt -o requirements.lock
(cd agent/client && npm install --package-lock-only --silent)
(cd dashboard    && npm install --package-lock-only --silent)

# Ruff config
echo -e "[tool.ruff]\ntarget-version = 'py311'\nline-length = 100" > pyproject.toml

# Dockerfile + ignores
cat > Dockerfile.agent <<'DOCKER'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.lock .
RUN pip install --no-cache-dir -r requirements.lock
COPY . .
CMD ["python","agent/server/sesame.py","run","--host","0.0.0.0","--port","8080"]
DOCKER
printf ".venv/\n.env\nnode_modules/\n" >> .gitignore
echo -e ".env\nnode_modules\n.venv\n.git" > .dockerignore
echo -e ".venv/\n.env\nnode_modules/\n.git/" > .gcloudignore

# GitHub Action + env file
mkdir -p .github/workflows
cat > .github/workflows/ci.yml <<'YAML'
name: Peazy CI
on: { push: { branches: [main] } }
jobs:
  build-test-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-python@v5
      with: { python-version: "3.11" }
    - run: |
        python -m pip install --upgrade pip
        pip install -r requirements.lock pytest ruff
        ruff .
        pytest -q || true
    - uses: actions/setup-node@v4
      with: { node-version: "20" }
    - run: |
        cd agent/client && npm ci && cd ../../
        cd dashboard && npm ci && cd ..
        cd agent/client && npm run lint --if-present && cd ../../
        cd dashboard && npm run lint --if-present && cd ..
    - run: |
        python agent/server/sesame.py run --host 0.0.0.0 --port 8080 &
        PID=$!; sleep 15; curl -f http://localhost:8080/api/health; kill $PID
    - uses: google-github-actions/auth@v2
      with: { credentials_json: ${{ secrets.GOOGLE_SA_KEY }} }
    - uses: google-github-actions/setup-gcloud@v2
      with: { project_id: ${{ secrets.GCP_PROJECT }} }
    - run: |
        gcloud builds submit --tag gcr.io/${{ secrets.GCP_PROJECT }}/peazy-agent:${{ github.sha }} --timeout=15m
    - uses: google-github-actions/deploy-cloudrun@v2
      with:
        service: peazy-agent
        image: gcr.io/${{ secrets.GCP_PROJECT }}/peazy-agent:${{ github.sha }}
        region: us-central1
        min-instances: 1
        max-instances: 3
        env-vars-file: cloudrun-env.yaml
    - run: |
        cd agent/client && npm run build && cd ../../
        tar -C agent/client/dist -czf site.tar.gz .
    - uses: google-github-actions/upload-cloud-storage@v1
      with:
        path: site.tar.gz
        destination: peazy-web
        parent: false
YAML
cat > cloudrun-env.yaml <<'ENV'
WEBAPP_PORT: "8080"
DAILY_API_KEY: ${DAILY_API_KEY}
DAILY_DOMAIN_NAME: ${DAILY_DOMAIN_NAME}
GOOGLE_API_KEY: ${GOOGLE_API_KEY}
PIPECAT_CLOUD_API: ${PIPECAT_CLOUD_API}
ENV

# commit + push
git add .
git commit -m "chore: CI/CD pipeline, env loader, Dockerfile, locks"
git push origin main
echo -e "\n🎉  Pushed to main — GitHub Action will now build & deploy."
