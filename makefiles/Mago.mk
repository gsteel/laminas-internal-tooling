HAS_MAGO = FALSE
MAGO_CONFIG =

ifneq ("$(wildcard mago.toml)","")
    HAS_MAGO = TRUE
    MAGO_CONFIG = mago.toml
endif

mago-fmt: install ## Format source code with Mago
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago fmt
.PHONY: mago-fmt

mago-fmt-check: install ## Check source code formatting with Mago without modifying any files
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago fmt --check
.PHONY: mago-fmt-check

mago-lint: install ## Lint source code with Mago
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago lint --fail-on-out-of-sync-baseline
.PHONY: mago-lint

mago-lint-fix: install ## Fix 'fixable' CS violations with mago
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago lint --fix --format-after-fix
.PHONY: mago-lint-fix

mago-sa: install ## Static analysis with Mago
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago analyse --fail-on-out-of-sync-baseline
.PHONY: mago-sa

mago-watch: install ## Run Mago static analysis in watch mode
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago analyse --watch
.PHONY: mago-watch

mago-sa-fix: install ## Fix 'fixable' static analysis issues
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago analyse --fix --format-after-fix --fail-on-remaining
.PHONY: mago-sa-fix

mago-set-lint-baseline: install ## Expand the current lint baseline
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago lint --generate-baseline
.PHONY:mago-set-lint-baseline

mago-update-lint-baseline: install ## Remove fixed issues from the lint baseline
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago lint --remove-outdated-baseline-entries
.PHONY:mago-update-lint-baseline

mago-set-sa-baseline: install ## Expand the current static analysis baseline
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago analyse --generate-baseline
.PHONY:mago-set-sa-baseline

mago-update-sa-baseline: install ## Remove fixed issues from the static analysis baseline
	@$(DOCKER_RUN) ${DOCKER_IMAGE_NAME} vendor/bin/mago analyse --remove-outdated-baseline-entries
.PHONY:mago-update-sa-baseline

mago-update-baseline: mago-update-sa-baseline mago-update-lint-baseline ## Update the SA and Lint baselines
.PHONY:mago-update-baseline

mago-fix: mago-fmt mago-lint-fix mago-sa-fix ## Run all Mago's fixers
.PHONY: mago-fix

ifeq ("$(HAS_MAGO)", "TRUE")

QA_TARGETS := $(QA_TARGETS) mago-fmt-check mago-lint mago-sa

endif
