CURRENT_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

migrate-to-php86: _do-migrate-to-php86 build-php-image-unconditionally bump-dev ## Remove support for PHP 8.2 and add Support for PHP 8.6
.PHONY: migrate-to-php86

_do-migrate-to-php86: build-php-image
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} php $(CURRENT_DIRECTORY)migrate $(_MAKEFILE_DIR)
.PHONY: _do-migrate-to-php86
