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
# Copyright (c) 2002, 2011, Oracle and/or its affiliates. All rights reserved.
#
# lib/libexacct/demo/Makefile
#

PROG = exdump

include ../../../cmd/Makefile.cmd

LDLIBS += -lexacct -lproject -lsocket -lnsl
CFLAGS += $(CCVERBOSE)

.KEEP_STATE:

DEMOFILES = \
	exdump.c \
	Makefile \
	README

ROOTDEMODIR = $(ROOT)/usr/demo/libexacct
ROOTDEMOFILES = $(DEMOFILES:%=$(ROOTDEMODIR)/%)

all: $(PROG)

install: all $(ROOTDEMOFILES)

# The demos do not deliver shared objects, and do not require stubs.
# Provide NULL make rules to satisfy the parent makefiles.
stub:
stubinstall:

clean:

lint: lint_PROG

$(ROOTDEMODIR):
	$(INS.dir)

$(ROOTDEMODIR)/%: %.demo
	$(INS.rename)

$(ROOTDEMODIR)/%: %
	$(INS.file)

$(ROOTDEMOFILES): $(ROOTDEMODIR)

$(ROOTDEMODIR) := DIRMODE = 755

$(ROOTDEMOFILES) := FILEMODE = 644

include ../../../cmd/Makefile.targ
