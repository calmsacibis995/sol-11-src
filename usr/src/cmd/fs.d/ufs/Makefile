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
#
# Copyright (c) 1990, 2011, Oracle and/or its affiliates. All rights reserved.
#
#  /usr/src/cmd/lib/fs/ufs is the directory of all ufs specific commands
#  whose executable reside in $(INSDIR1) and $(INSDIR2).
#
#	NOTE:   ufsdump and ufsrestore have been merged into hsmdump and
#		hsmrestore.  The source is located in usr/src/cmd/backup.
#		When the Online Backup producted is no longer supported
#		they should be moved here again.
#


SUBDIR1=	clri edquota ff fsck fsckall fsdb fsirand fstyp growfs \
		labelit lockfs ncheck quot quotacheck quotaon \
		repquota svc tunefs
SUBDIR2= 	df fssnap mkfs mount newfs volcopy
ROLLDIR=	roll_log
SUBDIRS=	$(ROLLDIR) $(SUBDIR1) $(SUBDIR2)

all:=		TARGET= all
install:=	TARGET= install
clean:=		TARGET= clean
clobber:=	TARGET= clobber
lint:=		TARGET= lint
catalog:=       TARGET= catalog

# for messaging catalog
#
POFILE= ufs.po
POFILES= $(SUBDIR2:%=%/%.po)

.KEEP_STATE:

.PARALLEL:	$(SUBDIRS)

all install:	$(ROLLDIR) .WAIT $(SUBDIR1) $(SUBDIR2)

catalog:        $(POFILE)

$(POFILE):      $(SUBDIR2)
	$(RM) 	$@
	cat     $(POFILES)      > $@

clean clobber lint: $(SUBDIRS)

$(SUBDIRS): FRC
	@cd $@; pwd; $(MAKE) $(MFLAGS) $(TARGET)

FRC:
