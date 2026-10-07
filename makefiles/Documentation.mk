MKDOCS_IMAGE_NAME ?= laminas/mkdocs
MKDOCS_IMAGE_ID := $(shell docker images -q $(MKDOCS_IMAGE_NAME) | xargs)

HAS_DOCS = FALSE

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

CLEAN_TARGETS := $(CLEAN_TARGETS) docs-rm-mkdocs-image docs-rm-theme-files

HELP += $(call MK_HELP,'docs-build','Build the docs static HTML files using a Docker container')

# Fetch the documentation theme repo
documentation-theme:
	git clone git@github.com:laminas/documentation-theme.git

# Build the MkDocs image with necessary dependencies for building the docs
docs-build-mkdocs-image: documentation-theme
ifeq ("$(HAS_DOCS)","TRUE")
ifeq ($(strip $(MKDOCS_IMAGE_ID)),)
	@cd documentation-theme/builder && docker build -t $(MKDOCS_IMAGE_NAME) .
endif
else
	@$(call MK_INFO,"Skipping the docs Docker image - no docs found")
endif
.PHONY: docs-build-mkdocs-image

docs-build: docs-build-mkdocs-image
	@$(DOCKER_RUN) $(MKDOCS_IMAGE_NAME) ./documentation-theme/build.sh -u https://www.example.com
	$(info $(LAMINAS_DOCS_DIRECTORY)/html/index.html)
.PHONY: docs-build

# Removes the docker image for MkDocs
docs-rm-mkdocs-image:
ifneq ($(strip $(MKDOCS_IMAGE_ID)),)
	@$(call MK_INFO,"Removing the Docs Builder Image")
	@docker image rm ${MKDOCS_IMAGE_ID}
endif
.PHONY: docs-rm-mkdocs-image

# Removes `./documentation-theme`
docs-rm-theme-files:
	@rm -rf documentation-theme
	@rm -rf $(LAMINAS_DOCS_DIRECTORY)/html
.PHONY: docs-rm-theme-files

endif
