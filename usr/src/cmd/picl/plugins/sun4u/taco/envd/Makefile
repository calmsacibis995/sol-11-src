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
# cmd/picl/plugins/sun4u/taco/envd/Makefile
#
include	$(SRC)/Makefile.psm

LIBRARY=	libpiclenvd.a
VERS=		.1

OBJECTS=	piclenvd.o piclenvsetup.o 

# include library definitions
include $(SRC)/lib/Makefile.lib

ROOT_PLATFORM = $(USR_PLAT_DIR)/SUNW,Sun-Blade-1500

include	$(SRC)/cmd/picl/plugins/Makefile.com

CPPFLAGS +=	-D_REENTRANT -D_POSIX_PTHREAD_SEMANTICS
CPPFLAGS +=	-I$(SRC)/uts/sun4u/ -I$(SRC)/uts/common/
CPPFLAGS +=	-I$(SRC)/uts/sun4u/taco
CPPFLAGS +=     -I$(SRC)/cmd/picl/plugins/lib/picld_pluginutil

SRCS=		$(OBJECTS:%.o=%.c)

LIBS =		$(DYNLIB)

ROOTLIBDIR	= $(ROOT_PLAT_PLUGINDIR)

CONF=           envmodel.conf
ROOTCONF=       $(CONF:%=$(ROOTLIBDIR)/%)
$(ROOTCONF)	:= FILEMODE = 0644
INFOS=          envmodel.info

LINTSRC =	$(LINTLIB:%.ln=%)
ROOTLINTDIR =	$(ROOTLIBDIR)
ROOTLINT =	$(LINTSRC:%=$(ROOTLINTDIR)/%)

CLEANFILES=	$(LINTOUT) $(LINTLIB)

CFLAGS +=	$(CCVERBOSE)
DYNFLAGS +=	-R/usr/platform/\$$PLATFORM/lib/picl/plugins:/usr/platform/sun4u/lib/picl/plugins:/usr/lib/picl/plugins
LDLIBS +=	-L$(SRC)/cmd/picl/plugins/common/devtree
LDLIBS +=       -L$(SRC)/cmd/picl/plugins/lib/picld_pluginutil/$(MACH)
LDLIBS +=	-L$(ROOT)/usr/lib/picl/plugins -lpicldevtree -lpicltree
LDLIBS +=       -lpicld_pluginutil
LDLIBS +=	-ldevinfo -lc

.KEEP_STATE:

SUBDIRS=

POFILE =	piclenvd_taco.po
POFILES =	$(SRCS:%.c=%.po)

all :=		TARGET= all
install :=	TARGET= install
clean :=	TARGET= clean
clobber :=	TARGET= clobber
lint :=		TARGET= lint
_msg :=		TARGET= _msg

all: $(LIBS) $(LIBLINKS) $(CONF)

install:	$(ROOTLIBDIR) all $(ROOTLIBS) $(ROOTLINKS) $(ROOTCONF)

$(CONF): $(INFOS)
	$(RM) $@
	$(CPP) envmodel.info > $@


$(POFILE):	$(POFILES)
	$(CAT) $(POFILES) > $(POFILE)

_msg:	$(MSGDOMAIN) $(POFILE)
	$(RM) $(MSGDOMAIN)/$(POFILE)
	$(CP) $(POFILE) $(MSGDOMAIN)/$(POFILE)

$(MSGDOMAIN):
	$(INS.dir)


$(LIBLINKS):	FRC
	$(RM) $@; $(SYMLINK) $(DYNLIB) $@

# include library targets
include $(SRC)/lib/Makefile.targ
include	$(SRC)/cmd/picl/plugins/Makefile.targ

$(ROOTLINTDIR)/%: ../%
	$(INS.file)

lint:
	$(LINT.c) $(SRCS)

$(SUBDIRS): FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

FRC:
