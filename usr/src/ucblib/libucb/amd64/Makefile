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
# Copyright (c) 2004, 2011, Oracle and/or its affiliates. All rights reserved.
#

SYSOBJS= signal.o

include ../Makefile.com
include $(SRC)/lib/Makefile.lib.64

DYNFLAGS += $(DYNFLAGS64)
BUILD.SO= $(CC) $(CFLAGS) -o $@ -G $(DYNFLAGS) $(PICS) \
	-L $(LROOT)/usr/lib/$(MACH64) $(LDLIBS)

# amd64-specific rule
pics/%.o: ../$(MACH)/sys/%.c
	$(COMPILE.c) -o $@ $<
	$(POST_PROCESS_O)

.KEEP_STATE:

install: stubinstall all $(ROOTLIBS64) $(ROOTLINKS64)

stubinstall: stub $(STUBROOTLIBS64) $(STUBROOTLINKS64)
