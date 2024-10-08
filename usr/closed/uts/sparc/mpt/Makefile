#
# Copyright (c) 2004, 2011, Oracle and/or its affiliates. All rights reserved.
#
#	This makefile drives the production of the mpt driver kernel module.
#
#	Sparc architecture dependent
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSCLOSED = ../..
UTSBASE   = ../../../../src/uts

#
#	Define the module and object file sets.
#
MODULE		= mpt
OBJECTS		= $(MPT_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(MPT_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_DRV_DIR)/$(MODULE)
CONF_SRCDIR	= $(UTSCLOSED)/common/io/scsi/adapters
WARLOCK_OUT     = $(MPT_OBJS:%.o=%.ll)
WARLOCK_OK      = $(MODULE).ok
WLCMD_DIR       = $(UTSBASE)/common/io/warlock
ROOTETCDRVCONF	= $(ROOT_ETC_DRV_DIR)/$(MODULE)

#
# 	Kernel Module Dependencies
#
LDFLAGS += -dy -Nmisc/scsi -Ndrv/scsi_vhci

#
#	Define targets
#
ALL_TARGET	= $(BINARY) $(CONFMOD)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(BINARY) $(ROOTMODULE) $(ROOT_CONFFILE) $(ROOT_ETCCONFFILE)

#
#	Include common rules.
#
include $(UTSCLOSED)/sparc/Makefile.sparc

# 
# lint pass one enforcement 
# 
CFLAGS += $(CCVERBOSE)

#
# For now, disable these lint checks; maintainers should endeavor
# to investigate and remove these for maximum lint coverage.
# Please do not carry these forward to new Makefiles.
#
LINTTAGS	+= -erroff=E_BAD_PTR_CAST_ALIGN
LINTTAGS	+= -erroff=E_ASSIGN_NARROW_CONV
LINTTAGS	+= -erroff=E_SUSPICIOUS_COMPARISON

#
#	Default build targets.
#
.KEEP_STATE:

all:		$(ALL_DEPS)

def:		$(DEF_DEPS)

clean:		$(CLEAN_DEPS)
		$(RM) $(WARLOCK_OUT) $(WARLOCK_OK)

clobber:	$(CLOBBER_DEPS)
		$(RM) $(WARLOCK_OUT) $(WARLOCK_OK)

lint:		$(LINT_DEPS)

modlintlib:	$(MODLINTLIB_DEPS)

clean.lint:	$(CLEAN_LINT_DEPS)

install:	$(INSTALL_DEPS)

#
#	Include common targets.
#
include $(UTSCLOSED)/sparc/Makefile.targ

#
#	Defines for local commands.
#
WARLOCK		= warlock
WLCC		= wlcc
TOUCH		= touch
TEST		= test

#
#	lock_lint rules
#
SCSI_FILES = $(SCSI_OBJS:%.o= -l $(UTSBASE)/sparc/scsi/%.ll)

warlock: $(WARLOCK_OK)

$(WARLOCK_OK): $(WARLOCK_OUT) warlock_ddi.files scsi.files \
	$(WLCMD_DIR)/mpt.wlcmd
	$(WARLOCK) -c $(WLCMD_DIR)/mpt.wlcmd $(WARLOCK_OUT) \
	$(UTSBASE)/sparc/warlock/scsi.ll \
	$(SCSI_FILES) \
	-l $(UTSBASE)/sparc/warlock/ddi_dki_impl.ll
	$(TOUCH) $@

%.ll: $(UTSCLOSED)/common/io/scsi/adapters/%.c
	$(WLCC) $(CPPFLAGS) -DDEBUG -o $@ $<

warlock_ddi.files:
	@cd $(UTSBASE)/sparc/warlock; pwd; $(MAKE) warlock

scsi.files:
	@cd $(UTSBASE)/sparc/scsi; pwd; $(MAKE) warlock

