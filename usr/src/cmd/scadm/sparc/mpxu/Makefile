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
# Copyright (c) 2002, 2011, Oracle and/or its affiliates. All rights reserved.
#
# cmd/scadm/sparc/mpxu/Makefile
#
# Platform specific Makefile for the scadm command.
#
# PLATFORM is the target for the binary instalation.
#
# PLATLINKS is a list of platforms which are to be linked to this binary
#	at the file level.
#
SRCDIR		= ../..
PLATFORM	= SUNW,Sun-Fire-V240
PLATLINKS	= SUNW,Sun-Fire-V250
PLATLINKS	+= SUNW,Sun-Fire-V445
PLATLINKS	+= SUNW,Sun-Fire-V215

include $(SRCDIR)/Makefile.com

CFLAGS		+= -R /usr/platform/$(PLATFORM)/lib

LDLIBS		+= -L$(LROOT)/usr/platform/$(PLATFORM)/lib
LDLIBS		+= -lrsc -lcurses
LINTFLAGS	+= -u

.KEEP_STATE:

all:	librsc $(PROG)

librsc:
	cd $(SRCDIR)/../../lib/librsc ; $(MAKE) install

include $(SRCDIR)/Makefile.targ
