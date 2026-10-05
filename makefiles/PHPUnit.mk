HAS_PHPUNIT = FALSE
PHPUNIT_CONFIG =

ifneq ("$(wildcard phpunit.xml.dist)", "")
    HAS_PHPUNIT = TRUE
    PHPUNIT_CONFIG = phpunit.xml.dist
endif

ifneq ("$(wildcard phpunit.xml)", "")
    HAS_PHPUNIT = TRUE
    PHPUNIT_CONFIG = phpunit.xml
endif

ifeq ("$(HAS_PHPUNIT)","TRUE")
    QA_TARGETS := $(QA_TARGETS) test
    CLEAN_TARGETS := $(CLEAN_TARGETS) clear-phpunit-cache
endif

test: install ## Run PHPUnit tests
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/phpunit
.PHONY: test

clear-phpunit-cache: ## Clear the PHPUnit Cache
	$(eval PHPUNIT_CACHE_DIR := $(shell xpath -q -e 'string(//phpunit/@cacheDirectory)' ${PHPUNIT_CONFIG}))
ifneq ($(wildcard ${PHPUNIT_CACHE_DIR}), "")
	@$(call MK_INFO, "Clearing PHPUnit Cache")
	@rm -rf ${PHPUNIT_CACHE_DIR}
endif
.PHONY: clear-phpunit-cache
