INFECTION_DIRECTORY ?= $(PROJECT_DIR)tools/infection
HAS_INFECTION := $(strip $(shell if [ -d $(INFECTION_DIRECTORY) ]; then echo TRUE; fi))


ifeq ("$(HAS_INFECTION)", "TRUE")

BUMP_TOOLS_TARGETS += infection-bump
UPDATE_TOOLS_TARGETS += infection-update
INSTALL_TOOLS_TARGETS += infection-install
QA_TARGETS += infection

HELP += $(call MK_HELP,'infection','Run mutation tests')

infection:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) $(INFECTION_DIRECTORY)/vendor/bin/infection --configuration=infection.json --static-analysis-tool=mago
.PHONY: infection

infection-update:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(INFECTION_DIRECTORY) \
    		update
.PHONY: infection-update

infection-install:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(INFECTION_DIRECTORY) \
    		install
.PHONY: infection-install

infection-bump: infection-update _do-infection-bump infection-update
.PHONY: infection-bump

_do-infection-bump:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer \
    		--working-dir=$(INFECTION_DIRECTORY) \
    		bump -D
.PHONY: _do-infection-bump

endif
