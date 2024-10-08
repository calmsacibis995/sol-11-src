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
# uts/intel/io/sd/Makefile
#
# Copyright (c) 1997, 2010, Oracle and/or its affiliates. All rights reserved.
#
#	This makefile drives the production of the sd
#	kernel module.
#
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE	= ../..

#
#	Define the module and object file sets.
#
MODULE		= sd
OBJECTS		= $(SD_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(SD_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_DRV_DIR)/$(MODULE)
CONF_SRCDIR	= $(UTSBASE)/intel/io/scsi/targets
WARLOCK_OUT     = $(SD_OBJS:%.o=%.ll)
WARLOCK_OK      = $(MODULE).ok
WLCMD_DIR	= $(UTSBASE)/common/io/warlock

#
#	Include common rules.
#
include $(UTSBASE)/intel/Makefile.intel

#
#	Define targets
#
ALL_TARGET	= $(BINARY) $(CONFMOD)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(BINARY) $(ROOTMODULE) $(ROOT_CONFFILE)

#
#	Overrides.
#
DEBUG_FLGS	=
DEBUG_DEFS	+= $(DEBUG_FLGS)

INC_PATH	+= -I$(UTSBASE)/intel/io/scsi/targets

CPPFLAGS	+= -D_EXTVTOC

#
# For now, disable these lint checks; maintainers should endeavor
# to investigate and remove these for maximum lint coverage.
# Please do not carry these forward to new Makefiles.
#
LINTTAGS	+= -erroff=E_SUSPICIOUS_COMPARISON
LINTTAGS	+= -erroff=E_BAD_PTR_CAST_ALIGN
LINTTAGS	+= -erroff=E_STATIC_UNUSED
LINTTAGS	+= -erroff=E_PTRDIFF_OVERFLOW
LINTTAGS	+= -erroff=E_ASSIGN_NARROW_CONV

#
#	Default build targets.
#
.KEEP_STATE:

def:		$(DEF_DEPS)

all:		$(ALL_DEPS)

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
# Warlock targets
#
# Note that in warlock_with_{esp,isp} it is important to load sd.ll
# before {isp,esp}.ll; the reason is that both have _init/_info/_fini
# and warlock can only handle one extern function by a given name;
# any loaded after the first are ignored.

SCSI_FILES = $(SCSI_OBJS:%.o=-l ../scsi/%.ll)
CMLB_FILES = $(CMLB_OBJS:%.o=-l ../cmlb/%.ll)

WARLOCK_TARGETS = warlock_alone
$(CLOSED_BUILD)WARLOCK_TARGETS += warlock_with_mpt warlock_with_glm

warlock: $(WARLOCK_TARGETS)

warlock_alone: $(WARLOCK_OK)

$(WARLOCK_OK):	$(WLCMD_DIR)/sd.wlcmd $(WARLOCK_OUT) scsi_files \
	warlock_ddi.files cmlb_files
	$(WARLOCK) -c $(WLCMD_DIR)/sd.wlcmd $(WARLOCK_OUT) $(SCSI_FILES) \
		$(CMLB_FILES) \
		-l ../warlock/ddi_dki_impl.ll
	$(TOUCH) $@

%.ll: $(UTSBASE)/common/io/scsi/targets/%.c
	$(WLCC) $(CPPFLAGS) -DDEBUG -o $@ $<

warlock_with_glm: $(WLCMD_DIR)/sd_with_glm.wlcmd $(WARLOCK_OUT) scsi_files \
	glm_files warlock_ddi.files cmlb_files
	$(WARLOCK) -c $(WLCMD_DIR)/sd_with_glm.wlcmd \
		$(WARLOCK_OUT) \
		$(CLOSED)/uts/intel/glm/*.ll \
		 $(SCSI_FILES) $(CMLB_FILES) \
		-l ../warlock/ddi_dki_impl.ll

warlock_with_mpt: $(WLCMD_DIR)/sd_with_mpt.wlcmd $(WARLOCK_OUT) scsi_files \
	mpt_files warlock_ddi.files cmlb_files
	$(WARLOCK) -c $(WLCMD_DIR)/sd_with_mpt.wlcmd \
		$(WARLOCK_OUT) \
		$(CLOSED)/uts/intel/mpt/*.ll \
		$(SCSI_FILES) $(CMLB_FILES) \
		-l ../warlock/ddi_dki_impl.ll

glm_files:
	@cd $(CLOSED)/uts/intel/glm; pwd; $(MAKE) warlock

mpt_files:
	@cd $(CLOSED)/uts/intel/mpt; pwd; $(MAKE) warlock

cmlb_files:
	@cd ../cmlb; pwd; $(MAKE) warlock

scsi_files:
	@cd ../scsi; pwd; $(MAKE) warlock

warlock_ddi.files:
	@cd ../warlock; pwd; $(MAKE) warlock
