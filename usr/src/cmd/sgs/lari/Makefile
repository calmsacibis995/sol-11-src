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
# Copyright (c) 2003, 2011, Oracle and/or its affiliates. All rights reserved.

PROG=		lari

include		$(SRC)/cmd/Makefile.cmd
include		$(SRC)/cmd/sgs/Makefile.com

PSRC=		$(PROG).pl
POFILE=		$(SGSMSGDIR)/$(PROG)

.KEEP_STATE:

all:		$(PROG)

$(PROG):	$(PSRC)
		$(RM) $@
		$(SED) -e "s@TEXT_DOMAIN@\"SUNW_OST_SGS\"@" $(PSRC) > $@
		$(CHMOD) +x $@

install \
package:	all $(VAR_SGSBINPROG)

clean:
		$(RM) $(PROG)

chkmsg \
lint:

catalog:	$(POFILE)

$(POFILE):	$(PSRC)
		$(XGETTEXT) $(XGETFLAGS) $(PSRC)
		@ echo "" > $(POFILE)
		@ echo "# Message file for cmd/sgs/lari" >> $(POFILE)
		@ echo "" >> $(POFILE)
		@ echo "domain	\"SUNW_OST_SGS"\" >> $(POFILE)
		@ echo "" >> $(POFILE)
		sed -e "/^domain/d" messages.po >> $(POFILE)
		@ $(RM) messages.po

include		$(SRC)/cmd/Makefile.targ
