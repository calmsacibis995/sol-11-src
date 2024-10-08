#
# Copyright (c) 1997, 2011, Oracle and/or its affiliates. All rights reserved.
#

PROG= ktutil

OBJS	= ktutil.o ktutil_ct.o ktutil_funcs.o
SRCS	= $(OBJS:.o=.c)

CLOBBERFILES += $(TESTPROG)

include ../../../Makefile.cmd
include $(SRC)/lib/gss_mechs/mech_krb5/Makefile.mech_krb5

POFILE = $(PROG).po
POFILES = generic.po

CPPFLAGS += -I$(SRC)/uts/common/gssapi/include \
	-I$(SRC)/lib/gss_mechs/mech_krb5/include/krb5 \
	-I$(SRC)/lib/krb5 \
        -I$(SRC)/lib/gss_mechs/mech_krb5/include \
	-I$(SRC)/uts/common/gssapi/include  \
	-I$(SRC)/uts/common/gssapi/mechs/krb5/include \
	-DHAVE_LIBSOCKET=1 -DHAVE_LIBNSL=1 -DHAVE_UNISTD_H=1 \
	-DHAVE_SYS_TIMEB_H=1 -DHAVE_ALLOCA_H=1 -DHAVE_FTIME=1 \
	 -DHAVE_TIMEZONE
COPTFLAG += $(XESS) #-I$(KINCDIR) 

# c99=%all supports the inline keyword found in some krb header files
C99MODE=	-xc99=%all
C99LMODE=	-Xc99=%all

LDFLAGS += $(KRUNPATH) $(KERBRUNPATH)
LDLIBS += $(KMECHLIB) $(LROOT)$(KERBLIBDIR)/libss.so

.KEEP_STATE:

all: $(PROG)

ktutil:	$(OBJS) 
	$(LINK.c) $(OBJS) -o $@ $(LDLIBS)
	$(POST_PROCESS)

install: $(KRB5PROG)

clean:
	$(RM) $(OBJS)

lint: lint_SRCS

include ../../../Makefile.targ

$(POFILE): $(DERIVED_FILES) .WAIT $(POFILES)
	$(RM) $@
	$(CAT) $(POFILES) > $@
	$(RM) generic.po

generic.po:
	$(RM) messages.po
	$(XGETTEXT) $(XGETFLAGS) `$(GREP) -l gettext *.[ch]`
	$(SED) "/^domain/d" messages.po > $@
	$(RM) messages.po
