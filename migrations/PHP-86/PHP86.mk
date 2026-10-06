CURRENT_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

HELP += $(call MK_HELP,'migrate-to-php86','Remove support for PHP 8.2 and add Support for PHP 8.6')

migrate-to-php86: _do-migrate-to-php86 build-php-image-unconditionally bump-dev
.PHONY: migrate-to-php86

_do-migrate-to-php86: build-php-image
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} php $(CURRENT_DIRECTORY)migrate $(PROJECT_DIR)
.PHONY: _do-migrate-to-php86
