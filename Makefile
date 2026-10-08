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
# The root directory of the project, theoretically…
PROJECT_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
# The Dockerfile to build
DOCKERFILE ?= "${_MAKEFILE_DIR}Dockerfile"

# The directory where standalone tooling is installed
TOOLS_DIR := $(PROJECT_DIR)tools
# Whether the tools directory exists
HAS_TOOLS := $(strip $(shell if [ -d $(TOOLS_DIR) ]; then echo TRUE; fi))

# Formatting Macros
MK_BLUE = echo -e "\033[34m"$(1)"\033[0m"
MK_GREEN = echo -e "\033[32m"$(1)"\033[0m"
MK_RED = echo -e "\e[31m"$(1)"\e[0m"
MK_HELP = "\033[36m"$(1)"\033[0m "$(2)"\n"

MK_INFO = @$(call MK_BLUE, $1)
MK_SUCCESS = @$(call MK_GREEN, $1)
MK_ERROR = @$(call MK_RED, $1)

# Variables for collecting targets
QA_TARGETS :=
CLEAN_TARGETS :=
BUMP_TOOLS_TARGETS :=
UPDATE_TOOLS_TARGETS :=
INSTALL_TOOLS_TARGETS :=

# The $(HELP) variable collects help text for the `help` target
HELP := ""
HELP += $(call MK_HELP,'help','Show this help')
HELP += $(call MK_HELP,'qa','Run all qa targets')
HELP += $(call MK_HELP,'clean','Run various clean up jobs')

ifneq ("$(wildcard .env)","")
    include .env
endif

#
# Make Targets Start Here…
#

help:
	@echo $(HELP)
.PHONY: help

#
# Include Makefile fragments first.
# These files collect various targets into `$CLEAN_TARGETS` and `$QA_TARGETS`
#
include $(_MAKEFILE_DIR)makefiles/Docker.mk
include $(_MAKEFILE_DIR)makefiles/Composer.mk
include $(_MAKEFILE_DIR)makefiles/Mago.mk
include $(_MAKEFILE_DIR)makefiles/PHPCodeSniffer.mk
include $(_MAKEFILE_DIR)makefiles/PHPUnit.mk
include $(_MAKEFILE_DIR)makefiles/Psalm.mk
include $(_MAKEFILE_DIR)makefiles/Rector.mk
include $(_MAKEFILE_DIR)makefiles/Infection.mk
include $(_MAKEFILE_DIR)makefiles/Utilities.mk

# Include the Tools fragment after all other tooling so that bump and update of stand-alone tools collects all necessary targets
include $(_MAKEFILE_DIR)makefiles/Tools.mk

# Run docs checks later during QA runs by moving them to the end of the inclusion list
include $(_MAKEFILE_DIR)makefiles/MarkdownLint.mk
include $(_MAKEFILE_DIR)makefiles/LinkChecker.mk
include $(_MAKEFILE_DIR)makefiles/Documentation.mk

# Migrations
include $(_MAKEFILE_DIR)migrations/Migrations.mk

#
# These clean targets are appended last in the main Makefile because, they need to run last…
#
CLEAN_TARGETS := $(CLEAN_TARGETS) uninstall remove-php-image

clean: $(CLEAN_TARGETS)
.PHONY: clean

qa: $(QA_TARGETS)
.PHONY: qa
