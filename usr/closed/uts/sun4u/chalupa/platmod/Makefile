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
# Copyright 2005 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# ident	"%Z%%M%	%I%	%E% SMI"
#

#
#	This makefile drives the production of the sun4u chalupa platform
#	module.
#
#	sun4u implementation architecture dependent
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSCLOSED = ../../..
UTSBASE	  = ../../../../../src/uts

#
#	Define the module and object file sets.
#
MODULE		= platmod
OBJECTS		= $(CHALUPA_PLATMOD_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(CHALUPA_PLATMOD_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_CHALUPA_MISC_DIR)/$(MODULE)

PLAT_DIR	= .
HERE		= $(CLOSED)/uts/sun4u/chalupa/platmod

#
#	Include common rules.
#
include $(UTSCLOSED)/sun4u/chalupa/Makefile.chalupa

#
#	Override defaults
#
CLEANFILES	+= $(PLATLIB) $(SYM_MOD)

#
#	Define targets
#
ALL_TARGET	= $(SYM_MOD)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(BINARY) $(ROOTMODULE)

#
#	Overrides
#
ALL_BUILDS	= $(ALL_BUILDSONLY64)
DEF_BUILDS	= $(DEF_BUILDSONLY64)
CLEANLINTFILES	+= $(LINT32_FILES)

#
# lint pass one enforcement
#
CFLAGS += $(CCVERBOSE)

#
#	Default build targets.
#
.KEEP_STATE:

def:		$(DEF_DEPS)

all:		$(ALL_DEPS)

clean:		$(CLEAN_DEPS)

clobber:	$(CLOBBER_DEPS)

lint:		$(LINT_DEPS)

modlintlib:	$(MODLINTLIB_DEPS)

clean.lint:	$(CLEAN_LINT_DEPS)

install:	$(INSTALL_DEPS)

check:

LINT_LIB_DIR	=$(CHALUPA_LINT_LIB_DIR)

$(PLATLIB):	$(BINARY)
	$(BUILD.SO) $(BINARY)

$(SYM_MOD):	$(UNIX_O) $(PLATLIB)
	@echo "resolving symbols against unix.o"
	@(cd $(UNIX_DIR); pwd; \
	    PLAT_DIR=$(HERE) SYM_MOD=$(HERE)/$(SYM_MOD) $(MAKE) symcheck)

#
#	Include common targets.
#
include $(UTSCLOSED)/sun4u/chalupa/Makefile.targ
