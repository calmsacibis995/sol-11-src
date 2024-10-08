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
# Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
#

PROG	= cw

MAN1FILES=	cw.1

include ../Makefile.tools

# Bootstrap problem -- we have to build cw before we can use it
i386_CC=		$(SPRO_VROOT)/bin/cc
sparc_CC=		$(SPRO_VROOT)/bin/cc
$(__GNUC)i386_CC=	$(GNU_ROOT)/bin/gcc
$(__GNUC)sparc_CC=	$(GNU_ROOT)/bin/gcc

CFLAGS += $(CCVERBOSE)

# Override CFLAGS.  This is needed only for bootstrap of cw.
CFLAGS=			-O -xspace -Xa -xildoff -xc99=%none
$(__GNUC)CFLAGS=	-O -D__sun -Wall -Wno-unknown-pragmas -Werror \
			-std=gnu89 -nodefaultlibs

$(__GNUC)LDLIBS +=	-lc
$(__GNUC)LDFLAGS= 	$(MAPFILE.NES:%=-Wl,-M%)

CPPFLAGS += -DDEFAULT_CC_DIR='"$(SPRO_VROOT)/bin"'
CPPFLAGS += -DDEFAULT_GCC_DIR='"$(GNU_ROOT)/bin"'
CPPFLAGS += -DDEFAULT_CPLUSPLUS_DIR='"$(SPRO_VROOT)/bin"'
CPPFLAGS += -DDEFAULT_GPLUSPLUS_DIR='"$(GNU_ROOT)/bin"'

$(ROOTONBLDMAN1FILES) := FILEMODE=      644

.KEEP_STATE:

all: $(PROG) $(MAN1FILES)

install: all .WAIT $(ROOTONBLDMACHPROG) $(ROOTONBLDMAN1FILES)

lint: lint_PROG

clean:

include ../Makefile.targ
