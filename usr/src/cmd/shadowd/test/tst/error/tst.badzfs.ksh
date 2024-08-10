#!/bin/ksh -p
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
# Copyright (c) 2009, 2011, Oracle and/or its affiliates. All rights reserved.
#

#
# Verify that we correctly flag invalid options to the 'shadow' ZFS option.
#

. $ST_TOOLS/utility.ksh

function fail_create
{
	typeset shadow=$1

	zfs create  -o mountpoint=$TST_ROOT -o shadow=$shadow \
	    $TST_RDATASET >/dev/null 2>&1
	# We explicitly check against 1 to catch core dumps
	[[ $? != 1 ]] && fail "successfully created dataset with shadow $shadow"
}

#
# Invalid or missing protocol
#
fail_create ""
fail_create a
fail_create b/c
fail_create a@b:
fail_create :///foo

#
# Invalid protocol
#
fail_create fil:///foo/bar
fail_create nothing:///baz

#
# Missing path
#
fail_create file://
fail_create file://notsup/export

#
# No such directory
#
fail_create file:///tmp/$(dirname $0).$$

#
# Missing NFS host
#
fail_create nfs:///export

exit 0
