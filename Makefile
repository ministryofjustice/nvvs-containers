.DEFAULT_GOAL := help

REGISTRY		:= ghcr.io
GITHUB_OWNER	:= $$(git config remote.origin.url | cut -d : -f 2 | cut -d / -f 1)
NAME			:= ${GITHUB_OWNER}/nvvs/terraform
TAG				:= $$(git log -1 --pretty=%h)
IMG				:= ${NAME}:${TAG}
LATEST			:= ${NAME}:latest

CURRENT_VERSION := $$(git describe --abbrev=0)
CURRENT_NUMBER	:= $$(echo $(CURRENT_VERSION) | cut -d "v" -f 2)

ifeq ($(SEMVAR),patch)
  NEXT_NUMBER := $$(./semver/increment_version.sh -p $(CURRENT_NUMBER))
else ifeq ($(SEMVAR),minor)
  NEXT_NUMBER := $$(./semver/increment_version.sh -m $(CURRENT_NUMBER))
else ifeq ($(SEMVAR),major)
  NEXT_NUMBER := $$(./semver/increment_version.sh -M $(CURRENT_NUMBER))
endif

NEXT_VERSION := "v$(NEXT_NUMBER)"

.PHONY: debug
debug: ## debug
	@echo $(NEXT_NUMBER)

.PHONY: current_version
current_version: ## Get current version eg v3.4.1
	@echo $(CURRENT_VERSION)
	@echo $(CURRENT_NUMBER)

.PHONY: preview_version
preview_version: ## increment version eg v3.4.1 > v3.5.0. Use SEMVAR=[ patch | minor | major ]
	@echo "CURRENT_VERSION := $(CURRENT_VERSION)"
	@echo "          $(SEMVAR) := $(NEXT_VERSION)"

.PHONY: tag
tag: ## Tag branch in git repo with next version number. Use SEMVAR=[ patch | minor | major ]
	@echo "tagging with $(NEXT_VERSION)"
	@git tag -a "$(NEXT_VERSION)" -m "Bump from $(CURRENT_VERSION) to $(NEXT_VERSION)"
	@git push origin main --follow-tags

.PHONY: build
build: ## Build & tag Docker image
	docker build --tag ${IMG} .
	docker tag ${IMG} ${LATEST}

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
