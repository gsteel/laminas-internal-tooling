
HAS_PSALM = FALSE
PSALM_CONFIG =

ifneq ("$(wildcard psalm.xml.dist)","")
    HAS_PSALM = TRUE
    PSALM_CONFIG = psalm.xml.dist
endif

ifneq ("$(wildcard psalm.xml)","")
    HAS_PSALM = TRUE
    PSALM_CONFIG = psalm.xml
endif

ifeq ("$(HAS_PSALM)","TRUE")

    QA_TARGETS := $(QA_TARGETS) psalm
    CLEAN_TARGETS := $(CLEAN_TARGETS) clear-psalm-cache

    ifneq ("$(wildcard ${PSALM_CONFIG})", "")
        $(eval PSALM_BASELINE := $(shell xpath -q -e 'string(//psalm/@errorBaseline)' ${PSALM_CONFIG}))
    endif

    ifeq (${PSALM_BASELINE}, "")
        PSALM_BASELINE = psalm-baseline.xml
    endif
endif

psalm: install ## Run Psalm static analysis
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/psalm
.PHONY: psalm

psalm-update-baseline: install ## Update the Psalm baseline, removing outdated issues
ifneq ("$(wildcard ${PSALM_BASELINE})", "")
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/psalm --update-baseline
else
	@$(call MK_ERROR, "A Psalm baseline has not been configured. Run `set-psalm-baseline` first.")
endif
.PHONY: psalm-update-baseline

psalm-set-baseline: install ## Add new issues to the Psalm baseline
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/psalm --set-baseline=${PSALM_BASELINE}
.PHONY: psalm-set-baseline

psalm-clear-cache: install ## Clear Psalm's cache
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/psalm --clear-cache
.PHONY: psalm-clear-cache
