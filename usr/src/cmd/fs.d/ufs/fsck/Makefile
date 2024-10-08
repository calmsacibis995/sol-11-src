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
# Copyright (c) 1990, 2011, Oracle and/or its affiliates. All rights reserved.
#
# cmd/fs.d/ufs/fsck/Makefile

FSTYPE=		ufs
LIBPROG=	fsck
ATTMK=		$(LIBPROG)

include		../../Makefile.fstype
include		../Makefile.roll

FSCKOBJS=	main.o dir.o dup_avl.o inode.o pass1.o pass1b.o \
		pass2.o \
		pass3.o pass3b.o pass4.o pass5.o setup.o \
		utilities.o
FSCKSRCS=	$(FSCKOBJS:%.o=%.c)

UFSDIR=		../../../../uts/common/fs/ufs
UFSOBJS=	ufs_subr.o ufs_tables.o
UFSSRCS=	$(UFSOBJS:%.o=$(UFSDIR)/%.c)
ROLLDIR=	../roll_log

OBJS=		$(FSCKOBJS) $(UFSOBJS) $(ROLLOBJS) $(FSLIB)
SRCS=		$(FSCKSRCS) $(UFSSRCS) $(ROLLSRCS) $(FSLIBSRC)

CPPFLAGS +=	-D_LARGEFILE64_SOURCE -I../../ -I../../../../lib/libadm/inc
LDLIBS +=	-lefi -lavl

$(LIBPROG):	$(OBJS)
		$(LINK.c) -o $@ $(OBJS) $(LDLIBS) $(CTFMERGE_HOOK)
		$(POST_PROCESS)

%.o:	$(UFSDIR)/%.c
	$(COMPILE.c) $< $(CTFCONVERT_HOOK)

# Use DEVLINTFLAGS and the definition of LINT.c below for development
# checking.  Prior to putback, increase Nlevel to 4 for extra sanity.
# Nlevel=2 is the default applied by lint.
#
# Remember to comment LINT.c out before doing the putback, as we shouldn't
# be overriding the top-level settings under normal circumstances.
#
# Note that you have to have a proto area with populated usr/include and
# usr/include/sys (or the parent workspace needs it).  Otherwise lint gets
# very confused.  Unfortunately, we also have to tell it where its own
# include directory is, or it gets the wrong version of note.h.

SECLEVEL=core
DEVLINTFLAGS =	-errtags=yes \
		$(C99LMODE) -errsecurity=$(SECLEVEL) \
		-x -Nlevel=2 \
		-I/net/tools-sparc/export/tools.sparc/on10-tools/SUNWspro/SOS8/prod/include/lint

#LINT.c=		$(LINT) $(DEVLINTFLAGS) $(CPPFLAGS)

lint:	lint_SRCS

clean:     
	$(RM) $(FSCKOBJS) $(UFSOBJS)

cscope.out tags: FRC
	$(XREF) -f -x $@

FRC:
