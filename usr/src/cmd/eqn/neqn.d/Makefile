#
# Copyright (c) 1991, 2010, Oracle and/or its affiliates. All rights reserved.
#
# cmd/eqn/neqn.d/Makefile
#

include		../../Makefile.cmd

PROG =		neqn

CSRCS =		diacrit.c eqnbox.c font.c fromto.c funny.c	\
		glob.c integral.c io.c lex.c lookup.c		\
		mark.c matrix.c move.c over.c paren.c		\
		pile.c shift.c size.c sqrt.c text.c

SRCS =		$(CSRCS:%=../%)

YACCSRC =	e.y

COBJS =		$(CSRCS:%.c=%.o)
OBJS =		$(YACCSRC:%.y=%.o) $(COBJS)


CLEANFILES =	y.tab.c y.tab.h $(YACCSRC:%.y=%.c) $(YACCSRC:%.y=%.def)

YFLAGS =	-d
CPPFLAGS =	-DNEQN -I. -I.. $(CPPFLAGS.master)
LDFLAGS +=	$(MAPFILE.NGB:%=-M%)

LINTFLAGS += -u

#
# for message catalog
#
POFILE= neqn.d.po
POFILES= e.po

.KEEP_STATE:

all :		$(PROG)

$(PROG) :	$(OBJS) $(MAPFILE.NGB)
		$(LINK.c) -o $@ $(OBJS) $(LDFLAGS) $(LDLIBS)
		$(POST_PROCESS)

catalog:        $(POFILE)
 
$(POFILE):      $(POFILES)
	 $(RM)	$@
	 cat     $(POFILES)      > $@


$(YACCSRC:%.y=%.c) + $(YACCSRC:%.y=%.def) : ../$(YACCSRC)
		$(YACC.y) ../$(YACCSRC)
		$(MV) y.tab.c $(YACCSRC:%.y=%.c)
		$(MV) y.tab.h $(YACCSRC:%.y=%.def)

$(COBJS) :	$$(@:%.o=../%.c)
		$(COMPILE.c) ../$(@:%.o=%.c)

install :	all $(ROOTPROG)

clean:
		$(RM) $(OBJS) $(CLEANFILES)

lint:		lint_SRCS

strip :
		$(STRIP) $(PROG)

include		../../Makefile.targ
