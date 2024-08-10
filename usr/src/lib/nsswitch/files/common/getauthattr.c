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
 * Copyright (c) 1999, 2011, Oracle and/or its affiliates. All rights reserved.
 */

#include "files_common.h"
#include <auth_attr.h>
#include <string.h>

/*
 *    files/getauthattr.c --
 *           "files" backend for nsswitch "auth_attr" database
 */

static files_hash_func hash_auth[1] = { hash_name };

static files_hash_t hashinfo = {
	DEFAULTMUTEX,
	sizeof (authattr_t),
	NSS_LINELEN_AUTHATTR,
	sizeof (hash_auth)/sizeof (files_hash_func),
	hash_auth
};

static nss_status_t
getbyname(files_backend_ptr_t be, void *a)
{
	return (_nss_files_XY_hash(be, a, 1, &hashinfo, 0,
	    _nss_files_check_name_colon));
}

static files_backend_op_t authattr_ops[] = {
	_nss_files_destr,
	_nss_files_endent,
	_nss_files_setent,
	_nss_files_getent_netdb,
	getbyname
};

/*ARGSUSED*/
nss_backend_t *
_nss_files_auth_attr_constr(const char *dummy1,
    const char *dummy2,
    const char *dummy3,
    const char *dummy4,
    const char *dummy5,
    const char *dummy6)
{
	return (_nss_files_constr(authattr_ops,
	    sizeof (authattr_ops) / sizeof (authattr_ops[0]),
	    AUTHATTR_DIRNAME,
	    NSS_LINELEN_AUTHATTR,
	    &hashinfo, 0));
}
