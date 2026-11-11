#
# Adds a blank php.ini file to the project root
#
# This is normally done so that the Docker container can mount it as a volume, enabling ini settings to be defined
# for PHP in the development container without the hassle of building a custom image for the project.
#

HAS_PHP_INI := "TRUE"
ifeq ("$(wildcard php.ini)","")
    HAS_PHP_INI := "FALSE"
endif

ifeq ($(HAS_PHP_INI),"FALSE")

_INI_FILE_MIGRATION_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
HELP += $(call MK_HELP,'init-ini','Add a blank php.ini file to the project root for development runtime configuration')

init-ini: php.ini _do-add-php-ini
.PHONY: init-ini

php.ini:
	@cp $(_INI_FILE_MIGRATION_DIRECTORY)template.ini php.ini

_do-add-php-ini:
	@$(DOCKER_RUN) $(DOCKER_IMAGE_NAME) php $(_INI_FILE_MIGRATION_DIRECTORY)migrate $(PROJECT_DIR)
.PHONY: _do-add-php-ini

endif # ! HAS_PHP_INI
