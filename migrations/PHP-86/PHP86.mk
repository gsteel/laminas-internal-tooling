CURRENT_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

migrate-to-php86: ## Remove support for PHP 8.2 and add Support for PHP 8.6
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} php $(CURRENT_DIRECTORY)migrate $(_MAKEFILE_DIR)
.PHONY: migrate-to-php86
