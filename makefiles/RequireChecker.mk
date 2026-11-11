
ifeq ("$(DOCKER_IMAGE_BUILT)", "TRUE")

CRC_DIRECTORY ?= $(PROJECT_DIR)tools/crc
HAS_CRC := $(strip $(shell if [ -d $(CRC_DIRECTORY) ]; then echo TRUE; fi))

ifeq ("$(HAS_CRC)", "TRUE")

BUMP_TOOLS_TARGETS += crc-bump
UPDATE_TOOLS_TARGETS += crc-update
INSTALL_TOOLS_TARGETS += crc-install

HELP += $(call MK_HELP,'crc','Check all dependencies are declared with composer-require-checker')
QA_TARGETS += crc

crc:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) $(CRC_DIRECTORY)/vendor/bin/composer-require-checker check --config-file=$(CRC_DIRECTORY)/config.json
.PHONY: crc

crc-update:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(CRC_DIRECTORY) \
    		update
.PHONY: crc-update

crc-install:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(CRC_DIRECTORY) \
    		install
.PHONY: crc-install

crc-bump: crc-update _do-crc-bump crc-update
.PHONY: crc-bump

_do-crc-bump:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(CRC_DIRECTORY) \
    		bump -D
.PHONY: _do-crc-bump

endif # HAS_CRC

endif # DOCKER_IMAGE_BUILT
