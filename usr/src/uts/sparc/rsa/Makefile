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
# Copyright (c) 2003, 2011, Oracle and/or its affiliates. All rights reserved.
#
#	This makefile drives the production of the RSA KEF provider.
#
#	sparc implementation architecture dependent
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE	= ../..
COM1_DIR = $(COMMONBASE)/bignum
COM2_DIR = $(COMMONBASE)/crypto

#
#	Define the module and object file sets.
#
MODULE		= rsa
OBJECTS		= $(RSAPROV_OBJS:%=$(OBJS_DIR)/%)
LINTS		= $(RSAPROV_OBJS:%.o=$(LINTS_DIR)/%.ln)
ROOTMODULE	= $(ROOT_CRYPTO_DIR)/$(MODULE)

#
#	Include common rules.
#
include $(UTSBASE)/sparc/Makefile.sparc

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
# Linkage dependencies
#
LDFLAGS += -dy -Ncrypto/md5 -Ncrypto/sha2 -Nmisc/bignum -Nmisc/kcf

#
# lint pass one enforcement
#
CFLAGS		+= $(CCVERBOSE) -I$(COM1_DIR) -I$(COM2_DIR)
CFLAGS		+= -DUMUL64
LINTFLAGS	+= -I$(COM1_DIR) -I$(COM2_DIR)

#
# For now, disable these lint checks; maintainers should endeavor
# to investigate and remove these for maximum lint coverage.
# Please do not carry these forward to new Makefiles.
#
LINTTAGS	+= -erroff=E_SUSPICIOUS_COMPARISON
LINTTAGS	+= -erroff=E_BAD_PTR_CAST_ALIGN
LINTTAGS	+= -erroff=E_SUPPRESSION_DIRECTIVE_UNUSED
LINTTAGS	+= -erroff=E_STATIC_UNUSED
LINTTAGS	+= -erroff=E_ASSIGN_NARROW_CONV

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
