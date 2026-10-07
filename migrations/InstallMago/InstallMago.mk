#
# Installs Mago as a project dependency
#

HAS_MAGO = FALSE
ifneq ("$(wildcard mago.toml)","")
    HAS_MAGO = TRUE
endif

ifeq ("$(HAS_MAGO)","FALSE")

CURRENT_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

HELP += $(call MK_HELP,'install-mago','Install Mago with initial configuration')

install-mago: _do-mago-composer-install $(PROJECT_DIR)mago.toml _do-mago-migration-tasks
.PHONY: install-mago

$(PROJECT_DIR)mago.toml:
	cp $(CURRENT_DIRECTORY)mago-template.toml $(PROJECT_DIR)mago.toml
	cp $(CURRENT_DIRECTORY)baseline-template.toml $(PROJECT_DIR)baseline.lint.toml
	cp $(CURRENT_DIRECTORY)baseline-template.toml $(PROJECT_DIR)baseline.sa.toml

_do-mago-migration-tasks:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} php $(CURRENT_DIRECTORY)migrate $(PROJECT_DIR)
.PHONY: _do-mago-migration-tasks

_do-mago-composer-install:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer require --dev carthage-software/mago
.PHONY: _do-mago-composer-install

endif
