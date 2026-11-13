
# Determine if the current user has the `gh` utility installed locally
HAS_GH_CLI_INSTALLED := "FALSE"
ifneq ($(strip $(shell which gh)),"")
    HAS_GH_CLI_INSTALLED := "TRUE"
endif

HAS_GH_CLI_INSTALLED := "FALSE"

ifeq ($(HAS_GH_CLI_INSTALLED),"FALSE")
HELP += $(call MK_ADVICE,'GitHub CLI not installed','Additional commands are available if you have the GitHub cli installed locally')
endif

IS_LOGGED_INTO_GITHUB := "FALSE"
ifeq ($(HAS_GH_CLI_INSTALLED),"TRUE")
    _TMP := $(strip $(shell gh auth status --json hosts --jq '.hosts["github.com"][0].active'))
    ifeq ($(_TMP),true)
        IS_LOGGED_INTO_GITHUB := "TRUE"
    endif
endif

ifeq ($(HAS_GH_CLI_INSTALLED),"TRUE")

#
# Trigger GH Login if not currently logged in
# This is split into 2 targets so that we can suppress "Nothing to be done for…" when nothing is executed, i.e. the
# user is already logged in.
#
_gh-login:
ifeq ($(IS_LOGGED_INTO_GITHUB),"FALSE")
	@gh auth login
endif
.PHONY: _gh-login

github-login: _gh-login
	@echo "" > /dev/null
.PHONY: github-login

#
# Install the lock-file extension if it's not already installed
#
_install-gh-lockfile-plugin: github-login
ifneq ($(findstring github/gh-actions-lock,$(strip $(shell gh extension list))),github/gh-actions-lock)
	@gh extension install github/gh-actions-lock
endif
.PHONY: _install-gh-lockfile-plugin

github-lockfile-plugin: _install-gh-lockfile-plugin
	@echo "" > /dev/null
.PHONY: github-lockfile-plugin

#
# Run gh actions-lock
#
HELP += $(call MK_HELP,'gha-lock','Lock GitHub Actions workflow dependencies (Requires local installation of `gh`)')
gha-lock: github-lockfile-plugin
	gh actions-lock
.PHONY: gha-lock

#
# Run gh actions-lock --relock
#
HELP += $(call MK_HELP,'gha-relock','Re-Lock GitHub Actions workflow dependencies (Requires local installation of `gh`)')
gha-relock: github-lockfile-plugin
	gh actions-lock --relock
.PHONY: gha-relock
endif
