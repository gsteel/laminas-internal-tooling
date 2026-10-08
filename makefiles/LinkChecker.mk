HAS_DOCS = FALSE
LINK_CHECKER_IMAGE_NAME := $(DOCKER_IMAGE_NAME)/link-checker
LINK_CHECKER_DOCKERFILE := $(_MAKEFILE_DIR)link-checker/Dockerfile
LINK_CHECKER_IMAGE_ID := $(shell docker images -q ${LINK_CHECKER_IMAGE_NAME} | xargs)

ifneq ("$(wildcard docs)","")
ifneq ("$(wildcard mkdocs.yml)","")
    HAS_DOCS = TRUE
    LAMINAS_DOCS_DIRECTORY := $(PROJECT_DIR)docs
endif
endif

ifneq ("$(wildcard doc)","")
ifneq ("$(wildcard mkdocs.yml)","")
    HAS_DOCS = TRUE
    LAMINAS_DOCS_DIRECTORY := $(PROJECT_DIR)doc
endif
endif

ifeq ("$(HAS_DOCS)","TRUE")

QA_TARGETS := $(QA_TARGETS) docs-check-links
CLEAN_TARGETS := $(CLEAN_TARGETS) docs-rm-link-checker

HELP += $(call MK_HELP,'docs-check-links','Checks links in the documentation Markdown files')

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

docs-check-links: docs-build-link-checker
	@$(call MK_INFO,"Checking links in documentation files")
	@$(DOCKER_RUN) ${LINK_CHECKER_IMAGE_NAME} -t 5 -qq -f compact "$(LAMINAS_DOCS_DIRECTORY)/**/*.md" README.md
.PHONY: docs-check-links

endif
