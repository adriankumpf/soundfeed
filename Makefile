CWD=$(shell pwd)

ASSETS?=${CWD}/apps/soundfeed_web/assets
BRUNCH?=${ASSETS}/node_modules/brunch/bin/brunch
RELEASE?=${CWD}/_build/prod/rel/soundfeed/bin/soundfeed

PORT=8192

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Install dependencies
	mix deps.get && mix cmd --app soundfeed_web "(cd ${ASSETS} && yarn install) || true"

.PHONY: start
start: ## Start the server in dev mode
	iex -S mix phx.server

.PHONY: start-prod
start-prod: ## Start the server in prod mode
	MIX_ENV=prod PORT=${PORT} mix run --no-halt

.PHONY: clean
clean: ## Clean up build files
	mix cmd --app soundfeed_web "mix phx.digest.clean" && \
	mix do clean, release.clean

.PHONY: build
build: ## Build a release
	${BRUNCH} build --production ${ASSETS} && \
	MIX_ENV=prod mix do cmd --app soundfeed_web "mix phx.digest" && \
	MIX_ENV=prod mix release

.PHONY: start-release
start-release: ## Start the packaged, standalone daemon
	PORT=${PORT} ${RELEASE} foreground
