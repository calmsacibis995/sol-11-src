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
# Copyright (c) 2003, 2011, Oracle and/or its affiliates. All rights reserved.
#

include ../../Makefile.master
include ../Makefile.lib

SUBDIRS =	binfile		\
		remote		\
		syslog

all :=		TARGET= all
clean :=	TARGET= clean
clobber :=	TARGET= clobber
delete :=	TARGET= delete
install :=	TARGET= install
lint :=		TARGET= lint
package :=	TARGET= package
_msg :=		TARGET= _msg

# Audit plugins are not linked to via the link-editor, and stubs are not needed.
# Provide NULL make rules to satisfy the parent makefiles.
stub:
stubinstall:

all package clean clobber install: $(SUBDIRS)

HDRS= auditd.h
ROOTDIRS= $(ROOT)/usr/include/security

ROOTHDRS= $(HDRS:%=$(ROOTDIRS)/%)
$(ROOTHDRS) := FILEMODE = 644

CHECKHDRS= $(HDRS:%.h=%.check)

# install rule
$(ROOTDIRS)/%: %
	$(INS.file)

.KEEP_STATE:

.PARALLEL: $(SUBDIRS)

install: install_h $(SUBDIRS)

install_h: $(ROOTDIRS) .WAIT $(ROOTHDRS)

_msg: $(SUBDIRS)

catalog: $(SUBDIRS)

check: $(CHECKHDRS)

lint: $(SUBDIRS)

$(ROOTDIRS):
	$(INS.dir)

$(SUBDIRS): FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

FRC:
