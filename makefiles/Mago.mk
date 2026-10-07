HAS_MAGO = FALSE
MAGO_CONFIG =

ifneq ("$(wildcard mago.toml)","")
    HAS_MAGO = TRUE
    MAGO_CONFIG = mago.toml
endif

ifeq ("$(HAS_MAGO)","TRUE")

QA_TARGETS := $(QA_TARGETS) mago-fmt-check mago-lint mago-sa

HELP += $(call MK_HELP,'mago-fmt','Format source code with Mago')
mago-fmt: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago fmt
.PHONY: mago-fmt

HELP += $(call MK_HELP,'mago-fmt-check','Check source code formatting with Mago without modifying any files')
mago-fmt-check: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago fmt --check
.PHONY: mago-fmt-check

HELP += $(call MK_HELP,'mago-lint','Lint source code with Mago')
mago-lint: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago lint --fail-on-out-of-sync-baseline
.PHONY: mago-lint

HELP += $(call MK_HELP,'mago-lint-fix','Fix fixable CS violations with mago')
mago-lint-fix: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago lint --fix --format-after-fix
.PHONY: mago-lint-fix

HELP += $(call MK_HELP,'mago-sa','Run static analysis with Mago')
mago-sa: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago analyse --fail-on-out-of-sync-baseline
.PHONY: mago-sa

HELP += $(call MK_HELP,'mago-sa-watch','Run static analysis with Mago in watch mode')
mago-watch: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago analyse --watch
.PHONY: mago-watch

HELP += $(call MK_HELP,'mago-sa-fix','Fix fixable static analysis issues')
mago-sa-fix: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago analyse --fix --format-after-fix --fail-on-remaining
.PHONY: mago-sa-fix

HELP += $(call MK_HELP,'mago-set-lint-baseline','Expand the current lint baseline')
mago-set-lint-baseline: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago lint --generate-baseline
.PHONY:mago-set-lint-baseline

#HELP += $(call MK_HELP,'mago-update-lint-baseline','Remove fixed issues from the lint baseline')
mago-update-lint-baseline: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago lint --remove-outdated-baseline-entries
.PHONY:mago-update-lint-baseline

HELP += $(call MK_HELP,'mago-set-sa-baseline','Expand the current static analysis baseline')
mago-set-sa-baseline: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago analyse --generate-baseline
.PHONY:mago-set-sa-baseline

#HELP += $(call MK_HELP,'mago-update-sa-baseline','Remove fixed issues from the static analysis baseline')
mago-update-sa-baseline: install
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago analyse --remove-outdated-baseline-entries
.PHONY:mago-update-sa-baseline

HELP += $(call MK_HELP,'mago-update-baseline','Update the SA and Lint baselines')
mago-update-baseline: mago-update-sa-baseline mago-update-lint-baseline
.PHONY:mago-update-baseline

HELP += $(call MK_HELP,'mago-fix','Run all Mago’s fixers')
mago-fix: mago-fmt mago-lint-fix mago-sa-fix
.PHONY: mago-fix

endif
