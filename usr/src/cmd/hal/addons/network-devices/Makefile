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
# Copyright (c) 2007, 2011, Oracle and/or its affiliates. All rights reserved.
#
#

PROG =		hald-addon-network-discovery
OBJS =		addon-network-discovery.o probe-snmp.o snmp.o logger.o cache.o common.o printer.o

include ../../../Makefile.cmd
include ../../Makefile.hal

ROOTCMDDIR =	$(ROOTLIB_HAL)

LDLIBS +=	-lc -ldbus-1 -lhal -lglib-2.0 -ldbus-glib-1
LDLIBS +=	-lnsl -lsocket
LDLIBS +=	$(ZIGNORE) -lnetsnmp

CPPFLAGS +=	$(HAL_DBUS_CPPFLAGS) $(HAL_GLIB_CPPFLAGS) $(HAL_CONFIG_CPPFLAGS)
CPPFLAGS +=	-I$(ROOT)/usr/include/hal -I../../hald -I../../utils
C99MODE =	$(C99_ENABLE)

.KEEP_STATE:

all: $(PROG)

probe-snmp.o: ../../probing/network-printer/probe-snmp.c
	$(COMPILE.c) -o $@ ../../probing/network-printer/probe-snmp.c
	$(POST_PROCESS_O)

logger.o: ../../hald/logger.c
	$(COMPILE.c) -o $@ ../../hald/logger.c
	$(POST_PROCESS_O)

printer.o: ../../utils/printer.c
	$(COMPILE.c) -o $@ ../../utils/printer.c
	$(POST_PROCESS_O)

$(PROG): $(OBJS)
	$(LINK.c) -o $@ $(OBJS) $(LDLIBS)
	$(POST_PROCESS)

install: all $(ROOTCMD)

clean:
	$(RM) $(OBJS) $(PROG)

FRC:

include ../../../Makefile.targ
