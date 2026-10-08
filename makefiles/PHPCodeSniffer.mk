
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
    HELP +=$(call MK_HELP,'phpcs','Run PHP_CodeSniffer coding standards checks')
    HELP +=$(call MK_HELP,'phpcbf','Run PHP_CodeSniffer fixers for coding style')

phpcs: install
	@$(call MK_INFO,"Checking coding standards")
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) vendor/bin/phpcs
.PHONY: phpcs

phpcbf: install
	@$(call MK_INFO,"Fixing coding standards")
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) vendor/bin/phpcbf
.PHONY: phpcs

ifneq ("$(PHPCS_CACHE_FILE)", "")
clear-phpcs-cache:
	rm -f ${PHPCS_CACHE_FILE}
.PHONY: clear-phpcs-cache
endif

endif
