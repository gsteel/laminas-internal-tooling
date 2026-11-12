
ifeq ("$(DOCKER_IMAGE_BUILT)", "TRUE")

COMPOSER_UNUSED_DIRECTORY ?= $(PROJECT_DIR)tools/unused
HAS_COMPOSER_UNUSED := $(strip $(shell if [ -d $(COMPOSER_UNUSED_DIRECTORY) ]; then echo TRUE; fi))

ifeq ("$(HAS_COMPOSER_UNUSED)", "TRUE")

BUMP_TOOLS_TARGETS += composer-unused-bump
UPDATE_TOOLS_TARGETS += composer-unused-update
INSTALL_TOOLS_TARGETS += composer-unused-install

HELP += $(call MK_HELP,'composer-unused','Check for unused dependencies with composer-unused')
QA_TARGETS += composer-unused

composer-unused:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) $(COMPOSER_UNUSED_DIRECTORY)/vendor/bin/composer-unused --configuration=$(COMPOSER_UNUSED_DIRECTORY)/composer-unused.php
.PHONY: composer-unused

composer-unused-update:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(COMPOSER_UNUSED_DIRECTORY) \
    		update
.PHONY: composer-unused-update

composer-unused-install:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(COMPOSER_UNUSED_DIRECTORY) \
    		install
.PHONY: composer-unused-install

composer-unused-bump: composer-unused-update _do-composer-unused-bump composer-unused-update
.PHONY: composer-unused-bump

_do-composer-unused-bump:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(COMPOSER_UNUSED_DIRECTORY) \
    		bump -D
.PHONY: _do-composer-unused-bump

endif # HAS_COMPOSER_UNUSED

endif # DOCKER_IMAGE_BUILT
