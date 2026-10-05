##
## Main Makefile to include in projects
##

### Variables ###

# Most Laminas & Mezzio Projects use PHP 8.2 as the current minimum PHP Version
# You can re-define the default PHP version in your own Makefile
PHP_VERSION ?= 8.2
# Any PHP extensions should be a space separated list of extension names without prefixes such as "ext-"
# Do not quote this string if you re-define it
PHP_EXTENSIONS ?= mbstring json xdebug
# All of the make targets that execute PHP code run in Docker, and an image is built using the PHP version desired
# This image should be named to something specific to the project (Normally the repo name such as "laminas/laminas-whatever").
DOCKER_IMAGE_NAME ?= laminas/default-php
# This is the image ID of the built Docker image
DOCKER_IMAGE_ID := $(shell docker images -q ${DOCKER_IMAGE_NAME} | xargs)
# Sets the shell for running make targets
SHELL ?= /bin/bash
# The default Makefile target
.DEFAULT_GOAL ?= help
# The parent directory of _this_ Makefile
_MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
# The Dockerfile to build
DOCKERFILE ?= "${_MAKEFILE_DIR}Dockerfile"

# Formatting Macros
MK_BLUE = echo -e "\033[34m"$(1)"\033[0m"
MK_GREEN = echo -e "\033[32m"$(1)"\033[0m"
MK_RED = echo -e "\e[31m"$(1)"\e[0m"
MK_INFO = @$(call MK_BLUE, $1)
MK_SUCCESS = @$(call MK_GREEN, $1)
MK_ERROR = @$(call MK_RED, $1)

# Variables for collecting targets
QA_TARGETS :=
CLEAN_TARGETS :=

ifneq ("$(wildcard .env)","")
    include .env
endif

#
# Make Targets Start Here…
#

help: ## shows this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_\-\.]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
.PHONY: help

#
# Include Makefile fragments first.
# These files collect various targets into `$CLEAN_TARGETS` and `$QA_TARGETS`
#
include makefiles/Docker.mk
include makefiles/Composer.mk
include makefiles/MarkdownLint.mk
include makefiles/Mago.mk
include makefiles/PHPCodeSniffer.mk
include makefiles/PHPUnit.mk
include makefiles/Psalm.mk

#
# These clean targets are appended last in the main Makefile because, they need to run last…
#
CLEAN_TARGETS := $(CLEAN_TARGETS) uninstall remove-php-image

clean: $(CLEAN_TARGETS)  ## Clean up caches and documentation artifacts
.PHONY: clean

qa: $(QA_TARGETS) ## Run all QA targets
.PHONY: qa
