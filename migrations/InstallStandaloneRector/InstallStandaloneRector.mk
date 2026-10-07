CURRENT_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
RECTOR_DIRECTORY := $(PROJECT_DIR)tools/rector
HAS_RECTOR_DIR := $(shell if [ -d $(RECTOR_DIRECTORY) ]; then echo -n TRUE; fi)

ifneq ("$(HAS_RECTOR_DIR)","TRUE")

PROJECT_COMPOSER_PLATFORM := $(shell $(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer config platform.php)
HELP += $(call MK_HELP,'install-rector','Install a standalone copy of rector into tools/rector')

install-rector: _do-install-rector $(RECTOR_DIRECTORY)
.PHONY: install-rector

_do-install-rector:
	@$(call MK_INFO,"Installing Rector")
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} php $(CURRENT_DIRECTORY)migrate $(PROJECT_DIR)
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
	cp $(CURRENT_DIRECTORY)templates/rector.php $(RECTOR_DIRECTORY)/
	echo vendor > $(RECTOR_DIRECTORY)/.gitignore
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(RECTOR_DIRECTORY) \
    		install
# end

endif
