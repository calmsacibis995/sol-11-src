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
# Copyright (c) 1997, 2011, Oracle and/or its affiliates. All rights reserved.
#
# cmd/sgs/yacc/sparcv9/Makefile
#

# This Makefile is only to produce 64-bit yacc shared library liby.so.1
# and not for building 64-bit yacc itself.
#
include ../Makefile.com
include ../../../../lib/Makefile.lib.64

# no messaging files here
POFILE=

.KEEP_STATE:

all_lib: stub $(LIBS)

install_extra: stubinstall all_lib $(ROOTLIBS64) $(ROOTLINKS64)

stubinstall stubinstall_extra: stub $(STUBROOTLIBS64) $(STUBROOTLINKS64)

include ../Makefile.targ
include ../../../Makefile.targ
include	$(SRC)/lib/Makefile.stub.targ

all:	FRC

install:	FRC

FRC:
