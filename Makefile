ASSETS?=$(shell pwd)/apps/soundfeed_web/assets
VERSION=$(shell cat VERSION)

# Read env file
sinclude env
export $(shell sed 's/=.*//' env)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | \
	sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Install dependencies
	@CLIENT_ID=${CLIENT_ID}; \
	mix deps.get && \
	mix deps.compile && \
	mix cmd --app soundfeed_web "(cd ${ASSETS} && yarn install) || true"

.PHONY: start
start: ## Start the server in dev mode
	@CLIENT_ID=${CLIENT_ID} iex -S mix phx.server

.PHONY: lint
lint: ## Lint code with Credo
	@mix credo

.PHONY: analyze
analyze: ## Run a static analysis with Dialyzer
	@mix dialyzer

.PHONY: build
build: ## Build a minimal docker container with the release
	@docker build \
		-t "soundfeed" \
		--build-arg CLIENT_ID=${CLIENT_ID} \
		--build-arg VERSION=${VERSION} \
		. && \
	docker tag soundfeed:latest soundfeed:${VERSION}


.PHONY: start-release
start-release: ## Start the docker container
	 @docker run -it --rm \
		--name soundfeed \
		-p 8080:8080 \
		-e ERLANG_COOKIE=${ERLANG_COOKIE} \
		-e CLIENT_ID=${CLIENT_ID} \
		soundfeed:${VERSION}
