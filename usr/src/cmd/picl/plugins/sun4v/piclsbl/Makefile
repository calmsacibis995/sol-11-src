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
# Copyright (c) 2005, 2011, Oracle and/or its affiliates. All rights reserved.
#
# cmd/picl/plugins/sun4v/piclsbl/Makefile

LIBRARY=	libpiclsbl.a
VERS=		.1

OBJECTS=	piclsbl.o

# include library definitions
include $(SRC)/lib/Makefile.lib
include $(SRC)/Makefile.psm

include $(SRC)/cmd/picl/plugins/Makefile.com

SRCS=		$(OBJECTS:%.o=%.c)

LINT_SRC=	$(LINTLIB:%.ln=%)	

$(OBJS_DIR)/%.o:		$(SRC)/sun4v/piclsbl/%.c
	$(COMPILE.c) -o $@ $<
	$(CTFCONVERT_O)

$(LINTS_DIR)/%.ln:              $(SRC)/sun4v/piclsbl/%.c
	@($(LHEAD) $(LINT.c) $< $(LTAIL))


LIBS =		$(DYNLIB)

ROOT_PLATFORM =		$(USR_PLAT_DIR)/sun4v
DYNFLAGS_PLAT =		/usr/platform/\$$PLATFORM/lib/picl/plugins
DYNFLAGS_SUN4V =	/usr/platform/sun4v/lib/picl/plugins
DYNFLAGS_COM =		/usr/lib/picl/plugins
ROOTLIBDIR =		$(ROOT_PLAT_PLUGINDIR)

CLEANFILES=	$(LINTOUT) $(LINTLIB)

CPPFLAGS +=	-I$(SRC)/sun4v/piclsbl
CPPFLAGS +=	-I$(SRC)/uts/common/sys
CPPFLAGS +=	-I$(SRC)/lib/libpcp/common
CPPFLAGS +=	-D_REENTRANT

CFLAGS +=	$(CCVERBOSE)
DYNFLAGS +=	-R$(DYNFLAGS_COM)

LDLIBS +=	-lc -lpicltree -lumem -lnvpair

LINTFLAGS +=	-erroff=E_BAD_PTR_CAST_ALIGN -v

.KEEP_STATE:

all: $(LIBS) $(LIBLINKS)

install:	all $(ROOTLIBDIR) $(ROOTLIBS) $(ROOTLINKS)

$(ROOTLIBDIR)/$(LIBS) :	$(LIBS)
	$(RM) -r $@; $(INS) -s -m $(FILEMODE) -f $(@D) $(LIBS)

$(LIBLINKS):	FRC
	$(RM) -r $(LIBLINKS); $(SYMLINK) $(DYNLIB) $(LIBLINKS)

# include library targets
include $(SRC)/cmd/picl/plugins/Makefile.targ
include $(SRC)/lib/Makefile.targ

lint :
	$(LINT.c) $(SRCS)

FRC:
