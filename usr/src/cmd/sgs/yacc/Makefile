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
# Copyright (c) 1993, 2011, Oracle and/or its affiliates. All rights reserved.
#
# cmd/sgs/yacc/Makefile
#

include		../../../Makefile.master

SUBDIRS=	$(MACH) $(BUILD64) $(MACH64)

CSRC=		common/y1.c common/y2.c common/y3.c common/y4.c

# conditional statements

all :=			TARGET= all
install :=		TARGET= install
install_extra :=		TARGET= install_extra
clean :=		TARGET= clean
clobber :=		TARGET= clobber
lint :=			TARGET= lint
stub :=			TARGET= stub
stubinstall :=		TARGET= stubinstall
stubinstall_extra :=	TARGET= stubinstall_extra

# for messaging catalog
#

POFILE= yacc.po

.KEEP_STATE:

all clean clobber install install_extra lint \
	stub stubinstall stubinstall_extra:	$(SUBDIRS)

catalog:	$(POFILE)

$(POFILE):	
	$(RM) $@
	$(XGETTEXT) $(XGETFLAGS) $(CSRC)
	sed "/^domain/d" < messages.po > $@
	$(RM) messages.po

$(MACH) $(MACH64): FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

FRC:
