APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

.PHONY: help
help:
	@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | \
	sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build image containing the release
	@docker build \
		-t ghcr.io/adriankumpf/$(APP_NAME):$(APP_VSN) \
		-t ghcr.io/adriankumpf/$(APP_NAME):latest \
		-t $(APP_NAME):$(APP_VSN) \
		-t $(APP_NAME) .

.PHONY: publish
publish: ## Publish image to the GitHub package registryt
	@docker push ghcr.io/adriankumpf/$(APP_NAME):$(APP_VSN)
	@docker push ghcr.io/adriankumpf/$(APP_NAME):latest

.PHONY: run
run: ## Run the app in Docker
	@docker run --env-file .env \
			--expose 4000 -p 4000:4000 \
			--rm -it $(APP_NAME)
