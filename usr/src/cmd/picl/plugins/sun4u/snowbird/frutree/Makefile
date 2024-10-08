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
# Copyright (c) 2004, 2011, Oracle and/or its affiliates. All rights reserved.
#
# cmd/picl/plugins/sun4u/snowbird/frutree/Makefile
#

include	$(SRC)/Makefile.psm

LIBRARY =	libpiclfrutree.a
VERS =		.1
PLATFORM =	SUNW,Netra-CP2300

OBJECTS =	piclfrutree.o picllibdevinfo.o piclkstat.o piclscsi.o

# include library definitions
include $(SRC)/lib/Makefile.lib

ROOT_PLATFORM = $(USR_PLAT_DIR)/$(PLATFORM)

include	$(SRC)/cmd/picl/plugins/Makefile.com

CFLAGS +=	$(CCVERBOSE)
CPPFLAGS +=	-D_REENTRANT -I$(SRC)/uts/common/

SRCS=		$(OBJECTS:%.o=%.c)

LIBS=		$(DYNLIB)

ROOTLIBDIR=	$(ROOT_PLAT_PLUGINDIR)

CLEANFILES=	$(LINTOUT) $(LINTLIB)

CPPFLAGS	+= -I$(USR_PSM_INCL_DIR)
CPPFLAGS	+= -I$(SRC)/cmd/picl/plugins/lib/picld_pluginutil
CPPFLAGS	+= -I$(SRC)/lib/libfru/include

LDLIBS +=	-L$(SRC)/cmd/picl/plugins/lib/picld_pluginutil/$(MACH)
LDLIBS +=	-L$(ROOT)/usr/lib/picl/plugins -lcfgadm -lc -lpicltree \
		-lpicld_pluginutil -lfru -lnvpair -ldevinfo \
		-lkstat -lpicldevtree
LDLIBS +=	-R/usr/platform/sun4u/lib/picl/plugins:/usr/lib/picl/plugins

.KEEP_STATE:

SUBDIRS=

POFILE= snowbird_piclfrutree.po
POFILES= $(SRCS:%.c=%.po)

all	:=	TARGET= all
install :=	TARGET= install
clean	:=	TARGET= clean
clobber	:=	TARGET= clobber
lint	:=	TARGET= lint
_msg	:=	TARGET= _msg

all: $(LIBS) $(LIBLINKS)

install:	$(ROOTLIBDIR) all $(ROOTLIBS) $(ROOTLINKS)

$(LIBLINKS):	FRC
	$(RM) $@; $(SYMLINK) ./$(DYNLIB) $@

_msg:	$(MSGDOMAIN) $(POFILE)
	$(RM) $(MSGDOMAIN)/$(POFILE)
	$(CP) $(POFILE) $(MSGDOMAIN)/$(POFILE)

$(POFILE):	$(POFILES)
		$(CAT) $(POFILES) > $(POFILE)

$(MSGDOMAIN):
	$(INS.dir)

# include library targets
include $(SRC)/lib/Makefile.targ
include	$(SRC)/cmd/picl/plugins/Makefile.targ

lint :
	$(LINT.c) $(SRCS)

$(SUBDIRS): FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

FRC:
