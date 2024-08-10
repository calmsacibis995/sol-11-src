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
 * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
 */
/*
 * Copyright Exar 2010. Copyright (c) 2002-2010 Neterion, Inc.
 * All right Reserved.
 *
 * FileName :   vxgehal-vpmgmt-reg.h
 *
 * Description:  Auto generated Titan register space
 *
 * Generation Information:
 *
 *       Source File(s):
 *
 *       C Template:       templates/c/location.st (version 1.10)
 *       Code Generation:  java/SWIF_Codegen.java (version 1.62)
 *       Frontend:      java/SWIF_Main.java (version 1.52)
 */

#ifndef	VXGE_HAL_VPMGMT_REGS_H
#define	VXGE_HAL_VPMGMT_REGS_H

__EXTERN_BEGIN_DECLS

typedef struct vxge_hal_vpmgmt_reg_t {

/* 0x00000 */	u64	one_cfg_sr_rdy;
#define	VXGE_HAL_ONE_CFG_SR_RDY_ONE_CFG_SR_RDY		    mBIT(7)
/* 0x00008 */	u64	sgrp_own;
#define	VXGE_HAL_SGRP_OWN_SGRP_OWN(val)			    vBIT(val, 0, 64)
	u8	unused00040[0x00040-0x00010];

/* 0x00040 */	u64	vpath_to_func_map_cfg1;
#define	VXGE_HAL_VPATH_TO_FUNC_MAP_CFG1_VPATH_TO_FUNC_MAP_CFG1(val)\
							    vBIT(val, 3, 5)
/* 0x00048 */	u64	vpath_is_first;
#define	VXGE_HAL_VPATH_IS_FIRST_VPATH_IS_FIRST		    mBIT(3)
/* 0x00050 */	u64	srpcim_to_vpath_wmsg;
#define	VXGE_HAL_SRPCIM_TO_VPATH_WMSG_SRPCIM_TO_VPATH_WMSG(val)\
							    vBIT(val, 0, 64)
/* 0x00058 */	u64	srpcim_to_vpath_wmsg_trig;
#define	VXGE_HAL_SRPCIM_TO_VPATH_WMSG_TRIG_TRIG		    mBIT(0)
	u8	unused00100[0x00100-0x00060];

/* 0x00100 */	u64	tim_vpath_assignment;
#define	VXGE_HAL_TIM_VPATH_ASSIGNMENT_BMAP_ROOT(val)	    vBIT(val, 0, 32)
	u8	unused00140[0x00140-0x00108];

/* 0x00140 */	u64	rqa_top_prty_for_vp;
#define	VXGE_HAL_RQA_TOP_PRTY_FOR_VP_RQA_TOP_PRTY_FOR_VP(val) vBIT(val, 59, 5)
	u8	unused00180[0x00180-0x00148];

/* 0x00180 */	u64	usdc_vpath_own;
#define	VXGE_HAL_USDC_VPATH_OWN_SGRP_OWN(val)		    vBIT(val, 0, 32)
	u8	unused001c0[0x001c0-0x00188];

/* 0x001c0 */	u64	rxmac_rx_pa_cfg0_vpmgmt_clone;
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_IGNORE_FRAME_ERR	mBIT(3)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_SUPPORT_SNAP_AB_N mBIT(7)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_SEARCH_FOR_HAO mBIT(18)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_SUPPORT_MOBILE_IPV6_HDRS\
							    mBIT(19)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_IPV6_STOP_SEARCHING mBIT(23)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_NO_PS_IF_UNKNOWN	mBIT(27)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_SEARCH_FOR_ETYPE	mBIT(35)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_TOSS_ANY_FRM_IF_L3_CSUM_ERR\
							    mBIT(39)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_TOSS_OFFLD_FRM_IF_L3_CSUM_ERR\
							    mBIT(43)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_TOSS_ANY_FRM_IF_L4_CSUM_ERR\
							    mBIT(47)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_TOSS_OFFLD_FRM_IF_L4_CSUM_ERR\
							    mBIT(51)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_TOSS_ANY_FRM_IF_RPA_ERR\
							    mBIT(55)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_TOSS_OFFLD_FRM_IF_RPA_ERR\
							    mBIT(59)
#define	VXGE_HAL_RXMAC_RX_PA_CFG0_VPMGMT_CLONE_JUMBO_SNAP_EN mBIT(63)
/* 0x001c8 */	u64	rts_mgr_cfg0_vpmgmt_clone;
#define	VXGE_HAL_RTS_MGR_CFG0_VPMGMT_CLONE_RTS_DP_SP_PRIORITY mBIT(3)
#define	VXGE_HAL_RTS_MGR_CFG0_VPMGMT_CLONE_FLEX_L4PRTCL_VALUE(val)\
							    vBIT(val, 24, 8)
#define	VXGE_HAL_RTS_MGR_CFG0_VPMGMT_CLONE_ICMP_TRASH	    mBIT(35)
#define	VXGE_HAL_RTS_MGR_CFG0_VPMGMT_CLONE_TCPSYN_TRASH	    mBIT(39)
#define	VXGE_HAL_RTS_MGR_CFG0_VPMGMT_CLONE_ZL4PYLD_TRASH    mBIT(43)
#define	VXGE_HAL_RTS_MGR_CFG0_VPMGMT_CLONE_L4PRTCL_TCP_TRASH mBIT(47)
#define	VXGE_HAL_RTS_MGR_CFG0_VPMGMT_CLONE_L4PRTCL_UDP_TRASH mBIT(51)
#define	VXGE_HAL_RTS_MGR_CFG0_VPMGMT_CLONE_L4PRTCL_FLEX_TRASH mBIT(55)
#define	VXGE_HAL_RTS_MGR_CFG0_VPMGMT_CLONE_IPFRAG_TRASH	    mBIT(59)
/* 0x001d0 */	u64	rts_mgr_criteria_priority_vpmgmt_clone;
#define	VXGE_HAL_RTS_MGR_CRITERIA_PRIORITY_VPMGMT_CLONE_ETYPE(val)\
							    vBIT(val, 5, 3)
#define	VXGE_HAL_RTS_MGR_CRITERIA_PRIORITY_VPMGMT_CLONE_ICMP_TCPSYN(val)\
							    vBIT(val, 9, 3)
#define	VXGE_HAL_RTS_MGR_CRITERIA_PRIORITY_VPMGMT_CLONE_L4PN(val)\
							    vBIT(val, 13, 3)
#define	VXGE_HAL_RTS_MGR_CRITERIA_PRIORITY_VPMGMT_CLONE_RANGE_L4PN(val)\
							    vBIT(val, 17, 3)
#define	VXGE_HAL_RTS_MGR_CRITERIA_PRIORITY_VPMGMT_CLONE_RTH_IT(val)\
							    vBIT(val, 21, 3)
#define	VXGE_HAL_RTS_MGR_CRITERIA_PRIORITY_VPMGMT_CLONE_DS(val)\
							    vBIT(val, 25, 3)
#define	VXGE_HAL_RTS_MGR_CRITERIA_PRIORITY_VPMGMT_CLONE_QOS(val)\
							    vBIT(val, 29, 3)
#define	VXGE_HAL_RTS_MGR_CRITERIA_PRIORITY_VPMGMT_CLONE_ZL4PYLD(val)\
							    vBIT(val, 33, 3)
#define	VXGE_HAL_RTS_MGR_CRITERIA_PRIORITY_VPMGMT_CLONE_L4PRTCL(val)\
							    vBIT(val, 37, 3)
/* 0x001d8 */	u64	rxmac_cfg0_port_vpmgmt_clone[3];
#define	VXGE_HAL_RXMAC_CFG0_PORT_VPMGMT_CLONE_RMAC_EN	    mBIT(3)
#define	VXGE_HAL_RXMAC_CFG0_PORT_VPMGMT_CLONE_STRIP_FCS	    mBIT(7)
#define	VXGE_HAL_RXMAC_CFG0_PORT_VPMGMT_CLONE_DISCARD_PFRM  mBIT(11)
#define	VXGE_HAL_RXMAC_CFG0_PORT_VPMGMT_CLONE_IGNORE_FCS_ERR mBIT(15)
#define	VXGE_HAL_RXMAC_CFG0_PORT_VPMGMT_CLONE_IGNORE_LONG_ERR mBIT(19)
#define	VXGE_HAL_RXMAC_CFG0_PORT_VPMGMT_CLONE_IGNORE_USIZED_ERR	mBIT(23)
#define	VXGE_HAL_RXMAC_CFG0_PORT_VPMGMT_CLONE_IGNORE_LEN_MISMATCH mBIT(27)
#define	VXGE_HAL_RXMAC_CFG0_PORT_VPMGMT_CLONE_MAX_PYLD_LEN(val)\
							    vBIT(val, 50, 14)
/* 0x001f0 */	u64	rxmac_pause_cfg_port_vpmgmt_clone[3];
#define	VXGE_HAL_RXMAC_PAUSE_CFG_PORT_VPMGMT_CLONE_GEN_EN   mBIT(3)
#define	VXGE_HAL_RXMAC_PAUSE_CFG_PORT_VPMGMT_CLONE_RCV_EN   mBIT(7)
#define	VXGE_HAL_RXMAC_PAUSE_CFG_PORT_VPMGMT_CLONE_ACCEL_SEND(val)\
							    vBIT(val, 9, 3)
#define	VXGE_HAL_RXMAC_PAUSE_CFG_PORT_VPMGMT_CLONE_DUAL_THR mBIT(15)
#define	VXGE_HAL_RXMAC_PAUSE_CFG_PORT_VPMGMT_CLONE_HIGH_PTIME(val)\
							    vBIT(val, 20, 16)
#define	VXGE_HAL_RXMAC_PAUSE_CFG_PORT_VPMGMT_CLONE_IGNORE_PF_FCS_ERR mBIT(39)
#define	VXGE_HAL_RXMAC_PAUSE_CFG_PORT_VPMGMT_CLONE_IGNORE_PF_LEN_ERR mBIT(43)
#define	VXGE_HAL_RXMAC_PAUSE_CFG_PORT_VPMGMT_CLONE_LIMITER_EN mBIT(47)
#define	VXGE_HAL_RXMAC_PAUSE_CFG_PORT_VPMGMT_CLONE_MAX_LIMIT(val)\
							    vBIT(val, 48, 8)
#define	VXGE_HAL_RXMAC_PAUSE_CFG_PORT_VPMGMT_CLONE_PERMIT_RATEMGMT_CTRL	mBIT(59)
	u8	unused00240[0x00240-0x00208];

/* 0x00240 */	u64	xmac_vsport_choices_vp;
#define	VXGE_HAL_XMAC_VSPORT_CHOICES_VP_VSPORT_VECTOR(val)  vBIT(val, 0, 17)
	u8	unused00260[0x00260-0x00248];

/* 0x00260 */	u64	xgmac_gen_status_vpmgmt_clone;
#define	VXGE_HAL_XGMAC_GEN_STATUS_VPMGMT_CLONE_XMACJ_NTWK_OK mBIT(3)
#define	VXGE_HAL_XGMAC_GEN_STATUS_VPMGMT_CLONE_XMACJ_NTWK_DATA_RATE mBIT(11)
/* 0x00268 */	u64	xgmac_status_port_vpmgmt_clone[2];
#define	VXGE_HAL_XGMAC_STATUS_PORT_VPMGMT_CLONE_RMAC_REMOTE_FAULT mBIT(3)
#define	VXGE_HAL_XGMAC_STATUS_PORT_VPMGMT_CLONE_RMAC_LOCAL_FAULT mBIT(7)
#define	VXGE_HAL_XGMAC_STATUS_PORT_VPMGMT_CLONE_XMACJ_MAC_PHY_LAYER_AVAIL\
							    mBIT(11)
#define	VXGE_HAL_XGMAC_STATUS_PORT_VPMGMT_CLONE_XMACJ_PORT_OK mBIT(15)
/* 0x00278 */	u64	xmac_gen_cfg_vpmgmt_clone;
#define	VXGE_HAL_XMAC_GEN_CFG_VPMGMT_CLONE_RATEMGMT_MAC_RATE_SEL(val)\
							    vBIT(val, 2, 2)
#define	VXGE_HAL_XMAC_GEN_CFG_VPMGMT_CLONE_TX_HEAD_DROP_WHEN_FAULT\
							    mBIT(7)
#define	VXGE_HAL_XMAC_GEN_CFG_VPMGMT_CLONE_FAULT_BEHAVIOUR\
							    mBIT(27)
#define	VXGE_HAL_XMAC_GEN_CFG_VPMGMT_CLONE_PERIOD_NTWK_UP(val)\
							    vBIT(val, 28, 4)
#define	VXGE_HAL_XMAC_GEN_CFG_VPMGMT_CLONE_PERIOD_NTWK_DOWN(val)\
							    vBIT(val, 32, 4)
/* 0x00280 */	u64	xmac_timestamp_vpmgmt_clone;
#define	VXGE_HAL_XMAC_TIMESTAMP_VPMGMT_CLONE_EN	mBIT(3)
#define	VXGE_HAL_XMAC_TIMESTAMP_VPMGMT_CLONE_USE_LINK_ID(val)\
							    vBIT(val, 6, 2)
#define	VXGE_HAL_XMAC_TIMESTAMP_VPMGMT_CLONE_INTERVAL(val)\
							    vBIT(val, 12, 4)
#define	VXGE_HAL_XMAC_TIMESTAMP_VPMGMT_CLONE_TIMER_RESTART\
							    mBIT(19)
#define	VXGE_HAL_XMAC_TIMESTAMP_VPMGMT_CLONE_XMACJ_ROLLOVER_CNT(val)\
							    vBIT(val, 32, 16)
/* 0x00288 */	u64	xmac_stats_gen_cfg_vpmgmt_clone;
#define	VXGE_HAL_XMAC_STATS_GEN_CFG_VPMGMT_CLONE_PRTAGGR_CUM_TIMER(val)\
							    vBIT(val, 4, 4)
#define	VXGE_HAL_XMAC_STATS_GEN_CFG_VPMGMT_CLONE_VPATH_CUM_TIMER(val)\
							    vBIT(val, 8, 4)
#define	VXGE_HAL_XMAC_STATS_GEN_CFG_VPMGMT_CLONE_VLAN_HANDLING\
							    mBIT(15)
/* 0x00290 */	u64	xmac_cfg_port_vpmgmt_clone[3];
#define	VXGE_HAL_XMAC_CFG_PORT_VPMGMT_CLONE_XGMII_LOOPBACK\
							    mBIT(3)
#define	VXGE_HAL_XMAC_CFG_PORT_VPMGMT_CLONE_XGMII_REVERSE_LOOPBACK\
							    mBIT(7)
#define	VXGE_HAL_XMAC_CFG_PORT_VPMGMT_CLONE_XGMII_TX_BEHAV\
							    mBIT(11)
#define	VXGE_HAL_XMAC_CFG_PORT_VPMGMT_CLONE_XGMII_RX_BEHAV\
							    mBIT(15)
	u8	unused002c0[0x002c0-0x002a8];

/* 0x002c0 */	u64	txmac_gen_cfg0_vpmgmt_clone;
#define	VXGE_HAL_TXMAC_GEN_CFG0_VPMGMT_CLONE_CHOSEN_TX_PORT\
							    mBIT(7)
/* 0x002c8 */	u64	txmac_cfg0_port_vpmgmt_clone[3];
#define	VXGE_HAL_TXMAC_CFG0_PORT_VPMGMT_CLONE_TMAC_EN\
							    mBIT(3)
#define	VXGE_HAL_TXMAC_CFG0_PORT_VPMGMT_CLONE_APPEND_PAD\
							    mBIT(7)
#define	VXGE_HAL_TXMAC_CFG0_PORT_VPMGMT_CLONE_PAD_BYTE(val) vBIT(val, 8, 8)
	u8	unused00300[0x00300-0x002e0];

/* 0x00300 */	u64	wol_mp_crc;
#define	VXGE_HAL_WOL_MP_CRC_CRC(val)			    vBIT(val, 0, 32)
#define	VXGE_HAL_WOL_MP_CRC_RC_EN			    mBIT(63)
/* 0x00308 */	u64	wol_mp_mask_a;
#define	VXGE_HAL_WOL_MP_MASK_A_MASK(val)		    vBIT(val, 0, 64)
/* 0x00310 */	u64	wol_mp_mask_b;
#define	VXGE_HAL_WOL_MP_MASK_B_MASK(val)		    vBIT(val, 0, 64)
	u8	unused00360[0x00360-0x00318];

/* 0x00360 */	u64	fau_pa_cfg_vpmgmt_clone;
#define	VXGE_HAL_FAU_PA_CFG_VPMGMT_CLONE_REPL_L4_COMP_CSUM  mBIT(3)
#define	VXGE_HAL_FAU_PA_CFG_VPMGMT_CLONE_REPL_L3_INCL_CF    mBIT(7)
#define	VXGE_HAL_FAU_PA_CFG_VPMGMT_CLONE_REPL_L3_COMP_CSUM  mBIT(11)
/* 0x00368 */	u64	rx_datapath_util_vp_clone;
#define	VXGE_HAL_RX_DATAPATH_UTIL_VP_CLONE_FAU_RX_UTILIZATION(val)\
							    vBIT(val, 7, 9)
#define	VXGE_HAL_RX_DATAPATH_UTIL_VP_CLONE_RX_UTIL_CFG(val) vBIT(val, 16, 4)
#define	VXGE_HAL_RX_DATAPATH_UTIL_VP_CLONE_FAU_RX_FRAC_UTIL(val)\
							    vBIT(val, 20, 4)
#define	VXGE_HAL_RX_DATAPATH_UTIL_VP_CLONE_RX_PKT_WEIGHT(val)\
							    vBIT(val, 24, 4)
	u8	unused00380[0x00380-0x00370];

/* 0x00380 */	u64	tx_datapath_util_vp_clone;
#define	VXGE_HAL_TX_DATAPATH_UTIL_VP_CLONE_TPA_TX_UTILIZATION(val)\
							    vBIT(val, 7, 9)
#define	VXGE_HAL_TX_DATAPATH_UTIL_VP_CLONE_TX_UTIL_CFG(val) vBIT(val, 16, 4)
#define	VXGE_HAL_TX_DATAPATH_UTIL_VP_CLONE_TPA_TX_FRAC_UTIL(val)\
							    vBIT(val, 20, 4)
#define	VXGE_HAL_TX_DATAPATH_UTIL_VP_CLONE_TX_PKT_WEIGHT(val) vBIT(val, 24, 4)

} vxge_hal_vpmgmt_reg_t;

__EXTERN_END_DECLS

#endif /* VXGE_HAL_VPMGMT_REGS_H */
