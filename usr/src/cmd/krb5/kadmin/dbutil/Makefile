#
# Copyright (c) 2001, 2011, Oracle and/or its affiliates. All rights reserved.
#

PROG= kdb5_util

OBJS	= kdb5_util.o \
        kdb5_create.o kadm5_create.o string_table.o kdb5_stash.o \
        kdb5_destroy.o ovload.o strtok.o dump.o kdb5_mkey.o ../cli/getdate.o

SRCS	= $(OBJS:.o=.c)

CLOBBERFILES += $(TESTPROG)

ISRCHDR=	iprop.h
KRB5IPROPDIR=	$(SRC)/cmd/krb5/iprop

include ../../../Makefile.cmd
include $(SRC)/lib/gss_mechs/mech_krb5/Makefile.mech_krb5

POFILE = $(PROG).po
POFILES = generic.po

CPPFLAGS += -I. -I../cli -I$(SRC)/lib/gss_mechs/mech_krb5/include/kerberosIV \
	-I$(SRC)/lib/gss_mechs/mech_krb5/include \
	-I$(SRC)/lib/gss_mechs/mech_krb5/include/krb5 \
	-I$(SRC)/lib/krb5 \
	-I$(SRC)/uts/common/gssapi/include \
	-I$(SRC)/uts/common/gssapi/mechs/krb5/include  \
	-I$(KRB5IPROPDIR) \
	-DHAVE_LIBSOCKET=1 -DHAVE_LIBNSL=1 -DHAVE_GETCWD=1 \
	-DHAVE_STRSTR=1 -DHAVE_COMPILE=1 -DHAVE_STEP=1 \
	-DHAVE_KRB_DB_H=1 -DHAVE_KDC_H=1 -DKDB4_DISABLE \
	-DUSE_KADM5_API_VERSION=2
COPTFLAG += $(XESS) #-I$(KINCDIR) 

# c99=%all supports the inline keyword found in some krb header files
C99MODE=	-xc99=%all
C99LMODE=	-Xc99=%all

#gtbtmp183 kdb5_create.c
CFLAGS +=       -erroff=E_ASSIGNMENT_TYPE_MISMATCH

LDFLAGS += $(KRUNPATH) $(KERBRUNPATH)
LDLIBS += -L $(LROOT_KLIBDIR) -L $(LKRB5LIB) \
	-lkadm5srv -lkdb -lmech_krb5 -lnsl -lgen

.KEEP_STATE:

all: $(PROG)

# Rpcgen-erate iprop.h from the iprop.x spec file
$(ISRCHDR):	$(KRB5IPROPDIR)/iprop.x
	$(RM)	$@
	$(RPCGEN) -h $(KRB5IPROPDIR)/iprop.x > $@

# Explicitly state the dependency on iprop.h
$(OBJS):	$(ISRCHDR)

$(PROG):	$(OBJS) 
	$(LINK.c) $(OBJS) -o $@ $(LDLIBS)
	$(POST_PROCESS)

install: $(KRB5SBINPROG)

clean:
	$(RM) $(OBJS) $(ISRCHDR)

lint: lint_SRCS

include ../../../Makefile.targ

$(POFILE): $(DERIVED_FILES) .WAIT $(POFILES)
	$(RM) $@
	$(CAT) $(POFILES) > $@

generic.po: FRC
	$(RM) messages.po
	$(XGETTEXT) $(XGETFLAGS) `$(GREP) -l gettext *.[ch]`
	$(SED) "/^domain/d" messages.po > $@
	$(RM) messages.po

FRC:
