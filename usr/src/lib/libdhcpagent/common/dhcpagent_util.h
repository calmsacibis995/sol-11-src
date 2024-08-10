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
 * Copyright (c) 1999, 2003, Oracle and/or its affiliates. All rights reserved.
 */

#ifndef	_DHCPAGENT_UTIL_H
#define	_DHCPAGENT_UTIL_H

#include <sys/types.h>
#include <dhcpagent_ipc.h>

/*
 * dhcpagent_util.[ch] provides common utility functions that are
 * useful to dhcpagent consumers.
 */

#ifdef	__cplusplus
extern "C" {
#endif

extern const char	*dhcp_state_to_string(DHCPSTATE);
extern dhcp_ipc_type_t  dhcp_string_to_request(const char *);
extern int		dhcp_start_agent(int);
extern const char	*dhcp_status_hdr_string(void);
extern const char	*dhcp_status_reply_to_string(dhcp_ipc_reply_t *);

#ifdef	__cplusplus
}
#endif

#endif	/* _DHCPAGENT_UTIL_H */
