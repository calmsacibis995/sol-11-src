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
# Copyright (c) 2001, 2011, Oracle and/or its affiliates. All rights reserved.
#

#
#     This makefile drives the production of all Makaha system
#     dependent modules for the sun4u architecture.
#

#
#	Path to the base of the uts directory tree (usually /usr/src/uts).
#
UTSBASE		= ../..

#
#	Include common rules.
#
include $(UTSBASE)/sun4u/makaha/Makefile.makaha

def		:=	TARGET= def
all		:=	TARGET= all
install		:=	TARGET= install
install_h	:=	TARGET= install_h
clean		:=	TARGET= clean
clobber		:=	TARGET= clobber
lint		:=	TARGET= lint
lintlib		:=	TARGET= lintlib
modlintlib	:=	TARGET= modlintlib
modlist		:=	TARGET= modlist
modlist		:=	NO_STATE= -K $$MODSTATE$$$$
clean.lint	:=	TARGET= clean.lint
check		:=	TARGET= check

#
#	Default build targets.
#
.KEEP_STATE:

def all clean.lint clean clobber modlist: $(MAKAHA_KMODS)

modlintlib:	$(MAKAHA_KMODS)

install:        $(ROOT_MAKAHA_DIR) $(ROOT_MAKAHA_DRV_DIR) \
				$(USR_MAKAHA_DIR) \
				$(USR_MAKAHA_INC_DIR) \
				$(USR_MAKAHA_SBIN_DIR) \
				$(USR_MAKAHA_LIB_DIR) \
				$(ROOT_SPUTNIK_DIR) $(USR_SPUTNIK_DIR) \
				$(USR_SPUTNIK_INC_DIR) \
				$(USR_SPUTNIK_SBIN_DIR) \
				$(USR_SPUTNIK_LIB_DIR) \
				.WAIT $(MAKAHA_KMODS) \
				scsb acebus pcf8574 \
				$(ROOT_MAKAHA_DRV_DIR)/acebus.conf \
				se.conf scsb.conf \
				ttymux_dacf ttymux.conf

$(ROOT_MAKAHA_DRV_DIR)/acebus.conf := FILEMODE= $(CFILEMODE)

$(ROOT_MAKAHA_DRV_DIR)/%: $(UTSBASE)/sun4u/makaha/io/%
		$(INS.file)

pcf8574:	$(ROOT_MAKAHA_DRV_DIR_64)
		-@$(RM) $(ROOT_MAKAHA_DRV_DIR_64)/$@
		$(SYMLINK) $(ROOT_MAKAHA_DRV_LINK_64)/$@ \
		$(ROOT_MAKAHA_DRV_DIR_64)/$@

acebus:	$(ROOT_MAKAHA_DRV_DIR_64)
		-@$(RM) $(ROOT_MAKAHA_DRV_DIR_64)/$@
		$(SYMLINK) $(ROOT_MAKAHA_DRV_LINK_64)/$@ \
		$(ROOT_MAKAHA_DRV_DIR_64)/$@

scsb:	$(ROOT_MAKAHA_DRV_DIR_64)
		-@$(RM) $(ROOT_MAKAHA_DRV_DIR_64)/$@
		$(SYMLINK) $(ROOT_MAKAHA_DRV_LINK_64)/$@ \
		$(ROOT_MAKAHA_DRV_DIR_64)/$@

scsb.conf:	$(ROOT_MAKAHA_DRV_DIR)
		-@$(RM) $(ROOT_MAKAHA_DRV_DIR)/$@
		$(SYMLINK) $(ROOT_MAKAHA_DRV_LINK)/$@ \
		$(ROOT_MAKAHA_DRV_DIR)/$@

se.conf:	$(ROOT_MAKAHA_DRV_DIR)
		-@$(RM) $(ROOT_MAKAHA_DRV_DIR)/$@
		$(SYMLINK) $(ROOT_MAKAHA_DRV_LINK)/$@ \
		$(ROOT_MAKAHA_DRV_DIR)/$@

ttymux_dacf:	$(ROOT_MAKAHA_DACF_DIR_64) \
		$(ROOT_SPUTNIK_DACF_DIR_64)
		-@$(RM) $(ROOT_MAKAHA_DACF_DIR_64)/$@
		-@$(RM) $(ROOT_SPUTNIK_DACF_DIR_64)/$@
		$(SYMLINK) $(ROOT_MAKAHA_DACF_LINK_64)/$@ \
		$(ROOT_MAKAHA_DACF_DIR_64)/$@
		$(SYMLINK) $(ROOT_SPUTNIK_DACF_LINK_64)/$@ \
		$(ROOT_SPUTNIK_DACF_DIR_64)/$@


ttymux.conf:	$(ROOT_MAKAHA_DRV_DIR) \
		$(ROOT_SPUTNIK_DRV_DIR)
		-@$(RM) $(ROOT_MAKAHA_DRV_DIR)/$@
		-@$(RM) $(ROOT_SPUTNIK_DRV_DIR)/$@
		$(SYMLINK) $(ROOT_MAKAHA_DRV_LINK)/$@ \
		$(ROOT_MAKAHA_DRV_DIR)/$@
		$(SYMLINK) $(ROOT_MAKAHA_DRV_LINK)/$@ \
		$(ROOT_SPUTNIK_DRV_DIR)/$@

install_h check:

lint:		modlintlib

#
# The 'lint.platmod' target lints the makaha platform module against
# the sun4u kernel.  This ends up doing all the kernel cross-checks,
# so it takes a couple of minutes.
# Due to the low ROI, it's not run by default, but it's a good
# idea to run this if you change os/makaha.c.
#
LINT_LIBS	 = $(LINT_LIB) \
		   -L$(MAKAHA_LINT_LIB_DIR) \
		   -L$(LINT_LIB_DIR) $(LINT_KMODS:%=-l%) \
		       $(CLOSED_LINT_KMODS:%=-l%) \
		   -L$(SPARC_LIB_DIR) $(SPARC_LINTS:%=-l%)

lint.platmod:   modlintlib
	@-$(ECHO) "\nMakaha Platform-dependent module: global crosschecks:"
	@-$(LINT) $(LINTFLAGS) $(LINT_LIBS) 2>&1 | $(LGREP.2)

$(MAKAHA_KMODS): FRC
	@cd $@; pwd; $(MAKE) $(NO_STATE) $(TARGET)

#
#	Include common targets.
#
include $(UTSBASE)/sun4u/makaha/Makefile.targ
