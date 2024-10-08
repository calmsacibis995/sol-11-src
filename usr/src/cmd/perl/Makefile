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

include ../Makefile.cmd

all	:= TARGET = all
install	:= TARGET = install
clobber := TARGET = clobber
clean	:= TARGET = clean
test	:= TARGET = test

# PERL_LEGACY is versions of Perl still delivered through ON
PERL_LEGACY = 5.8.4

# WOS_PERL is non-ON Perl
WOS_PERL = 5.12

PERL_VERSIONS = $(PERL_LEGACY) $(WOS_PERL)

.PARALLEL: $(PERL_VERSIONS)

i386_ARCH_TOKEN= i86pc
sparc_ARCH_TOKEN= sun4

ARCH_TOKEN= $($(MACH)_ARCH_TOKEN)

STRIP_CDDL = \
	usr/perl5/5.12/lib/Sun/Solaris/BSM/_BSMparse.pm \
	usr/perl5/5.12/lib/Sun/Solaris/Pg.pm \
	usr/perl5/5.12/lib/$(ARCH_TOKEN)-solaris-64int/Sun/Solaris/Intrs.pm \
	usr/perl5/5.12/lib/$(ARCH_TOKEN)-solaris-64int/Sun/Solaris/Kstat.pm \
	usr/perl5/5.12/lib/$(ARCH_TOKEN)-solaris-64int/Sun/Solaris/Lgrp.pm \
	usr/perl5/5.12/lib/$(ARCH_TOKEN)-solaris-64int/Sun/Solaris/Utils.pm \
	usr/perl5/5.8.4/lib/Encode/Makefile_PL.e2x \
	usr/perl5/5.8.4/lib/Sun/Solaris/BSM/_BSMparse.pm \
	usr/perl5/5.8.4/lib/Sun/Solaris/Intrs.pm \
	usr/perl5/5.8.4/lib/Sun/Solaris/Kstat.pm \
	usr/perl5/5.8.4/lib/Sun/Solaris/Lgrp.pm \
	usr/perl5/5.8.4/lib/Sun/Solaris/Pg.pm \
	usr/perl5/5.8.4/lib/Sun/Solaris/Utils.pm

ROOT_STRIP_CDDL= $(STRIP_CDDL:%=$(ROOT)/%)

$(ROOT_STRIP_CDDL) := FILEMODE= 0444

#
# copy_contrib is used by all the versions of perl to copy the files under
# contrib into their contrib build directory.  We therefore need to make sure
# it is fetched from SCCS before calling the version-specific makefiles so that
# they don't race over it.
#
all test: contrib/copy_contrib $(PERL_VERSIONS)

fixperms: $(ROOT_STRIP_CDDL)

install: contrib/copy_contrib $(PERL_VERSIONS) .WAIT fixperms

$(ROOT_STRIP_CDDL): FRC
	$(MV) $@ $(@F)
	$(INS.file) $(@F)
	$(RM) $(@F)

all install: THIRDPARTYLICENSE

clean: $(PERL_VERSIONS)

clobber: $(PERL_VERSIONS)
	$(RM) -r contrib/copy_contrib THIRDPARTYLICENSE $(WOS_PERL)

#
# Perl is not lint-clean.  Fake up a target.
#
lint:
	@ $(ECHO) "usr/src/cmd/perl is not lint-clean: skipping"
	@ $(TRUE)

#
# Second "if" corrects a problem in the perl build.
# Can remove once perl 5.12 becomes the default.
# 
$(PERL_VERSIONS): FRC
	@ if [ ! -d $@ ]; then \
	    $(CP) -r skel $@; \
	fi
	@ if [ $@ = $(WOS_PERL) ]; then \
		echo "patching skel for $(WOS_PERL)"; \
		sed -e '/^PERL_MM_ARGS/s/$$/ OPTIMIZE=-xO4/' \
			$@/Makefile > $@/Makefile_new; \
		rm -f $@/Makefile; \
		mv $@/Makefile_new $@/Makefile; \
	fi
	@ cd $@; pwd; PERL_VERSION=$@ $(MAKE) $(TARGET)

PODDIR = 5.8.4/distrib/pod
ARTLIC_SRC = $(PODDIR)/perlartistic.pod

#
# $(PODDIR)/pod2text may already exist (from "make install"), but it
# doesn't hurt to regenerate it.
#
THIRDPARTYLICENSE: $(ARTLIC_SRC)
	$(PERL) $(PODDIR)/pod2text.PL
	$(PODDIR)/pod2text $(ARTLIC_SRC) | \
	    $(SED) -n '/The "Artistic License"/,/The End/p' > $@

FRC:
