ASSETS?=$(shell pwd)/apps/ui/assets

APP_VSN ?= `git describe --abbrev=0 --tags`
BUILD ?= `git rev-parse --short HEAD`

# Read env file
sinclude env
export $(shell sed 's/=.*//' env)

.PHONY: help
help:
	@echo "soundfeed:$(APP_VSN)-$(BUILD)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | \
	sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Install dependencies
	@CLIENT_ID=${CLIENT_ID}; \
	mix deps.get && \
	mix deps.compile && \
	mix cmd --app ui "(cd ${ASSETS} && yarn install) || true"

.PHONY: start
start: ## Start the server in dev mode
	@CLIENT_ID=${CLIENT_ID} iex -S mix phx.server

.PHONY: build
build: ## Build a minimal docker container with the release
	@docker build -t soundfeed --build-arg CLIENT_ID=${CLIENT_ID} . && \
	docker tag soundfeed:latest soundfeed:$(APP_VSN)-$(BUILD)

.PHONY: start-release
start-release: ## Start the docker container
	 @docker run -it --rm \
		--name soundfeed \
		-p 8080:8080 \
		-e ERLANG_COOKIE=${ERLANG_COOKIE} \
		-e CLIENT_ID=${CLIENT_ID} \
		soundfeed:latest

.PHONY: deploy
deploy: ## Deploy
	@git push prod master
