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
#
# Copyright (c) 2003, 2011, Oracle and/or its affiliates. All rights reserved.
#
# uts/sparc/ibcm/Makefile
#
#	This makefile drives the production of the ibcm kernel
#	module. SPARC architecture dependent
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE	= ../..

#
#	Define the module and object file sets.
#
MODULE		= ibcm
OBJECTS		= $(IBCM_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(IBCM_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_MISC_DIR)/$(MODULE)
WARLOCK_OUT    = $(IBCM_OBJS:%.o=%.ll)
WARLOCK_OK      = $(MODULE).ok
WLCMD_DIR	= $(UTSBASE)/common/io/warlock

#
#	Include common rules.
#
include $(UTSBASE)/sparc/Makefile.sparc

#
#	Define targets
#
ALL_TARGET	= $(BINARY)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(BINARY) $(ROOTMODULE)

#
#	Overrides.
#
ALL_BUILDS	= $(ALL_BUILDSONLY64)
DEF_BUILDS	= $(DEF_BUILDSONLY64)

# 
# lint pass one enforcement 
# 
CFLAGS += $(CCVERBOSE)

#
#	depends on misc/ibtl and misc/ibmf
#
LDFLAGS	+= -dy -Nmisc/ibtl -Nmisc/ibmf -Ndrv/ip -Nmisc/dls

#
# For now, disable these lint checks; maintainers should endeavor
# to investigate and remove these for maximum lint coverage.
# Please do not carry these forward to new Makefiles.
#
LINTTAGS	+= -erroff=E_BAD_PTR_CAST_ALIGN
LINTTAGS	+= -erroff=E_ASSIGN_NARROW_CONV
LINTTAGS	+= -erroff=E_STATIC_UNUSED
LINTTAGS	+= -erroff=E_SUSPICIOUS_COMPARISON

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

modlintlib:	$(MODLINTLIB_DEPS) lint32

clean.lint:	$(CLEAN_LINT_DEPS)

install:	$(INSTALL_DEPS)

#
#	Include common targets.
#
include $(UTSBASE)/sparc/Makefile.targ

#
#       Defines for local commands.
#
WARLOCK         = warlock
WLCC            = wlcc
TOUCH           = touch
TEST            = test

warlock: $(WARLOCK_OK)

$(WARLOCK_OK): $(WARLOCK_OUT) $(WLCMD_DIR)/ibcm.wlcmd
	$(WARLOCK) -c $(WLCMD_DIR)/ibcm.wlcmd $(WARLOCK_OUT)
	$(TOUCH) $@

%.ll: $(UTSBASE)/common/io/ib/mgt/ibcm/%.c \
	$(UTSBASE)/common/sys/ib/mgt/ibcm/ibcm_impl.h
	$(WLCC)  $(CPPFLAGS) -DDEBUG -o $@ $<

warlock_ddi.files:
	@cd ../warlock; pwd; $(MAKE) warlock
