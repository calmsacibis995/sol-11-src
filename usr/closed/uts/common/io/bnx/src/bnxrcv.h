/*
 * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
 */

/******************************************************************************
 * The information contained in this file is confidential and proprietary to
 * Broadcom Corporation.  No part of this file may be reproduced or
 * distributed, in any form or by any means for any purpose, without the
 * express written permission of Broadcom Corporation.
 *
 * (c) COPYRIGHT 2007-2010 Broadcom Corporation, ALL RIGHTS RESERVED.
 ******************************************************************************/


#ifndef BNX_RCV_H
#define BNX_RCV_H

#include "bnx.h"

int  bnx_rxpkts_init( um_device_t * const umdevice );
void bnx_rxpkts_intr( um_device_t * const umdevice );
void bnx_rxpkts_post( um_device_t * const umdevice );
void bnx_rxpkts_recycle( um_device_t * const umdevice );
void bnx_rxpkts_fini( um_device_t * const umdevice );

#endif /* BNX_RCV_H */
