STRUCT_ARMED_DIRECTORY ?= $(PROJECT_DIR)tools/structarmed
HAS_STRUCT_ARMED := $(strip $(shell if [ -d $(STRUCT_ARMED_DIRECTORY) ]; then echo TRUE; fi))

ifeq ("$(HAS_STRUCT_ARMED)", "TRUE")

BUMP_TOOLS_TARGETS += structarmed-bump
UPDATE_TOOLS_TARGETS += structarmed-update
INSTALL_TOOLS_TARGETS += structarmed-install

HELP += $(call MK_HELP,'structarmed','Check the codebase with StructArmed')
QA_TARGETS += structarmed
CLEAN_TARGETS += structarmed-clear

structarmed:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) \
		$(STRUCT_ARMED_DIRECTORY)/vendor/bin/structarmed \
		--config $(STRUCT_ARMED_DIRECTORY)/structarmed.php \
		analyze
.PHONY: structarmed

HELP += $(call MK_HELP,'structarmed-fix','Run automatic fixes provided by StructArmed')
structarmed-fix:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) \
		$(STRUCT_ARMED_DIRECTORY)/vendor/bin/structarmed \
		--config $(STRUCT_ARMED_DIRECTORY)/structarmed.php \
		analyze --fix
.PHONY: structarmed-fix

structarmed-clear:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) \
		$(STRUCT_ARMED_DIRECTORY)/vendor/bin/structarmed \
		--config $(STRUCT_ARMED_DIRECTORY)/structarmed.php \
		clear-cache
.PHONY: structarmed-clear

structarmed-update:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(STRUCT_ARMED_DIRECTORY) \
    		update
.PHONY: structarmed-update

structarmed-install:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(STRUCT_ARMED_DIRECTORY) \
    		install
.PHONY: structarmed-install

structarmed-bump: structarmed-update _do-structarmed-bump structarmed-update
.PHONY: structarmed-bump

_do-structarmed-bump:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(STRUCT_ARMED_DIRECTORY) \
    		bump -D
.PHONY: _do-structarmed-bump

endif
