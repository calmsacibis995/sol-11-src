#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
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
#ident	"%Z%%M%	%I%	%E% SMI"
#
# Copyright 2006 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.

#	This makefile drives the production of the MI2CV nexus driver.
#
#	Path to the base of the uts directory tree (usually /usr/src/uts).

UTSCLOSED = ../..
UTSBASE   = ../../../../src/uts

#
#	Define the module and object file sets.
#
MODULE		= mi2cv
OBJECTS		= $(MI2CV_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(MI2CV_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_PSM_DRV_DIR)/$(MODULE)

#
#	Include common rules.
#
include $(UTSCLOSED)/sun4u/Makefile.sun4u

# 
# lint pass one enforcement 
# 
CFLAGS += $(CCVERBOSE) -I$(UTSBASE)/sun4u -I$(UTSCLOSED)/sun4u

LDFLAGS += -dy -N misc/i2c_svc

#
#	Define targets
#
ALL_TARGET	= $(BINARY)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(BINARY) $(ROOTMODULE)

#
# For now, disable these lint checks; maintainers should endeavor
# to investigate and remove these for maximum lint coverage.
# Please do not carry these forward to new Makefiles.
#
LINTTAGS	+= -erroff=E_BAD_PTR_CAST_ALIGN

.KEEP_STATE:

def:		$(DEF_DEPS)

all:		$(ALL_DEPS)

clean:		$(CLEAN_DEPS)

clobber:	$(CLOBBER_DEPS)

lint:		$(LINT_DEPS)

modlintlib:	$(MODLINTLIB_DEPS)

clean.lint:	$(CLEAN_LINT_DEPS)

install:	$(INSTALL_DEPS)

#
#	Defines for local commands.
#
WLCC		= wlcc
TOUCH		= touch
WARLOCK		= warlock

#
#	Warlock targets
#

MI2CV = $(MI2CV_OBJS:%.o=%.ll)

warlock: $(MODULE).ok 

%.ok:	$(MI2CV_FILES)
	$(TOUCH) $@

%.ll: $(UTSCLOSED)/sun4u/io/i2c/nexus/mi2cv/%.c
	$(WLCC) $(CFLAGS) $(CPPFLAGS) -DDEBUG -o $@ $<

#
#	Include common targets
#
include $(UTSCLOSED)/sun4u/Makefile.targ
