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

SVCMETHOD	= net-ipmp
MANIFEST	= network-ipmp.xml
PROG		= in.mpathd
ROOTFS_PROG	= $(PROG)
OBJS		= mpd_tables.o mpd_main.o mpd_probe.o
SRCS		= $(OBJS:%.o=%.c)
DEFAULTFILES	= mpathd.dfl

include ../../../Makefile.cmd

ROOTMANIFESTDIR=        $(ROOTSVCNETWORK)
$(ROOTMANIFEST)         := FILEMODE= 444

ROOTCMDDIR	= $(ROOT)/lib/inet

POFILE		= $(PROG).po
POFILES		= $(SRCS:%.c=%.po)

C99MODE		= $(C99_ENABLE)

#
# We need access to the ancillary data features which are only available
# via the SUS standards.  Further, C99 support requires SUSv3 or higher.
#
CPPFLAGS += -D_XOPEN_SOURCE=600 -D__EXTENSIONS__
LDLIBS	+= -lsocket -lnsl -lsysevent -lnvpair -lipmp -linetutil -ldlpi -lscf
LINTFLAGS += -erroff=E_INCONS_ARG_DECL2 -erroff=E_INCONS_ARG_USED2

#
# Instrument in.mpathd with CTF data to ease debugging.
#
CTFCONVERT_HOOK = && $(CTFCONVERT_O)
CTFMERGE_HOOK = && $(CTFMERGE) -L VERSION -o $@ $(OBJS)
$(OBJS) := CFLAGS += $(CTF_FLAGS)

.KEEP_STATE:

all:		$(PROG)

$(PROG):	$(OBJS)
		$(LINK.c) -o $@ $(OBJS) $(LDLIBS) $(CTFMERGE_HOOK)
		$(POST_PROCESS)

include ../Makefile.lib

$(ROOTLIBINETPROG):
		$(RM) $@; $(SYMLINK) ../../../lib/inet/$(PROG) $@

$(ROOTUSRSBINPROG):
		$(RM) $@; $(SYMLINK) ../lib/inet/$(PROG) $@

install:	all $(ROOTLIBINETPROG) $(ROOTUSRSBINPROG) $(ROOTCMD) \
		$(ROOTETCDEFAULTFILES) $(ROOTMANIFEST) $(ROOTSVCMETHOD)

check:		$(CHKMANIFEST)

clean:
		$(RM) $(OBJS)

lint:		lint_SRCS

$(POFILE): 	$(POFILES)
		$(RM) $@
		$(CAT) $(POFILES) > $@

include ../../../Makefile.targ
