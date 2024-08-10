/*
 * CDDL HEADER START
 *
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License (the "License").
 * You may not use this file except in compliance with the License.
 *
 * You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
 * or http://www.opensolaris.org/os/licensing.
 * See the License for the specific language governing permissions
 * and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL HEADER in each
 * file and include the License file at usr/src/OPENSOLARIS.LICENSE.
 * If applicable, add the following below this CDDL HEADER, with the
 * fields enclosed by brackets "[]" replaced with your own identifying
 * information: Portions Copyright [yyyy] [name of copyright owner]
 *
 * CDDL HEADER END
 */
/*
 * Copyright (c) 1998, Oracle and/or its affiliates. All rights reserved.
 */

#ifndef _META_RUNTIME_H
#define	_META_RUNTIME_H

/*
 * Declares functions that return the values of runtime
 * parameters set in /etc/lvm/runtime.cf.  All
 * the functions declared in this file are defined in
 * SUNWmd/lib/libmeta/meta_runtime.c unless otherwise
 * noted.
 */

#ifdef __cplusplus
extern "C" {
#endif

#include <sys/types.h>

extern
boolean_t
do_owner_ioctls(void);

#ifdef __cplusplus
}
#endif

#endif /* _META_RUNTIME_H */