
HAS_PSALM := FALSE
PSALM_CONFIG :=

ifneq ("$(wildcard psalm.xml.dist)","")
    HAS_PSALM := TRUE
    PSALM_CONFIG := psalm.xml.dist
endif

ifneq ("$(wildcard psalm.xml)","")
    HAS_PSALM := TRUE
    PSALM_CONFIG := psalm.xml
endif

ifeq ("$(HAS_PSALM)","TRUE")

UNINSTALL_PSALM_DIRECTORY := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

HELP += $(call MK_HELP,'uninstall-psalm','Remove Psalm along with its configuration file and baseline')

uninstall-psalm:
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer rm psalm/plugin-phpunit
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} composer rm vimeo/psalm
	rm -f psalm.xml
	rm -f psalm.xml.dist
	rm -f psalm-baseline.xml
	$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} php $(UNINSTALL_PSALM_DIRECTORY)migrate $(PROJECT_DIR)
.PHONY: uninstall-psalm

endif
