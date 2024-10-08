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
# Copyright (c) 2008, 2011, Oracle and/or its affiliates. All rights reserved.
#

# must be before include of Makefile.cmd
DYNPROG = nscadm nskernd

include ../../Makefile.cmd
include ../Makefile.com

PROG = $(DYNPROG)

OBJS=	nscadm.o nskernd.o
SRCS=	$(OBJS:%.o=%.c)
POFILES= $(OBJS:%.o=%.po)

nscadm	:= POBJS = nscadm.o
nskernd	:= POBJS = nskernd.o

CFLAGS += -v
CPPFLAGS += -DBUILD_REV_STR='"5.11"'
NSCADM_LDLIBS = -lnsctl
NSKERND_LDLIBS = -lnsctl -ldscfg
LINTFLAGS += -Xa -n -s -x -m -u -Dlint -errhdr=%user -DDEBUG
LINTDIR = $(KBASE)/lintdir
POFILE = nsctl_all.po
LFILE = $(LINTDIR)/nsctl.ln
ROOTLIBLINK = $(ROOTLIB)/nskernd
ROOTUSRSBINLINK = $(ROOTUSRSBIN)/nscadm

all	:=	TARGET= all
install	:=	TARGET= install
clean	:=	TARGET= clean
clobber	:=	TARGET= clobber
lint	:=	TARGET= lint

nscadm	:=	LDLIBS += $(NSCADM_LDLIBS)
nskernd	:=	LDLIBS += $(NSKERND_LDLIBS)

.KEEP_STATE:

.PARALLEL: $(OBJS)

all: $(PROG) $(POFILES)

install: all $(ROOTPROG) $(ROOTBIN)/nskernd $(ROOTLIBLINK) $(ROOTUSRSBINLINK)

lint:	lint_SRCS

clean:
	$(RM) *.o $(POFILES)

$(PROG): $$(POBJS)
	$(LINK.c) $(POBJS) -o $@ $(LDLIBS)
	$(POST_PROCESS)

$(POFILE): $(POFILES)
	$(RM) $@
	$(CAT) $(POFILES) > $@

$(ROOTLIBLINK): $(ROOTLIB) $(ROOTBIN)/nskernd
	-$(RM) $@; $(LN) $(ROOTBIN)/nskernd $@

$(ROOTUSRSBINLINK): $(ROOTUSRSBIN) $(ROOTPROG)
	-$(RM) $@; $(LN) $(ROOTBIN)/nscadm $@

include	../../Makefile.targ
