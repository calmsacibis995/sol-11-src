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
# Copyright (c) 2001, 2011, Oracle and/or its affiliates. All rights reserved.
#
# cmd/ssh/sftp-server/Makefile

PROG =		sftp-server

OBJS =		sftp-server-main.o
SRCS =		$(OBJS:.o=.c)

include ../../Makefile.cmd
include ../Makefile.ssh-common

LDLIBS +=	$(SSH_COMMON_LDLIBS) -lsocket -lcrypto -lbsm

POFILE_DIR =	..

.KEEP_STATE:

.PARALLEL:	$(OBJS)

all:		$(PROG)

$(PROG):	$(OBJS) ../libssh/$(MACH)/libssh.a \
	../libopenbsd-compat/$(MACH)/libopenbsd-compat.a
	$(LINK.c) $(OBJS) -o $@ $(LDLIBS) $(DYNFLAGS)
	$(POST_PROCESS)

install:	all $(ROOTLIBSSHPROG) $(ROOTLIBSSH)

clean:
	$(RM) -f $(OBJS) $(PROG)

lint:		lint_SRCS

include ../Makefile.msg.targ
include ../../Makefile.targ
