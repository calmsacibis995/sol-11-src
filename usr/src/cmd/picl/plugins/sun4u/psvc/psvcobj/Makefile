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

LIBRARY=	libpsvcobj.a
VERS=		.1

OBJECTS=	psvcobj.o

# include library definitions
include $(SRC)/lib/Makefile.lib
include $(SRC)/Makefile.psm

include $(SRC)/cmd/picl/plugins/Makefile.com

SRCS=		$(OBJECTS:%.o=%.c)

LIBS =		$(DYNLIB)

PLATFORM = sun4u

USR_PLAT_PSVCOBJ = $(LIBS:%=$(USR_PSM_LIB_DIR)/%)

CLEANFILES=	$(LINTOUT) $(LINTLIB)

CPPFLAGS +=	-I$(SRC)/uts/sun4u -I.

CFLAGS +=	$(CCVERBOSE)
LDLIBS +=	-lc 

LINTFLAGS +=

# definitions for install_h target
HDRS=		psvc_objects.h
PLATHDRS=	$(HDRS:%=$(USR_PSM_INCL_DIR)/%)
CHECKHDRS=	$(HDRS:%.h=%.check)

.KEEP_STATE:

SUBDIRS=

POFILE=	psvcobj.po

all :=		TARGET= all
install :=	TARGET= install
clean :=	TARGET= clean
clobber :=	TARGET= clobber
lint :=		TARGET= lint
_msg :=		TARGET= _msg

all: $(LIBS) $(LIBLINKS)

install:	all $(USR_PSM_LIB_DIR) $(USR_PLAT_PSVCOBJ)

install_h:	$(USR_PSM_INCL_DIR) $(PLATHDRS)

$(LIBLINKS):	FRC
	$(RM) $(LIBLINKS); $(SYMLINK) $(DYNLIB) $(LIBLINKS)

_msg:	$(POFILE)

# include library targets
include $(SRC)/cmd/picl/plugins/Makefile.targ
include $(SRC)/lib/Makefile.targ

$(USR_PSM_LIB_DIR):	FRC
	$(INS.dir)
 
$(USR_PSM_INCL_DIR)/%: %
	$(INS.file)

$(USR_PSM_LIB_DIR)/%: % $(USR_PSM_LIB_DIR)
	$(INS.file) ;\
	$(RM) -r $(USR_PSM_LIB_DIR)/libpsvcobj.so; \
	$(SYMLINK) ./libpsvcobj.so$(VERS) $(USR_PSM_LIB_DIR)/libpsvcobj.so

lint :
	$(LINT.c) $(SRCS)

$(SUBDIRS): FRC
	@cd $@; pwd; $(MAKE) $(TARGET)

FRC:
