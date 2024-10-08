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
# Copyright (c) 1990, 2011, Oracle and/or its affiliates. All rights reserved.
#

SYNCPROG=	syncinit syncloop syncstat
DHCPPROG=	dhcpconfig dhtadm pntadm

# EXPORT DELETE START
XMODPROG=	wanbootutil
# EXPORT DELETE END

PROG=		6to4relay arp gettable if_mpadm \
		in.comsat in.fingerd in.rarpd in.rexecd in.rlogind \
		in.rshd in.rwhod in.telnetd in.tftpd ipaddrsel \
		hostconfig route soconfig \
		ndd $(SYNCPROG) $(DHCPPROG) $(XMODPROG)

MANIFEST=	rarp.xml telnet.xml comsat.xml finger.xml \
		login.xml shell.xml rexec.xml socket-filter-kssl.xml \
		network-socket-config.xml tftp-udp6.xml
SVCMETHOD=	svc-sockfilter net-socket-config

RPCSVCPROG=	hostconfig
AUDITPROG=	in.rexecd in.rlogind in.rshd in.telnetd
PAMPROG=	in.rexecd in.rlogind in.rshd in.telnetd
SOCKETPROG=	6to4relay arp gettable hostconfig if_mpadm in.comsat \
		in.fingerd in.rarpd in.rexecd in.rlogind in.rshd \
		in.rwhod in.telnetd in.tftpd ipaddrsel route
NSLPROG=	6to4relay arp gettable hostconfig in.comsat in.rarpd \
		in.rexecd in.rlogind in.rshd in.rwhod in.telnetd \
		in.tftpd ipaddrsel route
CMDPROG=	in.telnetd
K5PROGS=	in.telnetd in.rlogind in.rshd
TSNETPROG=	route
DLADMPROG=	6to4relay
DEFAULTFILES=	telnetd.dfl

PROGSRCS=	$(PROG:%=%.c)
TFTPDOBJS=	in.tftpd.o tftpsubs.o
OTHERSRC=	../usr.bin/tftp/tftpsubs.c
FINGERDOBJS=	in.fingerd.o
K5RLOGINOBJS=	in.rlogind.o
K5RSHDOBJS=	in.rshd.o
K5TELNETOBJS=	in.telnetd.o
SRCS=		$(PROGSRCS) $(OTHERSRC)

SUBDIRS=	bootconfchk htable ifconfig ilbadm in.ftpd in.rdisc in.routed \
		in.talkd inetadm inetconv ipadm ipmpstat ipqosconf ipsecutils \
		kssl/kssladm kssl/ksslcfg netadm netcfg ping routeadm \
		snoop sppptun traceroute

MSGSUBDIRS=	bootconfchk htable ifconfig ilbadm in.routed in.talkd \
		inetadm inetconv ipadm ipmpstat ipqosconf ipsecutils \
		kssl/ksslcfg netadm netcfg routeadm sppptun snoop

# As programs get lint-clean, add them here and to the 'lint' target.
# Eventually this hack should go away, and all in PROG should be
# lint-clean.
LINTCLEAN=	6to4relay arp in.rlogind in.rshd in.telnetd in.tftpd \
		ipaddrsel route \
		in.rarpd if_mpadm $(SYNCPROG)
# Likewise, as subdirs get lint-clean, add them here.  Once
# they're all clean, replace the dependency of the lint target
# with SUBDIRS.  Also (sigh) deal with the commented-out build lines
# for the lint rule.
LINTSUBDIRS=	bootconfchk ilbadm in.rdisc in.routed in.talkd inetadm \
		inetconv ipmpstat ipqosconf ipsecutils kssl/kssladm \
		kssl/ksslcfg netadm netcfg ping routeadm sppptun traceroute

include ../../Makefile.cmd
ROOTMANIFESTDIR=	$(ROOTSVCNETWORK)
$(ROOTMANIFEST)		:= FILEMODE= 444
include ../Makefile.cmd-inet

COMMONOBJS=	addr_match.o kcmd.o store_forw_creds.o
COMMONSRCS=	$(COMMONOBJS:%.o=$(CMDINETCOMMONDIR)/%.c)
SRCS+=		$(COMMONSRCS)

#
# Message catalog
#
POFILES=	6to4relay.po if_mpadm.po in.comsat.po ipaddrsel.po route.po \
		soconfig.po
POFILE=		usr.sbin.po

all:=		TARGET= all
install:=	TARGET= install
clean:=		TARGET= clean
clobber:=	TARGET= clobber
lint:=		TARGET= lint
_msg:=		TARGET= _msg

CLOBBERFILES +=	$(PROG)
CLEANFILES += $(COMMONOBJS) $(K5RLOGINOBJS) $(K5RSHDOBJS) $(TFTPDOBJS)

CPPFLAGS +=	-DSYSV -DBSD_COMP -I$(CMDINETCOMMONDIR)

include $(SRC)/lib/gss_mechs/mech_krb5/Makefile.mech_krb5
K5LIBS=

# Eventually just plain CFLAGS should be += -v, but not until all in
# PROGS are lint clean.
$(LINTCLEAN)		:=	CFLAGS += $(CCVERBOSE)

$(SYNCPROG)		:=	LDLIBS += -ldlpi
$(SOCKETPROG)		:=	LDLIBS += -lsocket
$(NSLPROG)		:=	LDLIBS += -lnsl
$(AUDITPROG)		:=	LDLIBS += -lbsm
$(PAMPROG)		:=	LDLIBS += -lpam
$(RPCSVCPROG)		:=	LDLIBS += -lrpcsvc
$(K5PROGS)		:=	LDFLAGS += $(KRUNPATH) \
					-L$(LROOT)$(KLIBDIR_DO) \
					-L$(LROOT)$(KLIBDIR_GL)
$(K5PROGS)		:=	K5LIBS=  -lmech_krb5
$(K5PROGS)		:=	CPPFLAGS += -I$(SRC)/head \
				-I$(SRC)/uts/common/ \
				-I$(SRC)/uts/common/gssapi/mechs/krb5/include \
				-I$(SRC)/lib/gss_mechs/mech_krb5/include \
				-I$(SRC)/lib/pam_modules/krb5

# c99=%all supports the inline keyword found in some krb header files
$(K5PROGS)		:=	C99MODE = -xc99=%all
#$(K5PROGS)		:=	C99LMODE = -xc99=%all
LDLIBS +=	$(K5LIBS)
$(TSNETPROG)		:=	LDLIBS += -ltsnet
$(DLADMPROG)		:=	LDLIBS += -ldladm

in.rarpd		:=	LDLIBS += -linetutil -ldlpi
if_mpadm		:=	LDLIBS += -linetutil -lipmp
if_mpadm.po		:=	XGETFLAGS += -a
route			:=	CPPFLAGS += -DNDEBUG
ndd			:=	LDLIBS += -ldladm -lipadm
gettable in.comsat	:=	LDFLAGS += $(MAPFILE.NGB:%=-M%)
soconfig		:=	LDLIBS += -linetutil

.KEEP_STATE:

.PARALLEL:

all: $(PROG) $(SUBDIRS) THIRDPARTYLICENSE.arp

#
# message catalog
#
_msg: $(MSGSUBDIRS) $(POFILE)

syncutil: $(SYNCPROG)

$(POFILE): $(POFILES)
	$(RM) $@
	cat $(POFILES) > $@

%.o: $(CMDINETCOMMONDIR)/%.c
	$(COMPILE.c) -o $@ $<

in.fingerd: $(FINGERDOBJS)
	$(LINK.c) $(FINGERDOBJS) -o $@ $(LDLIBS) -lscf
	$(POST_PROCESS)

in.telnetd: $(K5TELNETOBJS)
	$(LINK.c) $(K5TELNETOBJS) -o $@ $(LDLIBS)
	$(POST_PROCESS)

in.rlogind: $(K5RLOGINOBJS) $(COMMONOBJS)
	$(LINK.c) $(K5RLOGINOBJS) $(COMMONOBJS) -o $@ $(LDLIBS)
	$(POST_PROCESS)

in.rshd: $(K5RSHDOBJS) $(COMMONOBJS)
	$(LINK.c) $(K5RSHDOBJS) $(COMMONOBJS) -o $@ $(LDLIBS)
	$(POST_PROCESS)

in.tftpd: $(TFTPDOBJS)
	$(LINK.c) $(TFTPDOBJS) -o $@ $(LDLIBS)
	$(POST_PROCESS)

tftpsubs.o: $(OTHERSRC)
	$(COMPILE.c) $(OTHERSRC) -o $@
	$(POST_PROCESS_O)

install: $(PROG) $(SUBDIRS) .WAIT $(ROOTUSRSBINPROG) \
	$(ROOTETCDEFAULTFILES) \
	$(ROOTMANIFEST) $(ROOTSVCMETHOD) THIRDPARTYLICENSE.arp

THIRDPARTYLICENSE.arp: arp.c
	$(SED) -n '/University of California/,/SUCH DAMAGE/p' arp.c > $@

CLOBBERFILES += THIRDPARTYLICENSE.arp

#
# The reason this rule checks for the existence of the
# Makefile is that some of the directories do not exist
# in our exportable source builds.
#
$(SUBDIRS): FRC
	@if [ -f $@/Makefile  ]; then \
		cd $@; pwd; $(MAKE) $(TARGET); \
	else \
		true; \
	fi

FRC:

check:	$(CHKMANIFEST)

clean:	$(SUBDIRS)
	-$(RM) $(CLEANFILES)

clobber: $(SUBDIRS)
	-$(RM) $(CLEANFILES) $(CLOBBERFILES)

lint: $(LINTSUBDIRS)
	$(LINT.c) 6to4relay.c $(LDLIBS) -lsocket -ldladm
	$(LINT.c) arp.c $(LDLIBS) -lsocket -lnsl
	@# $(LINT.c) in.rexecd.c $(LDLIBS) -lbsm -lpam
	$(LINT.c) -erroff=E_NAME_USED_NOT_DEF2 -erroff=E_NAME_DEF_NOT_USED2 \
		-erroff=E_SUPPRESSION_DIRECTIVE_UNUSED -Xc99=%all \
		-I$(SRC)/head -I$(SRC)/uts/common/ \
		-I$(SRC)/uts/common/gssapi/mechs/krb5/include \
		-I$(SRC)/lib/gss_mechs/mech_krb5/include \
		-I$(SRC)/lib/pam_modules/krb5 \
		in.rlogind.c $(COMMONSRCS) $(LDLIBS) -lbsm -lpam -lsocket -lnsl
	$(LINT.c) -erroff=E_NAME_USED_NOT_DEF2 -erroff=E_NAME_DEF_NOT_USED2 \
		-erroff=E_SUPPRESSION_DIRECTIVE_UNUSED -Xc99=%all \
		-I$(SRC)/head -I$(SRC)/uts/common/ \
		-I$(SRC)/uts/common/gssapi/mechs/krb5/include \
		-I$(SRC)/lib/gss_mechs/mech_krb5/include \
		-I$(SRC)/lib/pam_modules/krb5 \
		in.rshd.c $(COMMONSRCS) $(LDLIBS) -lbsm -lpam -lsocket -lnsl
	$(LINT.c) -erroff=E_NAME_USED_NOT_DEF2 \
		-erroff=E_GLOBAL_COULD_BE_STATIC2 \
		-I$(SRC)/head -I$(SRC)/uts/common/ \
		-I$(SRC)/uts/common/gssapi/mechs/krb5/include \
		-I$(SRC)/lib/gss_mechs/mech_krb5/include \
		-I$(SRC)/lib/pam_modules/krb5 \
		in.telnetd.c $(LDLIBS) -lbsm -lpam -lsocket -lnsl
	$(LINT.c) if_mpadm.c $(LDLIBS) -lsocket -lnsl -lipmp -linetutil
	$(LINT.c) ipaddrsel.c $(LDLIBS) -lsocket -lnsl
	$(LINT.c) route.c $(LDLIBS) -lsocket -lnsl -ltsnet
	$(LINT.c) syncinit.c $(LDLIBS) -ldlpi
	$(LINT.c) syncloop.c $(LDLIBS) -ldlpi
	$(LINT.c) syncstat.c $(LDLIBS) -ldlpi
	$(LINT.c) in.rarpd.c $(LDLIBS) -lsocket -lnsl -ldlpi -linetutil
	$(LINT.c) in.tftpd.c ../usr.bin/tftp/tftpsubs.c $(LDLIBS) \
	    -lsocket -lnsl

# EXPORT DELETE START
EXPORT_SRC:
	$(RM) Makefile+
	sed -e "/^# EXPORT DELETE START/,/^# EXPORT DELETE END/d" \
		< Makefile > Makefile+
	$(RM) Makefile
	$(MV) Makefile+ Makefile
	$(CHMOD) 444 Makefile
# EXPORT DELETE END
