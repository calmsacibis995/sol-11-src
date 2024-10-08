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
# uts/intel/vgatext/Makefile
# Copyright (c) 1992, 2011, Oracle and/or its affiliates. All rights reserved.
#
#	This makefile drives the production of the VGA text driver
#
#	intel implementation architecture independent
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE	= ../..

#
#	Define the module and object file sets.
#
MODULE		= vgatext
OBJECTS		= $(VGATEXT_OBJS:%=$(OBJS_DIR)/%) $(OBJS_DIR)/$(VGATEXT_FONT).o
LINTS		= $(VGATEXT_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_DRV_DIR)/$(MODULE)
VGATEXT_FONT	= 8859-1
VGATEXT_SRC	= $(UTSBASE)/intel/io/vgatext

INC_PATH	+= -I$(UTSBASE)/i86pc/io/gfx_private
LDFLAGS +=	-dy -Nmisc/agpmaster -Nmisc/gfx_private
#
#	Include common rules.
#
include $(UTSBASE)/intel/Makefile.intel

#
#	Define targets
#
ALL_TARGET	= $(BINARY) # $(SRC_CONFILE)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(BINARY) $(ROOTMODULE)

#
# For now, disable these lint checks; maintainers should endeavor
# to investigate and remove these for maximum lint coverage.
# Please do not carry these forward to new Makefiles.
#
LINTTAGS	+= -erroff=E_BAD_PTR_CAST_ALIGN
LINTTAGS	+= -erroff=E_STATIC_UNUSED

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

# Custom targets and rules

$(OBJS_DIR)/$(VGATEXT_FONT).c:	$(VGATEXT_SRC)/$(VGATEXT_FONT).bdf
	awk -f $(VGATEXT_SRC)/bdf_to_c.awk	\
		$(VGATEXT_SRC)/$(VGATEXT_FONT).bdf > $@

$(OBJS_DIR)/$(VGATEXT_FONT).o:	$(OBJS_DIR)/$(VGATEXT_FONT).c
	$(COMPILE.c) -o $@ $<
	$(CTFCONVERT_O)

#
#	Include common targets.
#
include $(UTSBASE)/intel/Makefile.targ

CLEANFILES	+= $(OBJS_DIR)/$(VGATEXT_FONT).c
