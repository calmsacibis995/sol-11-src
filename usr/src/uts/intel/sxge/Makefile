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
# Copyright (c) 2010, 2011, Oracle and/or its affiliates. All rights reserved.
#
# uts/intel/sxge/Makefile
#
#	This makefile drives the production of the Sun
#	10/40G sxge Ethernet leaf driver kernel module.
#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE	= ../..

#
#	Define the module and object file sets.
#
MODULE		= sxge
SXGE_OBJECTS =	$(SXGE_OBJS)
OBJECTS		=  $(SXGE_OBJECTS:%=$(OBJS_DIR)/%)
LINTS		= $(SXGE_OBJECTS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_DRV_DIR)/$(MODULE)
CONF_SRCDIR	= $(UTSBASE)/common/io/sxge

#
#	Include common rules.
#
include $(UTSBASE)/intel/Makefile.intel

#
#	Override defaults to build a unique, local modstubs.o.
#
MODSTUBS_DIR	= $(OBJS_DIR)

CLEANFILES	+= $(MODSTUBS_O)

#
#	Define targets
#
ALL_TARGET	= $(BINARY)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(BINARY) $(ROOTMODULE) $(ROOT_CONFFILE)

#
#
# Turn on doubleword alignment for 64 bit registers
#
#CFLAGS	+= -dalign
#
# Include hxge specific header files
#
INC_PATH	+= -I$(UTSBASE)/common
INC_PATH	+= -I$(UTSBASE)/common/io/sxge
#
#
# lint pass one enforcement
#
CFLAGS += -DSOLARIS
#
# Debug flags
#
#CFLAGS += -DSXGE_DEBUG
#
LINTFLAGS += -DSOLARIS
#
# STREAMS, DDI API limitations and other ON header file definitions such as ethernet.h
# force us to turn off these lint checks.
#
LINTTAGS	+= -erroff=E_BAD_PTR_CAST_ALIGN
LINTTAGS	+= -erroff=E_PTRDIFF_OVERFLOW
LINTTAGS	+= -erroff=E_FALSE_LOGICAL_EXPR
#
#	Driver depends on mac & IP
#
LDFLAGS		+= -dy -N misc/mac -N drv/ip

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

#
#	Include common targets.
#
include $(UTSBASE)/intel/Makefile.targ
