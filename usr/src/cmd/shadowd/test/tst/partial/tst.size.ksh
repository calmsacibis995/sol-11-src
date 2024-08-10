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
# Tests that we get the correct size when migrating a partially migrated file
# via SHADOW_IOC_MIGRATE.
#

. $ST_TOOLS/utility.ksh

tst_create_root

dd if=/dev/urandom of=$TST_ROOT/file bs=256k count=1 2>/dev/null || \
    fail "failed to create file"

tst_create_dataset

# migrate first 128k
dd if=$TST_SROOT/file of=/dev/null bs=1 count=1 iseek=128k conv=notrunc \
    2>/dev/null || fail "failed to read at 128k"

# should have 128k left
stsize $TST_SROOT/file || fail "failed to migrate file"

tst_destroy_dataset
