# own-the-house — declarative entry points. Config as code (principle 6).
# Run targets on the BOX. `make help` lists them.
.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help edge gateway gateway-down agent-hint verify observability

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

edge: ## Step 1: put the box on Tailscale and lock the firewall
	bash scripts/lock-edge.sh

gateway: ## Step 2: start the LiteLLM gateway (needs .env)
	cd gateway && docker compose --env-file ../.env up -d

gateway-down: ## Stop the gateway
	cd gateway && docker compose --env-file ../.env down

agent-hint: ## Step 3: reminder of how to point Claude Code at the gateway
	@echo 'export ANTHROPIC_BASE_URL="http://$${TAILSCALE_IP}:4000"'
	@echo 'export ANTHROPIC_AUTH_TOKEN="$${LITELLM_MASTER_KEY}"'
	@echo 'then: claude mcp add filesystem  &&  claude mcp add github'

verify: ## Check the invariants hold (run anytime)
	bash scripts/preflight.sh

observability: ## OPTIONAL: start the monitoring stack (read optional/observability/README.md first)
	cd optional/observability && docker compose --env-file ../../.env up -d
