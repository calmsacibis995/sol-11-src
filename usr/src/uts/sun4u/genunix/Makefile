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
# Copyright (c) 1994, 2011, Oracle and/or its affiliates. All rights reserved.
#
#	This makefile drives the production of the generic
#	unix kernel module.
#
#	sparc implementation architecture dependent
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE	= ../..

#
#	Define the module and object file sets.
#
MODULE		= genunix
GENUNIX		= $(OBJS_DIR)/$(MODULE)

OBJECTS		= $(GENUNIX_OBJS:%=$(OBJS_DIR)/%) \
		  $(NOT_YET_KMODS:%=$(OBJS_DIR)/%)

LINTS		= $(GENUNIX_OBJS:%.o=$(LINTS_DIR)/%.ln) \
		  $(NOT_YET_KMODS:%.o=$(LINTS_DIR)/%.ln)

ROOTMODULE	= $(ROOT_PSM_KERN_DIR)/$(MODULE)

PLATFORM	= sun4u
LIBGEN		= $(OBJS_DIR)/libgenunix.so
LIBSTUBS	= $(GENSTUBS_OBJS:%=$(OBJS_DIR)/%)

#
#	Include common rules.
#
include $(UTSBASE)/sparc/Makefile.sparc

#
#	Define targets
#
ALL_TARGET	= $(LIBGEN)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(GENUNIX) $(ROOTMODULE)

#
#	Override defaults
#
CLEANFILES	+= $(LIBSTUBS) $(LIBGEN)

LINT_LIB_DIR	= $(UTSBASE)/$(PLATFORM)/lint-libs/$(OBJS_DIR)
LINT_LIB	= $(LINT_LIB_DIR)/llib-lunix.ln
GEN_LINT_LIB	=

BINARY		=

CLOBBERFILES	+= $(GENUNIX)

#
# Non-SRU genunix builds merge a version of the ip module called ipctf.  This
# is to ensure that the common network-related types are included in genunix and
# can thus be uniquified out of other modules.  We don't want to do this for
# SRU builds.
#
IPCTF_TARGET	= $(IPCTF)
$(SRU_BUILD)IPCTF_TARGET =

# 
# lint pass one enforcement 
# 
CFLAGS += $(CCVERBOSE)
CPPFLAGS += -I$(SRC)/common
CPPFLAGS += -I$(SRC)/uts/common/fs/zfs

INC_PATH +=  -I$(UTSBASE)/sun4

#
# For now, disable these lint checks; maintainers should endeavor
# to investigate and remove these for maximum lint coverage.
# Please do not carry these forward to new Makefiles.
#
LINTTAGS	+= -erroff=E_SUSPICIOUS_COMPARISON
LINTTAGS	+= -erroff=E_BAD_PTR_CAST_ALIGN
LINTTAGS	+= -erroff=E_SUPPRESSION_DIRECTIVE_UNUSED
LINTTAGS	+= -erroff=E_STATIC_UNUSED
LINTTAGS	+= -erroff=E_PTRDIFF_OVERFLOW
LINTTAGS	+= -erroff=E_ASSIGN_NARROW_CONV

#
# Ensure that lint sees 'struct cpu' containing a fully declared
# embedded 'struct machcpu'
#
LINTFLAGS	+= -D_MACHDEP -I../../sun4 -I../../$(PLATFORM) -I../../sfmmu

#	Default build targets.
#
.KEEP_STATE:

.PARALLEL:	$(LIBSTUBS)

def:		$(DEF_DEPS)

all:		$(ALL_DEPS)

clean:		$(CLEAN_DEPS)

clobber:	$(CLOBBER_DEPS)

lint:		$(LINT_DEPS)

modlintlib:	$(MODLINTLIB_DEPS)

clean.lint:	$(CLEAN_LINT_DEPS)

install:  	$(INSTALL_DEPS)

install_h:


$(LIBGEN):	$(GENUNIX) $(LIBSTUBS)
	$(BUILD.SO) $(GENUNIX) $(LIBSTUBS)

$(IPCTF_TARGET) ipctf_target: FRC
	@cd $(IPDRV_DIR); pwd; $(MAKE) ipctf.$(OBJS_DIR)
	@pwd

$(GENUNIX): $(IPCTF_TARGET) $(OBJECTS)
	$(LD) $(LDFLAGS_uts_genunix) -o $@ $(OBJECTS)
	$(CTFMERGE_GENUNIX_MERGE)
	$(POST_PROCESS)

$(OBJECTS): $(OBJS_DIR)

#
#	Include common targets.
#
include $(UTSBASE)/sparc/Makefile.targ

#
#	Include sun4u workarounds.
#
include $(UTSBASE)/sun4u/Makefile.workarounds

ALL_DEFS +=	$(WORKAROUND_DEFS)
