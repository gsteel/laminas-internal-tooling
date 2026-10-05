# Makefile targets and variables for linting Markdown according to Laminas rules

# This is where we can download the Laminas org's Markdown lint configuration for linting local Markdown files
MDLINT_CONFIG_FILE ?= https://raw.githubusercontent.com/laminas/laminas-continuous-integration-action/e321dbdcc74e665512b5d2e8fd9012b3432df897/setup/markdownlint/markdownlint.json
# This is a Docker image for Markdown Lint CLI v2
MDLINT_IMAGE ?= davidanson/markdownlint-cli2:v0.23.2
# File pattern passed to markdownlint-cli2
MARKDOWN_FILE_PATTERN ?= *.md !COPYRIGHT.md !LICENSE.md
ifneq ("$(wildcard docs)","")
    MARKDOWN_FILE_PATTERN := $(MARKDOWN_FILE_PATTERN) docs/**/*.md
endif

$(eval MD_FILE_COUNT := $(shell find . -type f -name '*.md' -prune \( \! -path '*/vendor/*' \) -prune \( \! -path '*/tools/*' \) -print | wc -l))

HAS_MARKDOWN := TRUE
ifeq ("$(MD_FILE_COUNT)", "0")
    HAS_MARKDOWN := FALSE
endif

ifeq ("$(HAS_MARKDOWN)", "TRUE")
    QA_TARGETS := $(QA_TARGETS) docs-lint
    CLEAN_TARGETS := $(CLEAN_TARGETS) remove-mdlint-config
endif

docs-lint: .markdownlint.json ## Lint Markdown documentation files
	@$(call MK_INFO, "Linting documentation files")
	@$(DOCKER_RUN) ${MDLINT_IMAGE} ${MARKDOWN_FILE_PATTERN}
.PHONY: docs-lint

.markdownlint.json: ## Fetch the most recent settings for Markdown lint
	@$(call MK_INFO,"Fetching markdown lint configuration")
	@curl -s -o .markdownlint.json ${MDLINT_CONFIG_FILE}

remove-mdlint-config: ## Remove the downloaded markdown lint config file
ifneq ("$(wildcard .markdownlint.json)", "")
	@$(call MK_INFO,"Removing markdown lint configuration")
	@rm .markdownlint.json
endif
.PHONY: remove-mdlint-config
