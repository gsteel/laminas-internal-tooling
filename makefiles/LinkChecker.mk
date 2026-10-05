HAS_DOCS = FALSE
LINK_CHECKER_IMAGE_NAME := $(DOCKER_IMAGE_NAME)/link-checker
LINK_CHECKER_DOCKERFILE := $(_MAKEFILE_DIR)link-checker/Dockerfile
LINK_CHECKER_IMAGE_ID := $(shell docker images -q ${LINK_CHECKER_IMAGE_NAME} | xargs)

ifneq ("$(wildcard docs)","")
    HAS_DOCS = TRUE
    QA_TARGETS := $(QA_TARGETS) docs-check-links
    CLEAN_TARGETS := $(CLEAN_TARGETS) docs-rm-link-checker
endif

docs-build-link-checker:
ifeq ($(strip $(LINK_CHECKER_IMAGE_ID)),)
docs-build-link-checker: docs-build-link-checker-unconditionally
endif
.PHONY: docs-build-link-checker

docs-rm-link-checker:
ifneq ($(strip $(LINK_CHECKER_IMAGE_ID)),)
	@$(call MK_INFO,"Removing the Link Checker Docker Image")
	docker image rm ${LINK_CHECKER_IMAGE_ID}
endif
.PHONY: docs-rm-link-checker

docs-build-link-checker-unconditionally:
	@docker build \
    	-f ${LINK_CHECKER_DOCKERFILE} \
    	-t ${LINK_CHECKER_IMAGE_NAME} .
.PHONY: docs-build-link-checker-unconditionally

docs-check-links: ## Check documentation links
ifeq ("$(HAS_DOCS)","TRUE")
docs-check-links: docs-build-link-checker
	@$(call MK_INFO,"Checking links in documentation files")
	@$(DOCKER_RUN) ${LINK_CHECKER_IMAGE_NAME} -t 5 -qq -f raw "docs/**/*.md" README.md
endif
.PHONY: docs-check-links
