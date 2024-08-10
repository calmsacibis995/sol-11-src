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
# Tests that a file that cannot be migrated (i.e. a door) does not prevent
# the parent directory itself from being migrated.
#

. $ST_TOOLS/utility.ksh

tst_create_root

mkdir $TST_ROOT/dir || fail "failed to create dir"
echo "this is file a" > $TST_ROOT/dir/a || fail "failed to create a"
stdoor $TST_ROOT/dir/door || fail "failed to create door"

tst_create_dataset

cat $TST_SROOT/dir/a || fail "failed to cat a"
cat $TST_SROOT/dir/door && fail "successfully read door"

tst_clear_shadow

cat $TST_SROOT/dir/door

tst_destroy_dataset

rm -f $TST_ROOT/dir/door
