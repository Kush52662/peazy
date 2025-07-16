.PHONY: help dev build test lint clean install

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

dev: ## Start local development stack
	docker compose up --build

build: ## Build all applications
	cd apps/extension && pnpm build
	cd apps/dashboard && npm run build
	cd apps/agent && poetry run python -m pytest

test: ## Run all tests
	cd apps/extension && pnpm test
	cd apps/dashboard && npm run test
	cd apps/agent && poetry run pytest

lint: ## Run linting for all apps
	cd apps/extension && pnpm lint
	cd apps/dashboard && npm run lint
	cd apps/agent && poetry run ruff check . && poetry run black --check .

install: ## Install all dependencies
	pnpm install
	cd apps/extension && pnpm install
	cd apps/dashboard && npm install
	cd apps/agent && poetry install

clean: ## Clean build artifacts
	cd apps/extension && pnpm clean
	cd apps/dashboard && npm run clean
	docker compose down -v
	docker system prune -f

setup: install ## Setup development environment
	@echo "Development environment setup complete!"
	@echo "Run 'make dev' to start the local stack" 