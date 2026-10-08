_INFECTION_MIGRATION_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
INFECTION_DIRECTORY := $(PROJECT_DIR)tools/infection
HAS_INFECTION_DIR := $(strip $(shell if [ -d $(INFECTION_DIRECTORY) ]; then echo TRUE; fi))

ifneq ("$(HAS_INFECTION_DIR)","TRUE")

PROJECT_COMPOSER_PLATFORM := $(shell $(DOCKER_RUN) $(DOCKER_IMAGE_NAME) composer -qn config platform.php)
HELP += $(call MK_HELP,'install-infection','Install a standalone copy of infection into tools/infection')

install-infection: install-mago $(INFECTION_DIRECTORY) .github/workflows/infection.yml _do-install-infection
.PHONY: install-infection

_do-install-infection:
	@$(DOCKER_RUN) --env PHP_EXTENSIONS="$(PHP_EXTENSIONS)" $(DOCKER_IMAGE_NAME) php $(_INFECTION_MIGRATION_DIRECTORY)migrate $(PROJECT_DIR)
.PHONY: _do-install-infection

# Installation routine for infection:
$(INFECTION_DIRECTORY):
	mkdir -p $(INFECTION_DIRECTORY)
	cp $(_INFECTION_MIGRATION_DIRECTORY)composer-template.json $(INFECTION_DIRECTORY)/composer.json
	$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) composer \
		--working-dir=$(INFECTION_DIRECTORY) \
		config platform.php $(PROJECT_COMPOSER_PLATFORM)
	$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) composer \
		--working-dir=$(INFECTION_DIRECTORY) \
		require --dev infection/infection
	cp $(_INFECTION_MIGRATION_DIRECTORY)infection.json $(PROJECT_DIR)/
	echo vendor > $(INFECTION_DIRECTORY)/.gitignore
	echo infection.log.txt >> $(INFECTION_DIRECTORY)/.gitignore
# end

# Install the default workflow for infection in CI
.github/workflows/infection.yml:
	cp $(_INFECTION_MIGRATION_DIRECTORY)github-workflow.yml .github/workflows/infection.yml

endif
