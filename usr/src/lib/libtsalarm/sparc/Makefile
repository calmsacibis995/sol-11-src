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
# lib/libtsalarm/sparc/Makefile

UTSBASE= ../../../uts

PLATINCS += -I$(USR_PLAT_DIR)/sun4v/include -I$(UTSBASE)/sun4v

PLATFORM_OBJECTS= tsalarm.o

#
# platform library directory (/usr/platform/sun4v/lib)
#
PLATFORM=sun4v
LINKED_PLATFORMS = SUNW,Netra-T5220
LINKED_PLATFORMS += SUNW,Netra-T5440

include ../Makefile.com

#
# install rules
#

$(PLATLIBS)/libtsalarm.so $(STUBPLATLIBS)/libtsalarm.so:
	$(RM) -r $@; $(SYMLINK) libtsalarm.so.1 $@

$(USR_PSM_LIB_DIR)/% $(STUBUSR_PSM_LIB_DIR)/% := FILEMODE= 755

$(USR_PSM_LIB_DIR)/%: % $(USR_PSM_LIB_DIR)
	$(INS.file)

$(STUBUSR_PSM_LIB_DIR)/%: stubs/% $(STUBUSR_PSM_LIB_DIR)
	$(INS.file)

$(USR_PSM_LIB_DIR) $(STUBUSR_PSM_LIB_DIR):
	$(INS.dir)

$(USR_PSM_INCL_DIR)/%:	../common/% $(USR_PSM_INCL_DIR)
	$(INS.file)

$(USR_PSM_INCL_DIR):
	$(INS.dir)

$(LINKED_DIRS):	$(USR_PLAT_DIR)
	-$(INS.dir)

$(STUBLINKED_DIRS):	$(STUBUSR_PLAT_DIR)
	-$(INS.dir)

$(LINKED_LIB_DIRS):	$(LINKED_DIRS)
	-$(INS.dir)

$(STUBLINKED_LIB_DIRS):	$(STUBLINKED_DIRS)
	-$(INS.dir)

$(LINKED_LIBTSALARM_DIR):	$(USR_PLAT_DIR)
	-$(INS.slink7)

$(STUBLINKED_LIBTSALARM_DIR):	$(STUBUSR_PLAT_DIR)
	-$(INS.slink7)

$(LINKED_LIBTSALARM1_DIR):	$(USR_PLAT_DIR)
	-$(INS.slink6)

$(STUBLINKED_LIBTSALARM1_DIR):	$(STUBUSR_PLAT_DIR)
	-$(INS.slink6)

$(LINKED_INCL_DIRS):	$(LINKED_DIRS)
	-$(INS.slink8)

install: stubinstall all install_h $(USR_PSM_LIBS) $(PLATLIBS)/libtsalarm.so \
	$(LINKED_DIRS) $(LINKED_LIB_DIRS) \
	$(LINKED_LIBTSALARM_DIR) $(LINKED_LIBTSALARM1_DIR) \
	$(LINKED_INCL_DIRS)

install_h: $(USR_PSM_INCL_DIR)/tsalarm.h

stubinstall: stub $(STUBUSR_PSM_LIBS) $(STUBPLATLIBS)/libtsalarm.so \
	$(STUBLINKED_DIRS) $(STUBLINKED_LIB_DIRS) \
	$(STUBLINKED_LIBTSALARM_DIR) $(STUBLINKED_LIBTSALARM1_DIR)
