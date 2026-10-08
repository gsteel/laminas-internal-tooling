_STRUCT_ARMED_MIGRATION_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
STRUCT_ARMED_DIRECTORY := $(PROJECT_DIR)tools/structarmed
HAS_STRUCT_ARMED_DIR := $(strip $(shell if [ -d $(STRUCT_ARMED_DIRECTORY) ]; then echo TRUE; fi))

ifneq ("$(HAS_STRUCT_ARMED_DIR)","TRUE")

PROJECT_COMPOSER_PLATFORM := $(shell $(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer config platform.php)
HELP += $(call MK_HELP,'install-structarmed','Install a standalone copy of structarmed into tools/structarmed')

install-structarmed: $(STRUCT_ARMED_DIRECTORY) _do-install-structarmed
	@echo 'Now StructArmed is installed, you should edit its configuration file to define appropriate layers:'
	@echo 'https://boundwize.github.io/structarmed/configuration/'
.PHONY: install-structarmed

_do-install-structarmed:
	@$(DOCKER_RUN) --env PHP_EXTENSIONS="$(PHP_EXTENSIONS)" ${DOCKER_IMAGE_NAME} php $(_STRUCT_ARMED_MIGRATION_DIRECTORY)migrate $(PROJECT_DIR)
.PHONY: _do-install-structarmed

# Installation routine for rector:
$(STRUCT_ARMED_DIRECTORY):
	mkdir -p $(STRUCT_ARMED_DIRECTORY)
	echo '{}' > $(STRUCT_ARMED_DIRECTORY)/composer.json
	$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) composer \
		--working-dir=$(STRUCT_ARMED_DIRECTORY) \
		config platform.php $(PROJECT_COMPOSER_PLATFORM)
	$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) composer \
		--working-dir=$(STRUCT_ARMED_DIRECTORY) \
		require --dev boundwize/structarmed
	cp $(_STRUCT_ARMED_MIGRATION_DIRECTORY)structarmed.php $(STRUCT_ARMED_DIRECTORY)/
	echo vendor > $(STRUCT_ARMED_DIRECTORY)/.gitignore
	$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) composer \
    		--working-dir=$(STRUCT_ARMED_DIRECTORY) \
    		install
# end

endif
