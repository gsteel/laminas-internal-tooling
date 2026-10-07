RECTOR_DIRECTORY ?= $(PROJECT_DIR)tools/rector
HAS_RECTOR := $(shell if [ -d $(RECTOR_DIRECTORY) ]; then echo -n TRUE; fi)

ifneq ("$(HAS_RECTOR)", "TRUE")

HELP += $(call MK_HELP,'rector','Check the codebase with Rector')
rector:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) $(RECTOR_DIRECTORY)/vendor/bin/rector process --dry-run -c $(RECTOR_DIRECTORY)/rector.php
.PHONY: rector

HELP += $(call MK_HELP,'rector-fix','Fix code style inconsistencies with Rector')
rector-fix:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) $(RECTOR_DIRECTORY)/vendor/bin/rector process -c $(RECTOR_DIRECTORY)/rector.php
.PHONY: rector-fix

endif
