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

. /usr/lib/brand/solaris/common.ksh

# States
# ZONE_STATE_CONFIGURED           0 (never see)
# ZONE_STATE_INCOMPLETE           1 (never see)
# ZONE_STATE_INSTALLED            2
# ZONE_STATE_READY                3
# ZONE_STATE_RUNNING              4
# ZONE_STATE_SHUTTING_DOWN        5
# ZONE_STATE_DOWN                 6
# ZONE_STATE_MOUNTED              7

# cmd
#
# ready			0
# boot			1
# halt			4

ZONENAME=$1
ZONEPATH=$2
state=$3
cmd=$4
ALTROOT=$5

typeset zone
init_zone zone "$ZONENAME" "$ZONEPATH"
eval $(bind_legacy_zone_globals zone)

# If we're not halting the zone, then just return.
if [ $cmd -eq 4 ]; then
	is_brand_labeled
	if (( $? != 0 )); then
		# Leave the active boot environment mounted after halting (this
		# might be a different dataset than what was mounted).
		mount_active_be -c zone || fatal "$f_mount_active_be"
	else
		# Umount dataset on the root.
		unmount_be zone || fatal "$f_unmount_be"
	fi
fi

exit $ZONE_SUBPROC_OK