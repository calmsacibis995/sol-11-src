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
# Copyright (c) 2006, 2011, Oracle and/or its affiliates. All rights reserved.
#

LIBRARY =	libmd.a
VERS =		.1

OBJECTS =	md4.o md5.o sha1.o sha2.o

include		$(SRC)/lib/Makefile.lib
include		$(SRC)/lib/Makefile.rootfs
include		$(SRC)/lib/Makefile.lib.64
include		../Makefile.com

# For lint:
SRCS +=		md5_amd64.s sha1-x86_64.s sha256-x86_64.s sha512-x86_64.s \
			$(COMDIR)/sha1/amd64/sha1-ssse3.s

EXTPICS = 	pics/md5_amd64.o \
		pics/sha1-x86_64.o \
		pics/sha1-ssse3.o \
		pics/sha1-ssse3-1block.o \
		pics/sha1-avx.o \
		pics/sha1-avx-1block.o \
		pics/sha512-x86_64.o \
		pics/sha256-x86_64.o

CLEANFILES +=	$(EXTPICS) \
		$(EXTPICS:pics/%.o=%.s)

# This prevents <sys/asm_linkage.h> from including C source:
AS_CPPFLAGS += -D_ASM

.KEEP_STATE:

all:		stub $(LIBS)

install:	stubinstall all $(ROOTLIBS64) $(ROOTLINKS64) $(ROOTLINT64)

stubinstall:	stub $(STUBROOTLIBS64) $(STUBROOTLINKS64)

lint:		lintcheck

pics/%.o: %.s
		$(COMPILE.s) -o $@ ${@F:.o=.s}
		$(POST_PROCESS_O)

pics/sha1-ssse3.o: $(COMDIR)/sha1/amd64/sha1-ssse3.s
		$(COMPILE.s) -o $@ $(COMDIR)/sha1/amd64/sha1-ssse3.s
		$(POST_PROCESS_O)

pics/sha1-ssse3-1block.o: $(COMDIR)/sha1/amd64/sha1-ssse3.s
		$(COMPILE.s) -DINTEL_SHA1_SINGLEBLOCK -o $@ \
			$(COMDIR)/sha1/amd64/sha1-ssse3.s
		$(POST_PROCESS_O)

pics/sha1-avx.o: $(COMDIR)/sha1/amd64/sha1-ssse3.s
		$(COMPILE.s) -DUSE_AVX -o $@ $(COMDIR)/sha1/amd64/sha1-ssse3.s
		$(POST_PROCESS_O)

pics/sha1-avx-1block.o: $(COMDIR)/sha1/amd64/sha1-ssse3.s
		$(COMPILE.s) -DUSE_AVX -DINTEL_SHA1_SINGLEBLOCK -o $@ \
			$(COMDIR)/sha1/amd64/sha1-ssse3.s
		$(POST_PROCESS_O)

md5_amd64.s: $(COMDIR)/md5/amd64/md5_amd64.pl
		$(PERL) $? $@

sha1-x86_64.s: $(COMDIR)/sha1/amd64/sha1-x86_64.pl
		$(PERL) $? $@

sha512-x86_64.s: $(COMDIR)/sha2/amd64/sha512-x86_64.pl
		$(PERL) $? $@

sha256-x86_64.s: $(COMDIR)/sha2/amd64/sha512-x86_64.pl
		$(PERL) $? $@

include		../Makefile.targ
