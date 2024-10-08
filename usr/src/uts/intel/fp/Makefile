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
# uts/intel/fp/Makefile
#
# Copyright (c) 2003, 2011, Oracle and/or its affiliates. All rights reserved.
#
# ident "@(#)Makefile 1.10	08/07/25 SMI"
#
# This makefile drives the production of fp driver kernel module.
#
# i86pc architecture dependent
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE	= ../..

#
#	Define the module and object file sets.
#
MODULE		= fp
OBJECTS		= $(FP_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(FP_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_DRV_DIR)/$(MODULE)
CONF_SRCDIR     = $(UTSBASE)/intel/io/fibre-channel/impl/
ROOTETCDRVCONF	= $(ROOT_ETC_DRV_DIR)/$(MODULE)

#
#	Include common rules.
#
include $(UTSBASE)/Makefile.uts
include $(UTSBASE)/intel/Makefile.intel

#
#	Define targets
#
#ALL_TARGET	= $(BINARY) $(CONFMOD) $(ITUMOD)
ALL_TARGET	= $(BINARY)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(BINARY) $(ROOTMODULE) $(ROOT_CONFFILE) $(ROOT_ETCCONFFILE)

#
#	header file directories
#
INCS 		+= -I$(SRC)/uts/common/

#
#	Overrides
#
LDFLAGS		+= -dy -Ndrv/fcp -Nmisc/fctl -Nmisc/scsi

#
#	Lint tags
#
LINTTAGS	+= -erroff=E_ASSIGN_NARROW_CONV
LINTTAGS	+= -erroff=E_BAD_PTR_CAST_ALIGN
LINTTAGS	+= -erroff=E_SUSPICIOUS_COMPARISON
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

#
#	Include common targets.
#
include $(UTSBASE)/intel/Makefile.targ
