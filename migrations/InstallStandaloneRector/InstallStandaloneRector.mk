_RECTOR_MIGRATION_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
RECTOR_DIRECTORY := $(PROJECT_DIR)tools/rector
HAS_RECTOR_DIR := $(strip $(shell if [ -d $(RECTOR_DIRECTORY) ]; then echo TRUE; fi))

ifneq ("$(HAS_RECTOR_DIR)","TRUE")

PROJECT_COMPOSER_PLATFORM := $(shell $(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer config platform.php)
HELP += $(call MK_HELP,'install-rector','Install a standalone copy of rector into tools/rector')

install-rector: .github/workflows/rector.yml $(RECTOR_DIRECTORY) _do-install-rector
.PHONY: install-rector

_do-install-rector:
	@$(DOCKER_RUN) --env PHP_EXTENSIONS="$(PHP_EXTENSIONS)" ${DOCKER_IMAGE_NAME} php $(_RECTOR_MIGRATION_DIRECTORY)migrate $(PROJECT_DIR)
.PHONY: _do-install-rector

# Installation routine for rector:
$(RECTOR_DIRECTORY):
	mkdir -p $(RECTOR_DIRECTORY)
	echo '{}' > $(RECTOR_DIRECTORY)/composer.json
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
		--working-dir=$(RECTOR_DIRECTORY) \
		config platform.php $(PROJECT_COMPOSER_PLATFORM)
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
		--working-dir=$(RECTOR_DIRECTORY) \
		require --dev rector/rector
	cp $(_RECTOR_MIGRATION_DIRECTORY)templates/rector.php $(RECTOR_DIRECTORY)/
	echo vendor > $(RECTOR_DIRECTORY)/.gitignore
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(RECTOR_DIRECTORY) \
    		install
# end

# Install the default workflow for rector in CI
.github/workflows/rector.yml:
	cp $(_RECTOR_MIGRATION_DIRECTORY)templates/github-workflow.yml .github/workflows/rector.yml

endif
