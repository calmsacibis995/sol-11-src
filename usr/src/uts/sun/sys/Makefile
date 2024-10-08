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
# Copyright (c) 1989, 2011, Oracle and/or its affiliates. All rights reserved.
#
# include global definitions
include ../../../Makefile.master

HDRS=  \
avintr.h \
bootconf.h \
dkmpio.h		\
obpdefs.h		\
promif.h		promimpl.h \
ser_async.h		ser_zscc.h \
socalio.h		socalreg.h \
socal_cq_defs.h		socalmap.h		socalvar.h \
ttymux.h		ttymuxuser.h \
zsdev.h

SCSIADHDRS= \
fascmd.h	fasdma.h \
fasreg.h	fasvar.h	ifpio.h		sfvar.h

CLOSED_SCSIAD = $(CLOSED)/uts/sun/sys/scsi/adapters

CLOSED_SCSIADHDRS= \
ifpcmd.h	ifpmail.h	ifpreg.h	ifpvar.h \
ispcmd.h	ispmail.h	ispreg.h	ispvar.h

SCSITARGHDRS=

ROOTDIR=	$(ROOT)/usr/include/sys
ROOTDIRS=	$(ROOTDIR) \
		$(ROOTDIR)/audio \
		$(ROOTDIR)/scsi/adapters \
		$(ROOTDIR)/scsi/targets

ROOTHDRS= $(HDRS:%=$(ROOTDIR)/%)
$(CLOSED_BUILD)ROOTHDRS += $(CLOSED_HDRS:%=$(ROOTDIR)/%)
ROOTFCHDRS= $(FCHDRS:%=$(ROOTDIR)/fc4/%)
ROOTSCSIADHDRS= $(SCSIADHDRS:%=$(ROOTDIR)/scsi/adapters/%)
$(CLOSED_BUILD)ROOTSCSIADHDRS += \
	$(CLOSED_SCSIADHDRS:%=$(ROOTDIR)/scsi/adapters/%)
ROOTSCSITARGHDRS= $(SCSITARGHDRS:%=$(ROOTDIR)/scsi/targets/%)


# install rules
$(ROOTDIR)/%: %
	$(INS.file)

$(ROOTDIR)/%: $(CLOSED)/uts/sun/sys/%
	$(INS.file)

$(ROOTDIR)/audio/%: audio/%
	$(INS.file)

$(ROOTDIR)/scsi/adapters/%: scsi/adapters/%
	$(INS.file)

$(ROOTDIR)/scsi/adapters/%: $(CLOSED_SCSIAD)/%
	$(INS.file)

$(ROOTDIR)/scsi/targets/%: scsi/targets/%
	$(INS.file)

# check files really don't exist

audio/%.check:		audio/%.h
	$(DOT_H_CHECK)

scsi/adapters/%.check:	scsi/adapters/%.h
	$(DOT_H_CHECK)

scsi/targets/%.check:	scsi/targets/%.h
	$(DOT_H_CHECK)

CHECKHDRS= \
	$(HDRS:%.h=%.check) \
	$(FCHDRS:%.h=fc4/%.check) \
	$(SCSIADHDRS:%.h=scsi/adapters/%.check) \
	$(SCSITARGHDRS:%.h=scsi/targets/%.check)

$(CLOSED_BUILD)CHECKHDRS += \
	$(CLOSED_HDRS:%.h=$(CLOSED)/uts/sun/sys/%.check) \
	$(CLOSED_SCSIADHDRS:%.h=$(CLOSED_SCSIAD)/%.check)

# headers which won't quite meet the standards...
#
# devops.h has a macro where the formal parameters to the macro are greater
# than 80 characters.  cpp (or the equivalent built into acomp) does not allow
# continuation line breaks in the formal parameter list.  This could be fixed
# by giving shorter names to the formal parameters, but the right fix is to
# fix cpp.  (Also, /* CSTYLED */ doesn't seem to fix this.
#
devops.check    := CSTYLE_TAIL = | grep -v "line > 80 characters" | true

.KEEP_STATE:

.PARALLEL:	$(CHECKHDRS) $(ROOTHDRS) $(ROOTAUDHDRS) $(ROOTAUDIMPLHDRS) \
		$(ROOTSCSIADHDRS) $(ROOTSCSITARGHDRS) $(ROOTXHDRS) \
		$(ROOTFCHDRS)

install_h: 	$(ROOTDIRS) .WAIT $(ROOTHDRS) \
		$(ROOTAUDHDRS) $(ROOTAUDIMPLHDRS) \
		$(ROOTSCSIADHDRS) $(ROOTSCSITARGHDRS) $(ROOTFCHDRS)

$(ROOTDIRS):
	$(INS.dir)

check:	$(CHECKHDRS)
