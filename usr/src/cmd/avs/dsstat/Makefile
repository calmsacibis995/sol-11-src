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
#

DYNPROG = dsstat

include ../../Makefile.cmd
include ../Makefile.com

PROG = $(DYNPROG)

SUBDIRS=

dsstat		:= POBJS =  dsstat.o ii_stats.o sndr_stats.o \
			    sdbc_stats.o multi_stats.o common.o report.o

OBJS=	dsstat.o ii_stats.o sndr_stats.o sdbc_stats.o \
	multi_stats.o common.o report.o
SRCS= $(OBJS:%.o=%.c)

CFLAGS += -v
LDLIBS += -lkstat
LINTFLAGS += -Xa -n -s -x -m -u -Dlint -errhdr=%user
LINTFLAGS += -erroff=E_SEC_PRINTF_VAR_FMT -erroff=E_SEC_SPRINTF_UNBOUNDED_COPY
LINTDIR = $(KBASE)/lintdir
POFILE = dsstat_all.po
POFILES = $(OBJS:%.o=%.po)
LFILE = $(LINTDIR)/dsstat.ln
ROOTLINK = $(ROOTUSRSBIN)/$(PROG)

all	:=	TARGET= all
install	:=	TARGET= install
clean	:=	TARGET= clean
clobber	:=	TARGET= clobber
lint	:=	TARGET= lint

.KEEP_STATE:

.PARALLEL: $(OBJS)

all: $(SUBDIRS) $(PROG)

install: $(SUBDIRS) all $(ROOTPROG) $(ROOTLINK)

lint:	$(SUBDIRS) lint_SRCS

clean:	$(SUBDIRS)
	$(RM) *.o

$(PROG):	$$(POBJS)
	$(LINK.c) $(POBJS) -o $@ $(LDLIBS)
	$(POST_PROCESS)

$(POFILE): $(POFILES)
	$(RM) $@
	$(CAT) $(POFILES) > $@

$(SUBDIRS):	FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

$(ROOTLINK): $(ROOTUSRSBIN) $(ROOTPROG)
	-$(RM) $@; $(LN) $(ROOTPROG) $@

FRC:

include	../../Makefile.targ
