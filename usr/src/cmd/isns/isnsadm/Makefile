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
# Copyright (c) 2008, 2011, Oracle and/or its affiliates. All rights reserved.
#

PROG = isnsadm
SRCS = cmdparse.c isnsadm.c isnsadm_msg.c
OBJS = $(SRCS:%.c=%.o)

include ../../Makefile.cmd

LXML2 = -lxml2
lint := LXML2 =
LDLIBS += $(LXML2) -lscf -lc
CFLAGS += $(CCVERBOSE)
CPPFLAGS += -I. -I/usr/include/libxml2 -I../isnsd
POFILE = isnsadm_all.po
POFILES = $(OBJS:%.o=%.po)

LINTFLAGS += -xerroff=E_BAD_FORMAT_STR2 -xerroff=E_NAME_USED_NOT_DEF2

.KEEP_STATE:

all: $(PROG)

clean:
	$(RM) $(OBJS) $(PROG)

lint:	lint_SRCS

$(PROG): $(OBJS)
	$(LINK.c) -o $@ $(OBJS) $(LDLIBS)
	$(POST_PROCESS)

$(POFILE): $(POFILES)
	$(RM) $@
	$(CAT) $(POFILES) > $@

include ../../Makefile.targ

install: all .WAIT $(ROOTUSRSBINPROG)
