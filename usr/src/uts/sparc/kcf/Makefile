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
#	This makefile drives the production of the Kernel Cryptographic
#	Framework core module.
#
#	sparc implementation architecture dependent
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE	= ../..
COM_DIR = $(COMMONBASE)/crypto

#
#	Define the module and object file sets.
#
MODULE		= kcf
OBJECTS		= $(KCF_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(KCF_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_MISC_DIR)/$(MODULE)
KCF_OBJS	+= gcm_sparc.o kernel_fp_use.o
OFFSETS          = $(UTSBASE)/sun4/ml/offsets.in

#
#	Include common rules.
#
include $(UTSBASE)/sparc/Makefile.sparc


CLEANFILES += kernel_fp_use_offs.h
INC_PATH += -I.

#
#	Add FIPS-140 Checksum
#
POST_PROCESS	+= ; $(FIPS140_CHECKSUM)


#
#	Define targets
#
ALL_TARGET	= $(BINARY)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(BINARY) $(ROOTMODULE)

#
#	Include fips checksum header
#
INC_PATH	+= -I$(COM_DIR)/fips

#
# Linkage dependencies
#

#
# lint pass one enforcement
#
CFLAGS += $(CCVERBOSE) -I$(COM_DIR)
ASFLAGS += -xregsym=no -P -xarch=v9v

LINTTAGS	+= -I$(COM_DIR) -I.

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
include $(UTSBASE)/sparc/Makefile.targ

kernel_fp_use_offs.h: gen_kernel_fp_use_offs.c
	$(NATIVECC) -m64 -xarch=sparc -I$(UTSBASE)/common \
	-o gen_kernel_fp_use_offs gen_kernel_fp_use_offs.c
	./gen_kernel_fp_use_offs
	$(RM) gen_kernel_fp_use_offs
