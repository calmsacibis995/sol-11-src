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
# Copyright (c) 1989, 2010, Oracle and/or its affiliates. All rights reserved.
#

PROG= login
OBJS= login.o login_audit.o
SRCS= $(OBJS:%.o=%.c)
ONC_SRCS=$(SRCS:%.c=%.c_onc_plus)

DEFAULTFILES= login.dfl

include ../Makefile.cmd

LOGINDEVPERM= logindevperm
LOGINDEVPERMSRC= $(LOGINDEVPERM).sh
ROOTLOGINDEVPERM= $(LOGINDEVPERM:%=$(ROOTETC)/%)

$(ROOTLOGINDEVPERM) := FILEMODE = 644
FILEMODE= 555

CLOBBERFILES +=	$(LOGINDEVPERM) $(ONC_SRCS)

CPPFLAGS +=	-DSYSV -DCONSOLE='"/dev/console"' -DSECURITY \
		-D_FILE_OFFSET_BITS=64 -I$(SRC)/lib/pam_modules/krb5

LDLIBS += -lbsm -lpam -ldevinfo
CFLAGS += $(CCVERBOSE)

.KEEP_STATE:


all: $(PROG) $(ROOTLOGINDEVPERM)

$(LOGINDEVPERM): $(LOGINDEVPERMSRC)
	$(RM) $(LOGINDEVPERM)
	/bin/sh $(LOGINDEVPERMSRC) > $(LOGINDEVPERM)

$(PROG): $(OBJS)
	$(LINK.c) $(OBJS) -o $@ $(LDLIBS)
	$(POST_PROCESS)

install: all $(DIRS) $(ROOTPROG) $(ROOTETCDEFAULTFILES) $(ROOTLOGINDEVPERM)

clean:
	$(RM) $(OBJS)

lint:	lint_SRCS

include ../Makefile.targ

# make ONC_PLUS using suffix rule
#

ONC_PLUS: $(ONC_SRCS)
