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
# Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.
#

SHFILES= \
	get_depend_info \
	make_pkg_db

ETCFILES= \
	SampleLinks \
	SamplePkgLinks

SMAN1FILES= \
	get_depend_info.1 \
	make_pkg_db.1

include ../Makefile.tools

$(ROOTONBLDETCFILES) := FILEMODE=	644
$(ROOTONBLDSMAN1FILES) := FILEMODE=	644

.KEEP_STATE:

all:	$(SHFILES) $(SMAN1FILES)

install: all .WAIT $(ROOTONBLDSHFILES) $(ROOTONBLDETCFILES) \
	$(ROOTONBLDSMAN1FILES)

clean:
	$(RM) $(CLEANFILES)

include ../Makefile.targ

