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
# Copyright (c) 2005, 2011, Oracle and/or its affiliates. All rights reserved.
#

MODULE = etm
CLASS = arch
ARCH = sun4v

SRCS = etm.c etm_xport_api_dd.c etm_filter.c etm_ckpt.c

include ../../Makefile.plugin

CPPFLAGS += -I$(SRC)/uts/sun4v  \
	    -I$(SRC)/uts/common \
	    -I$(ROOT)/usr/platform/sun4v/include
LDLIBS += -L$(LROOT)/usr/lib/fm -lldom -ltopo
LDFLAGS += -R/usr/lib/fm

DYNFLAGS += -R/usr/lib
