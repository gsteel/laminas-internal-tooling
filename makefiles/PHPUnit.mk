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


HELP +=$(call MK_HELP,'test','Run PHPUnit tests')
test: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} vendor/bin/phpunit
.PHONY: test

clear-phpunit-cache:
	$(eval PHPUNIT_CACHE_DIR := $(shell xpath -q -e 'string(//phpunit/@cacheDirectory)' ${PHPUNIT_CONFIG}))
ifneq ($(wildcard ${PHPUNIT_CACHE_DIR}), "")
	@$(call MK_INFO, "Clearing PHPUnit Cache")
	@rm -rf ${PHPUNIT_CACHE_DIR}
endif
.PHONY: clear-phpunit-cache

endif
