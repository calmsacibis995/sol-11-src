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
 * Copyright (c) 2003, 2011, Oracle and/or its affiliates. All rights reserved.
 *
 * This is an unstable interface; changes may be made without
 * notice.
 */

#ifndef	_AUDIT_PLUGIN_H
#define	_AUDIT_PLUGIN_H

#include <stdio.h>
#include <paths.h>
#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

#define	BINFILE_FILE	_PATH_SYSVOL "/audit.log"

void __audit_syslog(const char *, int, int, int, const char *, ...);
void __audit_dowarn(char *, char *, int);
void __audit_dowarn2(char *, char *, char *, char *, int);
int __logpost(char *);
int __do_sethost(char *);
void __auditd_debug(char *, ...);
FILE *__auditd_debug_file_open(void);
boolean_t __audit_hrstrtonum(char *, uint64_t *);

#ifdef	__cplusplus
}
#endif

#endif	/* _AUDIT_PLUGIN_H */
