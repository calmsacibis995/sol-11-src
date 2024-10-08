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
# uts/sun4v/kt/Makefile
# Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
#
#	This makefile drives the production of the SPARC-T3 cpu module.
#
#	sun4v implementation architecture dependent
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE	= ../..

#
#	Define the module and object file sets.
#
MODULE		= SPARC-T3
OBJECTS		= $(NIAGARA2CPU_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(NIAGARA2CPU_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_PSM_CPU_DIR)/$(MODULE)

CPU_DIR		= .
HERE		= ../kt

#
#	Include common rules.
#
include $(UTSBASE)/sun4v/Makefile.sun4v

#
#	Override defaults
#
CLEANFILES	+= $(CPULIB) $(SYM_MOD)

#
#	Define targets
#
ALL_TARGET	= $(SYM_MOD)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= def $(BINARY) $(ROOTMODULE)

#
# lint pass one enforcement
#
CFLAGS += $(CCVERBOSE) -DKT_IMPL

#
# The ATOMIC_BO_ENABLE_SHIFT enables backoff in atomic routines.
# It is also used to scale final limit value w.r.t. number of
# online cpus.
#
ATOMIC_BO_FLAG = -DATOMIC_BO_ENABLE_SHIFT=4
CFLAGS += $(ATOMIC_BO_FLAG)
CPPFLAGS +=$(ATOMIC_BO_FLAG)
AS_CPPFLAGS += $(ATOMIC_BO_FLAG)

#
# cpu-module-specific flags
#
CPPFLAGS += -DCPU_MODULE -DKT_IMPL
#
# For RF, we pre-allocate 260MB of contiguous memory which is derived
# from the max config of 4 NIUs requiring 256MB, and trapstat using 4MB.
#
CPPFLAGS += -DSUN4V_CONTIG_MEM_PREALLOC_SIZE_MB=260
AS_CPPFLAGS += -DCPU_MODULE -DKT_IMPL

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

$(CPULIB):	$(BINARY)
	$(BUILD.SO) $(BINARY)

$(SYM_MOD):	$(UNIX_O) $(CPULIB)
	@echo "resolving symbols against unix.o"
	@(cd $(UNIX_DIR); pwd; \
	    CPU_DIR=$(HERE) SYM_MOD=$(HERE)/$(SYM_MOD) $(MAKE) symcheck)

#	Include common targets.
#
include $(UTSBASE)/$(PLATFORM)/Makefile.targ
