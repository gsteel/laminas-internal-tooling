
HAS_PSALM := FALSE
PSALM_CONFIG :=

ifneq ("$(wildcard psalm.xml.dist)","")
    HAS_PSALM := TRUE
    PSALM_CONFIG := psalm.xml.dist
endif

ifneq ("$(wildcard psalm.xml)","")
    HAS_PSALM := TRUE
    PSALM_CONFIG := psalm.xml
endif

ifeq ("$(HAS_PSALM)","TRUE")

    QA_TARGETS := $(QA_TARGETS) psalm
    CLEAN_TARGETS := $(CLEAN_TARGETS) clear-psalm-cache

    ifneq ("$(wildcard ${PSALM_CONFIG})", "")
        CONFIG_CONTENT := $(strip $(shell cat $(PSALM_CONFIG)))
        ifneq ($(CONFIG_CONTENT), "")
           $(eval PSALM_BASELINE := $(shell xpath -q -e 'string(//psalm/@errorBaseline)' ${PSALM_CONFIG}))
        endif
    endif

    ifeq (${PSALM_BASELINE}, "")
        PSALM_BASELINE = psalm-baseline.xml
    endif

HELP +=$(call MK_HELP,'psalm','Run Psalm static analysis')
psalm: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/psalm
.PHONY: psalm

HELP +=$(call MK_HELP,'psalm-update-baseline','Update the Psalm baseline removing outdated issues')
psalm-update-baseline: install
ifneq ("$(wildcard ${PSALM_BASELINE})", "")
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/psalm --update-baseline
else
	@$(call MK_ERROR, "A Psalm baseline has not been configured. Run `set-psalm-baseline` first.")
endif
.PHONY: psalm-update-baseline

HELP +=$(call MK_HELP,'psalm-set-baseline','Add new issues to the Psalm baseline')
psalm-set-baseline: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/psalm --set-baseline=${PSALM_BASELINE}
.PHONY: psalm-set-baseline

HELP +=$(call MK_HELP,'psalm-clear-cache','Clear the Psalm cache')
psalm-clear-cache: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/psalm --clear-cache
.PHONY: psalm-clear-cache

endif
