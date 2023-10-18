.DEFAULT_GOAL := help
include .config
export

.PHONY: debug
debug: ## debug
	echo ${version}

.PHONY: tag
tag: ## Tag git repo
	git tag -a ${version} -m "Bump ${version}"
	git push origin main --follow-tags

.PHONY: tag
build: ## Build Docker image
	echo "[${version}]"
	docker build --tag ghcr.io/${GITHUB_OWNER}/nvvs/terraform:${version} .

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
