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
# Tests the transfer-start and transfer-done probes for directories.  Sadly, we
# can't make any assumptions about the size of these transfers given the
# implementation details that is directory layout.  So we just make sure that
# we get the right callbacks, and that the result is non-zero.  We cross our
# fingers that two one-character directory entries can fit in a single buffer
# to our readdir call.
#

. $ST_TOOLS/utility.ksh

function create_file
{
	typeset file=$1 size=$2
	shift 2

	mkfile -n $size $file || fail "failed to create file"

	while [[ $# -gt 0 ]]; do
		typeset offset=$1 length=$2
		shift 2

		dd if=/dev/urandom of=$file bs=1024 count=$length \
		    oseek=$offset conv=notrunc 2> /dev/null || \
		    fail "failed to write data"	
	done
}

tst_create_root

mkdir $TST_ROOT/dir
mkdir $TST_ROOT/dir/a
mkdir $TST_ROOT/dir/b

tst_create_dataset

OUTPUT=/var/tmp/shadowtest.migrate.$$

ls $TST_SROOT > /dev/null

dtrace -s /dev/stdin <<EOF > $OUTPUT.1 &
#pragma D option quiet

int total;

BEGIN
{
	printf("%-24dBEGIN\n", timestamp);
}

ERROR
{
	printf("ERROR\n");
}

shadowfs:::transfer-start
/args[1] != NULL/
{
	printf("%-24dSTART %s %s %d\n", timestamp, args[0]->fi_pathname,
	   args[1], (int)args[2]);
}

shadowfs:::transfer-done
/args[1] != NULL && args[3] != 0/
{
	printf("%-24dDONE %s %s %d\n", timestamp, args[0]->fi_pathname,
	   args[1], (int)args[2]);
}

shadowfs:::complete
{
	printf("%-24dCOMPLETE %s\n", timestamp, args[0]->fi_pathname);
	exit(0);
}
EOF

DPID=$!

# wait for dtrace to start
until grep BEGIN $OUTPUT.1; do
	sleep 0.1
done

ls $TST_SROOT/dir || fail "failed to list dir"

wait $DPID

# sort the output by time and trim timestamps
cat $OUTPUT.1 | sort -n | cut -c 25- > $OUTPUT.3 || fail "failed to trim output"

cat > $OUTPUT.2 <<EOF

BEGIN
START $TST_SROOT/dir dir 0
DONE $TST_SROOT/dir dir 0
COMPLETE $TST_SROOT/dir
EOF

diff $OUTPUT.2 $OUTPUT.3 || fail "mismatched output"

rm -f $OUTPUT.*
tst_destroy_dataset
exit 0
