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
#
# Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved.
#
#

include		$(SRC)/lib/krb5/Makefile.lib

include $(SRC)/lib/gss_mechs/mech_krb5/Makefile.mech_krb5

SUBDIRS=	$(MACH)

all :=		TARGET= all
clean :=	TARGET= clean
clobber :=	TARGET= clobber
install :=	TARGET= install
lint :=		TARGET= lint
_msg :=		TARGET= _msg
stub :=		TARGET= stub
stubinstall :=	TARGET= stubinstall

.KEEP_STATE:

all clean clobber lint _msg stub stubinstall: $(SUBDIRS)

$(ROOTLIBDIR):
	$(INS.dir)

$(ROOTLIBDIR)/%: %
	$(INS.file)

install:   $(ROOTLIBDIR) $(SUBDIRS)

$(SUBDIRS): FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

FRC:
