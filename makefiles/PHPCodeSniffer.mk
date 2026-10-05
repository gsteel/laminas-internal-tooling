
HAS_PHPCS = FALSE
PHPCS_CONFIG =

ifneq ("$(wildcard phpcs.xml.dist)","")
    HAS_PHPCS = TRUE
    PHPCS_CONFIG = phpcs.xml.dist
endif

ifneq ("$(wildcard phpcs.xml)","")
    HAS_PHPCS = TRUE
    PHPCS_CONFIG = phpcs.xml
endif

ifeq ("$(HAS_PHPCS)","TRUE")
    PHPCS_CACHE_FILE:=$(shell xpath -q -e 'string(/ruleset/arg[@name="cache"]/@value)' ${PHPCS_CONFIG})
    QA_TARGETS := $(QA_TARGETS) phpcs
    CLEAN_TARGETS := $(CLEAN_TARGETS) clear-phpcs-cache
endif

phpcs: install ## Run PHP_CodeSniffer coding standards checks
	@$(call MK_INFO,"Checking coding standards")
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/phpcs
.PHONY: phpcs

phpcbf: install ## Run fixers for coding style
	@$(call MK_INFO,"Fixing coding standards")
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/phpcbf
.PHONY: phpcs

clear-phpcs-cache: ## Remove PHPCS Cache
ifneq ("$(PHPCS_CACHE_FILE)", "")
	rm -f ${PHPCS_CACHE_FILE}
endif
.PHONY: clear-phpcs-cache
