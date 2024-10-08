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
# Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.
#

include ../Makefile.lib

SUBDIRS = engine fcdriver extend packages pci gp2 upa interpreter efdaemon \
	jupiter
TESTDIRS = fcode_test

EFCODEDIRS= $(ROOTLIBDIR)/efcode $(ROOTLIBDIR)/efcode/$(MACH64)

all:= 		TARGET= all
install:=	TARGET= install
clean:=		TARGET= clean
clobber:=	TARGET= clobber
lint:=		TARGET= lint

.PARALLEL: $(SUBDIRS)
.KEEP_STATE:

all clean clobber lint: $(SUBDIRS)

$(EFCODEDIRS):
	$(INS.dir)

install: $(EFCODEDIRS) .WAIT $(SUBDIRS)

$(SUBDIRS): FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

$(TESTDIRS): FRC
	@cd $@; pwd; $(MAKE) all

# The efcode objects are not linked to by code outside this subtree,
# so stub objects are not needed. Provide NULL make rules to satisfy
# the parent makefiles.
stub:
stubinstall:

FRC:

#
# Interdependencies between shared objects follow.
#

extend fcdriver packages pci gp2 upa interpreter efdaemon jupiter: engine

fcdriver: packages

gp2 pci interpreter jupiter: fcdriver

interpreter: packages extend
