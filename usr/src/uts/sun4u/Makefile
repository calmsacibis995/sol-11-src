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
# Copyright (c) 1993, 2011, Oracle and/or its affiliates. All rights reserved.
#
#	This makefile drives the production of all implementation architecture
#	dependent modules for the sun4u architecture.
#

UTSBASE = ..

include Makefile.sun4u

#
#	The following are SPARC specific (rather than sun4u) specific modules
#	which are required for the sun4u kernel to completely lint. They are
#	not involved in the build in any other way. In order to minimize
#	build time, it is assumed that they are up to date. But since sun4u
#	is really a separate architecture we cannot use the v7 sparc modules.
#
SPARC_LIB_DIR	 = $(UTSBASE)/sparc/lint-libs/$(OBJS_DIR)

SPARC_LINTS	 =

#
#
#
LINT_LIBS	 = $(LINT_LIB) \
		   $(LINT_KMODS:%=$(LINT_LIB_DIR)/llib-l%.ln) \
		   $(CLOSED_LINT_KMODS:%=$(LINT_LIB_DIR)/llib-l%.ln) \
		   $(SPARC_LINTS:%=$(SPARC_LIB_DIR)/llib-l%.ln)


def		:=	TARGET= def
def.prereq	:=	TARGET= def
all		:=	TARGET= all
all.prereq	:=	TARGET= all
install		:=	TARGET= install
install.prereq	:=	TARGET= all
install_h	:=	TARGET= install_h
install_h.prere	:=	TARGET= install_h
clean		:=	TARGET= clean
clobber		:=	TARGET= clobber
lint		:=	TARGET= lint
lint.prereq	:=	TARGET= lint
lintlib		:=	TARGET= lintlib
modlintlib	:=	TARGET= modlintlib
modlist		:=	TARGET= modlist
modlist	modlist.sparc :=	NO_STATE= -K $$MODSTATE$$$$
clean.lint	:=	TARGET= clean.lint
check		:=	TARGET= check

.KEEP_STATE:

.PARALLEL:	$(PARALLEL_KMODS) $(CLOSED_KMODS) $(XMODS) $(CLOSED_XMODS) \
		$(IMPLEMENTATIONS) $(CLOSED_IMPLEMENTATIONS) \
		modlist modlist.sparc

# Override for CPU_KMODS... they cannot be built
# in parallel
.NO_PARALLEL:	$(CPU_KMODS)

def all clean clobber clean.lint: genassym unix .WAIT \
	$(KMODS) $(CLOSED_KMODS) $(XMODS) $(CLOSED_XMODS) \
	$(IMPLEMENTATIONS) $(CLOSED_IMPLEMENTATIONS)

# list the modules under sun4u.
modlist: unix $(KMODS) $(CLOSED_KMODS) $(XMODS) $(CLOSED_XMODS) \
	$(IMPLEMENTATIONS:.WAIT=) $(CLOSED_IMPLEMENTATIONS)

# list the modules for Install -k sun4u.
modlist.karch: modlist modlist.sparc

modlist.sparc:
	@cd $(SRC)/uts/sparc; pwd; $(MAKE) $(NO_STATE) modlist

install: install_platforms genassym unix .WAIT $(KMODS) $(CLOSED_KMODS) \
	$(XMODS) $(CLOSED_XMODS) $(IMPLEMENTATIONS) $(CLOSED_IMPLEMENTATIONS)

lintlib:	unix

modlintlib:	$(LINT_KMODS) $(CLOSED_LINT_KMODS)

genassym unix $(KMODS):	FRC
	@cd $@; pwd; $(MAKE) $(NO_STATE) $(TARGET)

#
# Privilege constants
#
# NOTE: The rules for generating priv_const.c file are shared between all
# processor architectures and should be kept in sync. If they are changed in
# this file make sure that x86 rules are updated as well.
#
PRIVS_C = $(UTSBASE)/common/os/priv_const.c

$(PRIVS_C): $(PRIVS_AWK) $(PRIVS_DEF)
	$(NAWK) -f $(PRIVS_AWK) < $(PRIVS_DEF) cfile=$@


#
# Prerequisites
#
# The uts/Makefile defines build parallelism for sun4 platforms such that sparc,
# sun4u and sun4v are all built in parallel. Also this Makefile specifies that
# all IMPLEMENTATIONS sun4u sub-platforms are built in parallel. This requires
# building certain parts before the parallel build can start. The uts/Makefile
# appends the '.prereq' string to the original target and executes this Makefile
# to build any prerequisites needed before the full parallel build can start.
# After that make continues with normal targets.
#
# Any build prerequisites for sun4 and IMPLEMENTATIONS builds should be
# described here.
#
# genassym is used to build dtrace and genunix, so it should be built first.
#
# priv_const.c is required to build genunix.
#
# genunix is used by everyone to ctfmerge with. Genunix is merged with sparc/ip
#   so as a side effect this dependency builds sparc/ip as part of the
#   prerequisites.
#
# unix is not required by itself but several sun4u platforms require
#   sun4u/platmod to be present. The easiest way to achieve this is to build
#   sun4u/unix first since sun4u/unix Makefile builds sun4u/platform correctly.
#   This causes full sun4u/unix to be built before all sun4u platforms and
#   before uts/sun4v and uts/sparc, but it acceptable since it is not spending
#   too much time building sun4u/unix.
#
all.prereq def.prereq install.prereq: genassym genunix unix

#
# Various sun4u platforms expect proto/root_sparc/platform/sun4u/include to be
# present. This is handled by running make install_h in sun4u/unix directory
# first.
#
install_h.prereq: FRC
	@cd sys; pwd; $(MAKE) $(TARGET)

#
# sun4u/unix and sun4u/genunix should be linted first since sparc does global
# cross-check with these lint libraries. The sun4u/unix and sun4u/genunix can be
# linted in parallel.
#
LINT_PREREQ = unix.lint genunix.lint
lint.prereq: $(LINT_PREREQ)

.PARALLEL:  $(LINT_PREREQ)

$(LINT_PREREQ):
	@cd $(@:%.lint=%); pwd; $(MAKE) $(TARGET)

#
# Nothing to do with any other prerequisites
#
%.prereq:

#
# Platform inter-dependencies
#
serengeti: cheetah
lw8: serengeti

quasar: darwin

#
# The genunix requires priv_const.c file to be generated first.
#
genunix: $(PRIVS_C)

#
# Rules
#

$(IMPLEMENTATIONS):	FRC
	@cd $@; pwd; THISIMPL=$@ $(MAKE) $(NO_STATE) $(TARGET)

$(CLOSED_IMPLEMENTATIONS):	FRC
	cd $(CLOSED)/uts/sun4u/$@; pwd; \
	    THISIMPL=$@ $(MAKE) $(NO_STATE) $(TARGET);

$(XMODS):	FRC
	@if [ -f $@/Makefile  ]; then \
		cd $@; pwd; $(MAKE) $(NO_STATE) $(TARGET); \
	else \
		true; \
	fi

$(CLOSED_XMODS):	FRC
	@if [ -f $(CLOSED)/uts/sun4u/$@/Makefile ]; then \
		cd $(CLOSED)/uts/sun4u/$@; pwd; $(MAKE) $(NO_STATE) $(TARGET); \
	else \
		true; \
	fi

$(CLOSED_KMODS):	FRC
	cd $(CLOSED)/uts/sun4u/$@; pwd; $(MAKE) $(NO_STATE) $(TARGET)

install_h check: install_platforms $(IMPLEMENTATIONS) \
	$(CLOSED_IMPLEMENTATIONS) FRC
	@cd sys; pwd; $(MAKE) $(TARGET)
	@cd vm; pwd; $(MAKE) $(TARGET)

#
# Rules for the /platforms directories.  This is hardwired here because
# the first stage of the project (KBI) only implements the userland
# changes, but the only reasonable place to record the aliases is
# here in kernel land.
#
$(ROOT_PLAT_DIRS): $(ROOT_PLAT_DIR)
	-$(INS.dir)

#
# create directories in /usr/platform/ for the implementations that are
# defined in $(IMPLEMENTED_PLATFORM)
#       (eg. SUNW,Ultra-1)
#
# Foreach $(IMPLEMENTED_PLATFORM) there can be a list of $(LINKED_PLATFORMS)
# that are linked to it.
#
$(USR_PLAT_DIR)/$(IMPLEMENTED_PLATFORM):	$(USR_PLAT_DIR)
	-$(INS.dir)

#
# create the links in /usr/platform/ foreach $(LINKED_PLATFORMS)
# to it's corresponding $(IMPLEMENTED_PLATFORM).
#
PLATFORMS	= $(LINKED_PLATFORMS)

$(USR_PLAT_DIRS): $(USR_PLAT_DIR)
	$(INS.slink3)

PLATFORMS	+= $(IMPLEMENTED_PLATFORM)

#
# Make the /platforms directories.  This is hardwired here because
# the first stage of the project (KBI) only implements the userland
# changes, but the only reasonable place to record the aliases is
# here in kernel land.
#
install_platforms:	$(ROOT_PSM_DIR) $(USR_PSM_DIR) \
			$(ROOT_PLAT_DIRS) $(USR_PLAT_DIRS) \
			$(USR_DESKTOP_DIR) $(USR_DESKTOP_INC_DIR) \
			$(USR_DESKTOP_SBIN_DIR) $(USR_DESKTOP_LIB_DIR)

#
# rules for making include, sbin, lib dirs/links in
# /usr/platform/$(PLATFORM)/ for desktop platforms
#
$(USR_DESKTOP_INC_DIR):		$(USR_DESKTOP_DIR)
	$(INS.slink4)

$(USR_DESKTOP_SBIN_DIR):	$(USR_DESKTOP_DIR)
	$(INS.slink5)

$(USR_DESKTOP_LIB_DIR):		$(USR_DESKTOP_DIR)
	-$(INS.dir)

#
#	Full kernel lint target.
#
LINT_TARGET	= globallint

globallint:
	@pwd
	@-$(ECHO) "\nSUN4U KERNEL: global crosschecks:"
	@-$(LINT) $(LINTFLAGS) $(LINT_LIBS) 2>&1 | $(LGREP.2)

lint:	lintlib .WAIT modlintlib .WAIT $(SPARC_LINTS) $(LINT_DEPS) \
	$(IMPLEMENTATIONS) $(CLOSED_IMPLEMENTATIONS) $(CPU_KMODS)

# EXPORT DELETE START

EXPORT_SRC:
	$(RM) Makefile+
	sed -e "/^# EXPORT DELETE START/,/^# EXPORT DELETE END/d" \
	    < Makefile > Makefile+
	$(MV) Makefile+ Makefile
	$(CHMOD) 444 Makefile

# EXPORT DELETE END

include ../Makefile.targ

#
# Cross-reference customization: build a cross-reference over all of the
# sun4u-related directories.
#
SHARED_XRDIRS	= ../sun4u ../sun4 ../sfmmu ../sparc ../sun ../common
CLOSED_XRDIRS	= $(SHARED_XRDIRS:../%=../% ../../../closed/uts/%)
XRDIRS		= $(SHARED_XRDIRS)
$(CLOSED_BUILD)XRDIRS	= $(CLOSED_XRDIRS:../../../closed/uts/sfmmu=)

XRPRUNE = i86pc

cscope.out tags: FRC
	$(XREF) -x $@
