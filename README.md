# Peazy - Learn by Doing AI Coach

Peazy transforms corporate software training from **"watch-to-learn"** into **"learn-by-doing."** An AI coach speaks to the learner and waits while the learner performs each step. Peazy also supports on-the-spot **Ask-Me-Anything** (AMA) help.

> **Note:** Pointer overlay and extension features are deferred to v0.2. v0.1 is voice-only.

## 🚀 Quick Start

The platform consists of two main components:
- **Agent**: FastAPI service for flow management and demo execution
- **Dashboard**: Next.js web interface for flow editing and session management

## 🏗️ Monorepo Structure

| Directory | Purpose | Tech Stack |
|-----------|---------|------------|
| `/apps/dashboard` | Next.js admin interface | React, voice-ui-kit, Pipecat Flows |
| `/apps/agent` | Python Pipecat agent | Python, Pipecat, Gemini |
| `/infra/` | Terraform & K8s manifests | Terraform, Helm, GKE |
| `/scripts/` | Development helpers | Shell, Python |
| `/docs/` | Architecture & ADRs | Markdown, Mermaid |

## 🚀 Quick Start

```bash
# Install dependencies
pnpm install

# Start local development
make dev

# Run linting and tests
pnpm lint && pnpm test
```

## 📋 Development

- **Branch naming**: `feat/<ticket>-<slug>`, `fix/<ticket>-<slug>`
- **Commits**: Conventional Commits format
- **Testing**: ≥80% coverage required
- **Security**: No secrets in code, use GCP Secret Manager

See `.cursor/rules/` for detailed development guidelines.

## 🎯 MVP Goals (v0.1.0)

- [ ] Fluid step-by-step guided tutorial with voice
- [ ] AMA query resolution feels natural
- [ ] Authoring experience delights Training Managers
- [ ] Cost visibility with real-time dashboard

## 📚 Documentation

- [Local Setup Guide](docs/local-setup.md)
- [Architecture Decision Records](docs/adr-0001-monorepo-bootstrap.md)
- [Product Requirements Document](docs/Peazy%20v0.1.0%20PRD) 