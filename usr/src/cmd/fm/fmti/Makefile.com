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
# Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved.
#

.KEEP_STATE:
.SUFFIXES:

SRCS = fmti.c fmti_subr.c bay_util.c
OBJS = $(SRCS:%.c=%.o)
LINTFILES = $(SRCS:%.c=%.ln)

PROG = fmti
ROOTLIBFM = $(ROOT)/usr/lib/fm
ROOTLIBFMD = $(ROOT)/usr/lib/fm/fmd
ROOTPROG = $(ROOTLIBFMD)/$(PROG)

CPPFLAGS += -I. -I../common -I$(SRC)/lib/fm/topo/modules/common/bay/common
CFLAGS += $(CTF_FLAGS) $(CCVERBOSE)
LDLIBS += -L$(LROOT)/usr/lib/fm -ldevinfo -lsysevent -ltopo
LDFLAGS += -R/usr/lib/fm
LINTFLAGS += -mnu

.NO_PARALLEL:
.PARALLEL: $(OBJS) $(LINTFILES)

all: $(PROG)

$(PROG): $(OBJS)
	$(LINK.c) $(OBJS) -o $@ $(LDLIBS)
	$(CTFMERGE) -L VERSION -o $@ $(OBJS)
	$(POST_PROCESS)

%.o: ../common/%.c
	$(COMPILE.c) $<
	$(CTFCONVERT_O)

%.o: $(SRC)/lib/fm/topo/modules/common/bay/common/%.c
	$(COMPILE.c) $<
	$(CTFCONVERT_O)

%.o: %.c
	$(COMPILE.c) $<
	$(CTFCONVERT_O)

clean:
	$(RM) $(OBJS) $(LINTFILES)

clobber: clean
	$(RM) $(PROG)

%.ln: ../common/%.c
	$(LINT.c) -c $<

%.ln: $(SRC)/lib/fm/topo/modules/common/bay/common/%.c
	$(LINT.c) -c $<

%.ln: %.c
	$(LINT.c) -c $<

lint: $(LINTFILES)
	$(LINT) $(LINTFLAGS) $(LINTFILES)

$(ROOTLIBFMD)/%: %
	$(INS.file)

install_h:

install: all $(ROOTPROG)