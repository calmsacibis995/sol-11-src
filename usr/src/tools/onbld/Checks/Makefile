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
# Copyright (c) 2008, 2011, Oracle and/or its affiliates. All rights reserved.
#

include $(SRC)/Makefile.master
include ../../Makefile.tools

PYSRCS = \
	CStyle.py	\
	Cddl.py		\
	CmtBlk.py	\
	Comments.py	\
	Copyright.py	\
	DbLookups.py	\
	HdrChk.py	\
	JStyle.py	\
	Keywords.py	\
	Mapfile.py		\
	ProcessCheck.py \
	Rti.py		\
	__init__.py

PYOBJS =	$(PYSRCS:%.py=%.pyc)
PYTOPDIR =	$(ROOTONBLDLIB)
PYMODDIR = 	onbld/Checks

include ../../Makefile.python

all: $(PYVERSOJBS)

$(ROOTPYDIR_26)/Cddl.py $(ROOTPYDIR_26)/Cddl.pyc := INS_CDDL_ARG=

install: all $(ROOTPYFILES)

clean:

clobber: clean pyclobber
