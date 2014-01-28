------------------------------------------------------------------------------
-- $Id: xps_ll_temac.vhd,v 1.1.4.39 2009/11/17 07:11:39 tomaik Exp $
------------------------------------------------------------------------------
-- xps_ll_temac.vhd
------------------------------------------------------------------------------
--
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2000, 2001, 2002, 2003, 2004, 2005, 2008 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--

------------------------------------------------------------------------------
-- Filename:        xps_ll_temac.vhd
-- Version:         v2.00a
-- Description:     top level of xps_ll_temac
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--            -- xps_ll_temac.vhd
--               -- soft_temac_wrap.vhd
--               -- v4_temac_wrap.vhd
--               -- v5_temac_wrap.vhd
--               -- tx_llink_top.vhd           ******
--                  -- tx_temac_if.vhd
--                     -- tx_temac_if_sm.vhd
--                     -- tx_csum_mux.vhd
--                     -- tx_data_mux.vhd
--                     -- tx_cl_if.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Change log:
-------------------------------------------------------------------------------
-- 
-- *** xps_ll_temac_v2_02_a EDK 11.1 *** 
-- New Features
-- Re-designed for robustness, to improve performance and reduce resources
-- Added extended receive multicast address filtering, extended VLAN
-- processing, receive and transmit statistics, and Ethernet AVB support
-- Removed soft TEMAC code and made seperate encrypted pay sub-core so that
-- all of the free code can be un-encrypted
-- 
-- Resolved Issues
-- Removed all asynchronous resets and all latches CR<472683> CR<471362>
-- CR<476763>
-- Fixed broadcast reject function CR<474010>
-- Fix transmit LocalLink throttling to handle all cases
-- Integrate support for QVirtex4 and QRVirtex4 devices
-- Remove support for Virtex2-Pro devices
-- 
-- Known Issues
-- None
-- 
-- Other Information
-- None
-- 
-- *** xps_ll_temac_v1_01_b EDK 10.1.3 *** 
-- New Features
-- None
-- 
-- Resolved Issues
-- An answer record with patch files was created to support 
-- QVirtex4 and QRVirtex4 devices AR<31417>
-- 
-- Known Issues
-- Broadcast reject function does not work CR<474010>
-- Some asynchronous resets and some latches cause timing problems
-- CR<472683> CR<471362> CR<476763>
-- The Transmit LocalLink interface requires specific throttling used
-- by xps_ll_fifo, SDMA, and HDMA cores and no other throttling pattern
-- will work
-- 
-- *** xps_ll_temac_v1_01_b EDK 10.1.2 *** 
-- New Features
-- Updated tcl and MPD files to add checks for proper port usage based on
-- device and PHY interface used and one or two TEMACs used
-- 
-- Resolved Issues
-- Include fix for timing problem after receiving a bad frame or pause frame
-- which caused next good frame to be dropped see AR<30188> CR<466889>
-- Included fix to allow building Virtex 5 FXT SGMII and 1000BaseX systems
-- see AR<30235>
-- 
-- Known Issues
-- None
-- 
-- Other Information
-- None
-- 
-- *** xps_ll_temac_v1_01_a EDK 10.1.1 ***
-- New Features
-- None
-- 
-- Resolved Issues
-- None
-- 
-- Known Issues
-- Can't build Virtex 5 FXT SGMII or 1000Base-X systems see AR<30188>
-- A good frame following a bad frame or pause frame may also be dropped see
-- AR<30188> CR<466889>
-- 
-- Other Information
-- None
--
-- *** xps_ll_temac_v1_01_a EDK 10.1 ***
-- New Features
-- Added 1000Base-X and SGMII PHY interface options to hard TEMAC configs.
-- Add support for Virtex 2 Pro with soft TEMAC config
-- Add support for Virtex 5 FXT devices and C_SUBFAMILY parameter
-- Added interrupt bit 24 to indicate MGTs are out of reset
-- 
-- Resolved Issues
-- TX CSUM fix by removing Tx LocalLink interface header processing
-- enhancement from EDK 9.2.1 see AR<29708> CR<453031>
-- Fixed receive address validation problem that has existed in all
-- releases to this point see CR<448026> CR<454243> CR<456168> CR<456169>
-- Add parameters for IDELAYCTRL generation and placement rather than having
-- hard coded see CR<448845>
-- Power-up default value of Virtex 4 hard TEMAC unicast and pause address
-- registers when using  SGMII and 1000Base-X corrected to match data sheet
-- CR<458088>
-- TX CSUM fix for frames that don't end on a 32-bit word boundry. Problem
-- induced by change to fix long timing path in EDK 9.2.2 release see
-- CR<460704>
--
-- Known Issues
-- None
-- 
-- Other Information
-- Update Virtex 5 TEMAC wrappers to latest designs in Corgen
--  
-- *** xps_ll_temac_v1_00_b EDK 9.2.2 ***
-- New Features
-- None
-- 
-- Resolved Issues
-- None
-- 
-- Known Issues
-- TX CSUM broken in 9.2.1 release see AR<29708> CR<453031>
-- Receive address validation problem see CR<448026> CR<454243> CR<456168>
-- CR<456169>
-- Can not easily add IDELAYCTRLs and placement see CR<448845>
-- 
-- Other Information
-- None
--
-- *** xps_ll_temac_v1_00_b EDK 9.2.1 ***
-- New Features
-- Added MII PHY interface option to soft TEMAC configuration.
-- Enabled smaller TX and RX FIFOs
-- Reduced the depth of the RX client FIFO to reduce BRAM usage
-- 
-- Resolved Issues
-- Included a fix for TX CSUM 
-- Included an enhancement for the TX LocalLink inteface header processing
-- Included a fix for 10 Mb/s mode with some LocalLink clock rates where
-- back to back TX packets can incorrectly run together see CR<451163>
-- Added a register to a TX path signal to improve a worst case long timing
-- path
-- 
-- Known Issues
-- Receive address validation problem see CR<448026> CR<454243>
-- CR<456168> CR<456169>
-- Can not easily add IDELAYCTRLs and placement see CR<448845>
-- 
-- Other Information
-- None
--
-- *** xps_ll_temac_v1_00_a EDK 9.2 ***
-- New Features
-- First full release
-- 
-- Resolved Issues
-- None
-- 
-- Known Issues
-- None
-- 
-- Other Information
-- None
-- 
-- *** xps_ll_temac_v1_00_a EDK 9.1.2 ***
-- New Features
-- New core xps_ll_temac_v1_01_a early access for simulation not
-- Released area of EDK
-- 
-- Resolved Issues
-- None
-- 
-- Known Issues
-- None
-- 
-- Other Information
-- None
--
--  
------------------------------------------------------------------------------
-- Author:      
-- History:
--
------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_com" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_bit.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

library soft_temac_wrap_v2_03_a;
use soft_temac_wrap_v2_03_a.all;

library eth_stat_wrap_v2_03_a;
use eth_stat_wrap_v2_03_a.all;

library plbv46_slave_single_v1_01_a;
use plbv46_slave_single_v1_01_a.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;
use proc_common_v3_00_a.ipif_pkg.all;
use proc_common_v3_00_a.family.all;
use proc_common_v3_00_a.all;
-- begin change to accomidate Spartan 6 clock change for statistics
use proc_common_v3_00_a.family_support.all;
-- end change to accomidate Spartan 6 clock change for statistics

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

entity xps_ll_temac is
  generic (
    C_NUM_IDELAYCTRL            : integer range 0 to 16 := 1;
      -- RANGE = (0:16)
    C_SUBFAMILY                 : string                := "FX";
    C_RESERVED                  : integer range 0 to 1  := 0;  
    C_FAMILY                    : string                := "virtex5";  
    C_BASEADDR                  : std_logic_vector      := X"FFFFFFFF";
    C_HIGHADDR                  : std_logic_vector      := X"00000000";
    C_SPLB_DWIDTH               : integer               := 32;
    C_SPLB_AWIDTH               : integer               := 32;
    C_SPLB_NUM_MASTERS          : integer               := 8;
    C_SPLB_MID_WIDTH            : integer               := 3;
    C_SPLB_P2P                  : integer range 0 to 1  := 0;
    C_BUS2CORE_CLK_RATIO        : integer range 1 to 2  := 2;
        -- Specifies the clock ratio from BUS to Core allowing
        -- the core to operate at a slower than the bus clock rate
        -- A value of 1 represents 1:1 and a value of 2 represents
        -- 2:1 where the bus clock is twice as fast as the core 
        -- clock.
    C_INCLUDE_IO                : integer range 0 to 1  := 1;
    C_TEMAC_TYPE                : integer range 0 to 3  := 0;  
      -- 0 - Virtex 5 hard TEMAC (FX, LXT, SXT devices)                
      -- 1 - Virtex 4 hard TEMAC (FX)               
      -- 2 - Soft TEMAC         
      -- 3 - Virtex 6 hard TEMAC         
    C_PHY_TYPE                  : integer range 0 to 5  := 1;
      -- 0 - MII                
      -- 1 - GMII               
      -- 2 - RGMII V1.3         
      -- 3 - RGMII V2.0         
      -- 4 - SGMII         
      -- 5 - 1000Base-X PCS/PMA 
      -- 6 - None (not used)
    C_TEMAC1_ENABLED            : integer range 0 to 1  := 0;
      -- 0 - EMAC 0 used but EMAC 1 not used
      -- 1 - EMAC 0 and EMAC 1 used
    C_TEMAC0_PHYADDR            : std_logic_vector(4 downto 0) := "00001";
    C_TEMAC1_PHYADDR            : std_logic_vector(4 downto 0) := "00010";
    C_TEMAC0_TXFIFO             : integer               := 4096; 
    C_TEMAC0_RXFIFO             : integer               := 4096; 
    C_TEMAC1_TXFIFO             : integer               := 4096; 
    C_TEMAC1_RXFIFO             : integer               := 4096; 
    C_TEMAC0_TXCSUM             : integer               := 0;
    C_TEMAC0_RXCSUM             : integer               := 0;
    C_TEMAC1_TXCSUM             : integer               := 0;
    C_TEMAC1_RXCSUM             : integer               := 0;
    C_TEMAC0_TXVLAN_TRAN        : integer               := 0;
    C_TEMAC0_RXVLAN_TRAN        : integer               := 0;
    C_TEMAC1_TXVLAN_TRAN        : integer               := 0;
    C_TEMAC1_RXVLAN_TRAN        : integer               := 0;
    C_TEMAC0_TXVLAN_TAG         : integer               := 0;
    C_TEMAC0_RXVLAN_TAG         : integer               := 0;
    C_TEMAC1_TXVLAN_TAG         : integer               := 0;
    C_TEMAC1_RXVLAN_TAG         : integer               := 0;
    C_TEMAC0_TXVLAN_STRP        : integer               := 0;
    C_TEMAC0_RXVLAN_STRP        : integer               := 0;
    C_TEMAC1_TXVLAN_STRP        : integer               := 0;
    C_TEMAC1_RXVLAN_STRP        : integer               := 0;
    C_TEMAC0_MCAST_EXTEND       : integer               := 0;
    C_TEMAC1_MCAST_EXTEND       : integer               := 0;
    C_TEMAC0_STATS              : integer               := 0;
    C_TEMAC1_STATS              : integer               := 0;
    C_TEMAC0_AVB                : integer               := 0;
    C_TEMAC1_AVB                : integer               := 0;
    C_SIMULATION                : integer               := 0
    );

  port (
    -- System signals ---------------------------------------------------------
    TemacIntc0_Irpt         : out std_logic;
    TemacIntc1_Irpt         : out std_logic;

    -- Ethernet System signals ------------------------------------------------
    TemacPhy_RST_n          : out std_logic;

    -- GTX_CLK 125 MHz clock frequency supplied by the user
    GTX_CLK_0               : in  std_logic;

    -- SGMII MGT Clock buffer inputs 
    MGTCLK_P                : in  std_logic;
    MGTCLK_N                : in  std_logic;

    -- Reference clock for RGMII IODELAYs Need to supply a 200MHz clock
    REFCLK                  : in  std_logic;

    -- Dynamic Reconfiguration Port Clock Must be between 25MHz - 50 MHz                 
    DCLK                    : in  std_logic;

    -- PLB signals ------------------------------------------------------------
    SPLB_Clk                : in std_logic;
    SPLB_Rst                : in std_logic;
    Core_Clk                : in std_logic;
    
    -- Bus Slave signals ------------------------------------------------------
    PLB_ABus                : in  std_logic_vector(0 to 31);
    PLB_UABus               : in  std_logic_vector(0 to 31);
    PLB_PAValid             : in  std_logic;
    PLB_SAValid             : in  std_logic;
    PLB_rdPrim              : in  std_logic;
    PLB_wrPrim              : in  std_logic;
    PLB_masterID            : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
    PLB_abort               : in  std_logic;    
    PLB_busLock             : in  std_logic;
    PLB_RNW                 : in  std_logic;
    PLB_BE                  : in  std_logic_vector(0 to (C_SPLB_DWIDTH/8)-1);
    PLB_MSize               : in  std_logic_vector(0 to 1);
    PLB_size                : in  std_logic_vector(0 to 3);
    PLB_type                : in  std_logic_vector(0 to 2);
    PLB_lockErr             : in  std_logic;
    PLB_wrDBus              : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);
    PLB_wrBurst             : in  std_logic;
    PLB_rdBurst             : in  std_logic;
    PLB_wrPendReq           : in  std_logic; 
    PLB_rdPendReq           : in  std_logic; 
    PLB_wrPendPri           : in  std_logic_vector(0 to 1); 
    PLB_rdPendPri           : in  std_logic_vector(0 to 1); 
    PLB_reqPri              : in  std_logic_vector(0 to 1);
    PLB_TAttribute          : in  std_logic_vector(0 to 15); 

    -- Slave Response Signals
    Sl_addrAck              : out std_logic;
    Sl_SSize                : out std_logic_vector(0 to 1);
    Sl_wait                 : out std_logic;
    Sl_rearbitrate          : out std_logic;
    Sl_wrDAck               : out std_logic;
    Sl_wrComp               : out std_logic;
    Sl_wrBTerm              : out std_logic;
    Sl_rdDBus               : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
    Sl_rdWdAddr             : out std_logic_vector(0 to 3);
    Sl_rdDAck               : out std_logic;
    Sl_rdComp               : out std_logic;
    Sl_rdBTerm              : out std_logic;
    Sl_MBusy                : out std_logic_vector (0 to C_SPLB_NUM_MASTERS-1);
    Sl_MWrErr               : out std_logic_vector (0 to C_SPLB_NUM_MASTERS-1);                     
    Sl_MRdErr               : out std_logic_vector (0 to C_SPLB_NUM_MASTERS-1);                     
    Sl_MIRQ                 : out std_logic_vector (0 to C_SPLB_NUM_MASTERS-1);                     

    -- LocalLink 0 signals ----------------------------------------------------
    LlinkTemac0_CLK         : in  std_logic;
    LlinkTemac0_RST         : in  std_logic;
    LlinkTemac0_SOP_n       : in  std_logic;
    LlinkTemac0_EOP_n       : in  std_logic;
    LlinkTemac0_SOF_n       : in  std_logic;
    LlinkTemac0_EOF_n       : in  std_logic;
    LlinkTemac0_REM         : in  std_logic_vector(0 to 3);
    LlinkTemac0_Data        : in  std_logic_vector(0 to 31);
    LlinkTemac0_SRC_RDY_n   : in  std_logic;
    Temac0Llink_DST_RDY_n   : out std_logic;
    Temac0Llink_SOF_n       : out std_logic;
    Temac0Llink_SOP_n       : out std_logic;
    Temac0Llink_Data        : out std_logic_vector(0 to 31);
    Temac0Llink_REM         : out std_logic_vector(0 to 3);
    Temac0Llink_EOP_n       : out std_logic;
    Temac0Llink_EOF_n       : out std_logic;
    Temac0Llink_SRC_RDY_n   : out std_logic;
    LlinkTemac0_DST_RDY_n   : in  std_logic;

    -- LocalLink 1 signals ----------------------------------------------------
    LlinkTemac1_CLK         : in  std_logic;
    LlinkTemac1_RST         : in  std_logic;
    LlinkTemac1_SOP_n       : in  std_logic;
    LlinkTemac1_EOP_n       : in  std_logic;
    LlinkTemac1_SOF_n       : in  std_logic;
    LlinkTemac1_EOF_n       : in  std_logic;
    LlinkTemac1_REM         : in  std_logic_vector(0 to 3);
    LlinkTemac1_Data        : in  std_logic_vector(0 to 31);
    LlinkTemac1_SRC_RDY_n   : in  std_logic;
    Temac1Llink_DST_RDY_n   : out std_logic;
    Temac1Llink_SOP_n       : out std_logic;
    Temac1Llink_EOP_n       : out std_logic;
    Temac1Llink_SOF_n       : out std_logic;
    Temac1Llink_EOF_n       : out std_logic;
    Temac1Llink_REM         : out std_logic_vector(0 to 3);
    Temac1Llink_Data        : out std_logic_vector(0 to 31);
    Temac1Llink_SRC_RDY_n   : out std_logic;
    LlinkTemac1_DST_RDY_n   : in  std_logic;

    -- MII 0 signals ----------------------------------------------------------
    MII_TXD_0               : out std_logic_vector(3 downto 0);
    MII_TX_EN_0             : out std_logic;
    MII_TX_ER_0             : out std_logic;
    MII_RXD_0               : in  std_logic_vector(3 downto 0);
    MII_RX_DV_0             : in  std_logic;
    MII_RX_ER_0             : in  std_logic;
    MII_RX_CLK_0            : in  std_logic;
    MII_TX_CLK_0            : in  std_logic;

    -- MII 1 signals ----------------------------------------------------------
    MII_TXD_1               : out std_logic_vector(3 downto 0);
    MII_TX_EN_1             : out std_logic;
    MII_TX_ER_1             : out std_logic;
    MII_RXD_1               : in  std_logic_vector(3 downto 0);
    MII_RX_DV_1             : in  std_logic;
    MII_RX_ER_1             : in  std_logic;
    MII_RX_CLK_1            : in  std_logic;
    MII_TX_CLK_1            : in  std_logic;

    -- GMII 0 signals ---------------------------------------------------------
    GMII_TXD_0              : out std_logic_vector(7 downto 0);
    GMII_TX_EN_0            : out std_logic;
    GMII_TX_ER_0            : out std_logic;
    GMII_TX_CLK_0           : out std_logic;
    GMII_RXD_0              : in  std_logic_vector(7 downto 0);
    GMII_RX_DV_0            : in  std_logic;
    GMII_RX_ER_0            : in  std_logic;
    GMII_RX_CLK_0           : in  std_logic;

    -- GMII 1 signals ---------------------------------------------------------
    GMII_TXD_1              : out std_logic_vector(7 downto 0);
    GMII_TX_EN_1            : out std_logic;
    GMII_TX_ER_1            : out std_logic;
    GMII_TX_CLK_1           : out std_logic;
    GMII_RXD_1              : in  std_logic_vector(7 downto 0);
    GMII_RX_DV_1            : in  std_logic;
    GMII_RX_ER_1            : in  std_logic;
    GMII_RX_CLK_1           : in  std_logic;

    -- SGMII & 1000BASE_X 0 signals -------------------------------------------
    TXP_0                   : out std_logic;
    TXN_0                   : out std_logic;
    RXP_0                   : in  std_logic;
    RXN_0                   : in  std_logic;

    -- SGMII & 1000BASE_X 1 signals -------------------------------------------
    TXP_1                   : out std_logic;
    TXN_1                   : out std_logic;
    RXP_1                   : in  std_logic;
    RXN_1                   : in  std_logic;

    -- RGMII 0 signals --------------------------------------------------------
    RGMII_TXD_0             : out std_logic_vector(3 downto 0);
    RGMII_TX_CTL_0          : out std_logic;
    RGMII_TXC_0             : out std_logic;
    RGMII_RXD_0             : in  std_logic_vector(3 downto 0);
    RGMII_RX_CTL_0          : in  std_logic;
    RGMII_RXC_0             : in  std_logic;
--    RGMII_IOB_0             : inout std_logic;

    -- RGMII 1 signals --------------------------------------------------------
    RGMII_TXD_1             : out std_logic_vector(3 downto 0);
    RGMII_TX_CTL_1          : out std_logic;
    RGMII_TXC_1             : out std_logic;
    RGMII_RXD_1             : in  std_logic_vector(3 downto 0);
    RGMII_RX_CTL_1          : in  std_logic;
    RGMII_RXC_1             : in  std_logic;
--    RGMII_IOB_1             : inout std_logic;

    -- MIIM 0 signals ---------------------------------------------------------
    MDC_0                   : out std_logic;
    MDIO_0_I                : in  std_logic;
    MDIO_0_O                : out std_logic;
    MDIO_0_T                : out std_logic;

    -- MIIM 1 signals ---------------------------------------------------------
    MDC_1                   : out std_logic;
    MDIO_1_I                : in  std_logic;
    MDIO_1_O                : out std_logic;
    MDIO_1_T                : out std_logic;
    
    -- Host Interface ---------------------------------------------------------
    HostMiimRdy             : in  std_logic;
    HostRdData              : in  std_logic_vector(31 downto 0);
    HostMiimSel             : out std_logic;
    HostReq                 : out std_logic;
    HostAddr                : out std_logic_vector(9  downto 0);
    HostEmac1Sel            : out std_logic;

    -- TEMAC 0 avb client clk signals -----------------------------------------
    Temac0AvbTxClk          : out std_logic;
    Temac0AvbTxClkEn        : out std_logic;
    Temac0AvbRxClk          : out std_logic;
    Temac0AvbRxClkEn        : out std_logic;
    
    -- TEMAC 0 avb 2 mac client signals -------------------------------------------
    Avb2Mac0TxData         : in  std_logic_vector(7 downto 0);
    Avb2Mac0TxDataValid    : in  std_logic;
    Avb2Mac0TxUnderrun     : in  std_logic;
    Mac02AvbTxAck          : out std_logic;
    Mac02AvbRxData         : out std_logic_vector(7 downto 0);
    Mac02AvbRxDataValid    : out std_logic;
    Mac02AvbRxFrameGood    : out std_logic;
    Mac02AvbRxFrameBad     : out std_logic;
    
    -- TEMAC 0 temac 2 avb client signals -------------------------------------------
    Temac02AvbTxData       : out std_logic_vector(7 downto 0);
    Temac02AvbTxDataValid  : out std_logic;
    Temac02AvbTxUnderrun   : out std_logic;
    Avb2Temac0TxAck        : in  std_logic;
    Avb2Temac0RxData       : in  std_logic_vector(7 downto 0);
    Avb2Temac0RxDataValid  : in  std_logic;
    Avb2Temac0RxFrameGood  : in  std_logic;
    Avb2Temac0RxFrameBad   : in  std_logic;

    -- TEMAC 1 avb client clk signals -----------------------------------------
    Temac1AvbTxClk          : out std_logic;
    Temac1AvbTxClkEn        : out std_logic;
    Temac1AvbRxClk          : out std_logic;
    Temac1AvbRxClkEn        : out std_logic;
    
    -- TEMAC 1 avb 2 mac client signals -------------------------------------------
    Avb2Mac1TxData         : in  std_logic_vector(7 downto 0);
    Avb2Mac1TxDataValid    : in  std_logic;
    Avb2Mac1TxUnderrun     : in  std_logic;
    Mac12AvbTxAck          : out std_logic;
    Mac12AvbRxData         : out std_logic_vector(7 downto 0);
    Mac12AvbRxDataValid    : out std_logic;
    Mac12AvbRxFrameGood    : out std_logic;
    Mac12AvbRxFrameBad     : out std_logic;
    
    -- TEMAC 1 temac 2 avb client signals -------------------------------------------
    Temac12AvbTxData       : out std_logic_vector(7 downto 0);
    Temac12AvbTxDataValid  : out std_logic;
    Temac12AvbTxUnderrun   : out std_logic;
    Avb2Temac1TxAck        : in  std_logic;
    Avb2Temac1RxData       : in  std_logic_vector(7 downto 0);
    Avb2Temac1RxDataValid  : in  std_logic;
    Avb2Temac1RxFrameGood  : in  std_logic;
    Avb2Temac1RxFrameBad   : in  std_logic;

    -- Statistics 0 signals ---------------------------------------------------
    TxClientClk_0           : out std_logic;
    ClientTxStat_0          : out std_logic;
    ClientTxStatsVld_0      : out std_logic;
    ClientTxStatsByteVld_0  : out std_logic;
    RxClientClk_0           : out std_logic;
    ClientRxStats_0         : out std_logic_vector(6 downto 0);
    ClientRxStatsVld_0      : out std_logic;
    ClientRxStatsByteVld_0  : out std_logic;

    -- Statistics 1 signals ---------------------------------------------------
    TxClientClk_1           : out std_logic;
    ClientTxStat_1          : out std_logic;
    ClientTxStatsVld_1      : out std_logic;
    ClientTxStatsByteVld_1  : out std_logic;
    RxClientClk_1           : out std_logic;
    ClientRxStats_1         : out std_logic_vector(6 downto 0);
    ClientRxStatsVld_1      : out std_logic;
    ClientRxStatsByteVld_1  : out std_logic

    );


    -----------------------------------------------------------------
    -- Start of PSFUtil MPD attributes              
    -----------------------------------------------------------------
    attribute IP_GROUP                            : string;
    attribute IP_GROUP     of xps_ll_temac        : entity   is "LOGICORE";

    attribute IPTYPE                              : string; 
    attribute IPTYPE       of xps_ll_temac        : entity   is "PERIPHERAL"; 
     
    attribute RUN_NGCBUILD                        : string;
    attribute RUN_NGCBUILD of xps_ll_temac        : entity   is "TRUE";

    attribute ALERT                               : string;
    attribute ALERT        of xps_ll_temac        : entity   is 
    "This design requires design constraints to guarantee performance. Please refer to the xps_ll_temac_v2_03_a data sheet for details.";
    
    -----------------------------------------------------------------
    -- End of PSFUtil MPD attributes              
    -----------------------------------------------------------------                           

   attribute X_CORE_INFO : string;
   attribute X_CORE_INFO of xps_ll_temac : entity is "xps_ll_temac_v2_03_a, EDK 11.2";

end xps_ll_temac;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture imp of xps_ll_temac is

-------------------------------------------------------------------------------
--  Function Declarations
-------------------------------------------------------------------------------


------------------------------------------------------------------------------
--  Constant Declarations
------------------------------------------------------------------------------
constant C_NUM_CS              : integer := 10;
constant C_NUM_CE              : integer := 41;
constant C_SOFT_SIMULATION     : boolean := (C_SIMULATION = 1);
constant C_TEMAC0_TXVLAN_WIDTH : integer := (C_TEMAC0_TXVLAN_TRAN*12) + C_TEMAC0_TXVLAN_TAG + C_TEMAC0_TXVLAN_STRP;
constant C_TEMAC0_RXVLAN_WIDTH : integer := (C_TEMAC0_RXVLAN_TRAN*12) + C_TEMAC0_RXVLAN_TAG + C_TEMAC0_RXVLAN_STRP;
constant C_TEMAC1_TXVLAN_WIDTH : integer := (C_TEMAC1_TXVLAN_TRAN*12) + C_TEMAC1_TXVLAN_TAG + C_TEMAC1_TXVLAN_STRP;
constant C_TEMAC1_RXVLAN_WIDTH : integer := (C_TEMAC1_RXVLAN_TRAN*12) + C_TEMAC1_RXVLAN_TAG + C_TEMAC1_RXVLAN_STRP;


constant C_ARD_ADDR_RANGE_ARRAY  : SLV64_ARRAY_TYPE :=
             -- Base address and high address pairs.
              (
                X"00000000" & (C_BASEADDR or X"00000000"), -- user0 base address
                X"00000000" & (C_BASEADDR or X"0007FFFF")  -- user0 high address
               );
                          
constant C_ARD_NUM_CE_ARRAY   : INTEGER_ARRAY_TYPE :=
            -- This array spcifies the number of Chip Enables (CE) that is 
            -- required by the cooresponding baseaddr pair.
              (
                0 =>1                   
              );
           
constant C_IPIF_DWIDTH        : integer :=  32;

------------------------------------------------------------------------------
-- Signal and Type Declarations
------------------------------------------------------------------------------
-- Signal names begin with a lowercase letter. User defined types and the
-- enumerated values with a type are all uppercase letters.
-- Signals of a user-defined type should be declared after the type declaration
-- Group signals by interfaces
------------------------------------------------------------------------------
signal intPlbClk       : std_logic;

signal bus2IP_CS       : std_logic_vector(0 to ((C_ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);   
signal bus2IP_RdCE     : std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);     
signal bus2IP_WrCE     : std_logic_vector(0 to calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);     
signal bus2IP_Addr     : std_logic_vector(0 to C_SPLB_AWIDTH-1);
signal bus2IP_Data     : std_logic_vector(0 to C_IPIF_DWIDTH-1);
Signal bus2IP_RNW      : std_logic;
signal bus2IP_Clk      : std_logic;
signal iP2Bus_Data     : std_logic_vector(0 to C_IPIF_DWIDTH-1);
signal iP2Bus_WrAck    : std_logic;
signal iP2Bus_RdAck    : std_logic;

signal bus2Shim_CS     : std_logic_vector(0 to 0);
signal bus2Shim_RdCE   : std_logic_vector(0 to 0);
signal bus2Shim_WrCE   : std_logic_vector(0 to 0);
signal bus2Shim_Addr   : std_logic_vector(0 to C_SPLB_AWIDTH - 1 );
signal bus2Shim_Data   : std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
signal bus2Shim_RNW    : std_logic;
signal shim2Bus_Data   : std_logic_vector (0 to C_IPIF_DWIDTH - 1 );
signal shim2Bus_WrAck  : std_logic;                                  
signal shim2Bus_RdAck  : std_logic;                                  

signal shim2IP_CS     : std_logic_vector(0 to C_NUM_CS);
signal shim2IP_RdCE   : std_logic_vector(0 to C_NUM_CE);
signal shim2IP_WrCE   : std_logic_vector(0 to C_NUM_CE);
signal shim2IP_Addr   : std_logic_vector(0 to C_SPLB_AWIDTH - 1 );
signal shim2IP_Data   : std_logic_vector(0 to C_IPIF_DWIDTH - 1 );
signal shim2IP_RNW    : std_logic;
signal IP2Shim_Data   : std_logic_vector (0 to C_IPIF_DWIDTH - 1 );
signal IP2Shim_WrAck  : std_logic;                                  
signal IP2Shim_RdAck  : std_logic;                                  

signal hRst            : std_logic;

signal dCR_CLK         : std_logic;
signal dCR_ABus        : std_logic_vector(0 to 9);
signal dCR_Read        : std_logic;
signal dCR_Write       : std_logic;
signal dCR_Ack         : std_logic;
signal temacDcr_DBus   : std_logic_vector(0 to 31);
signal dcrTemac_DBus   : std_logic_vector(0 to 31);

signal intrpts0        : std_logic_vector(24 to 31);
signal intrpts1        : std_logic_vector(24 to 31);
signal tPReq0          : std_logic;
signal tPReq1          : std_logic;
signal cr0RegData      : std_logic_vector(18 to 31);
signal cr1RegData      : std_logic_vector(18 to 31);
signal tp0RegData      : std_logic_vector(16 to 31);
signal tp1RegData      : std_logic_vector(16 to 31);
signal ifgp0RegData    : std_logic_vector(24 to 31);
signal ifgp1RegData    : std_logic_vector(24 to 31);
signal is0RegData      : std_logic_vector(24 to 31);
signal is1RegData      : std_logic_vector(24 to 31);
signal ip0RegData      : std_logic_vector(24 to 31);
signal ip1RegData      : std_logic_vector(24 to 31);
signal ie0RegData      : std_logic_vector(24 to 31);
signal ie1RegData      : std_logic_vector(24 to 31);
signal ttag0RegData    : std_logic_vector(0 to 31);
signal ttag1RegData    : std_logic_vector(0 to 31);
signal rtag0RegData    : std_logic_vector(0 to 31);
signal rtag1RegData    : std_logic_vector(0 to 31);
signal tpid00RegData   : std_logic_vector(0 to 31);
signal tpid10RegData   : std_logic_vector(0 to 31);
signal tpid01RegData   : std_logic_vector(0 to 31);
signal tpid11RegData   : std_logic_vector(0 to 31);
signal uawL0RegData    : std_logic_vector(0 to 31);
signal uawL1RegData    : std_logic_vector(0 to 31);
signal uawU0RegData    : std_logic_vector(16 to 31);
signal uawU1RegData    : std_logic_vector(16 to 31);

signal rxClClkMcastAddr0    : std_logic_vector(0 to 14);
signal rxClClkMcastEn0      : std_logic;
signal rxClClkMcastRdData0  : std_logic_vector(0 to 0);
signal rxClClkMcastAddr1    : std_logic_vector(0 to 14);
signal rxClClkMcastEn1      : std_logic;
signal rxClClkMcastRdData1  : std_logic_vector(0 to 0);

signal llink0ClkTxAddr      : std_logic_vector(0 to 11);
signal llink0ClkTxRdData    : std_logic_vector(18 to 31);
signal llink1ClkTxAddr      : std_logic_vector(0 to 11);
signal llink1ClkTxRdData    : std_logic_vector(18 to 31);
signal llink0ClkRxVlanAddr      : std_logic_vector(0 to 11);
signal llink0ClkRxVlanRdData    : std_logic_vector(18 to 31);
signal llink1ClkRxVlanAddr      : std_logic_vector(0 to 11);
signal llink1ClkRxVlanRdData    : std_logic_vector(18 to 31);

signal Llink0ClkTxVlanBramEnA : std_logic;
signal Llink1ClkTxVlanBramEnA : std_logic;
signal Llink0ClkRxVlanBramEnA : std_logic;
signal Llink1ClkRxVlanBramEnA : std_logic;

signal llink0ClkStatsReset  : std_logic;
signal llink0ClkEMultiFltrEnbl: std_logic;
signal llink0ClkNewFncEnbl  : std_logic;
signal llink0ClkRxVStrpMode : std_logic_vector(0 to 1);
signal llink0ClkTxVStrpMode : std_logic_vector(0 to 1);
signal llink0ClkRxVTagMode  : std_logic_vector(0 to 1);
signal llink0ClkTxVTagMode  : std_logic_vector(0 to 1);
signal llink1ClkStatsReset  : std_logic;
signal llink1ClkEMultiFltrEnbl: std_logic;
signal llink1ClkNewFncEnbl  : std_logic;
signal llink1ClkRxVStrpMode : std_logic_vector(0 to 1);
signal llink1ClkTxVStrpMode : std_logic_vector(0 to 1);
signal llink1ClkRxVTagMode  : std_logic_vector(0 to 1);
signal llink1ClkTxVTagMode  : std_logic_vector(0 to 1);

signal eMAC0CLIENTRXD_mac          : std_logic_vector(7 downto  0);
signal eMAC0CLIENTRXDVLD_mac       : std_logic;
signal eMAC0CLIENTRXGOODFRAME_mac  : std_logic;
signal eMAC0CLIENTRXBADFRAME_mac   : std_logic;
signal eMAC0CLIENTRXD_temac          : std_logic_vector(7 downto  0);
signal eMAC0CLIENTRXDVLD_temac       : std_logic;
signal eMAC0CLIENTRXGOODFRAME_temac  : std_logic;
signal eMAC0CLIENTRXBADFRAME_temac   : std_logic;
signal eMAC0CLIENTRXFRAMEDROP  : std_logic;
signal eMAC0CLIENTRXSTATS      : std_logic_vector(6  downto  0);
signal softEmac0ClientRxStats  : std_logic_vector(27 downto 0);
signal softEmac0ClientTxStats  : std_logic_vector(31 downto 0);
signal eMAC0CLIENTRXSTATSVLD   : std_logic;
signal eMAC0CLIENTRXSTATSBYTEVLD: std_logic;
signal clientTxStat_0_i        : std_logic;
signal clientTxStatsVld_0_i    : std_logic;
signal clientTxStatsByteVld_0_i: std_logic;

signal cLIENTEMAC0TXD_mac          : std_logic_vector(7 downto  0);
signal cLIENTEMAC0TXDVLD_mac       : std_logic;
signal eMAC0CLIENTTXACK_mac        : std_logic;
signal cLIENTEMAC0TXUNDERRUN_mac   : std_logic;
signal cLIENTEMAC0TXD_temac          : std_logic_vector(7 downto  0);
signal cLIENTEMAC0TXDVLD_temac       : std_logic;
signal eMAC0CLIENTTXACK_temac        : std_logic;
signal cLIENTEMAC0TXUNDERRUN_temac   : std_logic;
signal cLIENTEMAC0TXDVLDMSW    : std_logic;
signal cLIENTEMAC0TXFIRSTBYTE  : std_logic;
signal eMAC0CLIENTTXCOLLISION  : std_logic;
signal eMAC0CLIENTTXRETRANSMIT : std_logic;

signal eMAC1CLIENTRXD_mac          : std_logic_vector(7 downto  0);
signal eMAC1CLIENTRXDVLD_mac       : std_logic;
signal eMAC1CLIENTRXGOODFRAME_mac  : std_logic;
signal eMAC1CLIENTRXBADFRAME_mac   : std_logic;
signal eMAC1CLIENTRXD_temac          : std_logic_vector(7 downto  0);
signal eMAC1CLIENTRXDVLD_temac       : std_logic;
signal eMAC1CLIENTRXGOODFRAME_temac  : std_logic;
signal eMAC1CLIENTRXBADFRAME_temac   : std_logic;
signal eMAC1CLIENTRXFRAMEDROP  : std_logic;
signal eMAC1CLIENTRXSTATS      : std_logic_vector(6  downto  0);
signal softEmac1ClientRxStats  : std_logic_vector(27 downto 0);
signal softEmac1ClientTxStats  : std_logic_vector(31 downto 0);
signal eMAC1CLIENTRXSTATSVLD   : std_logic;
signal eMAC1CLIENTRXSTATSBYTEVLD: std_logic;
signal clientTxStat_1_i        : std_logic;
signal clientTxStatsVld_1_i    : std_logic;
signal clientTxStatsByteVld_1_i: std_logic;

signal cLIENTEMAC1TXD_mac          : std_logic_vector(7 downto  0);
signal cLIENTEMAC1TXDVLD_mac       : std_logic;
signal eMAC1CLIENTTXACK_mac        : std_logic;
signal cLIENTEMAC1TXUNDERRUN_mac   : std_logic;
signal cLIENTEMAC1TXD_temac          : std_logic_vector(7 downto  0);
signal cLIENTEMAC1TXDVLD_temac       : std_logic;
signal eMAC1CLIENTTXACK_temac        : std_logic;
signal cLIENTEMAC1TXUNDERRUN_temac   : std_logic;
signal cLIENTEMAC1TXDVLDMSW    : std_logic;
signal cLIENTEMAC1TXFIRSTBYTE  : std_logic;
signal eMAC1CLIENTTXCOLLISION  : std_logic;
signal eMAC1CLIENTTXRETRANSMIT : std_logic;
signal cLIENTEMAC1TXIFGDELAY   : std_logic_vector(7  downto  0);

signal cLIENTEMAC0PAUSEREQ     : std_logic;
signal cLIENTEMAC1PAUSEREQ     : std_logic;

signal rX_CLIENT_CLK_0         : std_logic;
signal tX_CLIENT_CLK_0         : std_logic;

signal rX_CLIENT_CLK_1         : std_logic;
signal tX_CLIENT_CLK_1         : std_logic;

signal dummy                   : std_logic_vector(31 downto  0);
signal RGMII_IOB_0             : std_logic;
signal RGMII_IOB_1             : std_logic;

signal llinkTemac0_SOP_n_i     : std_logic;
signal llinkTemac0_EOP_n_i     : std_logic;
signal llinkTemac0_SOF_n_i     : std_logic;
signal llinkTemac0_EOF_n_i     : std_logic;
signal llinkTemac0_REM_i       : std_logic_vector(0 to 3);
signal llinkTemac0_Data_i      : std_logic_vector(0 to 31);
signal llinkTemac0_SRC_RDY_n_i : std_logic;
signal temac0Llink_DST_RDY_n_i : std_logic;
signal temac0Llink_SOP_n_i     : std_logic;
signal temac0Llink_EOP_n_i     : std_logic;
signal temac0Llink_SOF_n_i     : std_logic;
signal temac0Llink_EOF_n_i     : std_logic;
signal temac0Llink_REM_i       : std_logic_vector(0 to 3);
signal temac0Llink_Data_i      : std_logic_vector(0 to 31);
signal temac0Llink_SRC_RDY_n_i : std_logic;
signal llinkTemac0_DST_RDY_n_i : std_logic;

signal llinkTemac1_SOP_n_i     : std_logic;
signal llinkTemac1_EOP_n_i     : std_logic;
signal llinkTemac1_SOF_n_i     : std_logic;
signal llinkTemac1_EOF_n_i     : std_logic;
signal llinkTemac1_REM_i       : std_logic_vector(0 to 3);
signal llinkTemac1_Data_i      : std_logic_vector(0 to 31);
signal llinkTemac1_SRC_RDY_n_i : std_logic;
signal temac1Llink_DST_RDY_n_i : std_logic;
signal temac1Llink_SOP_n_i     : std_logic;
signal temac1Llink_EOP_n_i     : std_logic;
signal temac1Llink_SOF_n_i     : std_logic;
signal temac1Llink_EOF_n_i     : std_logic;
signal temac1Llink_REM_i       : std_logic_vector(0 to 3);
signal temac1Llink_Data_i      : std_logic_vector(0 to 31);
signal temac1Llink_SRC_RDY_n_i : std_logic;
signal llinkTemac1_DST_RDY_n_i : std_logic;

signal sPLB_Rst_d1             : std_logic;
signal sPLB_Rst_d2             : std_logic;
signal sPLB_Rst_d3             : std_logic;
signal sPLB_Rst_d4             : std_logic;
signal sPLB_Rst_d5             : std_logic;
signal sPLB_Rst_d6             : std_logic;
signal sPLB_Rst_d7             : std_logic;
signal sPLB_Rst_d8             : std_logic;
signal sPLB_Rst_d9             : std_logic;
signal sPLB_Rst_d10            : std_logic;
signal sPLB_Rst_d11            : std_logic;

signal llinkTemac0_RST_d1      : std_logic;
signal llinkTemac0_RST_d2      : std_logic;
signal llinkTemac0_RST_d3      : std_logic;
signal llinkTemac0_RST_d4      : std_logic;

signal llinkTemac1_RST_d1      : std_logic;
signal llinkTemac1_RST_d2      : std_logic;
signal llinkTemac1_RST_d3      : std_logic;
signal llinkTemac1_RST_d4      : std_logic;

signal lLinkClkTemac0LlPlb_RST_i       : std_logic;
signal lLinkClkTemac1LlPlb_RST_i       : std_logic;

signal plbClkTemac0LlPlb_RST_i : std_logic; 
signal plbClkTemac1LlPlb_RST_i : std_logic; 

signal rxDcmLocked_0           : std_logic; 
signal rxDcmLocked_1           : std_logic; 

signal rxClientClkEnbl0        : std_logic;
signal txClientClkEnbl0        : std_logic;
signal rxClientClkEnbl1        : std_logic;
signal txClientClkEnbl1        : std_logic;

signal stat0Reset              : std_logic;
signal stat1Reset              : std_logic;

signal hostAddr0     	 : std_logic_vector(9 downto 0);
signal hostReq0       	 : std_logic;
signal hostMiiMSel0   	 : std_logic;
signal hostRdData0    	 : std_logic_vector(31 downto 0);
signal hostStatsLswRdy0	 : std_logic;
signal hostStatsMswRdy0	 : std_logic;
signal stat0_iP2Bus_RdAck: std_logic;
signal stat0_iP2Bus_Data : std_logic_vector(0 to 31);

signal reg_iP2Bus_RdAck  : std_logic;
signal reg_iP2Bus_Data   : std_logic_vector(0 to 31);

signal hostAddr1     	 : std_logic_vector(9 downto 0);
signal hostReq1       	 : std_logic;
signal hostMiiMSel1   	 : std_logic;
signal hostRdData1    	 : std_logic_vector(31 downto 0);
signal hostStatsLswRdy1	 : std_logic;
signal hostStatsMswRdy1	 : std_logic;
signal stat1_iP2Bus_RdAck: std_logic;
signal stat1_iP2Bus_Data : std_logic_vector(0 to 31);

signal plbTemacRstDetected0 : std_logic;
signal plbRstLL0Domain      : std_logic;
signal plbTemacRstDetected1 : std_logic;
signal plbRstLL1Domain      : std_logic;

signal lL0TemacRstDetected  : std_logic;
signal lL0RstPlbDomain      : std_logic;
signal lL1TemacRstDetected  : std_logic;
signal lL1RstPlbDomain      : std_logic;

constant C_EMAC0_DCRBASEADDR      : bit_vector(9 downto 0) := "0000000000";
constant C_EMAC1_DCRBASEADDR      : bit_vector(9 downto 0) := "0000000100";

signal EMAC0CLIENTRXDVLD_TOSTATS  : std_logic;
signal EMAC1CLIENTRXDVLD_TOSTATS  : std_logic;

-- begin change to accomidate Spartan 6 clock change for statistics
signal softTemacStatClk           : std_logic;
-- end change to accomidate Spartan 6 clock change for statistics

begin

  -- begin change to accomidate Spartan 6 clock change for statistics
  S6_design: if(equalIgnoringCase(C_FAMILY, "spartan6")= TRUE) generate
    softTemacStatClk <= GTX_CLK_0;
  end generate S6_design;

  not_S6_design: if(equalIgnoringCase(C_FAMILY, "spartan6")= FALSE) generate
    softTemacStatClk <= REFCLK;
  end generate not_S6_design;    
  -- end change to accomidate Spartan 6 clock change for statistics

  AVB0_PRESENT: if(C_TEMAC0_AVB = 1) generate
  begin
    -- TEMAC 0 avb client clk signals -----------------------------------------
    Temac0AvbTxClk          <= tX_CLIENT_CLK_0;
    Temac0AvbTxClkEn        <= txClientClkEnbl0;
    Temac0AvbRxClk          <= rX_CLIENT_CLK_0;
    Temac0AvbRxClkEn        <= rxClientClkEnbl0;    
    -- TEMAC 0 avb 2 mac client signals -------------------------------------------
    cLIENTEMAC0TXD_mac        <= Avb2Mac0TxData;
    cLIENTEMAC0TXDVLD_mac     <= Avb2Mac0TxDataValid;
    cLIENTEMAC0TXUNDERRUN_mac <= Avb2Mac0TxUnderrun;
    Mac02AvbTxAck           <= eMAC0CLIENTTXACK_mac;
    Mac02AvbRxData          <= eMAC0CLIENTRXD_mac;
    Mac02AvbRxDataValid     <= eMAC0CLIENTRXDVLD_mac;
    Mac02AvbRxFrameGood     <= eMAC0CLIENTRXGOODFRAME_mac;
    Mac02AvbRxFrameBad      <= eMAC0CLIENTRXBADFRAME_mac;    
    -- TEMAC 0 temac 2 avb client signals -------------------------------------------
    Temac02AvbTxData         <= cLIENTEMAC0TXD_temac;
    Temac02AvbTxDataValid    <= cLIENTEMAC0TXDVLD_temac;
    Temac02AvbTxUnderrun     <= cLIENTEMAC0TXUNDERRUN_temac;
    eMAC0CLIENTTXACK_temac       <= Avb2Temac0TxAck;
    eMAC0CLIENTRXD_temac         <= Avb2Temac0RxData;
    eMAC0CLIENTRXDVLD_temac      <= Avb2Temac0RxDataValid;
    eMAC0CLIENTRXGOODFRAME_temac <= Avb2Temac0RxFrameGood;
    eMAC0CLIENTRXBADFRAME_temac  <= Avb2Temac0RxFrameBad;
  end generate AVB0_PRESENT;

  AVB1_PRESENT: if(C_TEMAC1_AVB = 1 and C_TEMAC1_ENABLED = 1) generate
  begin

  end generate AVB1_PRESENT;

  AVB0_ABSENT: if(C_TEMAC0_AVB = 0) generate
  begin
    Temac0AvbTxClk           <= '0';
    Temac0AvbTxClkEn         <= '0';
    Temac0AvbRxClk           <= '0';
    Temac0AvbRxClkEn         <= '0';
    cLIENTEMAC0TXD_mac         <= cLIENTEMAC0TXD_temac;
    cLIENTEMAC0TXDVLD_mac      <= cLIENTEMAC0TXDVLD_temac;
    cLIENTEMAC0TXUNDERRUN_mac  <= cLIENTEMAC0TXUNDERRUN_temac;
    Mac02AvbTxAck            <= '0';
    Mac02AvbRxData           <= (others => '0');
    Mac02AvbRxDataValid      <= '0';
    Mac02AvbRxFrameGood      <= '0';
    Mac02AvbRxFrameBad       <= '0';    
    Temac02AvbTxData         <= (others => '0');
    Temac02AvbTxDataValid    <= '0';
    Temac02AvbTxUnderrun     <= '0';
    eMAC0CLIENTTXACK_temac       <= eMAC0CLIENTTXACK_mac;
    eMAC0CLIENTRXD_temac         <= eMAC0CLIENTRXD_mac;
    eMAC0CLIENTRXDVLD_temac      <= eMAC0CLIENTRXDVLD_mac;
    eMAC0CLIENTRXGOODFRAME_temac <= eMAC0CLIENTRXGOODFRAME_mac;
    eMAC0CLIENTRXBADFRAME_temac  <= eMAC0CLIENTRXBADFRAME_mac;
  end generate AVB0_ABSENT;

  AVB1_ABSENT: if(C_TEMAC1_AVB = 0 or C_TEMAC1_ENABLED = 0) generate
  begin
    Temac1AvbTxClk           <= '0';
    Temac1AvbTxClkEn         <= '0';
    Temac1AvbRxClk           <= '0';
    Temac1AvbRxClkEn         <= '0';
    cLIENTEMAC1TXD_mac         <= cLIENTEMAC1TXD_temac;
    cLIENTEMAC1TXDVLD_mac      <= cLIENTEMAC1TXDVLD_temac;
    cLIENTEMAC1TXUNDERRUN_mac  <= cLIENTEMAC1TXUNDERRUN_temac;
    Mac12AvbTxAck            <= '0';
    Mac12AvbRxData           <= (others => '0');
    Mac12AvbRxDataValid      <= '0';
    Mac12AvbRxFrameGood      <= '0';
    Mac12AvbRxFrameBad       <= '0';    
    Temac12AvbTxData         <= (others => '0');
    Temac12AvbTxDataValid    <= '0';
    Temac12AvbTxUnderrun     <= '0';
    eMAC1CLIENTTXACK_temac       <= eMAC1CLIENTTXACK_mac;
    eMAC1CLIENTRXD_temac         <= eMAC1CLIENTRXD_mac;
    eMAC1CLIENTRXDVLD_temac      <= eMAC1CLIENTRXDVLD_mac;
    eMAC1CLIENTRXGOODFRAME_temac <= eMAC1CLIENTRXGOODFRAME_mac;
    eMAC1CLIENTRXBADFRAME_temac  <= eMAC1CLIENTRXBADFRAME_mac;
  end generate AVB1_ABSENT;
  
  IP2Shim_Data  <= stat0_iP2Bus_Data or stat1_iP2Bus_Data or reg_iP2Bus_Data;
  IP2Shim_RdAck <= stat0_iP2Bus_RdAck or stat1_iP2Bus_RdAck or reg_iP2Bus_RdAck;
  
  llink0ClkStatsReset  <= Cr0RegData(18);
  llink0ClkEMultiFltrEnbl <= Cr0RegData(19);
  llink0ClkNewFncEnbl  <= Cr0RegData(20);
  llink0ClkRxVStrpMode <= Cr0RegData(21 to 22);
  llink0ClkTxVStrpMode <= Cr0RegData(23 to 24);
  llink0ClkRxVTagMode  <= Cr0RegData(25 to 26);
  llink0ClkTxVTagMode  <= Cr0RegData(27 to 28);
  llink1ClkStatsReset  <= Cr1RegData(18);
  llink1ClkEMultiFltrEnbl <= Cr1RegData(19);
  llink1ClkNewFncEnbl  <= Cr1RegData(20);
  llink1ClkRxVStrpMode <= Cr1RegData(21 to 22);
  llink1ClkTxVStrpMode <= Cr1RegData(23 to 24);
  llink1ClkRxVTagMode  <= Cr1RegData(25 to 26);
  llink1ClkTxVTagMode  <= Cr1RegData(27 to 28);

  hRst              <= cr0RegData(31)    or cr1RegData(31) or SPLB_Rst;
  stat0Reset        <= llink0ClkStatsReset;
  stat1Reset        <= llink1ClkStatsReset;

----------------------------------------------------------------------
-- Pipeline the PLB reset to allow TEMAC to come out first and stretch
---------------------------------------------------------------------- 

PLBRST_PIPE : process (intPlbClk)
begin
  if intPlbClk'event and intPlbClk = '1' then
    if SPLB_Rst = '1' then
      sPLB_Rst_d1 <= '1';
      sPLB_Rst_d2 <= '1';
      sPLB_Rst_d3 <= '1';
      sPLB_Rst_d4 <= '1';
      sPLB_Rst_d5 <= '1';
      sPLB_Rst_d6 <= '1';
      sPLB_Rst_d7 <= '1';
      sPLB_Rst_d8 <= '1';
      sPLB_Rst_d9 <= '1';
      sPLB_Rst_d10<= '1';
      sPLB_Rst_d11<= '1';
    else
      sPLB_Rst_d1 <= SPLB_Rst;    
      sPLB_Rst_d2 <= sPLB_Rst_d1;    
      sPLB_Rst_d3 <= sPLB_Rst_d2;    
      sPLB_Rst_d4 <= sPLB_Rst_d3;    
      sPLB_Rst_d5 <= sPLB_Rst_d4;     
      sPLB_Rst_d6 <= sPLB_Rst_d5;     
      sPLB_Rst_d7 <= sPLB_Rst_d6;
      sPLB_Rst_d8 <= sPLB_Rst_d7;
      sPLB_Rst_d9 <= sPLB_Rst_d8;
      sPLB_Rst_d10 <= sPLB_Rst_d9;
      sPLB_Rst_d11 <= sPLB_Rst_d10 or sPLB_Rst_d9 or sPLB_Rst_d8 or sPLB_Rst_d7;
    end if;
  end if;
end process PLBRST_PIPE;

----------------------------------------------------------------------
-- Pipeline the locallink reset to stretch it
---------------------------------------------------------------------- 

LL0RST_PIPE : process (LlinkTemac0_CLK)
begin
  if LlinkTemac0_CLK'event and LlinkTemac0_CLK = '1' then
    if LlinkTemac0_RST = '1' then
      llinkTemac0_RST_d1 <= '1';
      llinkTemac0_RST_d2 <= '1';
      llinkTemac0_RST_d3 <= '1';
      llinkTemac0_RST_d4 <= '1';
    else
      llinkTemac0_RST_d1 <= LlinkTemac0_RST;    
      llinkTemac0_RST_d2 <= llinkTemac0_RST_d1;    
      llinkTemac0_RST_d3 <= llinkTemac0_RST_d2;    
      llinkTemac0_RST_d4 <= llinkTemac0_RST_d3 or llinkTemac0_RST_d2 or llinkTemac0_RST_d1 or LlinkTemac0_RST;    
    end if;
  end if;
end process LL0RST_PIPE;

LL1RST_PIPE : process (LlinkTemac1_CLK)
begin
  if LlinkTemac1_CLK'event and LlinkTemac1_CLK = '1' then
    if LlinkTemac1_RST = '1' then
      llinkTemac1_RST_d1 <= '1';
      llinkTemac1_RST_d2 <= '1';
      llinkTemac1_RST_d3 <= '1';
      llinkTemac1_RST_d4 <= '1';
    else
      llinkTemac1_RST_d1 <= LlinkTemac1_RST;    
      llinkTemac1_RST_d2 <= llinkTemac1_RST_d1;    
      llinkTemac1_RST_d3 <= llinkTemac1_RST_d2;    
      llinkTemac1_RST_d4 <= llinkTemac1_RST_d3 or llinkTemac1_RST_d2 or llinkTemac1_RST_d1 or LlinkTemac1_RST;    
    end if;
  end if;
end process LL1RST_PIPE;
  
  -------------------------------------------------------------------------
  -- Detect the PLB Reset and hold it for the LocalLink clock domain to 
  -- detect it.  After the LocalLink domain detects the reset, clear the 
  -- detect signal
  -------------------------------------------------------------------------
  DETECT_PLB_RESET0 : process(intPlbClk)
  begin 
     if rising_edge(intPlbClk) then
        if sPLB_Rst_d11 = '1' then
           plbTemacRstDetected0 <= '1';
        elsif plbRstLL0Domain = '1' then
           plbTemacRstDetected0 <= '0';  
        else
           plbTemacRstDetected0 <= plbTemacRstDetected0;
        end if;
     end if;
  end process;
  DETECT_PLB_RESET1 : process(intPlbClk)
  begin  
     if rising_edge(intPlbClk) then
        if sPLB_Rst_d11 = '1' then
           plbTemacRstDetected1 <= '1';
        elsif plbRstLL1Domain = '1' then
           plbTemacRstDetected1 <= '0';  
        else
           plbTemacRstDetected1 <= plbTemacRstDetected1;
        end if;
     end if;
  end process;
  -------------------------------------------------------------------------
  -- The reset has been detected, so pulse the reset for one clock in the 
  -- LocalLink domain.  Use plbRstLlDomain to combine with LocalLink RST
  -- to reset all synchronous logic the in the LocalLink domain.
  -------------------------------------------------------------------------
  SET_LL0_RESET : process(LlinkTemac0_CLK)
  begin  
     if rising_edge(LlinkTemac0_CLK) then
        if plbTemacRstDetected0 = '1' then
           plbRstLL0Domain <= '1';
        else
           plbRstLL0Domain <= '0';
        end if;
     end if;
  end process;  
  SET_LL1_RESET : process(LlinkTemac0_CLK)
  begin  
     if rising_edge(LlinkTemac1_CLK) then
        if plbTemacRstDetected1 = '1' then
           plbRstLL1Domain <= '1';
        else
           plbRstLL1Domain <= '0';
        end if;
     end if;
  end process;  

lLinkClkTemac0LlPlb_RST_i <= plbRstLL0Domain or llinkTemac0_RST_d4;
lLinkClkTemac1LlPlb_RST_i <= plbRstLL1Domain or llinkTemac1_RST_d4;
  
  -------------------------------------------------------------------------
  -- Detect the LocalLink Reset and hold it for the PLB clock domain to 
  -- detect it.  After the PLB domain detects the reset, clear the 
  -- detect signal
  -------------------------------------------------------------------------
  DETECT_LL_RESET0 : process(LlinkTemac0_CLK)
  begin 
     if rising_edge(LlinkTemac0_CLK) then
        if llinkTemac0_RST_d4 = '1' then
           lL0TemacRstDetected <= '1';
        elsif lL0RstPlbDomain = '1' then
           lL0TemacRstDetected <= '0';  
        else
           lL0TemacRstDetected <= lL0TemacRstDetected;
        end if;
     end if;
  end process;
  DETECT_LL_RESET1 : process(LlinkTemac1_CLK)
  begin  
     if rising_edge(LlinkTemac1_CLK) then
        if llinkTemac1_RST_d4 = '1' then
           lL1TemacRstDetected <= '1';
        elsif lL1RstPlbDomain = '1' then
           lL1TemacRstDetected <= '0';  
        else
           lL1TemacRstDetected <= lL1TemacRstDetected;
        end if;
     end if;
  end process;
  -------------------------------------------------------------------------
  -- The reset has been detected, so pulse the reset for one clock in the 
  -- PLB domain.  Use lL0RstPlbDomain to combine with PLB RST
  -- to reset all synchronous logic the in the PLB domain.
  -------------------------------------------------------------------------
  SET_PLB0_RESET : process(intPlbClk)
  begin  
     if rising_edge(intPlbClk) then
        if lL0TemacRstDetected = '1' then
           lL0RstPlbDomain <= '1';
        else
           lL0RstPlbDomain <= '0';
        end if;
     end if;
  end process;  
  SET_PLB1_RESET : process(intPlbClk)
  begin  
     if rising_edge(intPlbClk) then
        if lL1TemacRstDetected = '1' then
           lL1RstPlbDomain <= '1';
        else
           lL1RstPlbDomain <= '0';
        end if;
     end if;
  end process;  

plbClkTemac0LlPlb_RST_i <= lL0RstPlbDomain or sPLB_Rst_d11;
plbClkTEMAC1LlPlb_RST_i <= lL1RstPlbDomain or sPLB_Rst_d11;

TemacPhy_RST_n <= not(SPLB_Rst);

REDUCED_PLB_CLK: if(C_BUS2CORE_CLK_RATIO = 2) generate
begin
intPlbClk <= Core_Clk;
end generate REDUCED_PLB_CLK;

PLB_CLK: if(C_BUS2CORE_CLK_RATIO = 1) generate
begin
intPlbClk <= bus2IP_Clk;
end generate PLB_CLK;

----------------------------------------------------------------------
-- Register LocalLink bus signals
---------------------------------------------------------------------- 

REG_LLT0 : process (LlinkTemac0_CLK)
begin
  if LlinkTemac0_CLK'event and LlinkTemac0_CLK = '1' then
    if lLinkClkTemac0LlPlb_RST_i = '1' then
      llinkTemac0_SOP_n_i     <= '1';
      llinkTemac0_EOP_n_i     <= '1';
      llinkTemac0_SOF_n_i     <= '1';
      llinkTemac0_EOF_n_i     <= '1';
      llinkTemac0_REM_i       <= (others => '0');
      llinkTemac0_Data_i      <= (others => '0');
      llinkTemac0_SRC_RDY_n_i <= '1';
    else
      if (temac0Llink_DST_RDY_n_i = '0') then
        llinkTemac0_SOP_n_i     <= LlinkTemac0_SOP_n;    
        llinkTemac0_EOP_n_i     <= LlinkTemac0_EOP_n;    
        llinkTemac0_SOF_n_i     <= LlinkTemac0_SOF_n;    
        llinkTemac0_EOF_n_i     <= LlinkTemac0_EOF_n;    
        llinkTemac0_REM_i       <= LlinkTemac0_REM;      
        llinkTemac0_Data_i      <= LlinkTemac0_Data;     
        llinkTemac0_SRC_RDY_n_i <= LlinkTemac0_SRC_RDY_n;
      end if;
    end if;
  end if;
end process REG_LLT0;

  Temac0Llink_SOP_n       <= temac0Llink_SOP_n_i;      
  Temac0Llink_EOP_n       <= temac0Llink_EOP_n_i;      
  Temac0Llink_SOF_n       <= temac0Llink_SOF_n_i;      
  Temac0Llink_EOF_n       <= temac0Llink_EOF_n_i;      
  Temac0Llink_REM         <= temac0Llink_REM_i;        
  Temac0Llink_Data        <= temac0Llink_Data_i;       
  Temac0Llink_SRC_RDY_n   <= temac0Llink_SRC_RDY_n_i;  
  Temac0Llink_DST_RDY_n   <= temac0Llink_DST_RDY_n_i;  
  
  llinkTemac0_DST_RDY_n_i <= LlinkTemac0_DST_RDY_n;

------------------------------------------------------------------------------
-- Concurrent Signal Assignments
------------------------------------------------------------------------------

TxClientClk_0          <= tX_CLIENT_CLK_0;
RxClientClk_0          <= rX_CLIENT_CLK_0;
ClientRxStats_0        <= eMAC0CLIENTRXSTATS;
ClientRxStatsVld_0     <= eMAC0CLIENTRXSTATSVLD;
ClientRxStatsByteVld_0 <= eMAC0CLIENTRXSTATSBYTEVLD;
ClientTxStat_0         <= clientTxStat_0_i;
ClientTxStatsVld_0     <= clientTxStatsVld_0_i;
ClientTxStatsByteVld_0 <= clientTxStatsByteVld_0_i;

TxClientClk_1          <= tX_CLIENT_CLK_1;
RxClientClk_1          <= rX_CLIENT_CLK_1;
ClientRxStats_1        <= eMAC1CLIENTRXSTATS;
ClientRxStatsVld_1     <= eMAC1CLIENTRXSTATSVLD;
ClientRxStatsByteVld_1 <= eMAC1CLIENTRXSTATSBYTEVLD;
ClientTxStat_1         <= clientTxStat_1_i;
ClientTxStatsVld_1     <= clientTxStatsVld_1_i;
ClientTxStatsByteVld_1 <= clientTxStatsByteVld_1_i;

------------------------------------------------------------------------------
-- Component Instantiations
------------------------------------------------------------------------------

I_REGISTERS : entity xps_ll_temac_v2_03_a.registers(imp)
    generic map (
                 C_FAMILY              => C_FAMILY,
                 C_TEMAC1_ENABLED      => C_TEMAC1_ENABLED,
                 C_TEMAC0_TXVLAN_TRAN  => C_TEMAC0_TXVLAN_TRAN,
                 C_TEMAC0_TXVLAN_TAG   => C_TEMAC0_TXVLAN_TAG, 
                 C_TEMAC0_TXVLAN_STRP  => C_TEMAC0_TXVLAN_STRP,
                 C_TEMAC0_STATS        => C_TEMAC0_STATS,    
                 C_TEMAC1_TXVLAN_TRAN  => C_TEMAC1_TXVLAN_TRAN,
                 C_TEMAC1_TXVLAN_TAG   => C_TEMAC1_TXVLAN_TAG, 
                 C_TEMAC1_TXVLAN_STRP  => C_TEMAC1_TXVLAN_STRP,
                 C_TEMAC1_STATS        => C_TEMAC1_STATS,    
                 C_TEMAC0_RXVLAN_TRAN  => C_TEMAC0_RXVLAN_TRAN, 
                 C_TEMAC0_RXVLAN_TAG   => C_TEMAC0_RXVLAN_TAG,  
                 C_TEMAC0_RXVLAN_STRP  => C_TEMAC0_RXVLAN_STRP, 
                 C_TEMAC0_MCAST_EXTEND => C_TEMAC0_MCAST_EXTEND,
                 C_TEMAC1_RXVLAN_TRAN  => C_TEMAC1_RXVLAN_TRAN, 
                 C_TEMAC1_RXVLAN_TAG   => C_TEMAC1_RXVLAN_TAG,  
                 C_TEMAC1_RXVLAN_STRP  => C_TEMAC1_RXVLAN_STRP, 
                 C_TEMAC1_MCAST_EXTEND => C_TEMAC1_MCAST_EXTEND,
                 C_TEMAC0_TXVLAN_WIDTH => C_TEMAC0_TXVLAN_WIDTH,
                 C_TEMAC0_RXVLAN_WIDTH => C_TEMAC0_RXVLAN_WIDTH,
                 C_TEMAC1_TXVLAN_WIDTH => C_TEMAC1_TXVLAN_WIDTH,
                 C_TEMAC1_RXVLAN_WIDTH => C_TEMAC1_RXVLAN_WIDTH
                )
    port map    (
                 DCR_Clk      => dCR_Clk,        -- out to temac  
                 DCR_Read     => dCR_Read,       -- out to temac
                 DCR_Write    => dCR_Write,      -- out to temac
                 DCR_Ack      => dCR_Ack,        -- in  from temac
                 DCR_ABus     => dCR_ABus,       -- out to temac 
                 DCRTemac_DBus=> dcrTemac_DBus,  -- out to temac
                 TemacDcr_DBus=> temacDcr_DBus,  -- in  from temac
                 PlbClk       => intPlbClk,      -- in
                              
                 -- reference clock for the statistics core
                 -- begin change to accomidate Spartan 6 clock change for statistics
                 -- Ref_clk      => REFCLK,
                 Ref_clk      => softTemacStatClk,--REFCLK,         --: in 
                 -- end change to accomidate Spartan 6 clock change for statistics
                 Host_clk     => intPlbClk,      --: in 
                 txClClk      => tX_CLIENT_CLK_0,--: in 
                 rxClClk      => rX_CLIENT_CLK_0,--: in 
                 
                 RawReset     => sPLB_Rst_d11,    -- in  from top level system
                 IP2Bus_Data  => reg_iP2Bus_Data,    -- out to shim
                 IP2Bus_WrAck => IP2Shim_WrAck,   -- out to shim
                 IP2Bus_RdAck => reg_iP2Bus_RdAck,   -- out to sshim                               
                 Bus2IP_Addr  => shim2IP_Addr,   -- in  from shim                                
                 Bus2IP_Data  => shim2IP_Data,   -- in  from shim                                 
                 Bus2IP_RNW   => shim2IP_RNW ,   -- in  from shim                                 
                 Bus2IP_CS    => shim2IP_CS  ,   -- in  from shim                       
                 Bus2IP_RdCE  => shim2IP_RdCE,   -- in  from shim                        
                 Bus2IP_WrCE  => shim2IP_WrCE,   -- in  from shim
                 Intrpts0     => intrpts0,       -- in  
                 Intrpts1     => intrpts1,       -- in  
                 TPReq0       => tPReq0,         -- out 
                 TPReq1       => tPReq1,         -- out 
                 Cr0RegData   => cr0RegData,     -- out 
                 Cr1RegData   => cr1RegData,     -- out 
                 Tp0RegData   => tp0RegData,     -- out 
                 Tp1RegData   => tp1RegData,     -- out 
                 Ifgp0RegData => ifgp0RegData,   -- out 
                 Ifgp1RegData => ifgp1RegData,   -- out 
                 Is0RegData   => is0RegData,     -- out 
                 Is1RegData   => is1RegData,     -- out 
                 Ip0RegData   => ip0RegData,     -- out 
                 Ip1RegData   => ip1RegData,     -- out 
                 Ie0RegData   => ie0RegData,     -- out 
                 Ie1RegData   => ie1RegData,     -- out 
                 Intrpt0      => TemacIntc0_Irpt,-- out 
                 Intrpt1      => TemacIntc1_Irpt,-- out 
                 Ttag0RegData => ttag0RegData,   -- out
                 Ttag1RegData => ttag1RegData,   -- out
                 Rtag0RegData => rtag0RegData,   -- out
                 Rtag1RegData => rtag1RegData,   -- out
                 Tpid00RegData=> tpid00RegData,  -- out
                 Tpid10RegData=> tpid10RegData,  -- out
                 Tpid01RegData=> tpid01RegData,  -- out
                 Tpid11RegData=> tpid11RegData,  -- out
                 UawL0RegData => uawL0RegData,   -- out
                 UawL1RegData => uawL1RegData,   -- out
                 UawU0RegData => uawU0RegData,   -- out
                 UawU1RegData => uawU1RegData,   -- out
                 RxClClk0           => rX_CLIENT_CLK_0,    -- in
                 RxClClkMcastAddr0  => rxClClkMcastAddr0,  -- in
                 RxClClkMcastEn0    => rxClClkMcastEn0,    -- in
                 RxClClkMcastRdData0=> rxClClkMcastRdData0,-- out
                 RxClClk1           => rX_CLIENT_CLK_1,    -- in
                 RxClClkMcastAddr1  => rxClClkMcastAddr1,  -- in
                 RxClClkMcastEn1    => rxClClkMcastEn1,    -- in
                 RxClClkMcastRdData1=> rxClClkMcastRdData1,-- out
                 Llink0_CLK         => LlinkTemac0_CLK,    -- in
                 Llink1_CLK         => LlinkTemac1_CLK,    -- in
                 Llink0ClkTxAddr    => llink0ClkTxAddr,    -- in
                 Llink0ClkTxRdData  => llink0ClkTxRdData,  -- out
                 Llink1ClkTxAddr    => llink1ClkTxAddr,    -- in
                 Llink1ClkTxRdData  => llink1ClkTxRdData,  -- out
                 Llink0ClkRxVlanAddr    => llink0ClkRxVlanAddr,    -- in
                 Llink0ClkRxVlanRdData  => llink0ClkRxVlanRdData,  -- out
                 Llink1ClkRxVlanAddr    => llink1ClkRxVlanAddr,    -- in
                 Llink1ClkRxVlanRdData  => llink1ClkRxVlanRdData,   -- out
                 Llink0ClkTxVlanBramEnA => llink0ClkTxVlanBramEnA,-- in
                 Llink1ClkTxVlanBramEnA => llink1ClkTxVlanBramEnA,-- in
                 Llink0ClkRxVlanBramEnA => llink0ClkRxVlanBramEnA,-- in
                 Llink1ClkRxVlanBramEnA => llink1ClkRxVlanBramEnA -- in
                );

 I_TX0 : entity xps_ll_temac_v2_03_a.tx_llink_top(beh)
   generic map (
     C_FAMILY            => C_FAMILY,
     C_TEMAC_TXCSUM      => C_TEMAC0_TXCSUM,
     C_TEMAC_TXFIFO      => C_TEMAC0_TXFIFO,
     C_TEMAC_TYPE        => C_TEMAC_TYPE,
     C_TEMAC_TXVLAN_TRAN => C_TEMAC0_TXVLAN_TRAN,
     C_TEMAC_TXVLAN_TAG  => C_TEMAC0_TXVLAN_TAG, 
     C_TEMAC_TXVLAN_STRP => C_TEMAC0_TXVLAN_STRP,
     C_TEMAC_STATS       => C_TEMAC0_STATS    
   )			 
   port map (			 
     LLTemac_Clk             =>  LlinkTemac0_CLK,        -- in  
     LLTemac_Rst             =>  lLinkClkTemac0LlPlb_RST_i,        -- in  
     LLTemac_Data            =>  llinkTemac0_Data_i,       -- in  
     LLTemac_SOF_n           =>  llinkTemac0_SOF_n_i,      -- in  
     LLTemac_SOP_n           =>  llinkTemac0_SOP_n_i,      -- in  
     LLTemac_EOF_n           =>  llinkTemac0_EOF_n_i,      -- in  
     LLTemac_EOP_n           =>  llinkTemac0_EOP_n_i,      -- in  
     LLTemac_SRC_RDY_n       =>  llinkTemac0_SRC_RDY_n_i,  -- in  
     LLTemac_REM             =>  llinkTemac0_REM_i,        -- in  
     LLTemac_DST_RDY_n       =>  temac0Llink_DST_RDY_n_i,  -- out 
     TXFIFO_Und_Intr         =>  open,                   -- out 
     Tx2ClientPauseReq       =>  tPReq0,                 -- in  
     ClientEmacPauseReq      =>  cLIENTEMAC0PAUSEREQ,    -- out 
     Tx_cmplt                =>  intrpts0(26),           -- out 
     Tx_Cl_Clk               =>  tX_CLIENT_CLK_0,        -- in  
     ClientEmacTxd           =>  cLIENTEMAC0TXD_temac,         -- out 
     ClientEmacTxdVld        =>  cLIENTEMAC0TXDVLD_temac,      -- out 
     ClientEmacTxdVldMsw     =>  cLIENTEMAC0TXDVLDMSW,   -- out 
     ClientEmacTxFirstByte   =>  cLIENTEMAC0TXFIRSTBYTE, -- out 
     ClientEmacTxUnderRun    =>  cLIENTEMAC0TXUNDERRUN_temac,  -- out 
     EmacClientTxAck         =>  eMAC0CLIENTTXACK_temac,       -- in  
     EmacClientTxCollision   =>  eMAC0CLIENTTXCOLLISION, -- in  
     EmacClientTxRetransmit  =>  eMAC0CLIENTTXRETRANSMIT,-- in  
     EmacClientTxCE          =>  txClientClkEnbl0,
     Tx2ClientUnderRunIntrpt =>  open,                   -- out
     TtagRegData             =>  ttag0RegData,           -- in
     Tpid0RegData            =>  tpid00RegData,          -- in
     Tpid1RegData            =>  tpid01RegData,          -- in
     LlinkClkAddr            =>  llink0ClkTxAddr,  	 -- out
     LlinkClkRdData          =>  llink0ClkTxRdData,	 -- in
     LlinkClkTxVlanBramEnA   =>  llink0ClkTxVlanBramEnA, -- out
     LlinkClkNewFncEnbl      =>  llink0ClkNewFncEnbl,    -- in
     LlinkClkTxVStrpMode     =>  llink0ClkTxVStrpMode,   -- in
     LlinkClkTxVTagMode      =>  llink0ClkTxVTagMode     -- in
   );			  
     					  
 I_RX0 : entity xps_ll_temac_v2_03_a.rx_top(beh)
   generic map (
     C_FAMILY             => C_FAMILY,
     C_TEMAC_TYPE         => C_TEMAC_TYPE,
     C_TEMAC_RXCSUM       => C_TEMAC0_RXCSUM,
     C_TEMAC_RXFIFO       => C_TEMAC0_RXFIFO, 
     C_TEMAC_RXVLAN_TRAN  => C_TEMAC0_RXVLAN_TRAN, 
     C_TEMAC_RXVLAN_TAG   => C_TEMAC0_RXVLAN_TAG,  
     C_TEMAC_RXVLAN_STRP  => C_TEMAC0_RXVLAN_STRP, 
     C_TEMAC_MCAST_EXTEND => C_TEMAC0_MCAST_EXTEND,
     C_TEMAC_STATS        => C_TEMAC0_STATS,
     C_TEMAC_RXVLAN_WIDTH => C_TEMAC0_RXVLAN_WIDTH
     )			 
   port map (			 
     Plb_Clk                 =>  intPlbClk,               -- in  
     Plb_Rst                 =>  plbClkTemac0LlPlb_RST_i,       -- in  
     LLTemac_Clk             =>  LlinkTemac0_CLK,         -- in  
     LLTemac_Rst             =>  lLinkClkTemac0LlPlb_RST_i,       -- in  
     TemacLL_SOF_n           =>  temac0Llink_SOF_n_i,     -- out 
     TemacLL_SOP_n           =>  temac0Llink_SOP_n_i,     -- out 
     TemacLL_EOF_n           =>  temac0Llink_EOF_n_i,     -- out 
     TemacLL_EOP_n           =>  temac0Llink_EOP_n_i,     -- out 
     TemacLL_SRC_RDY_n       =>  temac0Llink_SRC_RDY_n_i, -- out 
     TemacLL_DST_RDY_n       =>  llinkTemac0_DST_RDY_n_i, -- in  
     TemacLL_REM             =>  temac0Llink_REM_i,       -- out 
     TemacLL_Data            =>  temac0Llink_Data_i,      -- out 
     RegCR_BrdCast_Rej       =>  cr0RegData(29),          -- in  
     RegCR_MulCast_Rej       =>  cr0RegData(30),          -- in  
     Rx_pckt_rej             =>  intrpts0(28),            -- out 
     Rx_cmplt                =>  intrpts0(29),            -- out 
     Pckt_Ovr_Run            =>  intrpts0(27),            -- out 
     RxClClkEn               =>  rxClientClkEnbl0,        -- in  
     Rx_Cl_Clk               =>  rX_CLIENT_CLK_0,         -- in  
     EmacClientRxBadFrame    =>  eMAC0CLIENTRXBADFRAME_temac,   -- in  
     EmacClientRxd           =>  eMAC0CLIENTRXD_temac,          -- in  
     EmacClientRxdVld        =>  eMAC0CLIENTRXDVLD_temac,       -- in  
     EmacClientRxFrameDrop   =>  eMAC0CLIENTRXFRAMEDROP,  -- in  
     EmacClientRxGoodFrame   =>  eMAC0CLIENTRXGOODFRAME_temac,  -- in  
     EmacClientRxStats       =>  eMAC0CLIENTRXSTATS,      -- in  
     SoftEmacClientRxStats   =>  softEmac0ClientRxStats,  -- in
     EmacClientRxStatsVld    =>  eMAC0CLIENTRXSTATSVLD,   -- in  
     RtagRegData             =>  rtag0RegData,            -- in
     Tpid0RegData            =>  tpid00RegData,           -- in
     Tpid1RegData            =>  tpid01RegData,           -- in
     UawLRegData             =>  UawL0RegData,            -- in
     UawURegData             =>  UawU0RegData,            -- in
     RxClClkMcastAddr        =>  rxClClkMcastAddr0,       -- out
     RxClClkMcastEn          =>  rxClClkMcastEn0,         -- out
     RxClClkMcastRdData      =>  rxClClkMcastRdData0,     -- in
     LlinkClkVlanAddr        =>  llink0ClkRxVlanAddr,  	  -- out
     LlinkClkVlanRdData      =>  llink0ClkRxVlanRdData,	  -- in
     LlinkClkRxVlanBramEnA   =>  llink0ClkRxVlanBramEnA,  -- out
     LlinkClkEMultiFltrEnbl  =>  llink0ClkEMultiFltrEnbl, -- in
     LlinkClkNewFncEnbl      =>  llink0ClkNewFncEnbl,     -- in
     LlinkClkRxVStrpMode     =>  llink0ClkRxVStrpMode,    -- in
     LlinkClkRxVTagMode      =>  llink0ClkRxVTagMode      -- in
   );			  

DUAL_SYS: if(C_TEMAC1_ENABLED = 1) generate
begin

----------------------------------------------------------------------
-- Register LocalLink bus signals
---------------------------------------------------------------------- 

REG_LLT1 : process (LlinkTemac1_CLK)
begin
  if LlinkTemac1_CLK'event and LlinkTemac1_CLK = '1' then
    if lLinkClkTemac1LlPlb_RST_i = '1' then
      llinkTemac1_SOP_n_i     <= '1';
      llinkTemac1_EOP_n_i     <= '1';
      llinkTemac1_SOF_n_i     <= '1';
      llinkTemac1_EOF_n_i     <= '1';
      llinkTemac1_REM_i       <= (others => '0');
      llinkTemac1_Data_i      <= (others => '0');
      llinkTemac1_SRC_RDY_n_i <= '1';
    else
      if (temac1Llink_DST_RDY_n_i = '0') then
        llinkTemac1_SOP_n_i     <= LlinkTemac1_SOP_n;    
        llinkTemac1_EOP_n_i     <= LlinkTemac1_EOP_n;    
        llinkTemac1_SOF_n_i     <= LlinkTemac1_SOF_n;    
        llinkTemac1_EOF_n_i     <= LlinkTemac1_EOF_n;    
        llinkTemac1_REM_i       <= LlinkTemac1_REM;      
        llinkTemac1_Data_i      <= LlinkTemac1_Data;     
        llinkTemac1_SRC_RDY_n_i <= LlinkTemac1_SRC_RDY_n;
      end if;
    end if;
  end if;
end process REG_LLT1;

  Temac1Llink_SRC_RDY_n   <= temac1Llink_SRC_RDY_n_i;  
  Temac1Llink_SOP_n       <= temac1Llink_SOP_n_i;      
  Temac1Llink_EOP_n       <= temac1Llink_EOP_n_i;      
  Temac1Llink_SOF_n       <= temac1Llink_SOF_n_i;      
  Temac1Llink_EOF_n       <= temac1Llink_EOF_n_i;      
  Temac1Llink_REM         <= temac1Llink_REM_i;        
  Temac1Llink_Data        <= temac1Llink_Data_i;       
  Temac1Llink_DST_RDY_n   <= temac1Llink_DST_RDY_n_i;  

  llinkTemac1_DST_RDY_n_i <= LlinkTemac1_DST_RDY_n;

   I_TX1 : entity xps_ll_temac_v2_03_a.tx_llink_top(beh)
     generic map (
       C_FAMILY            => C_FAMILY,
       C_TEMAC_TXCSUM      => C_TEMAC1_TXCSUM,
       C_TEMAC_TXFIFO      => C_TEMAC1_TXFIFO,
       C_TEMAC_TYPE        => C_TEMAC_TYPE,
       C_TEMAC_TXVLAN_TRAN => C_TEMAC1_TXVLAN_TRAN,
       C_TEMAC_TXVLAN_TAG  => C_TEMAC1_TXVLAN_TAG, 
       C_TEMAC_TXVLAN_STRP => C_TEMAC1_TXVLAN_STRP,
       C_TEMAC_STATS       => C_TEMAC1_STATS    
     )			 
     port map (			 
       LLTemac_Clk             =>  LlinkTemac1_CLK,        -- in  
       LLTemac_Rst             =>  lLinkClkTemac1LlPlb_RST_i,        -- in  
       LLTemac_Data            =>  llinkTemac1_Data_i,       -- in  
       LLTemac_SOF_n           =>  llinkTemac1_SOF_n_i,      -- in  
       LLTemac_SOP_n           =>  llinkTemac1_SOP_n_i,      -- in  
       LLTemac_EOF_n           =>  llinkTemac1_EOF_n_i,      -- in  
       LLTemac_EOP_n           =>  llinkTemac1_EOP_n_i,      -- in  
       LLTemac_SRC_RDY_n       =>  llinkTemac1_SRC_RDY_n_i,  -- in  
       LLTemac_REM             =>  llinkTemac1_REM_i,        -- in  
       LLTemac_DST_RDY_n       =>  temac1Llink_DST_RDY_n_i,  -- out 
       TXFIFO_Und_Intr         =>  open,                   -- out 
       Tx2ClientPauseReq       =>  tPReq1,                 -- in  
       ClientEmacPauseReq      =>  cLIENTEMAC1PAUSEREQ,    -- out 
       Tx_cmplt                =>  intrpts1(26),           -- out 
       Tx_Cl_Clk               =>  tX_CLIENT_CLK_1,        -- in  
       ClientEmacTxd           =>  cLIENTEMAC1TXD_temac,         -- out 
       ClientEmacTxdVld        =>  cLIENTEMAC1TXDVLD_temac,      -- out 
       ClientEmacTxdVldMsw     =>  cLIENTEMAC1TXDVLDMSW,   -- out 
       ClientEmacTxFirstByte   =>  cLIENTEMAC1TXFIRSTBYTE, -- out 
       ClientEmacTxUnderRun    =>  cLIENTEMAC1TXUNDERRUN_temac,  -- out 
       EmacClientTxAck         =>  eMAC1CLIENTTXACK_temac,       -- in  
       EmacClientTxCollision   =>  eMAC1CLIENTTXCOLLISION, -- in  
       EmacClientTxRetransmit  =>  eMAC1CLIENTTXRETRANSMIT,-- in  
       EmacClientTxCE          =>  txClientClkEnbl1,
       Tx2ClientUnderRunIntrpt =>  open,                   -- out
       TtagRegData             =>  ttag1RegData,           -- in
       Tpid0RegData            =>  tpid10RegData,          -- in
       Tpid1RegData            =>  tpid11RegData,          -- in
       LlinkClkAddr            =>  llink1ClkTxAddr,  	   -- out
       LlinkClkRdData          =>  llink1ClkTxRdData,	   -- in
       LlinkClkTxVlanBramEnA   =>  llink1ClkTxVlanBramEnA, -- out
       LlinkClkNewFncEnbl      =>  llink1ClkNewFncEnbl,    -- in
       LlinkClkTxVStrpMode     =>  llink1ClkTxVStrpMode,   -- in
       LlinkClkTxVTagMode      =>  llink1ClkTxVTagMode     -- in
     );			  
        					  
   I_RX1 : entity xps_ll_temac_v2_03_a.rx_top(beh)
     generic map (
       C_FAMILY             =>  C_FAMILY,
       C_TEMAC_TYPE         =>  C_TEMAC_TYPE,
       C_TEMAC_RXCSUM       =>  C_TEMAC1_RXCSUM,
       C_TEMAC_RXFIFO       =>  C_TEMAC1_RXFIFO, 
       C_TEMAC_RXVLAN_TRAN  => C_TEMAC1_RXVLAN_TRAN, 
       C_TEMAC_RXVLAN_TAG   => C_TEMAC1_RXVLAN_TAG,  
       C_TEMAC_RXVLAN_STRP  => C_TEMAC1_RXVLAN_STRP, 
       C_TEMAC_MCAST_EXTEND => C_TEMAC1_MCAST_EXTEND,
       C_TEMAC_STATS        => C_TEMAC1_STATS,     
       C_TEMAC_RXVLAN_WIDTH => C_TEMAC1_RXVLAN_WIDTH
     )			 
     port map (			 
       Plb_Clk                 =>  intPlbClk,               -- in  
       Plb_Rst                 =>  plbClkTemac1LlPlb_RST_i,       -- in  
       LLTemac_Clk             =>  LlinkTemac1_CLK,         -- in  
       LLTemac_Rst             =>  lLinkClkTemac1LlPlb_RST_i,       -- in  
       TemacLL_SOF_n           =>  temac1Llink_SOF_n_i,     -- out 
       TemacLL_SOP_n           =>  temac1Llink_SOP_n_i,     -- out 
       TemacLL_EOF_n           =>  temac1Llink_EOF_n_i,     -- out 
       TemacLL_EOP_n           =>  temac1Llink_EOP_n_i,     -- out 
       TemacLL_SRC_RDY_n       =>  temac1Llink_SRC_RDY_n_i, -- out 
       TemacLL_DST_RDY_n       =>  llinkTemac1_DST_RDY_n_i, -- in  
       TemacLL_REM             =>  temac1Llink_REM_i,       -- out 
       TemacLL_Data            =>  temac1Llink_Data_i,      -- out 
       RegCR_BrdCast_Rej       =>  cr1RegData(29),          -- in  
       RegCR_MulCast_Rej       =>  cr1RegData(30),          -- in  
       Rx_pckt_rej             =>  intrpts1(28),            -- out 
       Rx_cmplt                =>  intrpts1(29),            -- out 
       Pckt_Ovr_Run            =>  intrpts1(27),            -- out 
       RxClClkEn               =>  rxClientClkEnbl1,        -- in  
       Rx_Cl_Clk               =>  rX_CLIENT_CLK_1,         -- in  
       EmacClientRxBadFrame    =>  eMAC1CLIENTRXBADFRAME_temac,   -- in  
       EmacClientRxd           =>  eMAC1CLIENTRXD_temac,          -- in  
       EmacClientRxdVld        =>  eMAC1CLIENTRXDVLD_temac,       -- in  
       EmacClientRxFrameDrop   =>  eMAC1CLIENTRXFRAMEDROP,  -- in  
       EmacClientRxGoodFrame   =>  eMAC1CLIENTRXGOODFRAME_temac,  -- in  
       EmacClientRxStats       =>  eMAC1CLIENTRXSTATS,      -- in  
       SoftEmacClientRxStats   =>  softEmac1ClientRxStats,  -- in
       EmacClientRxStatsVld    =>  eMAC1CLIENTRXSTATSVLD,   -- in  
       RtagRegData             =>  rtag1RegData,            -- in
       Tpid0RegData            =>  tpid10RegData,           -- in
       Tpid1RegData            =>  tpid11RegData,           -- in
       UawLRegData             =>  UawL1RegData,            -- in
       UawURegData             =>  UawU1RegData,            -- in
       RxClClkMcastAddr        =>  rxClClkMcastAddr1,       -- out
       RxClClkMcastEn          =>  rxClClkMcastEn1,         -- out
       RxClClkMcastRdData      =>  rxClClkMcastRdData1,     -- in
       LlinkClkVlanAddr        =>  llink1ClkRxVlanAddr,  	    -- out
       LlinkClkVlanRdData      =>  llink1ClkRxVlanRdData,	    -- in
       LlinkClkRxVlanBramEnA   =>  llink1ClkRxVlanBramEnA,  -- out
       LlinkClkEMultiFltrEnbl  =>  llink1ClkEMultiFltrEnbl, -- in
       LlinkClkNewFncEnbl      =>  llink1ClkNewFncEnbl,     -- in
       LlinkClkRxVStrpMode     =>  llink1ClkRxVStrpMode,    -- in
       LlinkClkRxVTagMode      =>  llink1ClkRxVTagMode      -- in
     );			  
end generate DUAL_SYS;

SINGLE_SYS: if(C_TEMAC1_ENABLED = 0) generate
begin
  cLIENTEMAC1PAUSEREQ   <= '0';
  intrpts1(26 to 29)    <= (others => '0');
--  intrpts1(31)          <= '0';
  cLIENTEMAC1TXD_temac        <= (others => '0');
  cLIENTEMAC1TXDVLD_temac     <= '0';
  cLIENTEMAC1TXDVLDMSW  <= '0';
  cLIENTEMAC1TXFIRSTBYTE<= '0';
  cLIENTEMAC1TXUNDERRUN_temac <= '0';
  LlinkTemac1_SOP_n_i     <= '1';
  LlinkTemac1_EOP_n_i     <= '1';
  LlinkTemac1_SOF_n_i     <= '1';
  LlinkTemac1_EOF_n_i     <= '1';
  LlinkTemac1_REM_i       <= (others => '0');
  LlinkTemac1_Data_i      <= (others => '0');
  LlinkTemac1_SRC_RDY_n_i <= '1';
  LlinkTemac1_DST_RDY_n_i <= '1';

end generate SINGLE_SYS;

V6HARD_SYS: if(C_TEMAC_TYPE = 3) generate
begin

  NO_STATISTICS0: if(C_TEMAC0_STATS = 0) generate
  begin
    stat0_iP2Bus_RdAck <= '0';
    stat0_iP2Bus_Data  <= (others => '0');
  end generate NO_STATISTICS0;
 
  STATISTICS0: if(C_TEMAC0_STATS = 1) generate
  begin

    I_PLB2GHI0 : entity xps_ll_temac_v2_03_a.plb2ghi(imp)
    port map    (
      PlbClk          => intPlbClk,        -- in 
      PlbRst          => hRst,             -- in 
      PlbCs           => shim2IP_CS(1),     -- in 
      PlbRd           => shim2IP_RNW, --bus2IP_RdCE(32),  -- in 
      PlbAddr         => shim2IP_Addr,      -- in 
      PlbAck          => stat0_iP2Bus_RdAck,-- out
      PlbRdData       => stat0_iP2Bus_Data, -- out
      HostAddr        => hostAddr0,        -- out
      HostReq         => hostReq0,         -- out
      HostMiiMSel     => hostMiiMSel0,     -- out
      HostRdData      => hostRdData0,      -- in 
      HostStatsLswRdy => hostStatsLswRdy0, -- in 
      HostStatsMswRdy => hostStatsMswRdy0  -- in 
    );
    
    I_STAT0 : entity eth_stat_wrap_v2_03_a.eth_stat_wrap(wrapper)
      generic map (                                                                     
        C_FAMILY        => C_FAMILY,  
        C_TEMAC_TYPE    => C_TEMAC_TYPE,  
        C_NUM_STATS     => 34,
        C_STATS_WIDTH   => 64,
        C_MAC_TYPE      => "TEMAC"
      )
      port map    (
        -- asynchronous Reset     
        Reset                  => stat0Reset,

        -- reference clock for the statistics core
        Ref_clk                => REFCLK,

        -- Management (host) interface for the Ethernet MAC cores
        Host_clk               => intPlbClk,
        Host_addr              => hostAddr0,      
        Host_req               => hostReq0,       
        Host_miim_sel          => hostMiiMSel0,   
        Host_rd_data           => hostRdData0,    
        Host_stats_lsw_rdy     => hostStatsLswRdy0,
        Host_stats_msw_rdy     => hostStatsMswRdy0,
        
        -- Transmitter Statistic Vector inputs from ethernet MAC
        Tx_clk                 => tX_CLIENT_CLK_0,
        Tx_clk_en              => txClientClkEnbl0,
        Tx_statistics_soft     => (others => '0'),
        Tx_statistics_hard     => clientTxStat_0_i,
        Tx_statistics_valid    => clientTxStatsVld_0_i,
        Tx_stats_byte_valid    => clientTxStatsByteVld_0_i,

        -- Receiver Statistic Vector inputs from ethernet MAC
        Rx_clk                 => rX_CLIENT_CLK_0,
        Rx_clk_en              => rxClientClkEnbl0,
        Rx_statistics_soft     => (others => '0'),
        Rx_statistics_hard     => eMAC0CLIENTRXSTATS,
        Rx_statistics_valid    => eMAC0CLIENTRXSTATSVLD,
        Rx_stats_byte_valid    => eMAC0CLIENTRXSTATSBYTEVLD,
        Rx_data_valid          => EMAC0CLIENTRXDVLD_TOSTATS --eMAC0CLIENTRXDVLD_temac
      );
  end generate STATISTICS0;

  NO_STATISTICS1: if(C_TEMAC1_STATS = 0 or C_TEMAC1_ENABLED = 0) generate
  begin
    stat1_iP2Bus_RdAck <= '0';
    stat1_iP2Bus_Data  <= (others => '0');
  end generate NO_STATISTICS1;

  STATISTICS1: if(C_TEMAC1_STATS = 1 and C_TEMAC1_ENABLED = 1) generate
  begin

    I_PLB2GHI1 : entity xps_ll_temac_v2_03_a.plb2ghi(imp)
    port map    (
      PlbClk          => intPlbClk,        -- in 
      PlbRst          => hRst,             -- in 
      PlbCs           => shim2IP_CS(6),     -- in 
      PlbRd           => shim2IP_RNW, --bus2IP_RdCE(32),  -- in 
      PlbAddr         => shim2IP_Addr,      -- in 
      PlbAck          => stat1_iP2Bus_RdAck,-- out
      PlbRdData       => stat1_iP2Bus_Data, -- out
      HostAddr        => hostAddr1,        -- out
      HostReq         => hostReq1,         -- out
      HostMiiMSel     => hostMiiMSel1,     -- out
      HostRdData      => hostRdData1,      -- in 
      HostStatsLswRdy => hostStatsLswRdy1, -- in 
      HostStatsMswRdy => hostStatsMswRdy1  -- in 
    );

    I_STAT1 : entity eth_stat_wrap_v2_03_a.eth_stat_wrap(wrapper)
      generic map (                                                                     
        C_FAMILY        => C_FAMILY,  
        C_TEMAC_TYPE    => C_TEMAC_TYPE,  
        C_NUM_STATS     => 34,
        C_STATS_WIDTH   => 64,
        C_MAC_TYPE      => "TEMAC"
      )
      port map    (
        -- asynchronous Reset     
        Reset                  => stat1Reset,

        -- reference clock for the statistics core
        Ref_clk                => REFCLK,

        -- Management (host) interface for the Ethernet MAC cores
        Host_clk               => intPlbClk,
        Host_addr              => hostAddr1,      
        Host_req               => hostReq1,       
        Host_miim_sel          => hostMiiMSel1,   
        Host_rd_data           => hostRdData1,    
        Host_stats_lsw_rdy     => hostStatsLswRdy1,
        Host_stats_msw_rdy     => hostStatsMswRdy1,
        
        -- Transmitter Statistic Vector inputs from ethernet MAC
        Tx_clk                 => tX_CLIENT_CLK_1,
        Tx_clk_en              => txClientClkEnbl1,
        Tx_statistics_soft     => (others => '0'),
        Tx_statistics_hard     => clientTxStat_1_i,
        Tx_statistics_valid    => clientTxStatsVld_1_i,
        Tx_stats_byte_valid    => clientTxStatsByteVld_1_i,

        -- Receiver Statistic Vector inputs from ethernet MAC
        Rx_clk                 => rX_CLIENT_CLK_1,
        Rx_clk_en              => rxClientClkEnbl1,
        Rx_statistics_soft     => (others => '0'),
        Rx_statistics_hard     => eMAC1CLIENTRXSTATS,
        Rx_statistics_valid    => eMAC1CLIENTRXSTATSVLD,
        Rx_stats_byte_valid    => eMAC1CLIENTRXSTATSBYTEVLD,
        Rx_data_valid          => EMAC1CLIENTRXDVLD_TOSTATS --eMAC1CLIENTRXDVLD_temac

      );
  end generate STATISTICS1;
  
  I_TEMAC : entity xps_ll_temac_v2_03_a.v6_temac_wrap(imp)
    generic map (
                 C_NUM_IDELAYCTRL        => C_NUM_IDELAYCTRL,
                 C_SUBFAMILY             => C_SUBFAMILY,
                 C_RESERVED              => C_RESERVED,
                 C_PHY_TYPE              => C_PHY_TYPE,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC1_PRESENT         => C_TEMAC1_ENABLED,
                 C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
                 C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map    (
                -- Client Receiver Interface - EMAC0
                RX_CLIENT_CLK_ENABLE_0     => rxClientClkEnbl0,       -- out
                EMAC0CLIENTRXD             => eMAC0CLIENTRXD_mac,         -- out 
                EMAC0CLIENTRXDVLD          => eMAC0CLIENTRXDVLD_mac,      -- out 
                EMAC0CLIENTRXDVLDMSW       => open,                   -- out 
                EMAC0CLIENTRXGOODFRAME     => eMAC0CLIENTRXGOODFRAME_mac, -- out 
                EMAC0CLIENTRXBADFRAME      => eMAC0CLIENTRXBADFRAME_mac,  -- out 
                EMAC0CLIENTRXFRAMEDROP     => eMAC0CLIENTRXFRAMEDROP, -- out 
                EMAC0CLIENTRXDVREG6        => open,                   -- out 
                EMAC0CLIENTRXSTATS         => eMAC0CLIENTRXSTATS,     -- out 
                EMAC0CLIENTRXSTATSVLD      => eMAC0CLIENTRXSTATSVLD,  -- out 
                EMAC0CLIENTRXSTATSBYTEVLD  => eMAC0CLIENTRXSTATSBYTEVLD, -- out 
                EMAC0CLIENTRXDVLD_TOSTATS  => EMAC0CLIENTRXDVLD_TOSTATS, --out
                
                -- Client Transmitter Interface - EMAC0
                TX_CLIENT_CLK_ENABLE_0     => txClientClkEnbl0,       -- out
                CLIENTEMAC0TXD             => cLIENTEMAC0TXD_mac,         -- in  
                CLIENTEMAC0TXDVLD          => cLIENTEMAC0TXDVLD_mac,      -- in  
                CLIENTEMAC0TXDVLDMSW       => cLIENTEMAC0TXDVLDMSW,   -- in  
                EMAC0CLIENTTXACK           => eMAC0CLIENTTXACK_mac,       -- out 
                CLIENTEMAC0TXFIRSTBYTE     => cLIENTEMAC0TXFIRSTBYTE, -- in  
                CLIENTEMAC0TXUNDERRUN      => cLIENTEMAC0TXUNDERRUN_mac,  -- in  
                EMAC0CLIENTTXCOLLISION     => eMAC0CLIENTTXCOLLISION, -- out 
                EMAC0CLIENTTXRETRANSMIT    => eMAC0CLIENTTXRETRANSMIT,-- out 
                CLIENTEMAC0TXIFGDELAY      => ifgp0RegData(24 to 31), -- in  
                EMAC0CLIENTTXSTATS         => clientTxStat_0_i,         -- out 
                EMAC0CLIENTTXSTATSVLD      => clientTxStatsVld_0_i,     -- out 
                EMAC0CLIENTTXSTATSBYTEVLD  => clientTxStatsByteVld_0_i, -- out 
                -- MAC Control Interface - EMAC0
                CLIENTEMAC0PAUSEREQ        => cLIENTEMAC0PAUSEREQ,    -- in  
                CLIENTEMAC0PAUSEVAL        => tp0RegData,             -- in  
                -- Clock Signal - EMAC0       
                GTX_CLK_0                  => GTX_CLK_0,              -- in  
                RX_CLIENT_CLK_0            => rX_CLIENT_CLK_0,        -- out 
                TX_CLIENT_CLK_0            => tX_CLIENT_CLK_0,        -- out 
                -- MII Interface - EMAC0
                MII_TXD_0                  => MII_TXD_0,              -- out 
                MII_TX_EN_0                => MII_TX_EN_0,            -- out 
                MII_TX_ER_0                => MII_TX_ER_0,            -- out 
                MII_RXD_0                  => MII_RXD_0,              -- in  
                MII_RX_DV_0                => MII_RX_DV_0,            -- in  
                MII_RX_ER_0                => MII_RX_ER_0,            -- in  
                MII_RX_CLK_0               => MII_RX_CLK_0,           -- in  
                -- MII & GMII Interface - EMAC0
                MII_TX_CLK_0               => MII_TX_CLK_0,           -- in  
                -- GMII Interface - EMAC0
                GMII_TXD_0                 => GMII_TXD_0,             -- out 
                GMII_TX_EN_0               => GMII_TX_EN_0,           -- out 
                GMII_TX_ER_0               => GMII_TX_ER_0,           -- out 
                GMII_TX_CLK_0              => GMII_TX_CLK_0,          -- out 
                GMII_RXD_0                 => GMII_RXD_0,             -- in  
                GMII_RX_DV_0               => GMII_RX_DV_0,           -- in  
                GMII_RX_ER_0               => GMII_RX_ER_0,           -- in  
                GMII_RX_CLK_0              => GMII_RX_CLK_0,          -- in  
                -- SGMII Interface - EMAC0
                TXP_0                      => TXP_0,                  -- out 
                TXN_0                      => TXN_0,                  -- out 
                RXP_0                      => RXP_0,                  -- in  
                RXN_0                      => RXN_0,                  -- in  
                -- RGMII Interface - EMAC0
                RGMII_TXD_0                => RGMII_TXD_0,            -- out 
                RGMII_TX_CTL_0             => RGMII_TX_CTL_0,         -- out 
                RGMII_TXC_0                => RGMII_TXC_0,            -- out 
                RGMII_RXD_0                => RGMII_RXD_0,            -- in  
                RGMII_RX_CTL_0             => RGMII_RX_CTL_0,         -- in  
                RGMII_RXC_0                => RGMII_RXC_0,            -- in  
                -- MDIO Interface - EMAC0
                MDC_0                      => MDC_0,                  -- out 
                MDIO_0_I                   => MDIO_0_I,               -- in 
                MDIO_0_O                   => MDIO_0_O,               -- out 
                MDIO_0_T                   => MDIO_0_T,               -- out 
                EMAC0CLIENTANINTERRUPT     => intrpts0(30),           -- out 
                EMAC0ResetDoneInterrupt    => intrpts0(24),           -- out
                -- Client Receiver Interface - EMAC1
                RX_CLIENT_CLK_ENABLE_1     => rxClientClkEnbl1,       -- out
                EMAC1CLIENTRXD             => eMAC1CLIENTRXD_mac,         -- out 
                EMAC1CLIENTRXDVLD          => eMAC1CLIENTRXDVLD_mac,      -- out 
                EMAC1CLIENTRXDVLDMSW       => open,                   -- out 
                EMAC1CLIENTRXGOODFRAME     => eMAC1CLIENTRXGOODFRAME_mac, -- out 
                EMAC1CLIENTRXBADFRAME      => eMAC1CLIENTRXBADFRAME_mac,  -- out 
                EMAC1CLIENTRXFRAMEDROP     => eMAC1CLIENTRXFRAMEDROP, -- out 
                EMAC1CLIENTRXDVREG6        => open,                   -- out 
                EMAC1CLIENTRXSTATS         => eMAC1CLIENTRXSTATS,     -- out 
                EMAC1CLIENTRXSTATSVLD      => eMAC1CLIENTRXSTATSVLD,  -- out 
                EMAC1CLIENTRXSTATSBYTEVLD  => eMAC1CLIENTRXSTATSBYTEVLD, -- out 
                EMAC1CLIENTRXDVLD_TOSTATS  => EMAC1CLIENTRXDVLD_TOSTATS, --out
                
                -- Client Transmitter Interface - EMAC1
                TX_CLIENT_CLK_ENABLE_1     => txClientClkEnbl1,       -- out
                CLIENTEMAC1TXD             => cLIENTEMAC1TXD_mac,         -- in  
                CLIENTEMAC1TXDVLD          => cLIENTEMAC1TXDVLD_mac,      -- in  
                CLIENTEMAC1TXDVLDMSW       => cLIENTEMAC1TXDVLDMSW,   -- in  
                EMAC1CLIENTTXACK           => eMAC1CLIENTTXACK_mac,       -- out 
                CLIENTEMAC1TXFIRSTBYTE     => cLIENTEMAC1TXFIRSTBYTE, -- in  
                CLIENTEMAC1TXUNDERRUN      => cLIENTEMAC1TXUNDERRUN_mac,  -- in  
                EMAC1CLIENTTXCOLLISION     => eMAC1CLIENTTXCOLLISION, -- out 
                EMAC1CLIENTTXRETRANSMIT    => eMAC1CLIENTTXRETRANSMIT,-- out 
                CLIENTEMAC1TXIFGDELAY      => ifgp1RegData(24 to 31), -- in  
                EMAC1CLIENTTXSTATS         => clientTxStat_1_i,         -- out 
                EMAC1CLIENTTXSTATSVLD      => clientTxStatsVld_1_i,     -- out 
                EMAC1CLIENTTXSTATSBYTEVLD  => clientTxStatsByteVld_1_i, -- out 
                -- MAC Control Interface - EMAC1
                CLIENTEMAC1PAUSEREQ        => cLIENTEMAC1PAUSEREQ,    -- in  
                CLIENTEMAC1PAUSEVAL        => tp1RegData,             -- in  
                -- Clock Signal - EMAC1       
                RX_CLIENT_CLK_1            => rX_CLIENT_CLK_1,        -- out 
                TX_CLIENT_CLK_1            => tX_CLIENT_CLK_1,        -- out 
                -- MII Interface - EMAC1
                MII_TXD_1                  => MII_TXD_1,              -- out 
                MII_TX_EN_1                => MII_TX_EN_1,            -- out 
                MII_TX_ER_1                => MII_TX_ER_1,            -- out 
                MII_RXD_1                  => MII_RXD_1,              -- in  
                MII_RX_DV_1                => MII_RX_DV_1,            -- in  
                MII_RX_ER_1                => MII_RX_ER_1,            -- in  
                MII_RX_CLK_1               => MII_RX_CLK_1,           -- in  
                -- MII & GMII Interface - EMAC1
                MII_TX_CLK_1               => MII_TX_CLK_1,           -- in  
                -- GMII Interface - EMAC1
                GMII_TXD_1                 => GMII_TXD_1,             -- out 
                GMII_TX_EN_1               => GMII_TX_EN_1,           -- out 
                GMII_TX_ER_1               => GMII_TX_ER_1,           -- out 
                GMII_TX_CLK_1              => GMII_TX_CLK_1,          -- out 
                GMII_RXD_1                 => GMII_RXD_1,             -- in  
                GMII_RX_DV_1               => GMII_RX_DV_1,           -- in  
                GMII_RX_ER_1               => GMII_RX_ER_1,           -- in  
                GMII_RX_CLK_1              => GMII_RX_CLK_1,          -- in  
                -- SGMII Interface - EMAC1
                TXP_1                      => TXP_1,                  -- out 
                TXN_1                      => TXN_1,                  -- out 
                RXP_1                      => RXP_1,                  -- in  
                RXN_1                      => RXN_1,                  -- in  
                -- RGMII Interface - EMAC1
                RGMII_TXD_1                => RGMII_TXD_1,            -- out 
                RGMII_TX_CTL_1             => RGMII_TX_CTL_1,         -- out 
                RGMII_TXC_1                => RGMII_TXC_1,            -- out 
                RGMII_RXD_1                => RGMII_RXD_1,            -- in  
                RGMII_RX_CTL_1             => RGMII_RX_CTL_1,         -- in  
                RGMII_RXC_1                => RGMII_RXC_1,            -- in  
                -- MDIO Interface - EMAC1
                MDC_1                      => MDC_1,                  -- out 
                MDIO_1_I                   => MDIO_1_I,               -- in 
                MDIO_1_O                   => MDIO_1_O,               -- out 
                MDIO_1_T                   => MDIO_1_T,               -- out 
                EMAC1CLIENTANINTERRUPT     => intrpts1(30),           -- out 
                EMAC1ResetDoneInterrupt    => intrpts1(24),           -- out
                -- Host Interface
                HOSTCLK                    => intPlbClk,              -- in  

              -- DCR Interface
                DCREMACCLK                 => dCR_Clk,                -- in
                DCREMACABUS                => dCR_ABus,               -- in 
                DCREMACREAD                => dCR_Read,               -- in
                DCREMACWRITE               => dCR_Write,              -- in
                DCREMACDBUS                => dcrTemac_DBus,          -- in
                EMACDCRACK                 => dCR_Ack,                -- out 
                EMACDCRDBUS                => temacDcr_DBus,          -- out
                DCREMACENABLE              => '1',                    -- in  
                DCRHOSTDONEIR              => intrpts0(31),           -- out 

                -- SGMII MGT Clock buffer inputs 
                MGTCLK_P                   => MGTCLK_P,               -- in  
                MGTCLK_N                   => MGTCLK_N,               -- in  
                -- Asynchronous Reset
                RESET                      => hRst,                   -- in  
                REFCLK                     => REFCLK                  -- in  
                );

  softEmac0ClientRxStats <= (others => '0');                
  softEmac1ClientRxStats <= (others => '0');                
  rxDcmLocked_0 <= '1';
  rxDcmLocked_1	<= '1';
  intrpts0(25)  <= rxDcmLocked_0;
  intrpts1(25)  <= rxDcmLocked_1;
  
end generate V6HARD_SYS;

V5HARD_SYS: if(C_TEMAC_TYPE = 0) generate
begin

  NO_STATISTICS0: if(C_TEMAC0_STATS = 0) generate
  begin
    stat0_iP2Bus_RdAck <= '0';
    stat0_iP2Bus_Data  <= (others => '0');
  end generate NO_STATISTICS0;
 
  STATISTICS0: if(C_TEMAC0_STATS = 1) generate
  
  begin

    I_PLB2GHI0 : entity xps_ll_temac_v2_03_a.plb2ghi(imp)
    port map    (
      PlbClk          => intPlbClk,        -- in 
      PlbRst          => hRst,             -- in 
      PlbCs           => shim2IP_CS(1),     -- in 
      PlbRd           => shim2IP_RNW, --bus2IP_RdCE(32),  -- in 
      PlbAddr         => shim2IP_Addr,      -- in 
      PlbAck          => stat0_iP2Bus_RdAck,-- out
      PlbRdData       => stat0_iP2Bus_Data, -- out
      HostAddr        => hostAddr0,        -- out
      HostReq         => hostReq0,         -- out
      HostMiiMSel     => hostMiiMSel0,     -- out
      HostRdData      => hostRdData0,      -- in 
      HostStatsLswRdy => hostStatsLswRdy0, -- in 
      HostStatsMswRdy => hostStatsMswRdy0  -- in 
    );
    
    I_STAT0 : entity eth_stat_wrap_v2_03_a.eth_stat_wrap(wrapper)
      generic map (                                                                     
        C_FAMILY        => C_FAMILY,  
        C_TEMAC_TYPE    => C_TEMAC_TYPE,  
        C_NUM_STATS     => 34,
        C_STATS_WIDTH   => 64,
        C_MAC_TYPE      => "TEMAC"
      )
      port map    (
        -- asynchronous Reset     
        Reset                  => stat0Reset,

        -- reference clock for the statistics core
        Ref_clk                => REFCLK,

        -- Management (host) interface for the Ethernet MAC cores
        Host_clk               => intPlbClk,
        Host_addr              => hostAddr0,      
        Host_req               => hostReq0,       
        Host_miim_sel          => hostMiiMSel0,   
        Host_rd_data           => hostRdData0,    
        Host_stats_lsw_rdy     => hostStatsLswRdy0,
        Host_stats_msw_rdy     => hostStatsMswRdy0,
        
        -- Transmitter Statistic Vector inputs from ethernet MAC
        Tx_clk                 => tX_CLIENT_CLK_0,
        Tx_clk_en              => txClientClkEnbl0,
        Tx_statistics_soft     => (others => '0'),
        Tx_statistics_hard     => clientTxStat_0_i,
        Tx_statistics_valid    => clientTxStatsVld_0_i,
        Tx_stats_byte_valid    => clientTxStatsByteVld_0_i,

        -- Receiver Statistic Vector inputs from ethernet MAC
        Rx_clk                 => rX_CLIENT_CLK_0,
        Rx_clk_en              => rxClientClkEnbl0,
        Rx_statistics_soft     => (others => '0'),
        Rx_statistics_hard     => eMAC0CLIENTRXSTATS,
        Rx_statistics_valid    => eMAC0CLIENTRXSTATSVLD,
        Rx_stats_byte_valid    => eMAC0CLIENTRXSTATSBYTEVLD,
        Rx_data_valid          => EMAC0CLIENTRXDVLD_TOSTATS --eMAC0CLIENTRXDVLD_temac
      );
  end generate STATISTICS0;

  NO_STATISTICS1: if(C_TEMAC1_STATS = 0 or C_TEMAC1_ENABLED = 0) generate
  begin
    stat1_iP2Bus_RdAck <= '0';
    stat1_iP2Bus_Data  <= (others => '0');
  end generate NO_STATISTICS1;

  STATISTICS1: if(C_TEMAC1_STATS = 1 and C_TEMAC1_ENABLED = 1) generate
  begin

    I_PLB2GHI1 : entity xps_ll_temac_v2_03_a.plb2ghi(imp)
    port map    (
      PlbClk          => intPlbClk,        -- in 
      PlbRst          => hRst,             -- in 
      PlbCs           => shim2IP_CS(6),     -- in 
      PlbRd           => shim2IP_RNW, --bus2IP_RdCE(32),  -- in 
      PlbAddr         => shim2IP_Addr,      -- in 
      PlbAck          => stat1_iP2Bus_RdAck,-- out
      PlbRdData       => stat1_iP2Bus_Data, -- out
      HostAddr        => hostAddr1,        -- out
      HostReq         => hostReq1,         -- out
      HostMiiMSel     => hostMiiMSel1,     -- out
      HostRdData      => hostRdData1,      -- in 
      HostStatsLswRdy => hostStatsLswRdy1, -- in 
      HostStatsMswRdy => hostStatsMswRdy1  -- in 
    );

    I_STAT1 : entity eth_stat_wrap_v2_03_a.eth_stat_wrap(wrapper)
      generic map (                                                                     
        C_FAMILY        => C_FAMILY,  
        C_TEMAC_TYPE    => C_TEMAC_TYPE,  
        C_NUM_STATS     => 34,
        C_STATS_WIDTH   => 64,
        C_MAC_TYPE      => "TEMAC"
      )
      port map    (
        -- asynchronous Reset     
        Reset                  => stat1Reset,

        -- reference clock for the statistics core
        Ref_clk                => REFCLK,

        -- Management (host) interface for the Ethernet MAC cores
        Host_clk               => intPlbClk,
        Host_addr              => hostAddr1,      
        Host_req               => hostReq1,       
        Host_miim_sel          => hostMiiMSel1,   
        Host_rd_data           => hostRdData1,    
        Host_stats_lsw_rdy     => hostStatsLswRdy1,
        Host_stats_msw_rdy     => hostStatsMswRdy1,
        
        -- Transmitter Statistic Vector inputs from ethernet MAC
        Tx_clk                 => tX_CLIENT_CLK_1,
        Tx_clk_en              => txClientClkEnbl1,
        Tx_statistics_soft     => (others => '0'),
        Tx_statistics_hard     => clientTxStat_1_i,
        Tx_statistics_valid    => clientTxStatsVld_1_i,
        Tx_stats_byte_valid    => clientTxStatsByteVld_1_i,

        -- Receiver Statistic Vector inputs from ethernet MAC
        Rx_clk                 => rX_CLIENT_CLK_1,
        Rx_clk_en              => rxClientClkEnbl1,
        Rx_statistics_soft     => (others => '0'),
        Rx_statistics_hard     => eMAC1CLIENTRXSTATS,
        Rx_statistics_valid    => eMAC1CLIENTRXSTATSVLD,
        Rx_stats_byte_valid    => eMAC1CLIENTRXSTATSBYTEVLD,
        Rx_data_valid          => EMAC1CLIENTRXDVLD_TOSTATS --eMAC1CLIENTRXDVLD_temac       
      );
  end generate STATISTICS1;
  
  I_TEMAC : entity xps_ll_temac_v2_03_a.v5_temac_wrap(imp)
    generic map (
                 C_NUM_IDELAYCTRL        => C_NUM_IDELAYCTRL,
                 C_SUBFAMILY             => C_SUBFAMILY,
                 C_RESERVED              => C_RESERVED,
                 C_PHY_TYPE              => C_PHY_TYPE,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC1_PRESENT         => C_TEMAC1_ENABLED,
                 C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
                 C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map    (
                -- Client Receiver Interface - EMAC0
                RX_CLIENT_CLK_ENABLE_0     => rxClientClkEnbl0,       -- out
                EMAC0CLIENTRXD             => eMAC0CLIENTRXD_mac,         -- out 
                EMAC0CLIENTRXDVLD          => eMAC0CLIENTRXDVLD_mac,      -- out 
                EMAC0CLIENTRXDVLDMSW       => open,                   -- out 
                EMAC0CLIENTRXGOODFRAME     => eMAC0CLIENTRXGOODFRAME_mac, -- out 
                EMAC0CLIENTRXBADFRAME      => eMAC0CLIENTRXBADFRAME_mac,  -- out 
                EMAC0CLIENTRXFRAMEDROP     => eMAC0CLIENTRXFRAMEDROP, -- out 
                EMAC0CLIENTRXDVREG6        => open,                   -- out 
                EMAC0CLIENTRXSTATS         => eMAC0CLIENTRXSTATS,     -- out 
                EMAC0CLIENTRXSTATSVLD      => eMAC0CLIENTRXSTATSVLD,  -- out 
                EMAC0CLIENTRXSTATSBYTEVLD  => eMAC0CLIENTRXSTATSBYTEVLD, -- out 
                EMAC0CLIENTRXDVLD_TOSTATS  => EMAC0CLIENTRXDVLD_TOSTATS, --out
                
                -- Client Transmitter Interface - EMAC0
                TX_CLIENT_CLK_ENABLE_0     => txClientClkEnbl0,       -- out
                CLIENTEMAC0TXD             => cLIENTEMAC0TXD_mac,         -- in  
                CLIENTEMAC0TXDVLD          => cLIENTEMAC0TXDVLD_mac,      -- in  
                CLIENTEMAC0TXDVLDMSW       => cLIENTEMAC0TXDVLDMSW,   -- in  
                EMAC0CLIENTTXACK           => eMAC0CLIENTTXACK_mac,       -- out 
                CLIENTEMAC0TXFIRSTBYTE     => cLIENTEMAC0TXFIRSTBYTE, -- in  
                CLIENTEMAC0TXUNDERRUN      => cLIENTEMAC0TXUNDERRUN_mac,  -- in  
                EMAC0CLIENTTXCOLLISION     => eMAC0CLIENTTXCOLLISION, -- out 
                EMAC0CLIENTTXRETRANSMIT    => eMAC0CLIENTTXRETRANSMIT,-- out 
                CLIENTEMAC0TXIFGDELAY      => ifgp0RegData(24 to 31), -- in  
                EMAC0CLIENTTXSTATS         => clientTxStat_0_i,         -- out 
                EMAC0CLIENTTXSTATSVLD      => clientTxStatsVld_0_i,     -- out 
                EMAC0CLIENTTXSTATSBYTEVLD  => clientTxStatsByteVld_0_i, -- out 
                -- MAC Control Interface - EMAC0
                CLIENTEMAC0PAUSEREQ        => cLIENTEMAC0PAUSEREQ,    -- in  
                CLIENTEMAC0PAUSEVAL        => tp0RegData,             -- in  
                -- Clock Signal - EMAC0       
                GTX_CLK_0                  => GTX_CLK_0,              -- in  
                RX_CLIENT_CLK_0            => rX_CLIENT_CLK_0,        -- out 
                TX_CLIENT_CLK_0            => tX_CLIENT_CLK_0,        -- out 
                -- MII Interface - EMAC0
                MII_TXD_0                  => MII_TXD_0,              -- out 
                MII_TX_EN_0                => MII_TX_EN_0,            -- out 
                MII_TX_ER_0                => MII_TX_ER_0,            -- out 
                MII_RXD_0                  => MII_RXD_0,              -- in  
                MII_RX_DV_0                => MII_RX_DV_0,            -- in  
                MII_RX_ER_0                => MII_RX_ER_0,            -- in  
                MII_RX_CLK_0               => MII_RX_CLK_0,           -- in  
                -- MII & GMII Interface - EMAC0
                MII_TX_CLK_0               => MII_TX_CLK_0,           -- in  
                -- GMII Interface - EMAC0
                GMII_TXD_0                 => GMII_TXD_0,             -- out 
                GMII_TX_EN_0               => GMII_TX_EN_0,           -- out 
                GMII_TX_ER_0               => GMII_TX_ER_0,           -- out 
                GMII_TX_CLK_0              => GMII_TX_CLK_0,          -- out 
                GMII_RXD_0                 => GMII_RXD_0,             -- in  
                GMII_RX_DV_0               => GMII_RX_DV_0,           -- in  
                GMII_RX_ER_0               => GMII_RX_ER_0,           -- in  
                GMII_RX_CLK_0              => GMII_RX_CLK_0,          -- in  
                -- SGMII Interface - EMAC0
                TXP_0                      => TXP_0,                  -- out 
                TXN_0                      => TXN_0,                  -- out 
                RXP_0                      => RXP_0,                  -- in  
                RXN_0                      => RXN_0,                  -- in  
                -- RGMII Interface - EMAC0
                RGMII_TXD_0                => RGMII_TXD_0,            -- out 
                RGMII_TX_CTL_0             => RGMII_TX_CTL_0,         -- out 
                RGMII_TXC_0                => RGMII_TXC_0,            -- out 
                RGMII_RXD_0                => RGMII_RXD_0,            -- in  
                RGMII_RX_CTL_0             => RGMII_RX_CTL_0,         -- in  
                RGMII_RXC_0                => RGMII_RXC_0,            -- in  
                -- MDIO Interface - EMAC0
                MDC_0                      => MDC_0,                  -- out 
                MDIO_0_I                   => MDIO_0_I,               -- in 
                MDIO_0_O                   => MDIO_0_O,               -- out 
                MDIO_0_T                   => MDIO_0_T,               -- out 
                EMAC0CLIENTANINTERRUPT     => intrpts0(30),           -- out 
                EMAC0ResetDoneInterrupt    => intrpts0(24),           -- out
                -- Client Receiver Interface - EMAC1
                RX_CLIENT_CLK_ENABLE_1     => rxClientClkEnbl1,       -- out
                EMAC1CLIENTRXD             => eMAC1CLIENTRXD_mac,         -- out 
                EMAC1CLIENTRXDVLD          => eMAC1CLIENTRXDVLD_mac,      -- out 
                EMAC1CLIENTRXDVLDMSW       => open,                   -- out 
                EMAC1CLIENTRXGOODFRAME     => eMAC1CLIENTRXGOODFRAME_mac, -- out 
                EMAC1CLIENTRXBADFRAME      => eMAC1CLIENTRXBADFRAME_mac,  -- out 
                EMAC1CLIENTRXFRAMEDROP     => eMAC1CLIENTRXFRAMEDROP, -- out 
                EMAC1CLIENTRXDVREG6        => open,                   -- out 
                EMAC1CLIENTRXSTATS         => eMAC1CLIENTRXSTATS,     -- out 
                EMAC1CLIENTRXSTATSVLD      => eMAC1CLIENTRXSTATSVLD,  -- out 
                EMAC1CLIENTRXSTATSBYTEVLD  => eMAC1CLIENTRXSTATSBYTEVLD, -- out 
                EMAC1CLIENTRXDVLD_TOSTATS  => EMAC1CLIENTRXDVLD_TOSTATS, --out
                
                -- Client Transmitter Interface - EMAC1
                TX_CLIENT_CLK_ENABLE_1     => txClientClkEnbl1,       -- out
                CLIENTEMAC1TXD             => cLIENTEMAC1TXD_mac,         -- in  
                CLIENTEMAC1TXDVLD          => cLIENTEMAC1TXDVLD_mac,      -- in  
                CLIENTEMAC1TXDVLDMSW       => cLIENTEMAC1TXDVLDMSW,   -- in  
                EMAC1CLIENTTXACK           => eMAC1CLIENTTXACK_mac,       -- out 
                CLIENTEMAC1TXFIRSTBYTE     => cLIENTEMAC1TXFIRSTBYTE, -- in  
                CLIENTEMAC1TXUNDERRUN      => cLIENTEMAC1TXUNDERRUN_mac,  -- in  
                EMAC1CLIENTTXCOLLISION     => eMAC1CLIENTTXCOLLISION, -- out 
                EMAC1CLIENTTXRETRANSMIT    => eMAC1CLIENTTXRETRANSMIT,-- out 
                CLIENTEMAC1TXIFGDELAY      => ifgp1RegData(24 to 31), -- in  
                EMAC1CLIENTTXSTATS         => clientTxStat_1_i,         -- out 
                EMAC1CLIENTTXSTATSVLD      => clientTxStatsVld_1_i,     -- out 
                EMAC1CLIENTTXSTATSBYTEVLD  => clientTxStatsByteVld_1_i, -- out 
                -- MAC Control Interface - EMAC1
                CLIENTEMAC1PAUSEREQ        => cLIENTEMAC1PAUSEREQ,    -- in  
                CLIENTEMAC1PAUSEVAL        => tp1RegData,             -- in  
                -- Clock Signal - EMAC1       
                RX_CLIENT_CLK_1            => rX_CLIENT_CLK_1,        -- out 
                TX_CLIENT_CLK_1            => tX_CLIENT_CLK_1,        -- out 
                -- MII Interface - EMAC1
                MII_TXD_1                  => MII_TXD_1,              -- out 
                MII_TX_EN_1                => MII_TX_EN_1,            -- out 
                MII_TX_ER_1                => MII_TX_ER_1,            -- out 
                MII_RXD_1                  => MII_RXD_1,              -- in  
                MII_RX_DV_1                => MII_RX_DV_1,            -- in  
                MII_RX_ER_1                => MII_RX_ER_1,            -- in  
                MII_RX_CLK_1               => MII_RX_CLK_1,           -- in  
                -- MII & GMII Interface - EMAC1
                MII_TX_CLK_1               => MII_TX_CLK_1,           -- in  
                -- GMII Interface - EMAC1
                GMII_TXD_1                 => GMII_TXD_1,             -- out 
                GMII_TX_EN_1               => GMII_TX_EN_1,           -- out 
                GMII_TX_ER_1               => GMII_TX_ER_1,           -- out 
                GMII_TX_CLK_1              => GMII_TX_CLK_1,          -- out 
                GMII_RXD_1                 => GMII_RXD_1,             -- in  
                GMII_RX_DV_1               => GMII_RX_DV_1,           -- in  
                GMII_RX_ER_1               => GMII_RX_ER_1,           -- in  
                GMII_RX_CLK_1              => GMII_RX_CLK_1,          -- in  
                -- SGMII Interface - EMAC1
                TXP_1                      => TXP_1,                  -- out 
                TXN_1                      => TXN_1,                  -- out 
                RXP_1                      => RXP_1,                  -- in  
                RXN_1                      => RXN_1,                  -- in  
                -- RGMII Interface - EMAC1
                RGMII_TXD_1                => RGMII_TXD_1,            -- out 
                RGMII_TX_CTL_1             => RGMII_TX_CTL_1,         -- out 
                RGMII_TXC_1                => RGMII_TXC_1,            -- out 
                RGMII_RXD_1                => RGMII_RXD_1,            -- in  
                RGMII_RX_CTL_1             => RGMII_RX_CTL_1,         -- in  
                RGMII_RXC_1                => RGMII_RXC_1,            -- in  
                -- MDIO Interface - EMAC1
                MDC_1                      => MDC_1,                  -- out 
                MDIO_1_I                   => MDIO_1_I,               -- in 
                MDIO_1_O                   => MDIO_1_O,               -- out 
                MDIO_1_T                   => MDIO_1_T,               -- out 
                EMAC1CLIENTANINTERRUPT     => intrpts1(30),           -- out 
                EMAC1ResetDoneInterrupt    => intrpts1(24),           -- out
                -- Host Interface
                HOSTMIIMSEL                => HostMiimRdy,            -- in  
                HOSTWRDATA                 => HostRdData,             -- in  
                HOSTMIIMRDY                => HostMiimSel,            -- out 
                HOSTRDDATA(15)             => HostReq,                -- out 
                HOSTRDDATA(10)             => HostEmac1Sel,           -- out 
                HOSTRDDATA(9 downto 0)     => HostAddr,               -- out 
                HOSTRDDATA(14 downto 11)   => dummy(14 downto 11),    -- out 
                HOSTRDDATA(31 downto 16)   => dummy(31 downto 16),    -- out 
                HOSTCLK                    => intPlbClk,              -- in  

              -- DCR Interface
                DCREMACCLK                 => dCR_Clk,                -- in
                DCREMACABUS                => dCR_ABus,               -- in 
                DCREMACREAD                => dCR_Read,               -- in
                DCREMACWRITE               => dCR_Write,              -- in
                DCREMACDBUS                => dcrTemac_DBus,          -- in
                EMACDCRACK                 => dCR_Ack,                -- out 
                EMACDCRDBUS                => temacDcr_DBus,          -- out
                DCREMACENABLE              => '1',                    -- in  
                DCRHOSTDONEIR              => intrpts0(31),           -- out 

                -- SGMII MGT Clock buffer inputs 
                MGTCLK_P                   => MGTCLK_P,               -- in  
                MGTCLK_N                   => MGTCLK_N,               -- in  
                -- Asynchronous Reset
                RESET                      => hRst,                   -- in  
                REFCLK                     => REFCLK                  -- in  
                );

  softEmac0ClientRxStats <= (others => '0');                
  softEmac1ClientRxStats <= (others => '0');                
  rxDcmLocked_0 <= '1';
  rxDcmLocked_1	<= '1';
  intrpts0(25)  <= rxDcmLocked_0;
  intrpts1(25)  <= rxDcmLocked_1;
  
end generate V5HARD_SYS;

V4HARD_SYS: if(C_TEMAC_TYPE = 1) generate
begin
  rxClientClkEnbl0 <= '1';
  txClientClkEnbl0 <= '1';
  rxClientClkEnbl1 <= '1';
  txClientClkEnbl1 <= '1';

  STATISTICS0: if(C_TEMAC0_STATS = 1) generate
  begin

    I_PLB2GHI0 : entity xps_ll_temac_v2_03_a.plb2ghi(imp)
    port map    (
      PlbClk          => intPlbClk,        -- in 
      PlbRst          => hRst,             -- in 
      PlbCs           => shim2IP_CS(1),     -- in 
      PlbRd           => shim2IP_RNW, --bus2IP_RdCE(32),  -- in 
      PlbAddr         => shim2IP_Addr,      -- in 
      PlbAck          => stat0_iP2Bus_RdAck,-- out
      PlbRdData       => stat0_iP2Bus_Data, -- out
      HostAddr        => hostAddr0,        -- out
      HostReq         => hostReq0,         -- out
      HostMiiMSel     => hostMiiMSel0,     -- out
      HostRdData      => hostRdData0,      -- in 
      HostStatsLswRdy => hostStatsLswRdy0, -- in 
      HostStatsMswRdy => hostStatsMswRdy0  -- in 
    );
    
    I_STAT0 : entity eth_stat_wrap_v2_03_a.eth_stat_wrap(wrapper)
      generic map (                                                                     
        C_FAMILY        => C_FAMILY,  
        C_TEMAC_TYPE    => C_TEMAC_TYPE,  
        C_NUM_STATS     => 34,
        C_STATS_WIDTH   => 64,
        C_MAC_TYPE      => "TEMAC"
      )
      port map    (
        -- asynchronous Reset     
        Reset                  => stat0Reset,

        -- reference clock for the statistics core
        Ref_clk                => REFCLK,

        -- Management (host) interface for the Ethernet MAC cores
        Host_clk               => intPlbClk,
        Host_addr              => hostAddr0,      
        Host_req               => hostReq0,       
        Host_miim_sel          => hostMiiMSel0,   
        Host_rd_data           => hostRdData0,    
        Host_stats_lsw_rdy     => hostStatsLswRdy0,
        Host_stats_msw_rdy     => hostStatsMswRdy0,
        
        -- Transmitter Statistic Vector inputs from ethernet MAC
        Tx_clk                 => tX_CLIENT_CLK_0,
        Tx_clk_en              => '1',
        Tx_statistics_soft     => (others => '0'),
        Tx_statistics_hard     => clientTxStat_0_i,
        Tx_statistics_valid    => clientTxStatsVld_0_i,
        Tx_stats_byte_valid    => clientTxStatsByteVld_0_i,

        -- Receiver Statistic Vector inputs from ethernet MAC
        Rx_clk                 => rX_CLIENT_CLK_0,
        Rx_clk_en              => '1',
        Rx_statistics_soft     => (others => '0'),
        Rx_statistics_hard     => eMAC0CLIENTRXSTATS,
        Rx_statistics_valid    => eMAC0CLIENTRXSTATSVLD,
        Rx_stats_byte_valid    => eMAC0CLIENTRXSTATSBYTEVLD,
        Rx_data_valid          => eMAC0CLIENTRXDVLD_temac
      );
  end generate STATISTICS0;

  NO_STATISTICS0: if(C_TEMAC0_STATS = 0) generate
  begin
    stat0_iP2Bus_RdAck <= '0';
    stat0_iP2Bus_Data  <= (others => '0');
  end generate NO_STATISTICS0;

  STATISTICS1: if(C_TEMAC1_STATS = 1 and C_TEMAC1_ENABLED = 1) generate
  begin

    I_PLB2GHI1 : entity xps_ll_temac_v2_03_a.plb2ghi(imp)
    port map    (
      PlbClk          => intPlbClk,        -- in 
      PlbRst          => hRst,             -- in 
      PlbCs           => shim2IP_CS(6),     -- in 
      PlbRd           => shim2IP_RNW, --bus2IP_RdCE(32),  -- in 
      PlbAddr         => shim2IP_Addr,      -- in 
      PlbAck          => stat1_iP2Bus_RdAck,-- out
      PlbRdData       => stat1_iP2Bus_Data, -- out
      HostAddr        => hostAddr1,        -- out
      HostReq         => hostReq1,         -- out
      HostMiiMSel     => hostMiiMSel1,     -- out
      HostRdData      => hostRdData1,      -- in 
      HostStatsLswRdy => hostStatsLswRdy1, -- in 
      HostStatsMswRdy => hostStatsMswRdy1  -- in 
    );

    I_STAT1 : entity eth_stat_wrap_v2_03_a.eth_stat_wrap(wrapper)
      generic map (                                                                     
        C_FAMILY        => C_FAMILY,  
        C_TEMAC_TYPE    => C_TEMAC_TYPE,  
        C_NUM_STATS     => 34,
        C_STATS_WIDTH   => 64,
        C_MAC_TYPE      => "TEMAC"
      )
      port map    (
        -- asynchronous Reset     
        Reset                  => stat1Reset,

        -- reference clock for the statistics core
        Ref_clk                => REFCLK,

        -- Management (host) interface for the Ethernet MAC cores
        Host_clk               => intPlbClk,
        Host_addr              => hostAddr1,      
        Host_req               => hostReq1,       
        Host_miim_sel          => hostMiiMSel1,   
        Host_rd_data           => hostRdData1,    
        Host_stats_lsw_rdy     => hostStatsLswRdy1,
        Host_stats_msw_rdy     => hostStatsMswRdy1,
        
        -- Transmitter Statistic Vector inputs from ethernet MAC
        Tx_clk                 => tX_CLIENT_CLK_1,
        Tx_clk_en              => '1',
        Tx_statistics_soft     => (others => '0'),
        Tx_statistics_hard     => clientTxStat_1_i,
        Tx_statistics_valid    => clientTxStatsVld_1_i,
        Tx_stats_byte_valid    => clientTxStatsByteVld_1_i,

        -- Receiver Statistic Vector inputs from ethernet MAC
        Rx_clk                 => rX_CLIENT_CLK_1,
        Rx_clk_en              => '1',
        Rx_statistics_soft     => (others => '0'),
        Rx_statistics_hard     => eMAC1CLIENTRXSTATS,
        Rx_statistics_valid    => eMAC1CLIENTRXSTATSVLD,
        Rx_stats_byte_valid    => eMAC1CLIENTRXSTATSBYTEVLD,
        Rx_data_valid          => eMAC1CLIENTRXDVLD_temac
      );
  end generate STATISTICS1;

  NO_STATISTICS1: if(C_TEMAC1_STATS = 0 or C_TEMAC1_ENABLED = 0) generate
  begin
    stat1_iP2Bus_RdAck <= '0';
    stat1_iP2Bus_Data  <= (others => '0');
  end generate NO_STATISTICS1;
  
  I_TEMAC : entity xps_ll_temac_v2_03_a.v4_temac_wrap(imp)
    generic map (
                 C_NUM_IDELAYCTRL        => C_NUM_IDELAYCTRL,
                 C_RESERVED              => C_RESERVED,
                 C_PHY_TYPE              => C_PHY_TYPE,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC1_PRESENT         => C_TEMAC1_ENABLED,
                 C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
                 C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map    (
                -- Client Receiver Interface - EMAC0
                EMAC0CLIENTRXD             => eMAC0CLIENTRXD_mac,         -- out 
                EMAC0CLIENTRXDVLD          => eMAC0CLIENTRXDVLD_mac,      -- out 
                EMAC0CLIENTRXDVLDMSW       => open,                   -- out 
                EMAC0CLIENTRXGOODFRAME     => eMAC0CLIENTRXGOODFRAME_mac, -- out 
                EMAC0CLIENTRXBADFRAME      => eMAC0CLIENTRXBADFRAME_mac,  -- out 
                EMAC0CLIENTRXFRAMEDROP     => eMAC0CLIENTRXFRAMEDROP, -- out 
                EMAC0CLIENTRXDVREG6        => open,                   -- out 
                EMAC0CLIENTRXSTATS         => eMAC0CLIENTRXSTATS,     -- out 
                EMAC0CLIENTRXSTATSVLD      => eMAC0CLIENTRXSTATSVLD,  -- out 
                EMAC0CLIENTRXSTATSBYTEVLD  => eMAC0CLIENTRXSTATSBYTEVLD, -- out 
                -- Client Transmitter Interface - EMAC0
                CLIENTEMAC0TXD             => cLIENTEMAC0TXD_mac,         -- in  
                CLIENTEMAC0TXDVLD          => cLIENTEMAC0TXDVLD_mac,      -- in  
                CLIENTEMAC0TXDVLDMSW       => cLIENTEMAC0TXDVLDMSW,   -- in  
                EMAC0CLIENTTXACK           => eMAC0CLIENTTXACK_mac,       -- out 
                CLIENTEMAC0TXFIRSTBYTE     => cLIENTEMAC0TXFIRSTBYTE, -- in  
                CLIENTEMAC0TXUNDERRUN      => cLIENTEMAC0TXUNDERRUN_mac,  -- in  
                EMAC0CLIENTTXCOLLISION     => eMAC0CLIENTTXCOLLISION, -- out 
                EMAC0CLIENTTXRETRANSMIT    => eMAC0CLIENTTXRETRANSMIT,-- out 
                CLIENTEMAC0TXIFGDELAY      => ifgp0RegData(24 to 31), -- in  
                EMAC0CLIENTTXSTATS         => clientTxStat_0_i,         -- out 
                EMAC0CLIENTTXSTATSVLD      => clientTxStatsVld_0_i,     -- out 
                EMAC0CLIENTTXSTATSBYTEVLD  => clientTxStatsByteVld_0_i, -- out 
                -- MAC Control Interface - EMAC0
                CLIENTEMAC0PAUSEREQ        => cLIENTEMAC0PAUSEREQ,    -- in  
                CLIENTEMAC0PAUSEVAL        => tp0RegData,             -- in  
                -- Clock Signal - EMAC0       
                GTX_CLK_0                  => GTX_CLK_0,              -- in  
                RX_CLIENT_CLK_0            => rX_CLIENT_CLK_0,        -- out 
                TX_CLIENT_CLK_0            => tX_CLIENT_CLK_0,        -- out 
                -- MII Interface - EMAC0
                MII_TXD_0                  => MII_TXD_0,              -- out 
                MII_TX_EN_0                => MII_TX_EN_0,            -- out 
                MII_TX_ER_0                => MII_TX_ER_0,            -- out 
                MII_RXD_0                  => MII_RXD_0,              -- in  
                MII_RX_DV_0                => MII_RX_DV_0,            -- in  
                MII_RX_ER_0                => MII_RX_ER_0,            -- in  
                MII_RX_CLK_0               => MII_RX_CLK_0,           -- in  
                -- MII & GMII Interface - EMAC0
                MII_TX_CLK_0               => MII_TX_CLK_0,           -- in  
                -- GMII Interface - EMAC0
                GMII_TXD_0                 => GMII_TXD_0,             -- out 
                GMII_TX_EN_0               => GMII_TX_EN_0,           -- out 
                GMII_TX_ER_0               => GMII_TX_ER_0,           -- out 
                GMII_TX_CLK_0              => GMII_TX_CLK_0,          -- out 
                GMII_RXD_0                 => GMII_RXD_0,             -- in  
                GMII_RX_DV_0               => GMII_RX_DV_0,           -- in  
                GMII_RX_ER_0               => GMII_RX_ER_0,           -- in  
                GMII_RX_CLK_0              => GMII_RX_CLK_0,          -- in  
                -- SGMII Interface - EMAC0
                TXP_0                      => TXP_0,                  -- out 
                TXN_0                      => TXN_0,                  -- out 
                RXP_0                      => RXP_0,                  -- in  
                RXN_0                      => RXN_0,                  -- in  
                -- RGMII Interface - EMAC0
                RGMII_TXD_0                => RGMII_TXD_0,            -- out 
                RGMII_TX_CTL_0             => RGMII_TX_CTL_0,         -- out 
                RGMII_TXC_0                => RGMII_TXC_0,            -- out 
                RGMII_RXD_0                => RGMII_RXD_0,            -- in  
                RGMII_RX_CTL_0             => RGMII_RX_CTL_0,         -- in  
                RGMII_RXC_0                => RGMII_RXC_0,            -- in  
                RGMII_IOB_0                => RGMII_IOB_0,            -- inout
                -- MDIO Interface - EMAC0
                MDC_0                      => MDC_0,                  -- out 
                MDIO_0_I                   => MDIO_0_I,               -- in 
                MDIO_0_O                   => MDIO_0_O,               -- out 
                MDIO_0_T                   => MDIO_0_T,               -- out 
                EMAC0CLIENTANINTERRUPT     => intrpts0(30),           -- out 
                EMAC0ResetDoneInterrupt    => intrpts0(24),           -- out
                -- Client Receiver Interface - EMAC1
                EMAC1CLIENTRXD             => eMAC1CLIENTRXD_mac,         -- out 
                EMAC1CLIENTRXDVLD          => eMAC1CLIENTRXDVLD_mac,      -- out 
                EMAC1CLIENTRXDVLDMSW       => open,                   -- out 
                EMAC1CLIENTRXGOODFRAME     => eMAC1CLIENTRXGOODFRAME_mac, -- out 
                EMAC1CLIENTRXBADFRAME      => eMAC1CLIENTRXBADFRAME_mac,  -- out 
                EMAC1CLIENTRXFRAMEDROP     => eMAC1CLIENTRXFRAMEDROP, -- out 
                EMAC1CLIENTRXDVREG6        => open,                   -- out 
                EMAC1CLIENTRXSTATS         => eMAC1CLIENTRXSTATS,     -- out 
                EMAC1CLIENTRXSTATSVLD      => eMAC1CLIENTRXSTATSVLD,  -- out 
                EMAC1CLIENTRXSTATSBYTEVLD  => eMAC1CLIENTRXSTATSBYTEVLD, -- out 
                -- Client Transmitter Interface - EMAC1
                CLIENTEMAC1TXD             => cLIENTEMAC1TXD_mac,         -- in  
                CLIENTEMAC1TXDVLD          => cLIENTEMAC1TXDVLD_mac,      -- in  
                CLIENTEMAC1TXDVLDMSW       => cLIENTEMAC1TXDVLDMSW,   -- in  
                EMAC1CLIENTTXACK           => eMAC1CLIENTTXACK_mac,       -- out 
                CLIENTEMAC1TXFIRSTBYTE     => cLIENTEMAC1TXFIRSTBYTE, -- in  
                CLIENTEMAC1TXUNDERRUN      => cLIENTEMAC1TXUNDERRUN_mac,  -- in  
                EMAC1CLIENTTXCOLLISION     => eMAC1CLIENTTXCOLLISION, -- out 
                EMAC1CLIENTTXRETRANSMIT    => eMAC1CLIENTTXRETRANSMIT,-- out 
                CLIENTEMAC1TXIFGDELAY      => ifgp1RegData(24 to 31), -- in  
                EMAC1CLIENTTXSTATS         => clientTxStat_1_i,         -- out 
                EMAC1CLIENTTXSTATSVLD      => clientTxStatsVld_1_i,     -- out 
                EMAC1CLIENTTXSTATSBYTEVLD  => clientTxStatsByteVld_1_i, -- out 
                -- MAC Control Interface - EMAC1
                CLIENTEMAC1PAUSEREQ        => cLIENTEMAC1PAUSEREQ,    -- in  
                CLIENTEMAC1PAUSEVAL        => tp1RegData,             -- in  
                -- Clock Signal - EMAC1       
                RX_CLIENT_CLK_1            => rX_CLIENT_CLK_1,        -- out 
                TX_CLIENT_CLK_1            => tX_CLIENT_CLK_1,        -- out 
                -- MII Interface - EMAC1
                MII_TXD_1                  => MII_TXD_1,              -- out 
                MII_TX_EN_1                => MII_TX_EN_1,            -- out 
                MII_TX_ER_1                => MII_TX_ER_1,            -- out 
                MII_RXD_1                  => MII_RXD_1,              -- in  
                MII_RX_DV_1                => MII_RX_DV_1,            -- in  
                MII_RX_ER_1                => MII_RX_ER_1,            -- in  
                MII_RX_CLK_1               => MII_RX_CLK_1,           -- in  
                -- MII & GMII Interface - EMAC1
                MII_TX_CLK_1               => MII_TX_CLK_1,           -- in  
                -- GMII Interface - EMAC1
                GMII_TXD_1                 => GMII_TXD_1,             -- out 
                GMII_TX_EN_1               => GMII_TX_EN_1,           -- out 
                GMII_TX_ER_1               => GMII_TX_ER_1,           -- out 
                GMII_TX_CLK_1              => GMII_TX_CLK_1,          -- out 
                GMII_RXD_1                 => GMII_RXD_1,             -- in  
                GMII_RX_DV_1               => GMII_RX_DV_1,           -- in  
                GMII_RX_ER_1               => GMII_RX_ER_1,           -- in  
                GMII_RX_CLK_1              => GMII_RX_CLK_1,          -- in  
                -- SGMII Interface - EMAC1
                TXP_1                      => TXP_1,                  -- out 
                TXN_1                      => TXN_1,                  -- out 
                RXP_1                      => RXP_1,                  -- in  
                RXN_1                      => RXN_1,                  -- in  
                -- RGMII Interface - EMAC1
                RGMII_TXD_1                => RGMII_TXD_1,            -- out 
                RGMII_TX_CTL_1             => RGMII_TX_CTL_1,         -- out 
                RGMII_TXC_1                => RGMII_TXC_1,            -- out 
                RGMII_RXD_1                => RGMII_RXD_1,            -- in  
                RGMII_RX_CTL_1             => RGMII_RX_CTL_1,         -- in  
                RGMII_RXC_1                => RGMII_RXC_1,            -- in  
                RGMII_IOB_1                => RGMII_IOB_1,            -- inout
                -- MDIO Interface - EMAC1
                MDC_1                      => MDC_1,                  -- out 
                MDIO_1_I                   => MDIO_1_I,               -- in 
                MDIO_1_O                   => MDIO_1_O,               -- out 
                MDIO_1_T                   => MDIO_1_T,               -- out 
                EMAC1CLIENTANINTERRUPT     => intrpts1(30),           -- out 
                EMAC1ResetDoneInterrupt    => intrpts1(24),           -- out
                -- Host Interface
                HOSTMIIMSEL                => '0',                    -- in  
                HOSTWRDATA                 => (others => '0'),        -- in  
                HOSTMIIMRDY                => open,                   -- out 
                HOSTRDDATA                 => open,                   -- out 
                HOSTCLK                    => intPlbClk,              -- in  

                -- DCR Interface
                DCREMACCLK                 => dCR_Clk,                -- in
                DCREMACABUS                => dCR_ABus,               -- in 
                DCREMACREAD                => dCR_Read,               -- in
                DCREMACWRITE               => dCR_Write,              -- in
                DCREMACDBUS                => dcrTemac_DBus,          -- in
                EMACDCRACK                 => dCR_Ack,                -- out 
                EMACDCRDBUS                => temacDcr_DBus,          -- out
                DCREMACENABLE              => '1',                    -- in  
                DCRHOSTDONEIR              => intrpts0(31),           -- out 

                -- SGMII MGT Clock buffer inputs 
                MGTCLK_P                   => MGTCLK_P,               -- in  
                MGTCLK_N                   => MGTCLK_N,               -- in  

                -- Dynamic Reconfiguration Port Clock Must be between 25MHz - 50 MHz                 
                DCLK                       => DCLK,                   -- in

                -- Asynchronous Reset
                RESET                      => hRst,                   -- in  

                -- Reference clock for RGMII IODELAYs Need to supply a 200MHz clock
                REFCLK                     => REFCLK                  -- in  
                );
               
  HostAddr    <= (others => '0');
  HostEmac1Sel<= '0';
  HostReq     <= '0';
  HostMiimSel <= '0';

  softEmac0ClientRxStats <= (others => '0');                
  softEmac1ClientRxStats <= (others => '0');                
  rxDcmLocked_0 <= '1';
  rxDcmLocked_1	<= '1';
  intrpts0(25)  <= rxDcmLocked_0;
  intrpts1(25)  <= rxDcmLocked_1;
                
end generate V4HARD_SYS;

SOFT_SYS: if(C_TEMAC_TYPE = 2) generate
begin
  intrpts0(30) <= '0';
  intrpts1(30) <= '0';
  intrpts0(25)  <= rxDcmLocked_0;
  intrpts1(25)  <= rxDcmLocked_1;
  intrpts0(24)  <= '1';
  intrpts1(24)  <= '1';

  STATISTICS0: if(C_TEMAC0_STATS = 1) generate
  begin

    I_PLB2GHI0 : entity xps_ll_temac_v2_03_a.plb2ghi(imp)
    port map    (
      PlbClk          => intPlbClk,        -- in 
      PlbRst          => hRst,             -- in 
      PlbCs           => shim2IP_CS(1),     -- in 
      PlbRd           => shim2IP_RNW, --bus2IP_RdCE(32),  -- in 
      PlbAddr         => shim2IP_Addr,      -- in 
      PlbAck          => stat0_iP2Bus_RdAck,-- out
      PlbRdData       => stat0_iP2Bus_Data, -- out
      HostAddr        => hostAddr0,        -- out
      HostReq         => hostReq0,         -- out
      HostMiiMSel     => hostMiiMSel0,     -- out
      HostRdData      => hostRdData0,      -- in 
      HostStatsLswRdy => hostStatsLswRdy0, -- in 
      HostStatsMswRdy => hostStatsMswRdy0  -- in 
    );
    
    I_STAT0 : entity eth_stat_wrap_v2_03_a.eth_stat_wrap(wrapper)
      generic map (                                                                     
        C_FAMILY        => C_FAMILY,  
        C_TEMAC_TYPE    => C_TEMAC_TYPE,  
        C_NUM_STATS     => 34,
        C_STATS_WIDTH   => 64,
        C_MAC_TYPE      => "TEMAC"
      )
      port map    (
        -- asynchronous Reset     
        Reset                  => stat0Reset,

        -- reference clock for the statistics core
        -- begin change to accomidate Spartan 6 clock change for statistics
        --Ref_clk                => REFCLK,
        Ref_clk                => softTemacStatClk,
        -- end change to accomidate Spartan 6 clock change for statistics

        -- Management (host) interface for the Ethernet MAC cores
        Host_clk               => intPlbClk,
        Host_addr              => hostAddr0,      
        Host_req               => hostReq0,       
        Host_miim_sel          => hostMiiMSel0,   
        Host_rd_data           => hostRdData0,    
        Host_stats_lsw_rdy     => hostStatsLswRdy0,
        Host_stats_msw_rdy     => hostStatsMswRdy0,
        
        -- Transmitter Statistic Vector inputs from ethernet MAC
        Tx_clk                 => tX_CLIENT_CLK_0,
        Tx_clk_en              => txClientClkEnbl0,
        Tx_statistics_soft     => softEmac0ClientTxStats,
        Tx_statistics_hard     => '0',
        Tx_statistics_valid    => clientTxStatsVld_0_i,
        Tx_stats_byte_valid    => clientTxStatsByteVld_0_i,

        -- Receiver Statistic Vector inputs from ethernet MAC
        Rx_clk                 => rX_CLIENT_CLK_0,
        Rx_clk_en              => rxClientClkEnbl0,
        Rx_statistics_soft     => softEmac0ClientRxStats,
        Rx_statistics_hard     => (others => '0'),
        Rx_statistics_valid    => eMAC0CLIENTRXSTATSVLD,
        Rx_stats_byte_valid    => eMAC0CLIENTRXSTATSBYTEVLD,
        Rx_data_valid          => eMAC0CLIENTRXDVLD_temac
      );
  end generate STATISTICS0;

  NO_STATISTICS0: if(C_TEMAC0_STATS = 0) generate
  begin
    stat0_iP2Bus_RdAck <= '0';
    stat0_iP2Bus_Data  <= (others => '0');
  end generate NO_STATISTICS0;

  STATISTICS1: if(C_TEMAC1_STATS = 1 and C_TEMAC1_ENABLED = 1) generate
  begin

    I_PLB2GHI1 : entity xps_ll_temac_v2_03_a.plb2ghi(imp)
    port map    (
      PlbClk          => intPlbClk,        -- in 
      PlbRst          => hRst,             -- in 
      PlbCs           => shim2IP_CS(6),     -- in 
      PlbRd           => shim2IP_RNW, --bus2IP_RdCE(32),  -- in 
      PlbAddr         => shim2IP_Addr,      -- in 
      PlbAck          => stat1_iP2Bus_RdAck,-- out
      PlbRdData       => stat1_iP2Bus_Data, -- out
      HostAddr        => hostAddr1,        -- out
      HostReq         => hostReq1,         -- out
      HostMiiMSel     => hostMiiMSel1,     -- out
      HostRdData      => hostRdData1,      -- in 
      HostStatsLswRdy => hostStatsLswRdy1, -- in 
      HostStatsMswRdy => hostStatsMswRdy1  -- in 
    );

    I_STAT1 : entity eth_stat_wrap_v2_03_a.eth_stat_wrap(wrapper)
      generic map (                                                                     
        C_FAMILY        => C_FAMILY,  
        C_TEMAC_TYPE    => C_TEMAC_TYPE,  
        C_NUM_STATS     => 34,
        C_STATS_WIDTH   => 64,
        C_MAC_TYPE      => "TEMAC"
      )
      port map    (
        -- asynchronous Reset     
        Reset                  => stat1Reset,

        -- reference clock for the statistics core
        -- begin change to accomidate Spartan 6 clock change for statistics
        --Ref_clk                => REFCLK,
        Ref_clk                => softTemacStatClk,
        -- end change to accomidate Spartan 6 clock change for statistics

        -- Management (host) interface for the Ethernet MAC cores
        Host_clk               => intPlbClk,
        Host_addr              => hostAddr1,      
        Host_req               => hostReq1,       
        Host_miim_sel          => hostMiiMSel1,   
        Host_rd_data           => hostRdData1,    
        Host_stats_lsw_rdy     => hostStatsLswRdy1,
        Host_stats_msw_rdy     => hostStatsMswRdy1,
        
        -- Transmitter Statistic Vector inputs from ethernet MAC
        Tx_clk                 => tX_CLIENT_CLK_1,
        Tx_clk_en              => txClientClkEnbl1,
        Tx_statistics_soft     => softEmac1ClientTxStats,
        Tx_statistics_hard     => '0',
        Tx_statistics_valid    => clientTxStatsVld_1_i,
        Tx_stats_byte_valid    => '0',

        -- Receiver Statistic Vector inputs from ethernet MAC
        Rx_clk                 => rX_CLIENT_CLK_1,
        Rx_clk_en              => rxClientClkEnbl1,
        Rx_statistics_soft     => softEmac1ClientRxStats,
        Rx_statistics_hard     => (others => '0'),
        Rx_statistics_valid    => eMAC1CLIENTRXSTATSVLD,
        Rx_stats_byte_valid    => '0',
        Rx_data_valid          => eMAC1CLIENTRXDVLD_temac
      );
  end generate STATISTICS1;

  NO_STATISTICS1: if(C_TEMAC1_STATS = 0 or C_TEMAC1_ENABLED = 0) generate
  begin
    stat1_iP2Bus_RdAck <= '0';
    stat1_iP2Bus_Data  <= (others => '0');
  end generate NO_STATISTICS1;

  I_TEMAC : entity soft_temac_wrap_v2_03_a.soft_temac_wrap(imp)
    generic map (
                 C_NUM_IDELAYCTRL        => C_NUM_IDELAYCTRL,
                 C_PHY_TYPE              => C_PHY_TYPE,
                 C_RESERVED              => C_RESERVED,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_FAMILY                => C_FAMILY,
                 C_EMAC1_PRESENT         => C_TEMAC1_ENABLED,
                 C_SIMULATION            => C_SOFT_SIMULATION
                )
    port map    (
                RxDcmLocked_0                =>   rxDcmLocked_0,        -- out
                RxDcmLocked_1                =>   rxDcmLocked_1,        -- out
                  -- Client Receiver Interface - EMAC0
                RX_CLIENT_CLK_ENABLE_0       => rxClientClkEnbl0,       -- out
                EMAC0CLIENTRXD               => eMAC0CLIENTRXD_mac,         -- out 
                EMAC0CLIENTRXDVLD            => eMAC0CLIENTRXDVLD_mac,      -- out 
                EMAC0CLIENTRXGOODFRAME       => eMAC0CLIENTRXGOODFRAME_mac, -- out 
                EMAC0CLIENTRXBADFRAME        => eMAC0CLIENTRXBADFRAME_mac,  -- out 
                EMAC0CLIENTRXSTATS           => softEmac0ClientRxStats, -- out 
                EMAC0CLIENTRXSTATSVLD        => eMAC0CLIENTRXSTATSVLD,  -- out 

                  -- Client Transmitter Interface - EMAC0
                TX_CLIENT_CLK_ENABLE_0       => txClientClkEnbl0,       -- out
                CLIENTEMAC0TXD               => cLIENTEMAC0TXD_mac,         -- in 
                CLIENTEMAC0TXDVLD            => cLIENTEMAC0TXDVLD_mac,      -- in 
                EMAC0CLIENTTXACK             => eMAC0CLIENTTXACK_mac,       -- out
                CLIENTEMAC0TXUNDERRUN        => cLIENTEMAC0TXUNDERRUN_mac,  -- in 
                EMAC0CLIENTTXCOLLISION       => eMAC0CLIENTTXCOLLISION, -- out
                EMAC0CLIENTTXRETRANSMIT      => eMAC0CLIENTTXRETRANSMIT,-- out
                CLIENTEMAC0TXIFGDELAY        => ifgp0RegData(24 to 31), -- in 
                EMAC0CLIENTTXSTATS           => softEmac0ClientTxStats,                   -- out
                EMAC0CLIENTTXSTATSVLD        => clientTxStatsVld_0_i,                   -- out
				    
                  -- MAC Control Interface - EMAC0
                CLIENTEMAC0PAUSEREQ          => cLIENTEMAC0PAUSEREQ,    -- in 
                CLIENTEMAC0PAUSEVAL          => tp0RegData,             -- in 

                  -- GTX_CLK 125 MHz clock frequency supplied by the user
                GTX_CLK_0                    => GTX_CLK_0,              -- in 
				    
                RX_CLIENT_CLK_0              => rX_CLIENT_CLK_0,        -- out
                TX_CLIENT_CLK_0              => tX_CLIENT_CLK_0,        -- out

                -- MII Interface - EMAC0
                MII_TXD_0                  => MII_TXD_0,              -- out 
                MII_TX_EN_0                => MII_TX_EN_0,            -- out 
                MII_TX_ER_0                => MII_TX_ER_0,            -- out 
                MII_RXD_0                  => MII_RXD_0,              -- in  
                MII_RX_DV_0                => MII_RX_DV_0,            -- in  
                MII_RX_ER_0                => MII_RX_ER_0,            -- in  
                MII_RX_CLK_0               => MII_RX_CLK_0,           -- in  

                -- MII & GMII Interface - EMAC0
                MII_TX_CLK_0                 => MII_TX_CLK_0,           -- in 
				    
                  -- GMII Interface - EMAC0
                GMII_TXD_0                   => GMII_TXD_0,             -- out 
                GMII_TX_EN_0                 => GMII_TX_EN_0,           -- out 
                GMII_TX_ER_0                 => GMII_TX_ER_0,           -- out 
                GMII_TX_CLK_0                => GMII_TX_CLK_0,          -- out 
                GMII_RXD_0                   => GMII_RXD_0,             -- in  
                GMII_RX_DV_0                 => GMII_RX_DV_0,           -- in  
                GMII_RX_ER_0                 => GMII_RX_ER_0,           -- in  
                GMII_RX_CLK_0                => GMII_RX_CLK_0,          -- in  

                  -- MDIO Interface - EMAC0
                MDC_0                        => MDC_0,                  -- out
                MDIO_0_I                     => MDIO_0_I,               -- in 
                MDIO_0_O                     => MDIO_0_O,               -- out
                MDIO_0_T                     => MDIO_0_T,               -- out

                  -- Client Receiver Interface - EMAC1
                RX_CLIENT_CLK_ENABLE_1       => rxClientClkEnbl1,       -- out
                EMAC1CLIENTRXD               => eMAC1CLIENTRXD_mac,         -- out 
                EMAC1CLIENTRXDVLD            => eMAC1CLIENTRXDVLD_mac,      -- out 
                EMAC1CLIENTRXGOODFRAME       => eMAC1CLIENTRXGOODFRAME_mac, -- out 
                EMAC1CLIENTRXBADFRAME        => eMAC1CLIENTRXBADFRAME_mac,  -- out 
                EMAC1CLIENTRXSTATS           => softEmac1ClientRxStats, -- out 
                EMAC1CLIENTRXSTATSVLD        => eMAC1CLIENTRXSTATSVLD,  -- out 

                  -- Client Transmitter Interface - EMAC1
                TX_CLIENT_CLK_ENABLE_1       => txClientClkEnbl1,       -- out
                CLIENTEMAC1TXD               => cLIENTEMAC1TXD_mac,         -- in 
                CLIENTEMAC1TXDVLD            => cLIENTEMAC1TXDVLD_mac,      -- in 
                EMAC1CLIENTTXACK             => eMAC1CLIENTTXACK_mac,       -- out
                CLIENTEMAC1TXUNDERRUN        => cLIENTEMAC1TXUNDERRUN_mac,  -- in 
                EMAC1CLIENTTXCOLLISION       => eMAC1CLIENTTXCOLLISION,  -- out
                EMAC1CLIENTTXRETRANSMIT      => eMAC1CLIENTTXRETRANSMIT,-- out
                CLIENTEMAC1TXIFGDELAY        => ifgp1RegData(24 to 31), -- in 
                EMAC1CLIENTTXSTATS           => softEmac1ClientTxStats,                   -- out
                EMAC1CLIENTTXSTATSVLD        => clientTxStatsVld_1_i,                   -- out
				    
                  -- MAC Control Interface - EMAC1
                CLIENTEMAC1PAUSEREQ         => cLIENTEMAC1PAUSEREQ,     -- in 
                CLIENTEMAC1PAUSEVAL          => tp1RegData,             -- in 

                RX_CLIENT_CLK_1              => rX_CLIENT_CLK_1,        -- out 
                TX_CLIENT_CLK_1              => tX_CLIENT_CLK_1,        -- out 

                -- MII Interface - EMAC1
                MII_TXD_1                  => MII_TXD_1,              -- out 
                MII_TX_EN_1                => MII_TX_EN_1,            -- out 
                MII_TX_ER_1                => MII_TX_ER_1,            -- out 
                MII_RXD_1                  => MII_RXD_1,              -- in  
                MII_RX_DV_1                => MII_RX_DV_1,            -- in  
                MII_RX_ER_1                => MII_RX_ER_1,            -- in  
                MII_RX_CLK_1               => MII_RX_CLK_1,           -- in  

                -- MII & GMII Interface - EMAC0
                MII_TX_CLK_1                 => MII_TX_CLK_1,           -- in  
				    
                  -- GMII Interface - EMAC1
                GMII_TXD_1                   => GMII_TXD_1,             -- out
                GMII_TX_EN_1                 => GMII_TX_EN_1,           -- out
                GMII_TX_ER_1                 => GMII_TX_ER_1,           -- out
                GMII_TX_CLK_1                => GMII_TX_CLK_1,          -- out
                GMII_RXD_1                   => GMII_RXD_1,             -- in 
                GMII_RX_DV_1                 => GMII_RX_DV_1,           -- in 
                GMII_RX_ER_1                 => GMII_RX_ER_1,           -- in 
                GMII_RX_CLK_1                => GMII_RX_CLK_1,          -- in 

                  -- MDIO Interface - EMAC1
                MDC_1                        => MDC_1,                  -- out
                MDIO_1_I                     => MDIO_1_I,               -- in 
                MDIO_1_O                     => MDIO_1_O,               -- out
                MDIO_1_T                     => MDIO_1_T,               -- out

                HOSTCLK                      => intPlbClk,              -- in 
				    
                -- DCR Interface
                DCREMACCLK                   => dCR_Clk,                -- in
                DCREMACABUS                  => dCR_ABus,               -- in 
                DCREMACREAD                  => dCR_Read,               -- in
                DCREMACWRITE                 => dCR_Write,              -- in
                DCREMACDBUS                  => dcrTemac_DBus,          -- in
                EMACDCRACK                   => dCR_Ack,                -- out
                EMACDCRDBUS                  => temacDcr_DBus,          -- out
                DCREMACENABLE                => '1',                    -- in 
                DCRHOSTDONEIR                => intrpts0(31),           -- out
				    
                  -- Asynchronous RESET
                RESET                        => hRst,              -- in 
                REFCLK                       => REFCLK                  -- in  
  );  
				   
end generate SOFT_SYS;

  intrpts1(31)      <= intrpts0(31);

-------------------------------------------------------------------------------  
-- PLB V4.6 Slave
-------------------------------------------------------------------------------  
                            
  -- Instantiate the PLB IPIF
I_IPIF_BLK : entity plbv46_slave_single_v1_01_a.plbv46_slave_single
    generic map (
        C_ARD_ADDR_RANGE_ARRAY       => C_ARD_ADDR_RANGE_ARRAY,
        C_ARD_NUM_CE_ARRAY           => C_ARD_NUM_CE_ARRAY,
        C_BUS2CORE_CLK_RATIO         => C_BUS2CORE_CLK_RATIO,
        C_SPLB_P2P                   => C_SPLB_P2P,
        C_SPLB_MID_WIDTH             => C_SPLB_MID_WIDTH,
        C_SPLB_NUM_MASTERS           => C_SPLB_NUM_MASTERS,
        C_SPLB_AWIDTH                => C_SPLB_AWIDTH,
        C_SPLB_DWIDTH                => C_SPLB_DWIDTH,
        C_SIPIF_DWIDTH               => C_IPIF_DWIDTH,
        C_FAMILY                     => C_FAMILY
    )
    port map (
  
    -- System signals ---------------------------------------------------------
        SPLB_Clk             => SPLB_Clk,
        SPLB_Rst             => SPLB_Rst,

        -- Bus Slave Signals
        PLB_ABus            => PLB_ABus, 
        PLB_UABus           => PLB_UABus,
        PLB_PAValid         => PLB_PAValid,
        PLB_SAValid         => PLB_SAValid,
        PLB_rdPrim          => PLB_rdPrim,
        PLB_wrPrim          => PLB_wrPrim,
        PLB_masterID        => PLB_masterID,
        PLB_abort           => PLB_abort,
        PLB_busLock         => PLB_busLock,
        PLB_RNW             => PLB_RNW,
        PLB_BE              => PLB_BE,
        PLB_MSize           => PLB_MSize,
        PLB_size            => PLB_size,
        PLB_type            => PLB_type,
        PLB_lockErr         => PLB_lockErr,
        PLB_wrDBus          => PLB_wrDBus,
        PLB_wrBurst         => PLB_wrBurst,
        PLB_rdBurst         => PLB_rdBurst,
        PLB_wrPendReq       => PLB_wrPendReq,
        PLB_rdPendReq       => PLB_rdPendReq,
        PLB_wrPendPri       => PLB_wrPendPri,
        PLB_rdPendPri       => PLB_rdPendPri,
        PLB_reqPri          => PLB_reqPri,
        PLB_TAttribute      => PLB_TAttribute,

        Sl_addrAck          => Sl_addrAck,
        Sl_SSize            => Sl_SSize,
        Sl_wait             => Sl_wait,
        Sl_rearbitrate      => Sl_rearbitrate,
        Sl_wrDAck           => Sl_wrDAck,
        Sl_wrComp           => Sl_wrComp,
        Sl_wrBTerm          => Sl_wrBTerm,
        Sl_rdDBus           => Sl_rdDBus,
        Sl_rdWdAddr         => Sl_rdWdAddr,
        Sl_rdDAck           => Sl_rdDAck,
        Sl_rdComp           => Sl_rdComp,
        Sl_rdBTerm          => Sl_rdBTerm,
        Sl_MBusy            => Sl_MBusy,
        Sl_MWrErr           => Sl_MWrErr,
        Sl_MRdErr           => Sl_MRdErr,
        Sl_MIRQ             => Sl_MIRQ,
        
    -- IP Interconnect (IPIC) port signals -----------------------------------------
        --System Signals
        Bus2IP_Clk             =>  bus2IP_Clk,       
        Bus2IP_Reset           =>  open,       

        -- IP Slave signals
        IP2Bus_Data            =>  shim2Bus_Data ,     
        IP2Bus_WrAck           =>  shim2Bus_WrAck,      
        IP2Bus_RdAck           =>  shim2Bus_RdAck,      
        IP2Bus_Error           =>  '0',     
        Bus2IP_Addr            =>  bus2Shim_Addr,     
        Bus2IP_Data            =>  bus2Shim_Data,     
        Bus2IP_RNW             =>  bus2Shim_RNW ,     
        Bus2IP_BE              =>  open,     
        Bus2IP_CS              =>  bus2Shim_CS  ,
        Bus2IP_RdCE            =>  bus2Shim_RdCE,
        Bus2IP_WrCE            =>  bus2Shim_WrCE                  
      );  
      

-- Instantiate the Address response shim for invalid addresses
I_ADDR_SHIM : entity xps_ll_temac_v2_03_a.addr_response_shim(rtl)
   generic map(                                                                       
                                                                                   
      C_BUS2CORE_CLK_RATIO      => C_BUS2CORE_CLK_RATIO,                           
      C_SPLB_AWIDTH             => C_SPLB_AWIDTH,                                  
      C_SPLB_DWIDTH             => C_SPLB_DWIDTH,
      C_SIPIF_DWIDTH            => C_IPIF_DWIDTH,
      C_NUM_CS                  => C_NUM_CS,
      C_NUM_CE                  => C_NUM_CE,
      C_FAMILY                  => C_FAMILY 
      )
   port map(
      --Clock and Reset
      intPlbClk                 => intPlbClk,
      SPLB_Reset                => SPLB_Rst,

      -- PLB Slave Interface with Shim
      bus2Shim_Addr             => bus2Shim_Addr,      
      bus2Shim_Data             => bus2Shim_Data,      
      bus2Shim_RNW              => bus2Shim_RNW ,      
      bus2Shim_CS               => bus2Shim_CS  ,      
      bus2Shim_RdCE             => bus2Shim_RdCE,      
      bus2Shim_WrCE             => bus2Shim_WrCE,      

      shim2Bus_Data             => shim2Bus_Data ,  
      shim2Bus_WrAck            => shim2Bus_WrAck,  
      shim2Bus_RdAck            => shim2Bus_RdAck,  

      -- TEMAC Interface with Shim
      shim2IP_Addr              => shim2IP_Addr,
      shim2IP_Data              => shim2IP_Data,
      shim2IP_RNW               => shim2IP_RNW ,
      shim2IP_CS                => shim2IP_CS  ,
      shim2IP_RdCE              => shim2IP_RdCE,
      shim2IP_WrCE              => shim2IP_WrCE,

      IP2Shim_Data              => IP2Shim_Data, 
      IP2Shim_WrAck             => IP2Shim_WrAck,
      IP2Shim_RdAck             => IP2Shim_RdAck

   );      
      
end imp;