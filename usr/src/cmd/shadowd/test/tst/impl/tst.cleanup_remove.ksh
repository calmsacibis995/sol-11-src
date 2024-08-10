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
# Tests that SHADOW_IOC_PROCESS isn't tripped up by a directory or file being
# removed.
#

. $ST_TOOLS/utility.ksh

tst_create_root

echo "this is file a" > $TST_ROOT/a || fail "failed to create file a"
mkdir -p $TST_ROOT/dir || failed "failed to mkdir dir"
echo "this is file b" > $TST_ROOT/dir/b || fail "failed to create file b"
echo "this is file c" > $TST_ROOT/dir/c || fail "failed to create file c"

tst_create_dataset

ls $TST_SROOT/dir > /dev/null || fail "failed to ls $TST_SROOT/dir"
strotate $TST_SROOT || fail "failed to rotate pending list"
rm $TST_SROOT/dir/b

stprocess $TST_SROOT || fail "failed to process pending list"

tst_clear_shadow

cat $TST_SROOT/a || fail "failed to read file a"
[[ -f $TST_SROOT/dir/b ]] && fail "file dir/b still exists"
cat $TST_SROOT/dir/c || fail "failed to read file dir/c"

tst_destroy_dataset
