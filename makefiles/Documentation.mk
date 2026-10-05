MKDOCS_IMAGE_NAME ?= laminas/mkdocs
MKDOCS_IMAGE_ID := $(shell docker images -q $(MKDOCS_IMAGE_NAME) | xargs)

HAS_DOCS = FALSE

ifneq ("$(wildcard docs)","")
ifneq ("$(wildcard mkdocs.yml)","")
    HAS_DOCS = TRUE
    CLEAN_TARGETS := $(CLEAN_TARGETS) docs-rm-mkdocs-image
endif
endif

# Fetch the documentation theme repo
documentation-theme:
	git clone git@github.com:laminas/documentation-theme.git

# Conditionally fetch the theme based on the presence of mkdocs.yml and ./docs
docs-fetch-theme:
ifeq ("$(HAS_DOCS)","TRUE")
docs-fetch-theme: documentation-theme
endif
.PHONY: docs-fetch-theme

# Build the MkDocs image with necessary dependencies for building the docs
docs-build-mkdocs-image: docs-fetch-theme
ifeq ("$(HAS_DOCS)","TRUE")
ifeq ($(strip $(MKDOCS_IMAGE_ID)),)
	@cd documentation-theme/builder && docker build -t $(MKDOCS_IMAGE_NAME) .
endif
else
	@$(call MK_INFO,"Skipping the docs Docker image - no docs found")
endif
.PHONY: docs-build-mkdocs-image

docs-build: docs-build-mkdocs-image ## build the docs using a Docker container
ifeq ("$(HAS_DOCS)","TRUE")
	@$(DOCKER_RUN) $(MKDOCS_IMAGE_NAME) ./documentation-theme/build.sh -u https://www.example.com
	$(info ${PWD}/docs/html/index.html)
else
	@$(call MK_INFO,"No docs can be found for this project")
endif
.PHONY: docs-build

# Removes the docker image for MkDocs
docs-rm-mkdocs-image:
ifneq ($(strip $(MKDOCS_IMAGE_ID)),)
	@$(call MK_INFO,"Removing the Docs Builder Image")
	@docker image rm ${MKDOCS_IMAGE_ID}
endif
.PHONY: docs-rm-mkdocs-image
