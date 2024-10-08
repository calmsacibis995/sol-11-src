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
# Copyright (c) 1999, 2011, Oracle and/or its affiliates. All rights reserved.
#

PROG    = dhcpagent
ROOTFS_PROG = $(PROG)
DEFAULTFILES = dhcpagent.dfl

OBJS =	adopt.o agent.o async.o bound.o class_id.o defaults.o inform.o \
	init_reboot.o interface.o ipc_action.o packet.o release.o renew.o \
	request.o script_handler.o select.o states.o util.o

include ../../../Makefile.cmd

SRCS    = $(OBJS:%.o=%.c)
POFILES = $(OBJS:%.o=%.po)
XGETFLAGS += -a -x dhcpagent.xcl

#
# Instrument dhcpagent with CTF data to ease debugging.
#
CTFCONVERT_HOOK = && $(CTFCONVERT_O)
CTFMERGE_HOOK = && $(CTFMERGE) -L VERSION -o $@ $(OBJS)
$(OBJS) := CFLAGS += $(CTF_FLAGS)


#
# to compile a debug version, do a `make COPTFLAG="-g -XO0"'
#

CPPFLAGS  += -D_XOPEN_SOURCE=500 -D__EXTENSIONS__
LDLIBS    += -lxnet -lnvpair -ldhcpagent -ldhcputil -linetutil -ldevinfo -ldlpi

# Disable warnings that affect all XPG applications.
LINTFLAGS += -erroff=E_INCONS_ARG_DECL2 -erroff=E_INCONS_VAL_TYPE_DECL2

.KEEP_STATE:

all:		$(ROOTFS_PROG)

install:	all $(ROOTUSRSBINPROG) $(ROOTETCDEFAULTFILES)

$(PROG):	$(OBJS)
		$(LINK.c) -o $@ $(OBJS) $(LDLIBS) $(CTFMERGE_HOOK)
		$(POST_PROCESS)

$(POFILE):	$(POFILES)
		$(RM) $@; $(CAT) $(POFILES) > $@; $(RM) $(POFILES)

clean:
		$(RM) $(OBJS)

lint:		lint_SRCS

include ../../../Makefile.targ
