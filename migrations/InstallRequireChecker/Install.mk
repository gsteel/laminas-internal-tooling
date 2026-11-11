_CRC_MIGRATION_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
CRC_DIRECTORY := $(PROJECT_DIR)tools/crc
HAS_CRC_DIR := $(strip $(shell if [ -d $(CRC_DIRECTORY) ]; then echo TRUE; fi))


ifeq ("$(DOCKER_IMAGE_BUILT)", "TRUE")
ifneq ("$(HAS_CRC_DIR)","TRUE")

PROJECT_COMPOSER_PLATFORM := $(shell $(DOCKER_RUN) $(DOCKER_IMAGE_NAME) composer -qn --no-ansi config platform.php)
HELP += $(call MK_HELP,'install-crc','Install a standalone copy of composer-require-checker into tools/crc')

install-crc: .github/workflows/require-checker.yml $(CRC_DIRECTORY) _do-install-crc
.PHONY: install-crc

_do-install-crc:
	@$(DOCKER_RUN) --env PHP_EXTENSIONS="$(PHP_EXTENSIONS)" ${DOCKER_IMAGE_NAME} php $(_CRC_MIGRATION_DIRECTORY)migrate $(PROJECT_DIR)
.PHONY: _do-install-crc

# Installation routine for CRC:
$(CRC_DIRECTORY):
	mkdir -p $(CRC_DIRECTORY)
	echo '{}' > $(CRC_DIRECTORY)/composer.json
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
		--working-dir=$(CRC_DIRECTORY) \
		config platform.php $(PROJECT_COMPOSER_PLATFORM)
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
		--working-dir=$(CRC_DIRECTORY) \
		require --dev maglnet/composer-require-checker
	cp $(_CRC_MIGRATION_DIRECTORY)config.json $(CRC_DIRECTORY)/
	echo vendor > $(CRC_DIRECTORY)/.gitignore
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(CRC_DIRECTORY) \
    		install
# end

# Install the default workflow for CRC in CI
.github/workflows/require-checker.yml:
	cp $(_CRC_MIGRATION_DIRECTORY)github-workflow.yml .github/workflows/require-checker.yml

endif # !HAS_CRC_DIR
endif # DOCKER_IMAGE_BUILT
