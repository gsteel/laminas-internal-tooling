_COMPOSER_UNUSED_MIGRATION_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMPOSER_UNUSED_DIRECTORY := $(PROJECT_DIR)tools/unused
HAS_COMPOSER_UNUSED_DIR := $(strip $(shell if [ -d $(COMPOSER_UNUSED_DIRECTORY) ]; then echo TRUE; fi))


ifeq ("$(DOCKER_IMAGE_BUILT)", "TRUE")
ifneq ("$(HAS_COMPOSER_UNUSED_DIR)","TRUE")

PROJECT_COMPOSER_PLATFORM := $(shell $(DOCKER_RUN) $(DOCKER_IMAGE_NAME) composer -qn --no-ansi config platform.php)
HELP += $(call MK_HELP,'install-composer-unused','Install a standalone copy of composer-unused into tools/unused')

install-composer-unused: .github/workflows/composer-unused.yml $(COMPOSER_UNUSED_DIRECTORY) _do-install-composer-unused
.PHONY: install-composer-unused

_do-install-composer-unused:
	@$(DOCKER_RUN) --env PHP_EXTENSIONS="$(PHP_EXTENSIONS)" ${DOCKER_IMAGE_NAME} php $(_COMPOSER_UNUSED_MIGRATION_DIRECTORY)migrate $(PROJECT_DIR)
.PHONY: _do-install-composer-unused

# Installation routine for composer unused:
$(COMPOSER_UNUSED_DIRECTORY):
	mkdir -p $(COMPOSER_UNUSED_DIRECTORY)
	echo '{}' > $(COMPOSER_UNUSED_DIRECTORY)/composer.json
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
		--working-dir=$(COMPOSER_UNUSED_DIRECTORY) \
		config platform.php $(PROJECT_COMPOSER_PLATFORM)
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
		--working-dir=$(COMPOSER_UNUSED_DIRECTORY) \
		require --dev icanhazstring/composer-unused
	cp $(_COMPOSER_UNUSED_MIGRATION_DIRECTORY)composer-unused.php $(COMPOSER_UNUSED_DIRECTORY)/
	echo vendor > $(COMPOSER_UNUSED_DIRECTORY)/.gitignore
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(COMPOSER_UNUSED_DIRECTORY) \
    		install
# end

# Install the default workflow for composer-unused in CI
.github/workflows/composer-unused.yml:
	cp $(_COMPOSER_UNUSED_MIGRATION_DIRECTORY)github-workflow.yml .github/workflows/composer-unused.yml

endif # !HAS_COMPOSER_UNUSED_DIR
endif # DOCKER_IMAGE_BUILT
