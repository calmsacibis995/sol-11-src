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
# Copyright (c) 2008, 2011, Oracle and/or its affiliates. All rights reserved.
#

PROG = isns

DSRC = isns_provider.d
DTRACE_HEADER = $(DSRC:%.d=%.h)

COBJS	= main.o qry.o admintf.o dsapi.o log.o sched.o dseng.o scn.o cache.o
COBJS	+= dump.o msgq.o server.o config.o esi.o obj.o utils.o dd.o func.o
COBJS	+= pdu.o door.o htable.o
OBJS	= $(COBJS) $(DSRC:%.d=%.o)
SRCS	= $(COBJS:%.o=%.c)
POFILE= isns.po
POFILES	= $(COBJS:%.o=%.po)

include ../../Makefile.cmd

DATA_STORE	= xml
XML_DIR		= xml_def
ISNS_SVC	= $(XML_DIR)/isns_server.xml

MANIFEST	= isns_server.xml
ROOTMANIFESTDIR	= $(ROOTSVCNETWORK)
$(ROOTSVCNETWORK)/isns_server.xml	:= FILEMODE = 0444

CFLAGS 		+=	$(CCVERBOSE)
CPPFLAGS 	+= -I./ -I/usr/include/libxml2
CPPFLAGS	+= -DTARGET_DATA_STORE=$(DATA_STORE)
CPPFLAGS	+= -D_POSIX_PTHREAD_SEMANTICS
LINTFLAGS += -xerroff=E_BAD_PTR_CAST_ALIGN
LINTFLAGS += -xerroff=E_NAME_USED_NOT_DEF2
LINTFLAGS += -xerroff=E_CASE_FALLTHRU

obj.o := CERRWARN += -erroff=E_CONST_OBJ_SHOULD_HAVE_INITIZR
obj.o := CERRWARN += -erroff=E_IMPLICIT_DECL_FUNC_RETURN_INT

LXML2 = -lxml2
lint := LXML2 =
LDLIBS		+= -lsocket -lnsl -lscf $(LXML2)

.KEEP_STATE:

all:	$(PROG)

$(PROG): $(OBJS)
	$(LINK.c) -o $@ $(OBJS) $(LDLIBS)
	$(POST_PROCESS)

%.h: %.d
	$(DTRACE) -xnolibs -h -s $< -o $@

%.o:	%.c $(DTRACE_HEADER)
	$(COMPILE.c) $<
	$(POST_PROCESS_O)

%.o:	%.d $(COBJS)
	$(COMPILE.d) -xnolibs -s $< $(COBJS)
	$(POST_PROCESS_O)

clean:
	$(RM) $(OBJS)

lint:	lint_SRCS

$(POFILE): $(POFILES)
	$(RM) $@
	$(CAT) $(POFILES) > $@

check:	$(CHKMANIFEST)

include ../../Makefile.targ

install: all .WAIT $(ROOTUSRSBINPROG) $(ROOTMANIFEST)
