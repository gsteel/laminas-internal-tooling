RECTOR_DIRECTORY ?= $(PROJECT_DIR)tools/rector
HAS_RECTOR := $(strip $(shell if [ -d $(RECTOR_DIRECTORY) ]; then echo TRUE; fi))


ifeq ("$(HAS_RECTOR)", "TRUE")

BUMP_TOOLS_TARGETS += rector-bump
UPDATE_TOOLS_TARGETS += rector-update

HELP += $(call MK_HELP,'rector','Check the codebase with Rector')
rector:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) $(RECTOR_DIRECTORY)/vendor/bin/rector process --dry-run -c $(RECTOR_DIRECTORY)/rector.php
.PHONY: rector

HELP += $(call MK_HELP,'rector-fix','Fix code style inconsistencies with Rector')
rector-fix:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) $(RECTOR_DIRECTORY)/vendor/bin/rector process -c $(RECTOR_DIRECTORY)/rector.php
.PHONY: rector-fix

rector-update:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(RECTOR_DIRECTORY) \
    		update
.PHONY: rector-update

rector-bump: rector-update _do-rector-bump rector-update
.PHONY: rector-bump

_do-rector-bump:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(RECTOR_DIRECTORY) \
    		bump -D
.PHONY: _do-rector-bump

endif
