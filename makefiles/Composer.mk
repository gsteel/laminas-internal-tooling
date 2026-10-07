#
# Make targets for PHP dependency management with composer
#

HELP += $(call MK_HELP,'install','Install composer dependencies from composer.json')
HELP += $(call MK_HELP,'update','Update composer dependencies')
HELP += $(call MK_HELP,'outdated','Show outdated dependencies')
HELP += $(call MK_HELP,'bump-dev','Bump development composer dependencies')
HELP += $(call MK_HELP,'uninstall','Remove composer dependencies')

install: build-php-image
ifeq ("$(wildcard vendor)","")
	@$(call MK_INFO,"Installing PHP Dependencies")
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer install
endif
.PHONY: install

update: install
	@$(call MK_INFO,"Updating PHP Dependencies")
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer update
.PHONY: update

outdated: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer outdated
.PHONY: outdated

bump-dev: update
	@$(call MK_INFO,"Bumping Development Dependencies")
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer bump -D
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer update
.PHONY: bump-dev

composer-validate: build-php-image
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer validate --check-lock --strict
.PHONY: composer-validate

composer-autoload: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer dump-autoload --optimize --strict-psr
.PHONY: composer-autoload

uninstall:
ifneq ("$(wildcard vendor)","")
	@$(call MK_INFO,"Removing PHP Dependencies")
	rm -rf vendor
endif
.PHONY: uninstall

QA_TARGETS := composer-validate
