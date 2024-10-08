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
# uts/sun4v/bignum/Makefile
#
#
# Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved.
#
#	This makefile drives the production of the bignum kernel module.
#
#	sun4v implementation architecture dependent
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE	= ../..
COMMONBASE = ../../..
CRYPTODIR = $(COMMONBASE)/crypto
COM1_DIR = $(COMMONBASE)/bignum

#
#	Define the module and object file sets.
#
MODULE		= bignum
OBJECTS		= $(BIGNUM_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(BIGNUM_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_PSM_MISC_DIR)/$(MODULE)

#
#	Include common rules.
#
include $(UTSBASE)/sun4v/Makefile.sun4v

#
#	Add FIPS-140 Checksum
#
POST_PROCESS	+= ; $(FIPS140_CHECKSUM)

#
#	Override defaults
#
CLEANFILES += montmul_offsets.h
INC_PATH += -I$(COM1_DIR)/sun4v -I$(COM1_DIR) \
		-I$(CRYPTODIR) -I. -I$(UTSBASE)/sparc/kcf

#
#	Define targets
#
ALL_TARGET	= $(BINARY)
LINT_TARGET	= $(MODULE).lint
INSTALL_TARGET	= $(BINARY) $(ROOTMODULE)

#
# Linkage dependencies
#
LDFLAGS		+= -dy -Nmisc/kcf

# 
# lint pass one enforcement 
# 
CFLAGS	+= $(CCVERBOSE)
CFLAGS	+= -DUMUL64 -DYF_MODEXP
LINTFLAGS	+= -I$(COM1_DIR) -I. -DUMUL64 -DYF_MODEXP

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
include $(UTSBASE)/sun4v/Makefile.targ

montmul_offsets.h:	$(COM1_DIR)/sun4v/generate_montmul_offsets.c \
			$(COM1_DIR)/sun4v/montmul_vt.h
	$(NATIVECC) -m64 -xarch=sparc -o generate_montmul_offsets \
	$(COM1_DIR)/sun4v/generate_montmul_offsets.c
	./generate_montmul_offsets
	$(RM) generate_montmul_offsets

$(OBJS_DIR)/montmul_vt_asm.o:	$(SRC)/common/bignum/sun4v/montmul_vt_asm.s \
		montmul_offsets.h
	$(COMPILE.s) -D_sparcv9 -o $(OBJS_DIR)/montmul_vt_asm.o \
		$(SRC)/common/bignum/sun4v/montmul_vt_asm.s
	$(CTFCONVERT_O)
