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
# cmd/fs.d/quota/Makefile

PROG=		quota

include		$(SRC)/cmd/Makefile.cmd

UTSBASE =	$(SRC)/uts
OTHERINSTALL=	$(ROOTUSRSBIN)/$(LIBPROG)
LINKVALUE=	../lib/fs/$(FSTYPE)/$(LIBPROG)

OBJS=		quota.o rquota_xdr.o replica.o
SRCS=		quota.c rquota_xdr.c ../nfs/lib/replica.c
XFILE=		$(ROOT)/usr/include/rpcsvc/rquota.x
CPPFLAGS +=	-I $(ROOT)/usr/include/sys -D_LARGEFILE64_SOURCE
CPPFLAGS +=	-I $(UTSBASE)/common/brand/solaris10
LDLIBS +=	-lnsl
POFILE=		quota.po

FILEMODE= 04555

all:		$(PROG)

$(PROG): $(OBJS)
		$(LINK.c) -o $@ $(OBJS) $(LDLIBS)
		$(POST_PROCESS)

install:	all $(ROOTUSRSBINPROG)

lint:		lint_SRCS

clean:
		$(RM) $(OBJS) rquota_xdr.c

rquota_xdr.c:	$(XFILE)
		$(RPCGEN) -C -c $(XFILE) -o $@

replica.o:	../nfs/lib/replica.c
		$(COMPILE.c) ../nfs/lib/replica.c

catalog:        $(POFILE)

include		$(SRC)/cmd/Makefile.targ
