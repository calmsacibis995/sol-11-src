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

#
# lib/libsmbfs/Makefile
#

include $(SRC)/lib/Makefile.lib

HDRS=		smbfs_acl.h smbfs_api.h smb_keychain.h
HDRDIR=		netsmb

ROOTHDRDIR=	$(ROOT)/usr/include/netsmb
ROOTHDRS= $(HDRS:%=$(ROOTHDRDIR)/%)

# ISA targets
SUBDIRS = $(MACH)
$(BUILD64)SUBDIRS += $(MACH64)

# conditional assignments
all :=		TARGET= all
install :=	TARGET= install
clean :=	TARGET= clean
clobber :=	TARGET= clobber
lint :=		TARGET= lint
stub :=		TARGET = stub
stubinstall :=	TARGET = stubinstall

MSGFILES =	`$(GREP) -l gettext smb/*.[ch]`
POFILE =	libsmbfs.po

.KEEP_STATE:

all install clean clobber lint stub stubinstall:  $(SUBDIRS)

_msg: $(MSGDOMAINPOFILE)

$(POFILE):	pofile_MSGFILES

install_h: $(ROOTHDRDIR) $(ROOTHDRS)

check: $(CHECKHDRS)

$(ROOTHDRDIR)/%: %
	$(INS.file)

$(ROOTHDRDIR):
	$(INS.dir)

$(SUBDIRS): FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

FRC:

include $(SRC)/lib/Makefile.targ
include $(SRC)/Makefile.msg.targ
