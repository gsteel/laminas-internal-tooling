#
# Make targets for building and using a generic PHP Docker image.
# These targets are foundational for most other QA features.
#

DOCKER_DEFAULT_SECURITY_OPS=--cap-drop=ALL --security-opt="no-new-privileges=true"
DOCKER_COMMON_OPS:=-v "`pwd`:`pwd`" -w "`pwd`" -v "`pwd`/.git:`pwd`/.git:ro" --ulimit nofile=1000000
DOCKER_RUN:=docker run --rm -it ${DOCKER_DEFAULT_SECURITY_OPS} ${DOCKER_COMMON_OPS}

HELP += $(call MK_HELP,'build-php-image','Build the PHP image if not already built')
HELP += $(call MK_HELP,'shell','Get a shell running in the PHP Docker container')

build-php-image:
ifeq ($(strip $(DOCKER_IMAGE_ID)),)
build-php-image: build-php-image-unconditionally
endif
.PHONY: build-php-image

build-php-image-unconditionally:
	@$(call MK_INFO,"Building the PHP Docker Image")
	@echo "${PHP_EXTENSIONS}"
	@docker build \
	-f ${DOCKERFILE} \
	--build-arg PHP_VERSION="${PHP_VERSION}" \
	--build-arg PHP_EXTENSIONS="${PHP_EXTENSIONS}" \
	-t ${DOCKER_IMAGE_NAME} .
.PHONY: build-php-image-unconditionally

remove-php-image:
ifneq ($(strip $(DOCKER_IMAGE_ID)),)
	@$(call MK_INFO,"Removing the PHP Docker Image")
	docker image rm ${DOCKER_IMAGE_ID}
endif
.PHONY: remove-php-image

shell: build-php-image
	@$(DOCKER_RUN) ${DOCKER_IMAGE_ID} bash
.PHONY: shell
