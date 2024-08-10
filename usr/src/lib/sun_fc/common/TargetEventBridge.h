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
 * Copyright 2008 Sun Microsystems, Inc.  All rights reserved.
 * Use is subject to license terms.
 */

#ifndef	_TARGETEVENTBRIDGE_H
#define	_TARGETEVENTBRIDGE_H



#include "TargetEventListener.h"

/**
 * @memo	    Bridge interface for target events
 * 
 * @doc		    Used to abstract clients from the specific 
 *		    underlying details of event management for
 *		    the given HBA/driver stack.
 */
class TargetEventBridge{
public:
    virtual void addListener(TargetEventListener *listener,
	    HBAPort *port, uint64_t targetWWN, bool filter) = 0;
    virtual void removeListener(TargetEventListener *listener) = 0;
    virtual int32_t getMaxListener() = 0;
};

#endif /* _TARGETEVENTBRIDGE_H */
