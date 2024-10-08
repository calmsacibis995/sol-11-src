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
# Copyright (c) 2003, 2011, Oracle and/or its affiliates. All rights reserved.
#

PROG=	zonecfg
OBJS=	zonecfg.o zonecfg_lex.o zonecfg_grammar.tab.o

include ../Makefile.cmd

# zonecfg has a name clash with main() and libl.so.1.  However, zonecfg must
# still export a number of "yy*" (libl) interfaces.  Reduce all other symbols
# to local scope.
MAPFILES +=	$(MAPFILE.LEX) $(MAPFILE.NGB)
MAPOPTS =	$(MAPFILES:%=-M%)

LFLAGS =	-t
YFLAGS =	-d -b zonecfg_grammar
LDLIBS +=	-lzonecfg -ll -lnsl -ltecla -lzfs -lbrand -ldladm -linetutil \
		-lsocket -lnvpair
CPPFLAGS +=	-I.
LDFLAGS +=	$(MAPOPTS)
CLEANFILES +=	zonecfg_lex.c zonecfg_grammar.tab.c zonecfg_grammar.tab.h

.KEEP_STATE:

all: $(PROG)

$(PROG): $(OBJS) $(MAPFILES)
	$(LINK.c) -o $@ $(OBJS) $(LDLIBS)
	$(POST_PROCESS)

install: all $(ROOTUSRSBINPROG)

zonecfg_lex.c:	zonecfg_lex.l zonecfg_grammar.tab.h zonecfg.h
	$(LEX) $(LFLAGS) zonecfg_lex.l > $@

zonecfg_grammar.tab.h zonecfg_grammar.tab.c:	zonecfg_grammar.y zonecfg.h
	$(YACC) $(YFLAGS) zonecfg_grammar.y

zonecfg_lex.o zonecfg_grammar.tab.o := CCVERBOSE =

check:	$(PROG).c $(PROG).h
	$(CSTYLE) -pP $(PROG).c $(PROG).h
	$(HDRCHK) $(PROG).h

clean:
	$(RM) $(OBJS) $(CLEANFILES)

#
# We don't do lint of lex- and yacc- generated source files
#
lint:
	$(LINT.c) -c $(PROG).c $(LDLIBS)

include ../Makefile.targ
