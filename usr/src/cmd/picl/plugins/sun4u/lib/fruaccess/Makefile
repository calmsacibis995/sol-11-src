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
# cmd/picl/plugins/sun4u/lib/fruaccess/Makefile
#
LIBRARY=	libfruaccess.a
VERS=		.1
OBJECTS=	fru_access.o cvrt_spd_data.o crcutils.o crcmodel.o

# include library definitions
include $(SRC)/Makefile.psm
include $(SRC)/lib/Makefile.lib

ROOT_PLATFORM = $(USR_PLAT_DIR)/sun4u

include $(SRC)/cmd/picl/plugins/Makefile.com

SRCS=		$(OBJECTS:%.o=%.c)

LIBS=		$(DYNLIB)

ROOTLIBDIR      = $(ROOT_PLATFORM)/lib

CONF = 		fru_container.conf
ROOTCONF=       $(CONF:%=$(ROOTLIBDIR)/%)
$(ROOTCONF)	:= FILEMODE = 0644


CLEANFILES=	$(LINTOUT) $(LINTLIB)
CLOBBERFILES += $(LIBLINKS)
CSTYLE    = cstyle -p -P
HDRCHK    = hdrchk


CPPFLAGS +=	-I$(SRC)/lib/libfru/include
CPPFLAGS +=	-I$(SRC)/lib/libfruutils/
CFLAGS +=	$(CCVERBOSE) -DBIG_ENDIAN
LDLIBS +=	-lc -lpicltree -lfruutils
LDLIBS +=	-ldevinfo
LDLIBS +=	-Wl,-f/opt/SUNWSMS/lib/$(DYNLIBPSR)     #  SMS before platform
LDLIBS +=	-Wl,-f/usr/platform/\$$PLATFORM/lib/$(DYNLIBPSR)

.KEEP_STATE:


SUBDIRS=

all :=		TARGET= all
install :=	TARGET= install
clean :=	TARGET= clean
clobber :=	TARGET= clobber
lint :=		TARGET= lint
_msg :=		TARGET= _msg

LN = ln -s

POFILE=		$(LIBRARY:.a=.po)

all:  $(DYNLIB) $(LIBLINKS) $(CONF)

install:	$(ROOTLIBDIR) all $(ROOTLIBS) $(ROOTLINKS) $(ROOTCONF)

_msg:	$(MSGDOMAIN) $(POFILE)
	$(RM) $(MSGDOMAIN)/$(POFILE)
	$(CP) $(POFILE) $(MSGDOMAIN)

$(POFILE):
	$(RM) $@ messages.po
	$(XGETTEXT) $(XGETFLAGS) *.[ch]* */*.[ch]*
	$(SED) -e '/^# msg/d' -e '/^domain/d' messages.po > $@
	$(RM) messages.po

$(MSGDOMAIN):
	$(INS.dir)

$(LIBLINKS):	FRC
	$(RM) $@; $(SYMLINK) $(DYNLIB) $@

check-style:
	$(CSTYLE) *.cc *.c *.h
	$(HDRCHK) *.h

# include library targets
include $(SRC)/cmd/picl/plugins/Makefile.targ
include $(SRC)/lib/Makefile.targ

lint :
	$(LINT.c) -m $(SRCS)

$(SUBDIRS): FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

FRC:
