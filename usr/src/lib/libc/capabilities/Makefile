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

include		$(SRC)/Makefile.master

# Each target directory is responsible for making a symbol capabilities object.
$(SPARC_BLD)SUBDIRS = \
		sun4u \
		sun4u-opl \
		sun4u-us3-hwcap1 \
		sun4u-us3-hwcap2 \
		sun4v-hwcap1 \
		sun4v-hwcap2 \
		sun4v-hwcap3 \
		sparc-pause
$(INTEL_BLD)SUBDIRS = \
		hrt

all :=		TARGET= all
clean :=	TARGET= clean
clobber :=	TARGET= clobber
install :=	TARGET= install

.KEEP_STATE:

.PARALLEL:	$(SUBDIRS)

all clean clobber install: \
		$(SUBDIRS)

lint:

$(SUBDIRS):	FRC
		@cd $@; pwd; $(MAKE) $(TARGET)

FRC:
