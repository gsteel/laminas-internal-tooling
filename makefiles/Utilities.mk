
HELP += $(call MK_HELP,'set-default-ignores','Ensures all the usual entries are added to .gitignore')

set-default-ignores: install
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} php -f $(_MAKEFILE_DIR)migrations/bin/standard-gitignores.php $(PROJECT_DIR)
.PHONY: set-default-ignores
