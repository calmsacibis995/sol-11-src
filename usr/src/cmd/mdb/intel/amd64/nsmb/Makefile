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
# Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.

MDBTGT		= kvm
MODULE		= nsmb.so
MODSRCS_DIR	= ../../../common/modules/nsmb
MODSRCS		= nsmb.c

include ../../../../Makefile.cmd
include ../../../../Makefile.cmd.64
include ../../Makefile.amd64

# This kmod goes in /usr/kernel/kmdb
ROOTKMOD = $(ROOT)/usr/kernel/kmdb$(MACHMODDIR)

include ../../../Makefile.module

CPPFLAGS	+= -I$(SRC)/uts/common/fs/smbclnt
CPPFLAGS	+= -I$(SRC)/uts/common

C99MODE=	-xc99=%all
C99LMODE=	-Xc99=%all

# maybe not the best place for this, but
# we need to create this directory.
$(ROOTKMOD):
	$(INS.dir)
