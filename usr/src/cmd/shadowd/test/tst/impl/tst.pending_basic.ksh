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
# This verifies that the pending FID list is correct for a very basic tree
# structure.
#

. $ST_TOOLS/utility.ksh

stsuspend

tst_create_root

echo "this is file a" > $TST_ROOT/a || fail "failed to create file a"
mkdir -p $TST_ROOT/dir1/dir2 || failed "failed to mkdir dir1/dir2"
echo "this is file b" > $TST_ROOT/dir1/b || fail "failed to create file b"
echo "this is file c" > $TST_ROOT/dir1/dir2/c || fail "failed to create file c"

tst_create_dataset

find $TST_SROOT -exec cat {} \; > /dev/null 2>& 1

stpending 0 $TST_SROOT $TST_SROOT/a $TST_SROOT/dir1 $TST_SROOT/dir1/dir2 \
    $TST_SROOT/dir1/b $TST_SROOT/dir1/dir2/c || \
    fail "unexpected pending list"

tst_destroy_dataset

stresume