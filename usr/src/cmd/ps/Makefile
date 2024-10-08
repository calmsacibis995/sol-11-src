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
# cmd/ps/Makefile
#

PROG= ps
OBJS=ps.o ucbps.o
SRCS=$(OBJS:%.o=%.c)

include ../Makefile.cmd

XGETFLAGS += -a -x ps.xcl

DCFILE= $(PROG).dc

ROOTUCBPROG = $(ROOT)/usr/ucb/$(PROG)
ROOTUCBPROG64 = $(ROOT)/usr/ucb/$(MACH64)/$(PROG)

$(BUILD64)SUBDIRS += $(MACH64)

all	:=	TARGET = all
install	:=	TARGET = install
clean	:=	TARGET = clean
clobber	:=	TARGET = clobber
lint	:=	TARGET = lint

.KEEP_STATE:

all:	$(SUBDIRS)

clean clobber lint:	$(SUBDIRS)

install:	$(SUBDIRS)
	-$(RM) $(ROOTPROG)
	-$(LN) $(ROOTPROG64) $(ROOTPROG)
	-$(RM) $(ROOTUCBPROG)
	-$(LN) $(ROOTPROG64) $(ROOTUCBPROG)
	$(BUILD64)-$(RM) $(ROOTUCBPROG64)
	$(BUILD64)-$(LN) $(ROOTPROG64) $(ROOTUCBPROG64)

$(SUBDIRS):	FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

FRC:

$(DCFILE): $(PROG).c
	$(RM) $(DCFILE)
	$(COMPILE.cpp) $(PROG).c  | \
	$(XGETTEXT) -c TRANSLATION_NOTE -t -
	$(SED) -e '/^domain/d' messages.po > $@
	$(RM) messages.po

include ../Makefile.targ
