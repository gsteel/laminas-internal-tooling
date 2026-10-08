#
# If _any_ tools are installed, and the targets for updating or bumping those tools are non-empty, then
# add targets for bumping or updating _all_ stand-alone tools
#

ifeq ("$(HAS_TOOLS)", "TRUE")

ifneq ($(strip $(UPDATE_TOOLS_TARGETS)), "")
HELP += $(call MK_HELP,'update-tools','Update all standalone tools')
update-tools: $(UPDATE_TOOLS_TARGETS)
.PHONY: update-tools
endif

ifneq ($(strip $(BUMP_TOOLS_TARGETS)), "")
HELP += $(call MK_HELP,'bump-tools','Bump and update the versions for all standalone tools')
bump-tools: $(BUMP_TOOLS_TARGETS)
.PHONY: bump-tools
endif

ifneq ($(strip $(INSTALL_TOOLS_TARGETS)), "")
HELP += $(call MK_HELP,'install-tools','Install all standalone tools')
install-tools: $(INSTALL_TOOLS_TARGETS)
.PHONY: install-tools
endif

endif
