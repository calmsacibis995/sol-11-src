#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
# Copyright (c) 2009, 2011, Oracle and/or its affiliates. All rights reserved.
#
#	This makefile drives the production of the mpt_sas driver kernel module.
#
#	intel architecture dependent
#

#
#	Paths to the base of the uts directory trees
#
UTSBASE   = ../../../../src/uts

#
#	Define the module and object file sets.
#
MODULE		= mpt_sas
OBJECTS		= $(MPTSAS_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(MPTSAS_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_DRV_DIR)/$(MODULE)
CONF_SRCDIR	= $(UTSBASE)/common/io/scsi/adapters/mpt_sas/
WARLOCK_OUT     = $(MPTSAS_OBJS:%.o=%.ll)
WARLOCK_OK      = $(MODULE).ok
WLCMD_DIR       = $(UTSBASE)/common/io/warlock
ROOTETCDRVCONF	= $(ROOT_ETC_DRV_DIR)/$(MODULE)

#
#	Kernel Module Dependencies
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
include $(UTSBASE)/intel/Makefile.intel

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
include $(UTSBASE)/intel/Makefile.targ

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
SCSI_FILES = $(SCSI_OBJS:%.o= -l $(UTSBASE)/intel/scsi/%.ll)

warlock: $(WARLOCK_OK)

$(WARLOCK_OK): $(WARLOCK_OUT) warlock_ddi.files scsi.files \
	$(WLCMD_DIR)/mptsas.wlcmd
	$(WARLOCK) -c $(WLCMD_DIR)/mptsas.wlcmd $(WARLOCK_OUT) \
	$(SCSI_FILES) \
	$(UTSBASE)/intel/warlock/scsi.ll \
	-l $(UTSBASE)/intel/warlock/ddi_dki_impl.ll
	$(TOUCH) $@

%.ll: $(UTSBASE)/common/io/scsi/adapters/mpt_sas/%.c
	$(WLCC) $(CPPFLAGS) -DDEBUG -o $@ $<

warlock_ddi.files:
	@cd $(UTSBASE)/intel/warlock; pwd; $(MAKE) warlock

scsi.files:
	@cd $(UTSBASE)/intel/scsi; pwd; $(MAKE) warlock

