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
# Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
#
# common/crypto/aes/Makefile
#
# include global definitions
include $(SRC)/Makefile.master

.KEEP_STATE:

FRC:


# EXPORT DELETE START
EXPORT_SRC:
	$(RM) Makefile+ aes_impl.c+ aes_impl.h+ amd64/aes_amd64.s+ \
		amd64/aes_intel.s+ sun4u/aes_crypt_asm.s+
	sed -e "/EXPORT DELETE START/,/EXPORT DELETE END/d" \
		< aes_impl.c > aes_impl.c+
	$(MV) aes_impl.c+ aes_impl.c
	sed -e "/EXPORT DELETE START/,/EXPORT DELETE END/d" \
		< aes_impl.h > aes_impl.h+
	$(MV) aes_impl.h+ aes_impl.h
	sed -e "/EXPORT DELETE START/,/EXPORT DELETE END/d" \
		< aes_modes.c > aes_modes.c+
	$(MV) aes_modes.c+ aes_modes.c
	sed -e "/EXPORT DELETE START/,/EXPORT DELETE END/d" \
		< amd64/aes_amd64.s > amd64/aes_amd64.s+
	$(MV) amd64/aes_amd64.s+ amd64/aes_amd64.s
	sed -e "/EXPORT DELETE START/,/EXPORT DELETE END/d" \
		< amd64/aes_intel.s > amd64/aes_intel.s+
	$(MV) amd64/aes_intel.s+ amd64/aes_intel.s
	sed -e "/EXPORT DELETE START/,/EXPORT DELETE END/d" \
		< sun4u/aes_crypt_asm.s > sun4u/aes_crypt_asm.s+
	$(MV) sun4u/aes_crypt_asm.s+ sun4u/aes_crypt_asm.s
	sed -e "/^# EXPORT DELETE START/,/^# EXPORT DELETE END/d" \
		< Makefile > Makefile+
	$(RM) Makefile
	$(MV) Makefile+ Makefile
	$(CHMOD) 444 Makefile aes_impl.c aes_impl.h amd64/aes_amd64.s \
		amd64/aes_intel.s sun4u/aes_crypt_asm.s

# EXPORT DELETE END
