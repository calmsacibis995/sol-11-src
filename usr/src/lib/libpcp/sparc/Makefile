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
# Copyright (c) 2005, 2011, Oracle and/or its affiliates. All rights reserved.
#
# lib/libpcp/sparc/Makefile

UTSBASE= ../../../uts

PLATINCS += -I$(USR_PLAT_DIR)/sun4v/include -I$(UTSBASE)/sun4v

PLATFORM_OBJECTS= libpcp.o pcp_utils.o

#
# platform library directory (/usr/platform/SUNW,Sun-Fire-T200/lib)
#
PLATFORM=sun4v
LINKED_PLATFORMS = SUNW,Sun-Fire-T200 \
		SUNW,Netra-CP3060 \
		SUNW,Sun-Blade-T6300 \
		SUNW,Sun-Blade-T6320 \
		SUNW,SPARC-Enterprise-T5120 \
		SUNW,T5140 \
		SUNW,Netra-CP3260 \
		SUNW,USBRDT-5240 \
		SUNW,Netra-T5220 \
		SUNW,Netra-T5440


include ../Makefile.com

#
# install rules
#

$(PLATLIBS)/libpcp.so $(STUBPLATLIBS)/libpcp.so:
	$(RM) -r $@; $(SYMLINK) libpcp.so.1 $@

$(USR_PSM_LIB_DIR)/%: % $(USR_PSM_LIB_DIR)
	$(INS.file)

$(STUBUSR_PSM_LIB_DIR)/%: stubs/% $(STUBUSR_PSM_LIB_DIR)
	$(INS.file)

$(USR_PSM_LIB_DIR) $(STUBUSR_PSM_LIB_DIR):
	$(INS.dir)

$(LINKED_DIRS):   $(USR_PLAT_DIR)
	-$(INS.dir)

$(STUBLINKED_DIRS):   $(STUBUSR_PLAT_DIR)
	-$(INS.dir)

$(LINKED_LIB_DIRS):  $(LINKED_DIRS)
	-$(INS.dir)

$(STUBLINKED_LIB_DIRS):  $(STUBLINKED_DIRS)
	-$(INS.dir)

$(LINKED_LIBPCP_DIR): $(USR_PLAT_DIR)
	-$(INS.slink7)

$(STUBLINKED_LIBPCP_DIR): $(STUBUSR_PLAT_DIR)
	-$(INS.slink7)

$(LINKED_LIBPCP1_DIR): $(USR_PLAT_DIR)
	-$(INS.slink6)

$(STUBLINKED_LIBPCP1_DIR): $(STUBUSR_PLAT_DIR)
	-$(INS.slink6)

$(LINKED_LLIBLPCP_DIR): $(USR_PLAT_DIR)
	-$(INS.slink8)

$(STUBLINKED_LLIBLPCP_DIR): $(STUBUSR_PLAT_DIR)
	-$(INS.slink8)

install: stubinstall all $(USR_PSM_LIBS) $(PLATLIBS)/libpcp.so \
	$(LINKED_DIRS) $(LINKED_LIB_DIRS) \
	$(LINKED_LIBPCP_DIR) $(LINKED_LIBPCP1_DIR) \
	$(LINKED_LLIBLPCP_DIR)

# LIBS includes the lint library, but we don't want to build one
# for the stub proto.
$(STUBUSR_PSM_LIB_DIR)/llib-lpcp.ln:

stubinstall: stub $(STUBUSR_PSM_LIBS) $(STUBPLATLIBS)/libpcp.so \
	$(STUBLINKED_DIRS) $(STUBLINKED_LIB_DIRS) \
	$(STUBLINKED_LIBPCP_DIR) $(STUBLINKED_LIBPCP1_DIR)
