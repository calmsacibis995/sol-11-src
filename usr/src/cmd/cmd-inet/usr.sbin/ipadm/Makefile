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
# Copyright (c) 2010, 2011, Oracle and/or its affiliates. All rights reserved.
#

PROG =		ipadm
ROOTFS_PROG =	$(PROG)
LOCALOBJS=	ipadm.o
COMMONOBJS=	
OBJS=		$(LOCALOBJS) $(COMMONOBJS)

include ../../../Makefile.cmd
include ../../Makefile.cmd-inet

XGETFLAGS += 	-a -x $(PROG).xcl
LOCALSRCS=	$(LOCALOBJS:%.o=%.c)
COMMONSRCS=	$(CMDINETCOMMONDIR)/$(COMMONOBJS:%.o=%.c)
SRCS=		$(LOCALSRCS) $(COMMONSRCS)

CPPFLAGS +=	-I$(CMDINETCOMMONDIR)
LDLIBS +=       -linetutil -lipadm -lnvpair -lcmdutils
LINTFLAGS +=	-m

# ipadm uses the ancillary data feature which is available only through
# UNIX 98 standards version of Socket interface. This interface is supposed to
# be accessed by -lxnet. We used to add -lsocket to capture new
# not-yet-standard interfaces, but that no longer is necessary.
#
# Someday -lxnet alone should be enough when IPv6 inspired new interfaces
# are part of standards.
LDLIBS +=	-lxnet

# these #defines are required to use UNIX 98 interfaces
_D_UNIX98_EXTN= -D_XOPEN_SOURCE=500 -D__EXTENSIONS__

$(OBJS)		:= CPPFLAGS +=	$(_D_UNIX98_EXTN)

LINTFLAGS +=	$(_D_UNIX98_EXTN)

$(ROOTCFGDIR)/ipadm.conf := FILEMODE= 644

#
# Instrument ipadm with CTF data to ease debugging.
#
CTFCONVERT_HOOK = && $(CTFCONVERT_O)
CTFMERGE_HOOK = && $(CTFMERGE) -L VERSION -o $@ $(OBJS)
$(OBJS) := CFLAGS += $(CTF_FLAGS)

.KEEP_STATE:

all:	$(ROOTFS_PROG)

$(PROG):	$(OBJS)
	$(LINK.c) $(OBJS) -o $@ $(LDLIBS) $(CTFMERGE_HOOK)
	$(POST_PROCESS)

install: all $(ROOTUSRSBINPROG) $(ROOTCFGDIR) $(ROOTCFGFILES)

clean:
	$(RM) $(OBJS)

lint:	lint_SRCS

$(ROOTCFGDIR):
	$(INS.dir)

$(ROOTCFGDIR)/%: $(ROOTCFGDIR) %
	$(INS.file)

include ../../../Makefile.targ
