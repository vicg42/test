------------------------------------------------------------------------------
-- $Id: registers.vhd,v 1.1.4.39 2009/11/17 07:11:34 tomaik Exp $
------------------------------------------------------------------------------
-- registers - entity and arch
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
-- Filename:        registers.vhd
-- Version:         v2.00a
-- Description:     Include a meaningful description of your file. Multi-line
--                  descriptions should align with each other
--
--  Addr   REG    Chipselect #
-- offset
-- 0x000   RAF0   Bus2IP_Wr/RdCE(0) Bus2IP_CS(0)
-- 0x004   TPF0   Bus2IP_Wr/RdCE(1) Bus2IP_CS(0)
-- 0x008   IFGP0  Bus2IP_Wr/RdCE(2) Bus2IP_CS(0)
-- 0x00C   IS0    Bus2IP_Wr/RdCE(3) Bus2IP_CS(0)
-- 0x010   IP0    Bus2IP_Wr/RdCE(4) Bus2IP_CS(0)
-- 0x014   IE0    Bus2IP_Wr/RdCE(5) Bus2IP_CS(0)
-- 0x018   TTAG0  Bus2IP_Wr/RdCE(6) Bus2IP_CS(0)
-- 0x01C   RTAG0  Bus2IP_Wr/RdCE(7) Bus2IP_CS(0)
--
-- 0x020   MSW0   Bus2IP_Wr/RdCE(8) Bus2IP_CS(0)
-- 0x024   LSW0   Bus2IP_Wr/RdCE(9) Bus2IP_CS(0)
-- 0x028   CTL0   Bus2IP_Wr/RdCE(10) Bus2IP_CS(0)
-- 0x02C   RDY0   Bus2IP_Wr/RdCE(11) Bus2IP_CS(0)
-- 0x030   UAWL0  Bus2IP_Wr/RdCE(12) Bus2IP_CS(0)
-- 0x034   UAWU0  Bus2IP_Wr/RdCE(13) Bus2IP_CS(0)
-- 0x038   TPID00 Bus2IP_Wr/RdCE(14) Bus2IP_CS(0)
-- 0x03C   TPID01 Bus2IP_Wr/RdCE(15) Bus2IP_CS(0)
--
-- 0x040   RAF1   Bus2IP_Wr/RdCE(16) Bus2IP_CS(0)
-- 0x044   TPF1   Bus2IP_Wr/RdCE(17) Bus2IP_CS(0)
-- 0x048   IFGP1  Bus2IP_Wr/RdCE(18) Bus2IP_CS(0)
-- 0x04C   IS1    Bus2IP_Wr/RdCE(19) Bus2IP_CS(0)
-- 0x050   IP1    Bus2IP_Wr/RdCE(20) Bus2IP_CS(0)
-- 0x054   IE1    Bus2IP_Wr/RdCE(21) Bus2IP_CS(0)
-- 0x058   TTAG1  Bus2IP_Wr/RdCE(22) Bus2IP_CS(0)
-- 0x05C   RTAG1  Bus2IP_Wr/RdCE(23) Bus2IP_CS(0)
--
-- 0x060   MSW1   Bus2IP_Wr/RdCE(24) Bus2IP_CS(0)
-- 0x064   LSW1   Bus2IP_Wr/RdCE(25) Bus2IP_CS(0)
-- 0x068   CTL1   Bus2IP_Wr/RdCE(26) Bus2IP_CS(0)
-- 0x06C   RDY1   Bus2IP_Wr/RdCE(27) Bus2IP_CS(0)
-- 0x070   UAWL1  Bus2IP_Wr/RdCE(28) Bus2IP_CS(0)
-- 0x074   UAWU1  Bus2IP_Wr/RdCE(29) Bus2IP_CS(0)
-- 0x078   TPID10 Bus2IP_Wr/RdCE(30) Bus2IP_CS(0)
-- 0x07C   TPID11 Bus2IP_Wr/RdCE(31) Bus2IP_CS(0)
--
-- 0x0038000 - 0x0038144 STAT COUNTERS 0  BRAM Bus2IP_Wr/RdCE(32) Bus2IP_CS(1)
-- 0x0030000 - 0x0033FFF TX VLAN TRANS 0  BRAM Bus2IP_Wr/RdCE(33) Bus2IP_CS(2)
-- 0x0034000 - 0x0037FFF RX VLAN TRANS 0  BRAM Bus2IP_Wr/RdCE(34) Bus2IP_CS(3)
-- 0x003C000 - 0x003FFFF AVB 0                 Bus2IP_Wr/RdCE(35) Bus2IP_CS(4)
-- 0x0010000 - 0x002FFFF Multicast ADDR 0 BRAM Bus2IP_Wr/RdCE(36) Bus2IP_CS(5)
-- 0x0068000 - 0x0068144 STAT COUNTERS 1  BRAM Bus2IP_Wr/RdCE(37) Bus2IP_CS(6)
-- 0x0060000 - 0x0063FFF TX VLAN TRANS 1  BRAM Bus2IP_Wr/RdCE(38) Bus2IP_CS(7)
-- 0x0064000 - 0x0067FFF RX VLAN TRANS 1  BRAM Bus2IP_Wr/RdCE(39) Bus2IP_CS(8)
-- 0x006C000 - 0x006FFFF AVB 1                 Bus2IP_Wr/RdCE(40) Bus2IP_CS(9)
-- 0x0040000 - 0x005FFFF Multicast ADDR 1 BRAM Bus2IP_Wr/RdCE(41) Bus2IP_CS(10)
--
-- C_EMAC0_DCRBASEADDR : bit_vector(9 downto 0) := "0000000000";
-- C_EMAC1_DCRBASEADDR : bit_vector(9 downto 0) := "0000000100";
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the 
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--              top_level.vhd
--                  -- second_level_file1.vhd
--                      -- third_level_file1.vhd
--                          -- fourth_level_file.vhd
--                      -- third_level_file2.vhd
--                  -- second_level_file2.vhd
--                  -- second_level_file3.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:      
-- History:
--
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
--      combinatorial signals:                  "*_cmb" 
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

library proc_common_v3_00_a;
use proc_common_v3_00_a.all;

library unisim;
use unisim.vcomponents.all;

library xps_ll_temac_v2_03_a;

entity registers is
  generic
  (
    C_FAMILY              : string   := "virtex5";
    C_TEMAC1_ENABLED      : integer  := 1;
    C_TEMAC0_TXVLAN_TRAN  : integer  := 1;
    C_TEMAC0_TXVLAN_TAG   : integer  := 1; 
    C_TEMAC0_TXVLAN_STRP  : integer  := 1;
    C_TEMAC0_STATS        : integer  := 1;
    C_TEMAC1_TXVLAN_TRAN  : integer  := 1;
    C_TEMAC1_TXVLAN_TAG   : integer  := 1;
    C_TEMAC1_TXVLAN_STRP  : integer  := 1;
    C_TEMAC1_STATS        : integer  := 1;
    C_TEMAC0_RXVLAN_TRAN  : integer  := 1; 
    C_TEMAC0_RXVLAN_TAG   : integer  := 1; 
    C_TEMAC0_RXVLAN_STRP  : integer  := 1; 
    C_TEMAC0_MCAST_EXTEND : integer  := 1;
    C_TEMAC1_RXVLAN_TRAN  : integer  := 1;
    C_TEMAC1_RXVLAN_TAG   : integer  := 1;
    C_TEMAC1_RXVLAN_STRP  : integer  := 1;
    C_TEMAC1_MCAST_EXTEND : integer  := 1;    
    C_TEMAC0_TXVLAN_WIDTH : integer  := 1;
    C_TEMAC0_RXVLAN_WIDTH : integer  := 1;
    C_TEMAC1_TXVLAN_WIDTH : integer  := 1;
    C_TEMAC1_RXVLAN_WIDTH : integer  := 1
  );			
  port
  (
    DCR_Clk      : out std_logic;
    DCR_Read     : out std_logic;
    DCR_Write    : out std_logic;
    DCR_Ack      : in  std_logic;
    DCR_ABus     : out std_logic_vector(0 to 9);
    DCRTemac_DBus: out std_logic_vector(0 to 31);
    TemacDcr_DBus: in  std_logic_vector(0 to 31);
    PlbClk       : in  std_logic;
                                          
    Ref_clk      : in  std_logic;
    Host_clk     : in  std_logic;
    txClClk      : in  std_logic;
    rxClClk      : in  std_logic;
                                          
    RawReset     : in  std_logic;
    IP2Bus_Data  : out std_logic_vector(0 to 31);
    IP2Bus_WrAck : out std_logic;
    IP2Bus_RdAck : out std_logic;
    Bus2IP_Addr  : in  std_logic_vector(0 to 31);
    Bus2IP_Data  : in  std_logic_vector(0 to 31);
    Bus2IP_RNW   : in  std_logic;
    Bus2IP_CS    : in  std_logic_vector(0 to 10);   
    Bus2IP_RdCE  : in  std_logic_vector(0 to 41);     
    Bus2IP_WrCE  : in  std_logic_vector(0 to 41);     
    Intrpts0     : in  std_logic_vector(24 to 31);
    Intrpts1     : in  std_logic_vector(24 to 31);
    TPReq0       : out std_logic;
    TPReq1       : out std_logic;
    Cr0RegData   : out std_logic_vector(18 to 31);
    Cr1RegData   : out std_logic_vector(18 to 31);
    Tp0RegData   : out std_logic_vector(16 to 31);
    Tp1RegData   : out std_logic_vector(16 to 31);
    Ifgp0RegData : out std_logic_vector(24 to 31);
    Ifgp1RegData : out std_logic_vector(24 to 31);
    Is0RegData   : out std_logic_vector(24 to 31);
    Is1RegData   : out std_logic_vector(24 to 31);
    Ip0RegData   : out std_logic_vector(24 to 31);
    Ip1RegData   : out std_logic_vector(24 to 31);
    Ie0RegData   : out std_logic_vector(24 to 31);
    Ie1RegData   : out std_logic_vector(24 to 31);
    Intrpt0      : out std_logic;
    Intrpt1      : out std_logic;
    Ttag0RegData : out std_logic_vector(0 to 31);
    Ttag1RegData : out std_logic_vector(0 to 31);
    Rtag0RegData : out std_logic_vector(0 to 31);
    Rtag1RegData : out std_logic_vector(0 to 31);
    Tpid00RegData: out std_logic_vector(0 to 31);
    Tpid10RegData: out std_logic_vector(0 to 31);
    Tpid01RegData: out std_logic_vector(0 to 31);
    Tpid11RegData: out std_logic_vector(0 to 31);
    UawL0RegData : out std_logic_vector(0 to 31);
    UawL1RegData : out std_logic_vector(0 to 31);
    UawU0RegData : out std_logic_vector(16 to 31);
    UawU1RegData : out std_logic_vector(16 to 31);
    RxClClk0            : in  std_logic;
    RxClClkMcastAddr0   : in  std_logic_vector(0 to 14);
    RxClClkMcastEn0     : in  std_logic;
    RxClClkMcastRdData0 : out std_logic_vector(0 to 0);
    RxClClk1            : in  std_logic;
    RxClClkMcastAddr1   : in  std_logic_vector(0 to 14);
    RxClClkMcastEn1     : in  std_logic;
    RxClClkMcastRdData1 : out std_logic_vector(0 to 0);
    Llink0_CLK          : in  std_logic;
    Llink1_CLK          : in  std_logic;    
    Llink0ClkTxAddr     : in  std_logic_vector(0 to 11);
    Llink0ClkTxRdData   : out std_logic_vector(18 to 31);
    Llink1ClkTxAddr     : in  std_logic_vector(0 to 11);
    Llink1ClkTxRdData   : out std_logic_vector(18 to 31);
    Llink0ClkRxVlanAddr     : in  std_logic_vector(0 to 11);
    Llink0ClkRXVlanRdData   : out std_logic_vector(18 to 31);
    Llink1ClkRxVlanAddr     : in  std_logic_vector(0 to 11);
    Llink1ClkRXVlanRdData   : out std_logic_vector(18 to 31);
    Llink0ClkTxVlanBramEnA : in std_logic;
    Llink1ClkTxVlanBramEnA : in std_logic;
    Llink0ClkRxVlanBramEnA : in std_logic;
    Llink1ClkRxVlanBramEnA : in std_logic
  );
end registers;

------------------------------------------------------------------------------
-- Architecture
------------------------------------------------------------------------------

architecture imp of registers is

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

signal dCR_Read_i     : std_logic;
signal dCR_Write_i    : std_logic;
signal dCR_ABus_i     : std_logic_vector(0 to 9);
signal dCRTemac_DBus_i: std_logic_vector(0 to 31);

signal cr0RdData      : std_logic_vector(18 to 31);
signal cr1RdData      : std_logic_vector(18 to 31);
signal tp0RdData      : std_logic_vector(16 to 31);
signal tp1RdData      : std_logic_vector(16 to 31);
signal ifgp0RdData    : std_logic_vector(24 to 31);
signal ifgp1RdData    : std_logic_vector(24 to 31);
signal is0RdData      : std_logic_vector(24 to 31);
signal is1RdData      : std_logic_vector(24 to 31);
signal ie0RdData      : std_logic_vector(24 to 31);
signal ie1RdData      : std_logic_vector(24 to 31);
signal ip0RdData      : std_logic_vector(24 to 31);
signal ip1RdData      : std_logic_vector(24 to 31);
signal ttag0RdData    : std_logic_vector(0 to 31);
signal ttag1RdData    : std_logic_vector(0 to 31);
signal rtag0RdData    : std_logic_vector(0 to 31);
signal rtag1RdData    : std_logic_vector(0 to 31);
signal tpid00RdData   : std_logic_vector(0 to 31);
signal tpid10RdData   : std_logic_vector(0 to 31);
signal tpid01RdData   : std_logic_vector(0 to 31);
signal tpid11RdData   : std_logic_vector(0 to 31);
signal uawL0RdData    : std_logic_vector(0 to 31);
signal uawL1RdData    : std_logic_vector(0 to 31);
signal uawU0RdData    : std_logic_vector(16 to 31);
signal uawU1RdData    : std_logic_vector(16 to 31);

signal is0RegData_i   : std_logic_vector(24 to 31);
signal is1RegData_i   : std_logic_vector(24 to 31);
signal ie0RegData_i   : std_logic_vector(24 to 31);
signal ie1RegData_i   : std_logic_vector(24 to 31);
signal ttag0RegData_i : std_logic_vector(0 to 31);
signal ttag1RegData_i : std_logic_vector(0 to 31);
signal rtag0RegData_i : std_logic_vector(0 to 31);
signal rtag1RegData_i : std_logic_vector(0 to 31);
signal tpid00RegData_i: std_logic_vector(0 to 31);
signal tpid10RegData_i: std_logic_vector(0 to 31);
signal tpid01RegData_i: std_logic_vector(0 to 31);
signal tpid11RegData_i: std_logic_vector(0 to 31);
signal uawL0RegData_i : std_logic_vector(0 to 31);
signal uawL1RegData_i : std_logic_vector(0 to 31);
signal uawU0RegData_i : std_logic_vector(16 to 31);
signal uawU1RegData_i : std_logic_vector(16 to 31);

signal plbClkMcast0RdData    : std_logic_vector(0 to 0);
signal plbClkMcast1RdData    : std_logic_vector(0 to 0);
signal plbClkMcast0RdData_i  : std_logic_vector(0 to 0);
signal plbClkMcast1RdData_i  : std_logic_vector(0 to 0);

signal plbClkTxVlan0RdData   : std_logic_vector(18 to 31);
signal plbClkTxVlan1RdData   : std_logic_vector(18 to 31);

signal plbClkTxVlan0RdData_i : std_logic_vector(((31-C_TEMAC0_TXVLAN_WIDTH)+1) to 31);
signal plbClkTxVlan1RdData_i : std_logic_vector(((31-C_TEMAC1_TXVLAN_WIDTH)+1) to 31);

signal plbClkTxVlan0WrData_i : std_logic_vector(((31-C_TEMAC0_TXVLAN_WIDTH)+1) to 31);
signal plbClkTxVlan1WrData_i : std_logic_vector(((31-C_TEMAC1_TXVLAN_WIDTH)+1) to 31);

signal plbClkRxVlan0RdData   : std_logic_vector(18 to 31);
signal plbClkRxVlan1RdData   : std_logic_vector(18 to 31);

signal plbClkRxVlan0RdData_i : std_logic_vector(((31-C_TEMAC0_RXVLAN_WIDTH)+1) to 31);
signal plbClkRxVlan1RdData_i : std_logic_vector(((31-C_TEMAC1_RXVLAN_WIDTH)+1) to 31);

signal plbClkRxVlan0WrData_i : std_logic_vector(((31-C_TEMAC0_RXVLAN_WIDTH)+1) to 31);
signal plbClkRxVlan1WrData_i : std_logic_vector(((31-C_TEMAC1_RXVLAN_WIDTH)+1) to 31);

signal llink0ClkTxRdData_i   : std_logic_vector(((31-C_TEMAC0_TXVLAN_WIDTH)+1) to 31);
signal llink1ClkTxRdData_i   : std_logic_vector(((31-C_TEMAC1_TXVLAN_WIDTH)+1) to 31);
signal llink0ClkRxRdData_i   : std_logic_vector(((31-C_TEMAC0_RXVLAN_WIDTH)+1) to 31);
signal llink1ClkRxRdData_i   : std_logic_vector(((31-C_TEMAC1_RXVLAN_WIDTH)+1) to 31);

signal temac0_txvlan_dina    : std_logic_vector(((31-C_TEMAC0_TXVLAN_WIDTH)+1) to 31);
signal temac0_rxvlan_dina    : std_logic_vector(((31-C_TEMAC0_RXVLAN_WIDTH)+1) to 31);
signal temac1_txvlan_dina    : std_logic_vector(((31-C_TEMAC1_TXVLAN_WIDTH)+1) to 31);
signal temac1_rxvlan_dina    : std_logic_vector(((31-C_TEMAC1_RXVLAN_WIDTH)+1) to 31);

signal rdData        : std_logic_vector(0 to 31);
--signal wrData        : std_logic_vector(0 to 31);

signal softRead0     : std_logic;
signal softRead1     : std_logic;
signal softWrite0    : std_logic;
signal softWrite1    : std_logic;
signal dCR_Read0     : std_logic;
signal dCR_Read1     : std_logic;
signal dCR_Write0    : std_logic;
signal dCR_Write1    : std_logic;
signal dcrTemac1Op   : std_logic;
signal temacDcr_DBus_i : std_logic_vector(0 to 31);
signal dCR_Ack_i     : std_logic;
signal softRead0_d1  : std_logic;
signal softRead1_d1  : std_logic;
signal softWrite0_d1 : std_logic;
signal softWrite1_d1 : std_logic;
signal dCR_Read0_d1  : std_logic;   
signal dCR_Write0_d1 : std_logic;   
signal dCR_Read1_d1  : std_logic;   
signal dCR_Write1_d1 : std_logic; 

signal iP2Bus_WrAck_i: std_logic;
signal iP2Bus_RdAck_i: std_logic;

signal rdAckBlocker  : std_logic;
signal wrAckBlocker  : std_logic;

signal bus2IP_WrCE_36_d1 : std_logic;
signal bus2IP_WrCE_36_en : std_logic;

signal bus2IP_WrCE_41_d1 : std_logic;
signal bus2IP_WrCE_41_en : std_logic;

signal bus2IP_WrCE_33_d1 : std_logic;
signal bus2IP_WrCE_33_en : std_logic;

signal bus2IP_WrCE_38_d1 : std_logic;
signal bus2IP_WrCE_38_en : std_logic;

signal bus2IP_WrCE_34_d1 : std_logic;
signal bus2IP_WrCE_34_en : std_logic;

signal bus2IP_WrCE_39_d1 : std_logic;
signal bus2IP_WrCE_39_en : std_logic;

begin
  PIPE_RAM_WRITE_PROCESS: process (PlbClk)
  begin
    if (PlbClk'event and PlbClk = '1') then
      if (RawReset = '1') then
        bus2IP_WrCE_36_d1     <= '0';
        bus2IP_WrCE_36_en     <= '0';
        bus2IP_WrCE_41_d1     <= '0';
        bus2IP_WrCE_41_en     <= '0';
        bus2IP_WrCE_33_d1     <= '0';
        bus2IP_WrCE_33_en     <= '0';
        bus2IP_WrCE_38_d1     <= '0';
        bus2IP_WrCE_38_en     <= '0';
        bus2IP_WrCE_34_d1     <= '0';
        bus2IP_WrCE_34_en     <= '0';
        bus2IP_WrCE_39_d1     <= '0';
        bus2IP_WrCE_39_en     <= '0';
      else
        bus2IP_WrCE_36_d1     <= Bus2IP_WrCE(36);
        bus2IP_WrCE_36_en     <= Bus2IP_WrCE(36) and not(bus2IP_WrCE_36_d1);
        bus2IP_WrCE_41_d1     <= Bus2IP_WrCE(41);
        bus2IP_WrCE_41_en     <= Bus2IP_WrCE(41) and not(bus2IP_WrCE_41_d1);
        bus2IP_WrCE_33_d1     <= Bus2IP_WrCE(33);
        bus2IP_WrCE_33_en     <= Bus2IP_WrCE(33) and not(bus2IP_WrCE_33_d1);
        bus2IP_WrCE_38_d1     <= Bus2IP_WrCE(38);
        bus2IP_WrCE_38_en     <= Bus2IP_WrCE(38) and not(bus2IP_WrCE_38_d1);
        bus2IP_WrCE_34_d1     <= Bus2IP_WrCE(34);
        bus2IP_WrCE_34_en     <= Bus2IP_WrCE(34) and not(bus2IP_WrCE_34_d1);
        bus2IP_WrCE_39_d1     <= Bus2IP_WrCE(39);
        bus2IP_WrCE_39_en     <= Bus2IP_WrCE(39) and not(bus2IP_WrCE_39_d1);
      end if;
    end if;
  end process;

  temac0_txvlan_dina <= (others => '0');
  temac0_rxvlan_dina <= (others => '0');
  temac1_txvlan_dina <= (others => '0');
  temac1_rxvlan_dina <= (others => '0');

  -- TX 0 VLAN --
  TX0_VLAN_TRAN_STRP_TAG : if (C_TEMAC0_TXVLAN_TRAN = 1 and C_TEMAC0_TXVLAN_STRP = 1 and C_TEMAC0_TXVLAN_TAG = 1) generate
  begin
    plbClkTxVlan0RdData   <= plbClkTxVlan0RdData_i when (Bus2IP_RdCE(33) = '1') else
                            (others => '0');
    plbClkTxVlan0WrData_i <= Bus2IP_Data(18 to 31);
    Llink0ClkTxRdData     <= llink0ClkTxRdData_i;
  end generate TX0_VLAN_TRAN_STRP_TAG;

  TX0_VLAN_TRAN_STRP : if (C_TEMAC0_TXVLAN_TRAN = 1 and C_TEMAC0_TXVLAN_STRP = 1 and C_TEMAC0_TXVLAN_TAG = 0) generate
  begin
    plbClkTxVlan0RdData   <= plbClkTxVlan0RdData_i & '0' when (Bus2IP_RdCE(33) = '1') else
                            (others => '0');
    plbClkTxVlan0WrData_i <= Bus2IP_Data(18 to 30);
    Llink0ClkTxRdData     <= llink0ClkTxRdData_i & '0';
  end generate TX0_VLAN_TRAN_STRP;

  TX0_VLAN_TRAN_TAG : if (C_TEMAC0_TXVLAN_TRAN = 1 and C_TEMAC0_TXVLAN_STRP = 0 and C_TEMAC0_TXVLAN_TAG = 1) generate
  begin
    plbClkTxVlan0RdData   <= plbClkTxVlan0RdData_i(19 to 30) & '0' & plbClkTxVlan0RdData_i(31) when (Bus2IP_RdCE(33) = '1') else
                            (others => '0');
    plbClkTxVlan0WrData_i <= Bus2IP_Data(18 to 29)& Bus2IP_Data(31);
    Llink0ClkTxRdData     <= llink0ClkTxRdData_i(19 to 30) & '0' & llink0ClkTxRdData_i(31);
  end generate TX0_VLAN_TRAN_TAG;

  TX0_VLAN_TRAN : if (C_TEMAC0_TXVLAN_TRAN = 1 and C_TEMAC0_TXVLAN_STRP = 0 and C_TEMAC0_TXVLAN_TAG = 0) generate
  begin
    plbClkTxVlan0RdData   <= plbClkTxVlan0RdData_i(20 to 31) & "00" when (Bus2IP_RdCE(33) = '1') else
                            (others => '0');
    plbClkTxVlan0WrData_i <= Bus2IP_Data(18 to 29);
    Llink0ClkTxRdData     <= llink0ClkTxRdData_i(20 to 31) & "00";
  end generate TX0_VLAN_TRAN;

  TX0_VLAN_STRP_TAG : if (C_TEMAC0_TXVLAN_TRAN = 0 and C_TEMAC0_TXVLAN_STRP = 1 and C_TEMAC0_TXVLAN_TAG = 1) generate
  begin
    plbClkTxVlan0RdData   <= "000000000000" & plbClkTxVlan0RdData_i when (Bus2IP_RdCE(33) = '1') else
                            (others => '0');
    plbClkTxVlan0WrData_i <= Bus2IP_Data(30 to 31);
    Llink0ClkTxRdData     <= "000000000000" & llink0ClkTxRdData_i;
  end generate TX0_VLAN_STRP_TAG;

  TX0_VLAN_STRP : if (C_TEMAC0_TXVLAN_TRAN = 0 and C_TEMAC0_TXVLAN_STRP = 1 and C_TEMAC0_TXVLAN_TAG = 0) generate
  begin
    plbClkTxVlan0RdData   <= "000000000000" & plbClkTxVlan0RdData_i & '0' when (Bus2IP_RdCE(33) = '1') else
                            (others => '0');
    plbClkTxVlan0WrData_i <= Bus2IP_Data(30 to 30);
    Llink0ClkTxRdData     <= "000000000000" & llink0ClkTxRdData_i & '0';
  end generate TX0_VLAN_STRP;

  TX0_VLAN_TAG : if (C_TEMAC0_TXVLAN_TRAN = 0 and C_TEMAC0_TXVLAN_STRP = 0 and C_TEMAC0_TXVLAN_TAG = 1) generate
  begin
    plbClkTxVlan0RdData   <= "000000000000" & '0' & plbClkTxVlan0RdData_i when (Bus2IP_RdCE(33) = '1') else
                            (others => '0');
    plbClkTxVlan0WrData_i <= Bus2IP_Data(31 to 31);
    Llink0ClkTxRdData     <= "000000000000" & '0' & llink0ClkTxRdData_i;
  end generate TX0_VLAN_TAG;

  TX0_VLAN_NONE : if (C_TEMAC0_TXVLAN_TRAN = 0 and C_TEMAC0_TXVLAN_STRP = 0 and C_TEMAC0_TXVLAN_TAG = 0) generate
  begin
    plbClkTxVlan0RdData   <= (others => '0');
    Llink0ClkTxRdData     <= (others => '0');
  end generate TX0_VLAN_NONE;

  -- RX 0 VLAN --
  RX0_VLAN_TRAN_STRP_TAG : if (C_TEMAC0_RXVLAN_TRAN = 1 and C_TEMAC0_RXVLAN_STRP = 1 and C_TEMAC0_RXVLAN_TAG = 1) generate
  begin
    plbClkRXVlan0RdData   <= plbClkRXVlan0RdData_i when (Bus2IP_RdCE(34) = '1') else
                            (others => '0');
    plbClkRXVlan0WrData_i <= Bus2IP_Data(18 to 31);
    Llink0ClkRXVlanRdData     <= llink0ClkRXRdData_i;
  end generate RX0_VLAN_TRAN_STRP_TAG;

  RX0_VLAN_TRAN_STRP : if (C_TEMAC0_RXVLAN_TRAN = 1 and C_TEMAC0_RXVLAN_STRP = 1 and C_TEMAC0_RXVLAN_TAG = 0) generate
  begin
    plbClkRXVlan0RdData   <= plbClkRXVlan0RdData_i & '0' when (Bus2IP_RdCE(34) = '1') else
                            (others => '0');
    plbClkRXVlan0WrData_i <= Bus2IP_Data(18 to 30);
    Llink0ClkRXVlanRdData     <= llink0ClkRXRdData_i & '0';
  end generate RX0_VLAN_TRAN_STRP;

  RX0_VLAN_TRAN_TAG : if (C_TEMAC0_RXVLAN_TRAN = 1 and C_TEMAC0_RXVLAN_STRP = 0 and C_TEMAC0_RXVLAN_TAG = 1) generate
  begin
    plbClkRXVlan0RdData   <= plbClkRXVlan0RdData_i(19 to 30) & '0' & plbClkRXVlan0RdData_i(31) when (Bus2IP_RdCE(34) = '1') else
                            (others => '0');
    plbClkRXVlan0WrData_i <= Bus2IP_Data(18 to 29)& Bus2IP_Data(31);
    Llink0ClkRXVlanRdData     <= llink0ClkRXRdData_i(19 to 30) & '0' & llink0ClkRXRdData_i(31);
  end generate RX0_VLAN_TRAN_TAG;

  RX0_VLAN_TRAN : if (C_TEMAC0_RXVLAN_TRAN = 1 and C_TEMAC0_RXVLAN_STRP = 0 and C_TEMAC0_RXVLAN_TAG = 0) generate
  begin
    plbClkRXVlan0RdData   <= plbClkRXVlan0RdData_i(20 to 31) & "00" when (Bus2IP_RdCE(34) = '1') else
                            (others => '0');
    plbClkRXVlan0WrData_i <= Bus2IP_Data(18 to 29);
    Llink0ClkRXVlanRdData     <= llink0ClkRXRdData_i(20 to 31) & "00";
  end generate RX0_VLAN_TRAN;

  RX0_VLAN_STRP_TAG : if (C_TEMAC0_RXVLAN_TRAN = 0 and C_TEMAC0_RXVLAN_STRP = 1 and C_TEMAC0_RXVLAN_TAG = 1) generate
  begin
    plbClkRXVlan0RdData   <= "000000000000" & plbClkRXVlan0RdData_i when (Bus2IP_RdCE(34) = '1') else
                            (others => '0');
    plbClkRXVlan0WrData_i <= Bus2IP_Data(30 to 31);
    Llink0ClkRXVlanRdData     <= "000000000000" & llink0ClkRXRdData_i;
  end generate RX0_VLAN_STRP_TAG;

  RX0_VLAN_STRP : if (C_TEMAC0_RXVLAN_TRAN = 0 and C_TEMAC0_RXVLAN_STRP = 1 and C_TEMAC0_RXVLAN_TAG = 0) generate
  begin
    plbClkRXVlan0RdData   <= "000000000000" & plbClkRXVlan0RdData_i & '0' when (Bus2IP_RdCE(34) = '1') else
                            (others => '0');
    plbClkRXVlan0WrData_i <= Bus2IP_Data(30 to 30);
    Llink0ClkRXVlanRdData     <= "000000000000" & llink0ClkRXRdData_i & '0';
  end generate RX0_VLAN_STRP;

  RX0_VLAN_TAG : if (C_TEMAC0_RXVLAN_TRAN = 0 and C_TEMAC0_RXVLAN_STRP = 0 and C_TEMAC0_RXVLAN_TAG = 1) generate
  begin
    plbClkRXVlan0RdData   <= "000000000000" & '0' & plbClkRXVlan0RdData_i when (Bus2IP_RdCE(34) = '1') else
                            (others => '0');
    plbClkRXVlan0WrData_i <= Bus2IP_Data(31 to 31);
    Llink0ClkRXVlanRdData     <= "000000000000" & '0' & llink0ClkRXRdData_i;
  end generate RX0_VLAN_TAG;

  RX0_VLAN_NONE : if (C_TEMAC0_RXVLAN_TRAN = 0 and C_TEMAC0_RXVLAN_STRP = 0 and C_TEMAC0_RXVLAN_TAG = 0) generate
  begin
    plbClkRXVlan0RdData   <= (others => '0');
    Llink0ClkRXVlanRdData     <= (others => '0');
  end generate RX0_VLAN_NONE;

    -- TX 1 VLAN --
    TX1_VLAN_TRAN_STRP_TAG : if (C_TEMAC1_TXVLAN_TRAN = 1 and C_TEMAC1_TXVLAN_STRP = 1 and C_TEMAC1_TXVLAN_TAG = 1 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkTxVlan1RdData   <= plbClkTxVlan1RdData_i when (Bus2IP_RdCE(38) = '1') else
                              (others => '0');
      plbClkTxVlan1WrData_i <= Bus2IP_Data(18 to 31);
      Llink1ClkTxRdData     <= Llink1ClkTxRdData_i;
    end generate TX1_VLAN_TRAN_STRP_TAG;
  
    TX1_VLAN_TRAN_STRP : if (C_TEMAC1_TXVLAN_TRAN = 1 and C_TEMAC1_TXVLAN_STRP = 1 and C_TEMAC1_TXVLAN_TAG = 0 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkTxVlan1RdData   <= plbClkTxVlan1RdData_i & '0' when (Bus2IP_RdCE(38) = '1') else
                              (others => '0');
      plbClkTxVlan1WrData_i <= Bus2IP_Data(18 to 30);
      Llink1ClkTxRdData     <= Llink1ClkTxRdData_i & '0';
    end generate TX1_VLAN_TRAN_STRP;
  
    TX1_VLAN_TRAN_TAG : if (C_TEMAC1_TXVLAN_TRAN = 1 and C_TEMAC1_TXVLAN_STRP = 0 and C_TEMAC1_TXVLAN_TAG = 1 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkTxVlan1RdData   <= plbClkTxVlan1RdData_i(19 to 30) & '0' & plbClkTxVlan1RdData_i(31) when (Bus2IP_RdCE(38) = '1') else
                              (others => '0');
      plbClkTxVlan1WrData_i <= Bus2IP_Data(18 to 29)& Bus2IP_Data(31);
      Llink1ClkTxRdData     <= Llink1ClkTxRdData_i(19 to 30) & '0' & Llink1ClkTxRdData_i(31);
    end generate TX1_VLAN_TRAN_TAG;
  
    TX1_VLAN_TRAN : if (C_TEMAC1_TXVLAN_TRAN = 1 and C_TEMAC1_TXVLAN_STRP = 0 and C_TEMAC1_TXVLAN_TAG = 0 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkTxVlan1RdData   <= plbClkTxVlan1RdData_i(20 to 31) & "00" when (Bus2IP_RdCE(38) = '1') else
                              (others => '0');
      plbClkTxVlan1WrData_i <= Bus2IP_Data(18 to 29);
      Llink1ClkTxRdData     <= Llink1ClkTxRdData_i(20 to 31) & "00";
    end generate TX1_VLAN_TRAN;
  
    TX1_VLAN_STRP_TAG : if (C_TEMAC1_TXVLAN_TRAN = 0 and C_TEMAC1_TXVLAN_STRP = 1 and C_TEMAC1_TXVLAN_TAG = 1 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkTxVlan1RdData   <= "000000000000" & plbClkTxVlan1RdData_i when (Bus2IP_RdCE(38) = '1') else
                              (others => '0');
      plbClkTxVlan1WrData_i <= Bus2IP_Data(30 to 31);
      Llink1ClkTxRdData     <= "000000000000" & Llink1ClkTxRdData_i;
    end generate TX1_VLAN_STRP_TAG;
  
    TX1_VLAN_STRP : if (C_TEMAC1_TXVLAN_TRAN = 0 and C_TEMAC1_TXVLAN_STRP = 1 and C_TEMAC1_TXVLAN_TAG = 0 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkTxVlan1RdData   <= "000000000000" & plbClkTxVlan1RdData_i & '0' when (Bus2IP_RdCE(38) = '1') else
                              (others => '0');
      plbClkTxVlan1WrData_i <= Bus2IP_Data(30 to 30);
      Llink1ClkTxRdData     <= "000000000000" & Llink1ClkTxRdData_i & '0';
    end generate TX1_VLAN_STRP;
  
    TX1_VLAN_TAG : if (C_TEMAC1_TXVLAN_TRAN = 0 and C_TEMAC1_TXVLAN_STRP = 0 and C_TEMAC1_TXVLAN_TAG = 1 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkTxVlan1RdData   <= "000000000000" & '0' & plbClkTxVlan1RdData_i when (Bus2IP_RdCE(38) = '1') else
                              (others => '0');
      plbClkTxVlan1WrData_i <= Bus2IP_Data(31 to 31);
      Llink1ClkTxRdData     <= "000000000000" & '0' & Llink1ClkTxRdData_i;
    end generate TX1_VLAN_TAG;
  
    TX1_VLAN_NONE : if ((C_TEMAC1_TXVLAN_TRAN = 0 and C_TEMAC1_TXVLAN_STRP = 0 and C_TEMAC1_TXVLAN_TAG = 0) or C_TEMAC1_ENABLED = 0) generate
    begin
      plbClkTxVlan1RdData   <= (others => '0');
      Llink1ClkTxRdData     <= (others => '0');
    end generate TX1_VLAN_NONE;
  
    -- RX 1 VLAN --
    RX1_VLAN_TRAN_STRP_TAG : if (C_TEMAC1_RXVLAN_TRAN = 1 and C_TEMAC1_RXVLAN_STRP = 1 and C_TEMAC1_RXVLAN_TAG = 1 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkRXVlan1RdData   <= plbClkRXVlan1RdData_i when (Bus2IP_RdCE(39) = '1') else
                              (others => '0');
      plbClkRXVlan1WrData_i <= Bus2IP_Data(18 to 31);
      Llink1ClkRXVlanRdData     <= Llink1ClkRXRdData_i;
    end generate RX1_VLAN_TRAN_STRP_TAG;
  
    RX1_VLAN_TRAN_STRP : if (C_TEMAC1_RXVLAN_TRAN = 1 and C_TEMAC1_RXVLAN_STRP = 1 and C_TEMAC1_RXVLAN_TAG = 0 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkRXVlan1RdData   <= plbClkRXVlan1RdData_i & '0' when (Bus2IP_RdCE(39) = '1') else
                              (others => '0');
      plbClkRXVlan1WrData_i <= Bus2IP_Data(18 to 30);
      Llink1ClkRXVlanRdData     <= Llink1ClkRXRdData_i & '0';
    end generate RX1_VLAN_TRAN_STRP;
  
    RX1_VLAN_TRAN_TAG : if (C_TEMAC1_RXVLAN_TRAN = 1 and C_TEMAC1_RXVLAN_STRP = 0 and C_TEMAC1_RXVLAN_TAG = 1 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkRXVlan1RdData   <= plbClkRXVlan1RdData_i(19 to 30) & '0' & plbClkRXVlan1RdData_i(31) when (Bus2IP_RdCE(39) = '1') else
                              (others => '0');
      plbClkRXVlan1WrData_i <= Bus2IP_Data(18 to 29)& Bus2IP_Data(31);
      Llink1ClkRXVlanRdData     <= Llink1ClkRXRdData_i(19 to 30) & '0' & Llink1ClkRXRdData_i(31);
    end generate RX1_VLAN_TRAN_TAG;
  
    RX1_VLAN_TRAN : if (C_TEMAC1_RXVLAN_TRAN = 1 and C_TEMAC1_RXVLAN_STRP = 0 and C_TEMAC1_RXVLAN_TAG = 0 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkRXVlan1RdData   <= plbClkRXVlan1RdData_i(20 to 31) & "00" when (Bus2IP_RdCE(39) = '1') else
                              (others => '0');
      plbClkRXVlan1WrData_i <= Bus2IP_Data(18 to 29);
      Llink1ClkRXVlanRdData     <= Llink1ClkRXRdData_i(20 to 31) & "00";
    end generate RX1_VLAN_TRAN;
  
    RX1_VLAN_STRP_TAG : if (C_TEMAC1_RXVLAN_TRAN = 0 and C_TEMAC1_RXVLAN_STRP = 1 and C_TEMAC1_RXVLAN_TAG = 1 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkRXVlan1RdData   <= "000000000000" & plbClkRXVlan1RdData_i when (Bus2IP_RdCE(39) = '1') else
                              (others => '0');
      plbClkRXVlan1WrData_i <= Bus2IP_Data(30 to 31);
      Llink1ClkRXVlanRdData     <= "000000000000" & Llink1ClkRXRdData_i;
    end generate RX1_VLAN_STRP_TAG;
  
    RX1_VLAN_STRP : if (C_TEMAC1_RXVLAN_TRAN = 0 and C_TEMAC1_RXVLAN_STRP = 1 and C_TEMAC1_RXVLAN_TAG = 0 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkRXVlan1RdData   <= "000000000000" & plbClkRXVlan1RdData_i & '0' when (Bus2IP_RdCE(39) = '1') else
                              (others => '0');
      plbClkRXVlan1WrData_i <= Bus2IP_Data(30 to 30);
      Llink1ClkRXVlanRdData     <= "000000000000" & Llink1ClkRXRdData_i & '0';
    end generate RX1_VLAN_STRP;
  
    RX1_VLAN_TAG : if (C_TEMAC1_RXVLAN_TRAN = 0 and C_TEMAC1_RXVLAN_STRP = 0 and C_TEMAC1_RXVLAN_TAG = 1 and C_TEMAC1_ENABLED = 1) generate
    begin
      plbClkRXVlan1RdData   <= "000000000000" & '0' & plbClkRXVlan1RdData_i when (Bus2IP_RdCE(39) = '1') else
                              (others => '0');
      plbClkRXVlan1WrData_i <= Bus2IP_Data(31 to 31);
      Llink1ClkRXVlanRdData     <= "000000000000" & '0' & Llink1ClkRXRdData_i;
    end generate RX1_VLAN_TAG;
  
    RX1_VLAN_NONE : if ((C_TEMAC1_RXVLAN_TRAN = 0 and C_TEMAC1_RXVLAN_STRP = 0 and C_TEMAC1_RXVLAN_TAG = 0) or C_TEMAC1_ENABLED = 0) generate
    begin
      plbClkRXVlan1RdData   <= (others => '0');
      Llink1ClkRXVlanRdData     <= (others => '0');
    end generate RX1_VLAN_NONE;

  IP2Bus_WrAck<= iP2Bus_WrAck_i;
  IP2Bus_RdAck<= iP2Bus_RdAck_i;
  
  pipel_PROCESS : process (RawReset, PlbClk)
  begin
    if (PlbClk'event and PlbClk = '1') then
      if (RawReset = '1') then
        DCR_Read      <= '0';
        DCR_Write     <= '0';
        DCR_ABus      <= (others => '0');
        DCRTemac_DBus <= (others => '0');
      else
        DCR_Read      <= dCR_Read_i;     
        DCR_Write     <= dCR_Write_i;    
        DCR_ABus      <= dCR_ABus_i;     
        DCRTemac_DBus <= dCRTemac_DBus_i;
      end if;
    end if;
  end process;

  Is0RegData    <= is0RegData_i;
  Ie0RegData    <= ie0RegData_i;
  Ttag0RegData  <= ttag0RegData_i;
  Rtag0RegData  <= rtag0RegData_i;
  Tpid00RegData <= tpid00RegData_i;
  Tpid01RegData <= tpid01RegData_i;
  UawL0RegData  <= uawL0RegData_i;
  UawU0RegData  <= uawU0RegData_i;
  
  CR0_I :  entity xps_ll_temac_v2_03_a.reg_cr(imp)
    port map
    (
     Clk      => PlbClk,                   -- in
                                                        
     Ref_clk  => Ref_clk,
     Host_clk => Host_clk,
     txClClk  => txClClk,
     rxClClk  => rxClClk,
     
     RST      => RawReset,              -- in
     RawReset => RawReset,              -- in
     RdCE     => Bus2IP_RdCE(0),        -- in
     WrCE     => Bus2IP_WrCE(0),        -- in
     DataIn   => Bus2IP_Data(18 to 31), -- in
     DataOut  => cr0RdData,             -- out
     RegData  => Cr0RegData             -- out
    );
  
  TP0_I :  entity xps_ll_temac_v2_03_a.reg_tp(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(1),	-- in
     WrCE     => Bus2IP_WrCE(1),	-- in
     DataIn   => Bus2IP_Data(16 to 31), -- in
     DataOut  => tp0RdData,	        -- out
     RegData  => Tp0RegData,	        -- out
     TPReq    => TPReq0		        -- out
    );
   
  IFGP0_I :  entity xps_ll_temac_v2_03_a.reg_ifgp(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(2),	-- in
     WrCE     => Bus2IP_WrCE(2),	-- in
     DataIn   => Bus2IP_Data(24 to 31), -- in
     DataOut  => ifgp0RdData,	        -- out
     RegData  => Ifgp0RegData	        -- out
    );				   
  
  IS0_I :  entity xps_ll_temac_v2_03_a.reg_is(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(3),	-- in
     WrCE     => Bus2IP_WrCE(3),	-- in
     Intrpts  => Intrpts0,	        -- in
     DataIn   => Bus2IP_Data(24 to 31), -- out
     DataOut  => is0RdData,	        -- out
     RegData  => is0RegData_i	        -- out
    );
  
  IP0_I :  entity xps_ll_temac_v2_03_a.reg_ip(imp)
    port map
    (
     Clk      => PlbClk,	            -- in
     RST      => RawReset,	    -- in
     RdCE     => Bus2IP_RdCE(4),    -- in
     IsIn     => is0RegData_i,	    -- in
     IeIn     => ie0RegData_i,	    -- in
     DataOut  => ip0RdData,	    -- out
     RegData  => Ip0RegData,	    -- out
     Intrpt   => Intrpt0	    -- out
    );
  
  IE0_I :  entity xps_ll_temac_v2_03_a.reg_ie(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(5),	-- in
     WrCE     => Bus2IP_WrCE(5),	-- in
     DataIn   => Bus2IP_Data(24 to 31), -- in
     DataOut  => ie0RdData,	        -- out
     RegData  => ie0RegData_i	        -- out
    );				    
  
  TTAG0_I :  entity xps_ll_temac_v2_03_a.reg_32b(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(6),	-- in
     WrCE     => Bus2IP_WrCE(6),	-- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => ttag0RdData,	        -- out
     RegData  => ttag0RegData_i	        -- out
    );				    
  
  RTAG0_I :  entity xps_ll_temac_v2_03_a.reg_32b(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(7),	-- in
     WrCE     => Bus2IP_WrCE(7),	-- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => rtag0RdData,	        -- out
     RegData  => rtag0RegData_i	        -- out
    );				    
  
  UAWL0_I :  entity xps_ll_temac_v2_03_a.reg_32b(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(12),	-- in
     WrCE     => Bus2IP_WrCE(12),	-- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => uawL0RdData,	        -- out
     RegData  => uawL0RegData_i         -- out
    );				    
  
  UAWU0_I :  entity xps_ll_temac_v2_03_a.reg_16bl(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(13),	-- in
     WrCE     => Bus2IP_WrCE(13),	-- in
     DataIn   => Bus2IP_Data(16 to 31), -- in
     DataOut  => uawU0RdData,	        -- out
     RegData  => uawU0RegData_i	        -- out
    );
  
  TPID00_I :  entity xps_ll_temac_v2_03_a.reg_32b(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(14),	-- in
     WrCE     => Bus2IP_WrCE(14),	-- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => tpid00RdData,	        -- out
     RegData  => tpid00RegData_i        -- out
    );				    
  
  TPID01_I :  entity xps_ll_temac_v2_03_a.reg_32b(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(15),	-- in
     WrCE     => Bus2IP_WrCE(15),	-- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => tpid01RdData,	        -- out
     RegData  => tpid01RegData_i        -- out
    );				    

  EXTENDED_MULTICAST0 : if (C_TEMAC0_MCAST_EXTEND = 1) generate
  begin
    I_MULTICAST0_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
      generic map(
        c_family                 => C_FAMILY,
        c_xdevicefamily          => C_FAMILY, 

        -- Memory Specific Configurations
        c_mem_type               => 2,
           -- This wrapper only supports the True Dual Port RAM
           -- 0: Single Port RAM
           -- 1: Simple Dual Port RAM
           -- 2: True Dual Port RAM
           -- 3: Single Port Rom
           -- 4: Dual Port RAM
        c_algorithm              => 1,
           -- 0: Selectable Primative
           -- 1: Minimum Area
        c_prim_type              => 0,
           -- 0: ( 1-bit wide)
           -- 1: ( 2-bit wide)
           -- 2: ( 4-bit wide)
           -- 3: ( 9-bit wide)
           -- 4: (18-bit wide)
           -- 5: (36-bit wide)
           -- 6: (72-bit wide, single port only)
        c_byte_size              => 8,   -- 8 or 9

        -- Simulation Behavior Options
        c_sim_collision_check    => "NONE",
           -- "None"
           -- "Generate_X"
           -- "All"
           -- "Warnings_only"
        c_common_clk             => 0,   -- 0, 1
        c_disable_warn_bhv_coll  => 0,   -- 0, 1
        c_disable_warn_bhv_range => 0,   -- 0, 1

        -- Initialization Configuration Options
        c_load_init_file         => 0,
        c_init_file_name         => "no_coe_file_loaded",
        c_use_default_data       => 0,   -- 0, 1
        c_default_data           => "0", -- "..."

        -- Port A Specific Configurations
        c_has_mem_output_regs_a  => 0,   -- 0, 1
        c_has_mux_output_regs_a  => 0,   -- 0, 1
        c_write_width_a          => 1,  -- 1 to 1152
        c_read_width_a           => 1,  -- 1 to 1152
        c_write_depth_a          => 32768,  -- 2 to 9011200
        c_read_depth_a           => 32768,  -- 2 to 9011200
        c_addra_width            => 15,   -- 1 to 24
        c_write_mode_a           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_ena                => 1,   -- 0, 1
        c_has_regcea             => 0,   -- 0, 1
        c_has_ssra               => 0,   -- 0, 1
        c_sinita_val             => "0", --"..."
        c_use_byte_wea           => 0,   -- 0, 1
        c_wea_width              => 1,   -- 1 to 128

        -- Port B Specific Configurations
        c_has_mem_output_regs_b  => 0,   -- 0, 1
        c_has_mux_output_regs_b  => 0,   -- 0, 1
        c_write_width_b          => 1,  -- 1 to 1152
        c_read_width_b           => 1,  -- 1 to 1152
        c_write_depth_b          => 32768,  -- 2 to 9011200
        c_read_depth_b           => 32768,   -- 2 to 9011200
        c_addrb_width            => 15,   -- 1 to 24
        c_write_mode_b           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_enb                => 0,   -- 0, 1
        c_has_regceb             => 0,   -- 0, 1
        c_has_ssrb               => 0,   -- 0, 1
        c_sinitb_val             => "0", -- "..."
        c_use_byte_web           => 0,   -- 0, 1
        c_web_width              => 1,   -- 1 to 128

        -- Other Miscellaneous Configurations
        c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
           -- The number of pipeline stages within the MUX
           --    for both Port A and Port B
        c_use_ecc                => 0,
           -- See DS512 for the limited core option selections for ECC support
        c_use_ramb16bwer_rst_bhv => 0    --0, 1
        )
      port map
        (
        clka    => RxClClk0,       --: in  std_logic;
        ssra    => '0',            --: in  std_logic := '0';
        dina    => "0",            --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
        addra   => RxClClkMcastAddr0,   --: in  std_logic_vector(c_addra_width-1   downto 0);
        ena     => RxClClkMcastEn0,     --: in  std_logic := '1';
        regcea  => '0',            --: in  std_logic := '1';
        wea     => "0",            --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
        douta   => RxClClkMcastRdData0, --: out std_logic_vector(c_read_width_a-1  downto 0);

        clkb    => PlbClk,    --: in  std_logic := '0';
        ssrb    => '0',            --: in  std_logic := '0';
        dinb    => Bus2IP_Data(31 to 31),--: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
        addrb   => Bus2IP_Addr(15 to 29),--: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
        enb     => bus2IP_WrCE_36_en,            --: in  std_logic := '1';
        regceb  => '0',            --: in  std_logic := '1';
        web     => Bus2IP_WrCE(36 to 36),--: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
        doutb   => plbClkMcast0RdData_i,--: out std_logic_vector(c_read_width_b-1  downto 0);

        dbiterr => open,           --: out std_logic;
           -- Double bit error that that cannot be auto corrected by ECC
        sbiterr => open            --: out std_logic
           -- Single Bit Error that has been auto corrected on the output bus
        );
    plbClkMcast0RdData(0) <= plbClkMcast0RdData_i(0) and Bus2IP_RdCE(36);
  end generate EXTENDED_MULTICAST0;

  NO_EXTENDED_MULTICAST0 : if (C_TEMAC0_MCAST_EXTEND = 0) generate
  begin
    RxClClkMcastRdData0 <= (others => '0');
    plbClkMcast0RdData  <= (others => '0');
  end generate NO_EXTENDED_MULTICAST0;

  EXTENDED_MULTICAST1 : if (C_TEMAC1_MCAST_EXTEND = 1 and C_TEMAC1_ENABLED = 1) generate
  begin
    I_MULTICAST1_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
      generic map(
        c_family                 => C_FAMILY,
        c_xdevicefamily          => C_FAMILY, 

        -- Memory Specific Configurations
        c_mem_type               => 2,
           -- This wrapper only supports the True Dual Port RAM
           -- 0: Single Port RAM
           -- 1: Simple Dual Port RAM
           -- 2: True Dual Port RAM
           -- 3: Single Port Rom
           -- 4: Dual Port RAM
        c_algorithm              => 1,
           -- 0: Selectable Primative
           -- 1: Minimum Area
        c_prim_type              => 0,
           -- 0: ( 1-bit wide)
           -- 1: ( 2-bit wide)
           -- 2: ( 4-bit wide)
           -- 3: ( 9-bit wide)
           -- 4: (18-bit wide)
           -- 5: (36-bit wide)
           -- 6: (72-bit wide, single port only)
        c_byte_size              => 8,   -- 8 or 9

        -- Simulation Behavior Options
        c_sim_collision_check    => "NONE",
           -- "None"
           -- "Generate_X"
           -- "All"
           -- "Warnings_only"
        c_common_clk             => 0,   -- 0, 1
        c_disable_warn_bhv_coll  => 0,   -- 0, 1
        c_disable_warn_bhv_range => 0,   -- 0, 1

        -- Initialization Configuration Options
        c_load_init_file         => 0,
        c_init_file_name         => "no_coe_file_loaded",
        c_use_default_data       => 0,   -- 0, 1
        c_default_data           => "0", -- "..."

        -- Port A Specific Configurations
        c_has_mem_output_regs_a  => 0,   -- 0, 1
        c_has_mux_output_regs_a  => 0,   -- 0, 1
        c_write_width_a          => 1,  -- 1 to 1152
        c_read_width_a           => 1,  -- 1 to 1152
        c_write_depth_a          => 32768,  -- 2 to 9011200
        c_read_depth_a           => 32768,  -- 2 to 9011200
        c_addra_width            => 15,   -- 1 to 24
        c_write_mode_a           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_ena                => 1,   -- 0, 1
        c_has_regcea             => 0,   -- 0, 1
        c_has_ssra               => 0,   -- 0, 1
        c_sinita_val             => "0", --"..."
        c_use_byte_wea           => 0,   -- 0, 1
        c_wea_width              => 1,   -- 1 to 128

        -- Port B Specific Configurations
        c_has_mem_output_regs_b  => 0,   -- 0, 1
        c_has_mux_output_regs_b  => 0,   -- 0, 1
        c_write_width_b          => 1,  -- 1 to 1152
        c_read_width_b           => 1,  -- 1 to 1152
        c_write_depth_b          => 32768,  -- 2 to 9011200
        c_read_depth_b           => 32768,   -- 2 to 9011200
        c_addrb_width            => 15,   -- 1 to 24
        c_write_mode_b           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_enb                => 0,   -- 0, 1
        c_has_regceb             => 0,   -- 0, 1
        c_has_ssrb               => 0,   -- 0, 1
        c_sinitb_val             => "0", -- "..."
        c_use_byte_web           => 0,   -- 0, 1
        c_web_width              => 1,   -- 1 to 128

        -- Other Miscellaneous Configurations
        c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
           -- The number of pipeline stages within the MUX
           --    for both Port A and Port B
        c_use_ecc                => 0,
           -- See DS512 for the limited core option selections for ECC support
        c_use_ramb16bwer_rst_bhv => 0    --0, 1
        )
      port map
        (
        clka    => RxClClk1,       --: in  std_logic;
        ssra    => '0',            --: in  std_logic := '0';
        dina    => "0",            --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
        addra   => RxClClkMcastAddr1,   --: in  std_logic_vector(c_addra_width-1   downto 0);
        ena     => RxClClkMcastEn1,     --: in  std_logic := '1';
        regcea  => '0',            --: in  std_logic := '1';
        wea     => "0",            --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
        douta   => RxClClkMcastRdData1, --: out std_logic_vector(c_read_width_a-1  downto 0);

        clkb    => PlbClk,    --: in  std_logic := '0';
        ssrb    => '0',            --: in  std_logic := '0';
        dinb    => Bus2IP_Data(31 to 31),--: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
        addrb   => Bus2IP_Addr(15 to 29),--: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
        enb     => bus2IP_WrCE_41_en,            --: in  std_logic := '1';
        regceb  => '0',            --: in  std_logic := '1';
        web     => Bus2IP_WrCE(41 to 41),--: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
        doutb   => plbClkMcast1RdData_i,--: out std_logic_vector(c_read_width_b-1  downto 0);

        dbiterr => open,           --: out std_logic;
           -- Double bit error that that cannot be auto corrected by ECC
        sbiterr => open            --: out std_logic
           -- Single Bit Error that has been auto corrected on the output bus
        );
    plbClkMcast1RdData(0) <= plbClkMcast1RdData_i(0) and Bus2IP_RdCE(41);
  end generate EXTENDED_MULTICAST1;

  NO_EXTENDED_MULTICAST1 : if (C_TEMAC1_MCAST_EXTEND = 0 or C_TEMAC1_ENABLED = 0) generate
  begin
    RxClClkMcastRdData1 <= (others => '0');
    plbClkMcast1RdData  <= (others => '0');
  end generate NO_EXTENDED_MULTICAST1;

  TX_VLAN_BRAM0 : if (C_TEMAC0_TXVLAN_TRAN = 1 or C_TEMAC0_TXVLAN_TAG = 1 or C_TEMAC0_TXVLAN_STRP = 1) generate
  begin
    I_TX_VLAN0_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
      generic map(
        c_family                 => C_FAMILY,
        c_xdevicefamily          => C_FAMILY, 

        -- Memory Specific Configurations
        c_mem_type               => 2,
           -- This wrapper only supports the True Dual Port RAM
           -- 0: Single Port RAM
           -- 1: Simple Dual Port RAM
           -- 2: True Dual Port RAM
           -- 3: Single Port Rom
           -- 4: Dual Port RAM
        c_algorithm              => 1,
           -- 0: Selectable Primative
           -- 1: Minimum Area
        c_prim_type              => 3,
           -- 0: ( 1-bit wide)
           -- 1: ( 2-bit wide)
           -- 2: ( 4-bit wide)
           -- 3: ( 9-bit wide)
           -- 4: (18-bit wide)
           -- 5: (36-bit wide)
           -- 6: (72-bit wide, single port only)
        c_byte_size              => 8,   -- 8 or 9

        -- Simulation Behavior Options
        c_sim_collision_check    => "NONE",
           -- "None"
           -- "Generate_X"
           -- "All"
           -- "Warnings_only"
        c_common_clk             => 0,   -- 0, 1
        c_disable_warn_bhv_coll  => 0,   -- 0, 1
        c_disable_warn_bhv_range => 0,   -- 0, 1

        -- Initialization Configuration Options
        c_load_init_file         => 0,
        c_init_file_name         => "no_coe_file_loaded",
        c_use_default_data       => 0,   -- 0, 1
        c_default_data           => "0", -- "..."

        -- Port A Specific Configurations
        c_has_mem_output_regs_a  => 0,   -- 0, 1
        c_has_mux_output_regs_a  => 0,   -- 0, 1
        c_write_width_a          => C_TEMAC0_TXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_a           => C_TEMAC0_TXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_a          => 4096,  -- 2 to 9011200
        c_read_depth_a           => 4096,  -- 2 to 9011200
        c_addra_width            => 12,   -- 1 to 24
        c_write_mode_a           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_ena                => 0,   -- 0, 1
        c_has_regcea             => 0,   -- 0, 1
        c_has_ssra               => 0,   -- 0, 1
        c_sinita_val             => "0", --"..."
        c_use_byte_wea           => 0,   -- 0, 1
        c_wea_width              => 1,   -- 1 to 128

        -- Port B Specific Configurations
        c_has_mem_output_regs_b  => 0,   -- 0, 1
        c_has_mux_output_regs_b  => 0,   -- 0, 1
        c_write_width_b          => C_TEMAC0_TXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_b           => C_TEMAC0_TXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_b          => 4096,  -- 2 to 9011200
        c_read_depth_b           => 4096,   -- 2 to 9011200
        c_addrb_width            => 12,   -- 1 to 24
        c_write_mode_b           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_enb                => 0,   -- 0, 1
        c_has_regceb             => 0,   -- 0, 1
        c_has_ssrb               => 0,   -- 0, 1
        c_sinitb_val             => "0", -- "..."
        c_use_byte_web           => 0,   -- 0, 1
        c_web_width              => 1,   -- 1 to 128

        -- Other Miscellaneous Configurations
        c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
           -- The number of pipeline stages within the MUX
           --    for both Port A and Port B
        c_use_ecc                => 0,
           -- See DS512 for the limited core option selections for ECC support
        c_use_ramb16bwer_rst_bhv => 0    --0, 1
        )
      port map
        (
        clka    => Llink0_CLK,     --: in  std_logic;
        ssra    => '0',            --: in  std_logic := '0';
        dina    => temac0_txvlan_dina, --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
        addra   => Llink0ClkTxAddr,  --: in  std_logic_vector(c_addra_width-1   downto 0);
        ena     => Llink0ClkTxVlanBramEnA,            --: in  std_logic := '1';
        regcea  => '0',            --: in  std_logic := '1';
        wea     => "0",            --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
        douta   => llink0ClkTxRdData_i,--: out std_logic_vector(c_read_width_a-1  downto 0);

        clkb    => PlbClk,    --: in  std_logic := '0';
        ssrb    => '0',            --: in  std_logic := '0';
        dinb    => plbClkTxVlan0WrData_i,--: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
        addrb   => Bus2IP_Addr(18 to 29),--: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
        enb     => bus2IP_WrCE_33_en,            --: in  std_logic := '1';
        regceb  => '0',            --: in  std_logic := '1';
        web     => Bus2IP_WrCE(33 to 33),--: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
        doutb   => plbClkTxVlan0RdData_i,--: out std_logic_vector(c_read_width_b-1  downto 0);

        dbiterr => open,           --: out std_logic;
           -- Double bit error that that cannot be auto corrected by ECC
        sbiterr => open            --: out std_logic
           -- Single Bit Error that has been auto corrected on the output bus
        );
  end generate TX_VLAN_BRAM0;

  TX_VLAN_BRAM1 : if ((C_TEMAC1_TXVLAN_TRAN = 1 or C_TEMAC1_TXVLAN_TAG = 1 or C_TEMAC1_TXVLAN_STRP = 1) and C_TEMAC1_ENABLED = 1) generate
  begin
    I_TX_VLAN1_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
      generic map(
        c_family                 => C_FAMILY,
        c_xdevicefamily          => C_FAMILY, 

        -- Memory Specific Configurations
        c_mem_type               => 2,
           -- This wrapper only supports the True Dual Port RAM
           -- 0: Single Port RAM
           -- 1: Simple Dual Port RAM
           -- 2: True Dual Port RAM
           -- 3: Single Port Rom
           -- 4: Dual Port RAM
        c_algorithm              => 1,
           -- 0: Selectable Primative
           -- 1: Minimum Area
        c_prim_type              => 3,
           -- 0: ( 1-bit wide)
           -- 1: ( 2-bit wide)
           -- 2: ( 4-bit wide)
           -- 3: ( 9-bit wide)
           -- 4: (18-bit wide)
           -- 5: (36-bit wide)
           -- 6: (72-bit wide, single port only)
        c_byte_size              => 8,   -- 8 or 9

        -- Simulation Behavior Options
        c_sim_collision_check    => "NONE",
           -- "None"
           -- "Generate_X"
           -- "All"
           -- "Warnings_only"
        c_common_clk             => 0,   -- 0, 1
        c_disable_warn_bhv_coll  => 0,   -- 0, 1
        c_disable_warn_bhv_range => 0,   -- 0, 1

        -- Initialization Configuration Options
        c_load_init_file         => 0,
        c_init_file_name         => "no_coe_file_loaded",
        c_use_default_data       => 0,   -- 0, 1
        c_default_data           => "0", -- "..."

        -- Port A Specific Configurations
        c_has_mem_output_regs_a  => 0,   -- 0, 1
        c_has_mux_output_regs_a  => 0,   -- 0, 1
        c_write_width_a          => C_TEMAC1_TXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_a           => C_TEMAC1_TXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_a          => 4096,  -- 2 to 9011200
        c_read_depth_a           => 4096,  -- 2 to 9011200
        c_addra_width            => 12,   -- 1 to 24
        c_write_mode_a           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_ena                => 0,   -- 0, 1
        c_has_regcea             => 0,   -- 0, 1
        c_has_ssra               => 0,   -- 0, 1
        c_sinita_val             => "0", --"..."
        c_use_byte_wea           => 0,   -- 0, 1
        c_wea_width              => 1,   -- 1 to 128

        -- Port B Specific Configurations
        c_has_mem_output_regs_b  => 0,   -- 0, 1
        c_has_mux_output_regs_b  => 0,   -- 0, 1
        c_write_width_b          => C_TEMAC1_TXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_b           => C_TEMAC1_TXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_b          => 4096,  -- 2 to 9011200
        c_read_depth_b           => 4096,   -- 2 to 9011200
        c_addrb_width            => 12,   -- 1 to 24
        c_write_mode_b           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_enb                => 0,   -- 0, 1
        c_has_regceb             => 0,   -- 0, 1
        c_has_ssrb               => 0,   -- 0, 1
        c_sinitb_val             => "0", -- "..."
        c_use_byte_web           => 0,   -- 0, 1
        c_web_width              => 1,   -- 1 to 128

        -- Other Miscellaneous Configurations
        c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
           -- The number of pipeline stages within the MUX
           --    for both Port A and Port B
        c_use_ecc                => 0,
           -- See DS512 for the limited core option selections for ECC support
        c_use_ramb16bwer_rst_bhv => 0    --0, 1
        )
      port map
        (
        clka    => Llink1_CLK,     --: in  std_logic;
        ssra    => '0',            --: in  std_logic := '0';
        dina    => temac1_txvlan_dina, --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
        addra   => Llink1ClkTxAddr,  --: in  std_logic_vector(c_addra_width-1   downto 0);
        ena     => Llink1ClkTxVlanBramEnA,            --: in  std_logic := '1';
        regcea  => '0',            --: in  std_logic := '1';
        wea     => "0",            --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
        douta   => llink1ClkTxRdData_i,--: out std_logic_vector(c_read_width_a-1  downto 0);

        clkb    => PlbClk,    --: in  std_logic := '0';
        ssrb    => '0',            --: in  std_logic := '0';
        dinb    => plbClkTxVlan1WrData_i,--: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
        addrb   => Bus2IP_Addr(18 to 29),--: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
        enb     => bus2IP_WrCE_38_en,            --: in  std_logic := '1';
        regceb  => '0',            --: in  std_logic := '1';
        web     => Bus2IP_WrCE(38 to 38),--: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
        doutb   => plbClkTxVlan1RdData_i,--: out std_logic_vector(c_read_width_b-1  downto 0);

        dbiterr => open,           --: out std_logic;
           -- Double bit error that that cannot be auto corrected by ECC
        sbiterr => open            --: out std_logic
           -- Single Bit Error that has been auto corrected on the output bus
        );
  end generate TX_VLAN_BRAM1;

  RX_VLAN_BRAM0 : if (C_TEMAC0_RXVLAN_TRAN = 1 or C_TEMAC0_RXVLAN_TAG = 1 or C_TEMAC0_RXVLAN_STRP = 1) generate
  begin
    I_RX_VLAN0_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
      generic map(
        c_family                 => C_FAMILY,
        c_xdevicefamily          => C_FAMILY, 

        -- Memory Specific Configurations
        c_mem_type               => 2,
           -- This wrapper only supports the True Dual Port RAM
           -- 0: Single Port RAM
           -- 1: Simple Dual Port RAM
           -- 2: True Dual Port RAM
           -- 3: Single Port Rom
           -- 4: Dual Port RAM
        c_algorithm              => 1,
           -- 0: Selectable Primative
           -- 1: Minimum Area
        c_prim_type              => 3,
           -- 0: ( 1-bit wide)
           -- 1: ( 2-bit wide)
           -- 2: ( 4-bit wide)
           -- 3: ( 9-bit wide)
           -- 4: (18-bit wide)
           -- 5: (36-bit wide)
           -- 6: (72-bit wide, single port only)
        c_byte_size              => 8,   -- 8 or 9

        -- Simulation Behavior Options
        c_sim_collision_check    => "NONE",
           -- "None"
           -- "Generate_X"
           -- "All"
           -- "Warnings_only"
        c_common_clk             => 0,   -- 0, 1
        c_disable_warn_bhv_coll  => 0,   -- 0, 1
        c_disable_warn_bhv_range => 0,   -- 0, 1

        -- Initialization Configuration Options
        c_load_init_file         => 0,
        c_init_file_name         => "no_coe_file_loaded",
        c_use_default_data       => 0,   -- 0, 1
        c_default_data           => "0", -- "..."

        -- Port A Specific Configurations
        c_has_mem_output_regs_a  => 0,   -- 0, 1
        c_has_mux_output_regs_a  => 0,   -- 0, 1
        c_write_width_a          => C_TEMAC0_RXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_a           => C_TEMAC0_RXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_a          => 4096,  -- 2 to 9011200
        c_read_depth_a           => 4096,  -- 2 to 9011200
        c_addra_width            => 12,   -- 1 to 24
        c_write_mode_a           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_ena                => 0,   -- 0, 1
        c_has_regcea             => 0,   -- 0, 1
        c_has_ssra               => 0,   -- 0, 1
        c_sinita_val             => "0", --"..."
        c_use_byte_wea           => 0,   -- 0, 1
        c_wea_width              => 1,   -- 1 to 128

        -- Port B Specific Configurations
        c_has_mem_output_regs_b  => 0,   -- 0, 1
        c_has_mux_output_regs_b  => 0,   -- 0, 1
        c_write_width_b          => C_TEMAC0_RXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_b           => C_TEMAC0_RXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_b          => 4096,  -- 2 to 9011200
        c_read_depth_b           => 4096,   -- 2 to 9011200
        c_addrb_width            => 12,   -- 1 to 24
        c_write_mode_b           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_enb                => 0,   -- 0, 1
        c_has_regceb             => 0,   -- 0, 1
        c_has_ssrb               => 0,   -- 0, 1
        c_sinitb_val             => "0", -- "..."
        c_use_byte_web           => 0,   -- 0, 1
        c_web_width              => 1,   -- 1 to 128

        -- Other Miscellaneous Configurations
        c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
           -- The number of pipeline stages within the MUX
           --    for both Port A and Port B
        c_use_ecc                => 0,
           -- See DS512 for the limited core option selections for ECC support
        c_use_ramb16bwer_rst_bhv => 0    --0, 1
        )
      port map
        (
        clka    => Llink0_CLK,     --: in  std_logic;
        ssra    => '0',            --: in  std_logic := '0';
        dina    => temac0_rxvlan_dina, --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
        addra   => Llink0ClkRxVlanAddr,  --: in  std_logic_vector(c_addra_width-1   downto 0);
        ena     => Llink0ClkRxVlanBramEnA,            --: in  std_logic := '1';
        regcea  => '0',            --: in  std_logic := '1';
        wea     => "0",            --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
        douta   => llink0ClkRxRdData_i,--: out std_logic_vector(c_read_width_a-1  downto 0);

        clkb    => PlbClk,    --: in  std_logic := '0';
        ssrb    => '0',            --: in  std_logic := '0';
        dinb    => plbClkRxVlan0WrData_i,--: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
        addrb   => Bus2IP_Addr(18 to 29),--: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
        enb     => bus2IP_WrCE_34_en,            --: in  std_logic := '1';
        regceb  => '0',            --: in  std_logic := '1';
        web     => Bus2IP_WrCE(34 to 34),--: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
        doutb   => plbClkRxVlan0RdData_i,--: out std_logic_vector(c_read_width_b-1  downto 0);

        dbiterr => open,           --: out std_logic;
           -- Double bit error that that cannot be auto corrected by ECC
        sbiterr => open            --: out std_logic
           -- Single Bit Error that has been auto corrected on the output bus
        );
  end generate RX_VLAN_BRAM0;

  RX_VLAN_BRAM1 : if ((C_TEMAC1_RXVLAN_TRAN = 1 or C_TEMAC1_RXVLAN_TAG = 1 or C_TEMAC1_RXVLAN_STRP = 1) and C_TEMAC1_ENABLED = 1) generate
  begin
    I_RX_VLAN1_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
      generic map(
        c_family                 => C_FAMILY,
        c_xdevicefamily          => C_FAMILY, 

        -- Memory Specific Configurations
        c_mem_type               => 2,
           -- This wrapper only supports the True Dual Port RAM
           -- 0: Single Port RAM
           -- 1: Simple Dual Port RAM
           -- 2: True Dual Port RAM
           -- 3: Single Port Rom
           -- 4: Dual Port RAM
        c_algorithm              => 1,
           -- 0: Selectable Primative
           -- 1: Minimum Area
        c_prim_type              => 3,
           -- 0: ( 1-bit wide)
           -- 1: ( 2-bit wide)
           -- 2: ( 4-bit wide)
           -- 3: ( 9-bit wide)
           -- 4: (18-bit wide)
           -- 5: (36-bit wide)
           -- 6: (72-bit wide, single port only)
        c_byte_size              => 8,   -- 8 or 9

        -- Simulation Behavior Options
        c_sim_collision_check    => "NONE",
           -- "None"
           -- "Generate_X"
           -- "All"
           -- "Warnings_only"
        c_common_clk             => 0,   -- 0, 1
        c_disable_warn_bhv_coll  => 0,   -- 0, 1
        c_disable_warn_bhv_range => 0,   -- 0, 1

        -- Initialization Configuration Options
        c_load_init_file         => 0,
        c_init_file_name         => "no_coe_file_loaded",
        c_use_default_data       => 0,   -- 0, 1
        c_default_data           => "0", -- "..."

        -- Port A Specific Configurations
        c_has_mem_output_regs_a  => 0,   -- 0, 1
        c_has_mux_output_regs_a  => 0,   -- 0, 1
        c_write_width_a          => C_TEMAC1_RXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_a           => C_TEMAC1_RXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_a          => 4096,  -- 2 to 9011200
        c_read_depth_a           => 4096,  -- 2 to 9011200
        c_addra_width            => 12,   -- 1 to 24
        c_write_mode_a           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_ena                => 0,   -- 0, 1
        c_has_regcea             => 0,   -- 0, 1
        c_has_ssra               => 0,   -- 0, 1
        c_sinita_val             => "0", --"..."
        c_use_byte_wea           => 0,   -- 0, 1
        c_wea_width              => 1,   -- 1 to 128

        -- Port B Specific Configurations
        c_has_mem_output_regs_b  => 0,   -- 0, 1
        c_has_mux_output_regs_b  => 0,   -- 0, 1
        c_write_width_b          => C_TEMAC1_RXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_b           => C_TEMAC1_RXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_b          => 4096,  -- 2 to 9011200
        c_read_depth_b           => 4096,   -- 2 to 9011200
        c_addrb_width            => 12,   -- 1 to 24
        c_write_mode_b           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_enb                => 0,   -- 0, 1
        c_has_regceb             => 0,   -- 0, 1
        c_has_ssrb               => 0,   -- 0, 1
        c_sinitb_val             => "0", -- "..."
        c_use_byte_web           => 0,   -- 0, 1
        c_web_width              => 1,   -- 1 to 128

        -- Other Miscellaneous Configurations
        c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
           -- The number of pipeline stages within the MUX
           --    for both Port A and Port B
        c_use_ecc                => 0,
           -- See DS512 for the limited core option selections for ECC support
        c_use_ramb16bwer_rst_bhv => 0    --0, 1
        )
      port map
        (
        clka    => Llink1_CLK,     --: in  std_logic;
        ssra    => '0',            --: in  std_logic := '0';
        dina    => temac1_rxvlan_dina, --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
        addra   => Llink1ClkRxVlanAddr,  --: in  std_logic_vector(c_addra_width-1   downto 0);
        ena     => Llink1ClkRxVlanBramEnA,            --: in  std_logic := '1';
        regcea  => '0',            --: in  std_logic := '1';
        wea     => "0",            --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
        douta   => llink1ClkRxRdData_i,--: out std_logic_vector(c_read_width_a-1  downto 0);

        clkb    => PlbClk,    --: in  std_logic := '0';
        ssrb    => '0',            --: in  std_logic := '0';
        dinb    => plbClkRxVlan1WrData_i,--: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
        addrb   => Bus2IP_Addr(18 to 29),--: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
        enb     => bus2IP_WrCE_39_en,            --: in  std_logic := '1';
        regceb  => '0',            --: in  std_logic := '1';
        web     => Bus2IP_WrCE(39 to 39),--: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
        doutb   => plbClkRxVlan1RdData_i,--: out std_logic_vector(c_read_width_b-1  downto 0);

        dbiterr => open,           --: out std_logic;
           -- Double bit error that that cannot be auto corrected by ECC
        sbiterr => open            --: out std_logic
           -- Single Bit Error that has been auto corrected on the output bus
        );
  end generate RX_VLAN_BRAM1;

DUAL_SYS: if(C_TEMAC1_ENABLED = 1) generate
begin

  RD_ACK_BLOCKER_PROCESS : process (PlbClk,RawReset)
  begin
    if (PlbClk'event and PlbClk = '1') then
      if (RawReset = '1') then
        rdAckBlocker <= '0';
      else
        rdAckBlocker <= ((dCR_ack_i and (dCR_Read0 or dCR_Read1)) or softRead0_d1 or softRead1_d1) or -- set when = '1'
                        (rdAckBlocker and -- hold  when = '1'
                        ((dCR_ack_i and (dCR_Read0 or dCR_Read1)) or softRead0_d1 or softRead1_d1)); -- clear when = '0'
      end if;
    end if;
  end process;

  WR_ACK_BLOCKER_PROCESS : process (PlbClk,RawReset)
  begin
    if (PlbClk'event and PlbClk = '1') then
      if (RawReset = '1') then
        wrAckBlocker <= '0';
      else
        wrAckBlocker <= ((dCR_ack_i and (dCR_Write0 or dCR_Write1)) or softWrite0_d1 or softWrite1_d1) or -- set when = '1'
                        (wrAckBlocker and -- hold  when = '1'
                        ((dCR_ack_i and (dCR_Write0 or dCR_Write1)) or softWrite0_d1 or softWrite1_d1)); -- clear when = '0'
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- ACK_PROCESS
  --------------------------------------------------------------------------
  ACK_PROCESS : process (RawReset, PlbClk)
  begin
    if (PlbClk'event and PlbClk = '1') then
      if (RawReset = '1') then
        dCR_Read0_d1  <= '0';
        dCR_Write0_d1 <= '0';
        dCR_Read1_d1  <= '0';
        dCR_Write1_d1 <= '0';
        softRead0_d1  <= '0';
        softWrite0_d1 <= '0';
        softRead1_d1  <= '0';
        softWrite1_d1 <= '0';
        iP2Bus_WrAck_i  <= '0';
        iP2Bus_RdAck_i  <= '0';
      else
        dCR_Read0_d1  <= dCR_Read0;
        dCR_Write0_d1 <= dCR_Write0;
        dCR_Read1_d1  <= dCR_Read1;
        dCR_Write1_d1 <= dCR_Write1;
        softRead0_d1  <= softRead0;
        softWrite0_d1 <= softWrite0;
        softRead1_d1  <= softRead1;
        softWrite1_d1 <= softWrite1;
        iP2Bus_WrAck_i<= ((dCR_ack_i and (dCR_Write0 or dCR_Write1)) or
                         softWrite0_d1 or softWrite1_d1) and not(wrAckBlocker);
        iP2Bus_RdAck_i<= ((dCR_ack_i and (dCR_Read0 or dCR_Read1)) or
                         softRead0_d1  or softRead1_d1) and not(rdAckBlocker);
      end if;
    end if;
  end process;
  
  DCR_Clk     <= PlbClk;
  dCR_Read_i  <= dCR_Read0 or dCR_Read1;
  dCR_Read0   <= Bus2IP_RdCE(8) or
                 Bus2IP_RdCE(9) or
                 Bus2IP_RdCE(10)or
                 Bus2IP_RdCE(11);
  dCR_Read1   <= Bus2IP_RdCE(24)or
                 Bus2IP_RdCE(25)or
                 Bus2IP_RdCE(26)or
                 Bus2IP_RdCE(27);
  softRead0   <= Bus2IP_RdCE(0) or
                 Bus2IP_RdCE(1) or
                 Bus2IP_RdCE(2) or
                 Bus2IP_RdCE(3) or
                 Bus2IP_RdCE(4) or
                 Bus2IP_RdCE(5) or
                 Bus2IP_RdCE(6) or
                 Bus2IP_RdCE(7) or
                 Bus2IP_RdCE(12) or
                 Bus2IP_RdCE(13) or
                 Bus2IP_RdCE(14) or
                 Bus2IP_RdCE(15) or
                 --Bus2IP_RdCE(32) or
                 Bus2IP_RdCE(33) or
                 Bus2IP_RdCE(34) or
                 Bus2IP_RdCE(35) or
                 Bus2IP_RdCE(36);
  softRead1   <= Bus2IP_RdCE(16) or
                 Bus2IP_RdCE(17) or
                 Bus2IP_RdCE(18) or
                 Bus2IP_RdCE(19) or
                 Bus2IP_RdCE(20) or
                 Bus2IP_RdCE(21) or
                 Bus2IP_RdCE(22) or
                 Bus2IP_RdCE(23) or
                 Bus2IP_RdCE(28) or
                 Bus2IP_RdCE(29) or
                 Bus2IP_RdCE(30) or
                 Bus2IP_RdCE(31) or
                 --Bus2IP_RdCE(37) or
                 Bus2IP_RdCE(38) or
                 Bus2IP_RdCE(39) or
                 Bus2IP_RdCE(40) or
                 Bus2IP_RdCE(41);
  dCR_Write_i   <= dCR_Write0 or dCR_Write1;
  dCR_Write0  <= Bus2IP_WrCE(8) or
                 Bus2IP_WrCE(9) or
                 Bus2IP_WrCE(10)or
                 Bus2IP_WrCE(11);
  dCR_Write1  <= Bus2IP_WrCE(24)or
                 Bus2IP_WrCE(25)or
                 Bus2IP_WrCE(26)or
                 Bus2IP_WrCE(27);
  softWrite0  <= Bus2IP_WrCE(0) or
                 Bus2IP_WrCE(1) or
                 Bus2IP_WrCE(2) or
                 Bus2IP_WrCE(3) or
                 Bus2IP_WrCE(4) or
                 Bus2IP_WrCE(5) or
                 Bus2IP_WrCE(6) or
                 Bus2IP_WrCE(7) or
                 Bus2IP_WrCE(12) or
                 Bus2IP_WrCE(13) or
                 Bus2IP_WrCE(14) or
                 Bus2IP_WrCE(15) or
                 --Bus2IP_WrCE(32) or
                 Bus2IP_WrCE(33) or
                 Bus2IP_WrCE(34) or
                 Bus2IP_WrCE(35) or
                 Bus2IP_WrCE(36);
  softWrite1  <= Bus2IP_WrCE(16) or
                 Bus2IP_WrCE(17) or
                 Bus2IP_WrCE(18) or
                 Bus2IP_WrCE(19) or
                 Bus2IP_WrCE(20) or
                 Bus2IP_WrCE(21) or
                 Bus2IP_WrCE(22) or
                 Bus2IP_WrCE(23) or
                 Bus2IP_WrCE(28) or
                 Bus2IP_WrCE(29) or
                 Bus2IP_WrCE(30) or
                 Bus2IP_WrCE(31) or
                 --Bus2IP_WrCE(37) or
                 Bus2IP_WrCE(38) or
                 Bus2IP_WrCE(39) or
                 Bus2IP_WrCE(40) or
                 Bus2IP_WrCE(41);
  dcrTemac1Op <= dCR_Read1 or dCR_Write1;
  dCR_ABus_i    <= "0000000" & dcrTemac1Op & Bus2IP_Addr(28 to 29);
  dCR_ack_i   <= DCR_Ack;
  
  dCRTemac_DBus_i   <= Bus2IP_Data;
  temacDcr_DBus_i <= TemacDcr_DBus;
  
  Is1RegData <= is1RegData_i;
  Ie1RegData <= ie1RegData_i;
  Ttag1RegData<= ttag1RegData_i;
  Rtag1RegData<= rtag1RegData_i;
  Tpid10RegData <= tpid10RegData_i;
  Tpid11RegData <= tpid11RegData_i;
  UawL1RegData  <= uawL1RegData_i;
  UawU1RegData  <= uawU1RegData_i;

  CR1_I :  entity xps_ll_temac_v2_03_a.reg_cr(imp)
    port map
    (
     Clk      => PlbClk,                   -- in
                             
     Ref_clk  => Ref_clk,
     Host_clk => Host_clk,
     txClClk  => txClClk,
     rxClClk  => rxClClk,                            
     
     RST      => RawReset,              -- in
     RawReset => RawReset,              -- in
     RdCE     => Bus2IP_RdCE(16),       -- in
     WrCE     => Bus2IP_WrCE(16),       -- in
     DataIn   => Bus2IP_Data(18 to 31), -- in
     DataOut  => cr1RdData,             -- out
     RegData  => Cr1RegData             -- out
    );
  
  TP1_I :  entity xps_ll_temac_v2_03_a.reg_tp(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(17),	-- in
     WrCE     => Bus2IP_WrCE(17),	-- in
     DataIn   => Bus2IP_Data(16 to 31), -- in
     DataOut  => tp1RdData,	        -- out
     RegData  => Tp1RegData,	        -- out
     TPReq    => TPReq1		        -- out
    );
   
  IFGP1_I :  entity xps_ll_temac_v2_03_a.reg_ifgp(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(18),	-- in
     WrCE     => Bus2IP_WrCE(18),	-- in
     DataIn   => Bus2IP_Data(24 to 31), -- in
     DataOut  => ifgp1RdData,	        -- out
     RegData  => Ifgp1RegData	        -- out
    );				   
  
  IS1_I :  entity xps_ll_temac_v2_03_a.reg_is(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(19),	-- in
     WrCE     => Bus2IP_WrCE(19),	-- in
     Intrpts  => Intrpts1,	        -- in
     DataIn   => Bus2IP_Data(24 to 31), -- out
     DataOut  => is1RdData,	        -- out
     RegData  => is1RegData_i	        -- out
    );
  
  IP1_I :  entity xps_ll_temac_v2_03_a.reg_ip(imp)
    port map
    (
     Clk      => PlbClk,	            -- in
     RST      => RawReset,	    -- in
     RdCE     => Bus2IP_RdCE(20),   -- in
     IsIn     => is1RegData_i,	    -- in
     IeIn     => ie1RegData_i,	    -- in
     DataOut  => ip1RdData,	    -- out
     RegData  => Ip1RegData,	    -- out
     Intrpt   => Intrpt1	    -- out
    );
  
  IE1_I :  entity xps_ll_temac_v2_03_a.reg_ie(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(21),	-- in
     WrCE     => Bus2IP_WrCE(21),	-- in
     DataIn   => Bus2IP_Data(24 to 31), -- in
     DataOut  => ie1RdData,	        -- out
     RegData  => ie1RegData_i	        -- out
    );				    
  
  TTAG1_I :  entity xps_ll_temac_v2_03_a.reg_32b(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(22),	-- in
     WrCE     => Bus2IP_WrCE(22),	-- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => ttag1RdData,	        -- out
     RegData  => ttag1RegData_i	        -- out
    );				    
  
  RTAG1_I :  entity xps_ll_temac_v2_03_a.reg_32b(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(23),	-- in
     WrCE     => Bus2IP_WrCE(23),	-- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => rtag1RdData,	        -- out
     RegData  => rtag1RegData_i	        -- out
    );				    
  
  UAWL1_I :  entity xps_ll_temac_v2_03_a.reg_32b(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(28),	-- in
     WrCE     => Bus2IP_WrCE(28),	-- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => uawL1RdData,	        -- out
     RegData  => uawL1RegData_i         -- out
    );				    
  
  UAWU1_I :  entity xps_ll_temac_v2_03_a.reg_16bl(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(29),	-- in
     WrCE     => Bus2IP_WrCE(29),	-- in
     DataIn   => Bus2IP_Data(16 to 31), -- in
     DataOut  => uawU1RdData,	        -- out
     RegData  => uawU1RegData_i	        -- out
    );
  
  TPID10_I :  entity xps_ll_temac_v2_03_a.reg_32b(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(30),	-- in
     WrCE     => Bus2IP_WrCE(30),	-- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => tpid10RdData,	        -- out
     RegData  => tpid10RegData_i        -- out
    );				    
  
  TPID11_I :  entity xps_ll_temac_v2_03_a.reg_32b(imp)
    port map
    (
     Clk      => PlbClk,	                -- in
     RST      => RawReset,	        -- in
     RdCE     => Bus2IP_RdCE(31),	-- in
     WrCE     => Bus2IP_WrCE(31),	-- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => tpid11RdData,	        -- out
     RegData  => tpid11RegData_i        -- out
    );				    

  rdData  <= (
              ("000000000000000000" & cr0RdData) or
              ("0000000000000000" & tp0RdData) or
              ("000000000000000000000000" & ifgp0RdData)or
              ("000000000000000000000000" & is0RdData) or
              ("000000000000000000000000" & ie0RdData) or
              ("000000000000000000000000" & ip0RdData) or
              ttag0RdData or
              rtag0RdData or
              tpid00RdData or
              tpid01RdData or
              uawL0RdData or
              ("0000000000000000" & uawU0RdData) or
              ("0000000000000000000000000000000" & plbClkMcast0RdData) or
              ("000000000000000000" & plbClkTxVlan0RdData) or
              ("000000000000000000" & plbClkRxVlan0RdData) or
              ("000000000000000000" & cr1RdData) or
              ("0000000000000000" & tp1RdData) or
              ("000000000000000000000000" & ifgp1RdData)or
              ("000000000000000000000000" & is1RdData) or
              ("000000000000000000000000" & ie1RdData) or
              ("000000000000000000000000" & ip1RdData) or
              ttag1RdData or
              rtag1RdData or
              tpid10RdData or
              tpid11RdData or
              uawL1RdData or
              ("0000000000000000" & uawU1RdData) or
              ("0000000000000000000000000000000" & plbClkMcast1RdData) or
              ("000000000000000000" & plbClkTxVlan1RdData) or
              ("000000000000000000" & plbClkRxVlan1RdData)
             );
  IP2Bus_Data <= rdData when (dCR_Read0 = '0' and dCR_Read1 = '0') else
                 temacDcr_DBus_i;

end generate DUAL_SYS;

SINGLE_SYS: if(C_TEMAC1_ENABLED = 0) generate
begin

  RD_ACK_BLOCKER_PROCESS : process (PlbClk,RawReset)
  begin
    if (PlbClk'event and PlbClk = '1') then
      if (RawReset = '1') then
        rdAckBlocker <= '0';
      else
        rdAckBlocker <= ((dCR_ack_i and dCR_Read0) or softRead0_d1) or -- set when = '1'
                        (rdAckBlocker and -- hold  when = '1'
                        ((dCR_ack_i and dCR_Read0) or softRead0_d1)); -- clear when = '0'
      end if;
    end if;
  end process;

  WR_ACK_BLOCKER_PROCESS : process (PlbClk,RawReset)
  begin
    if (PlbClk'event and PlbClk = '1') then
      if (RawReset = '1') then
        wrAckBlocker <= '0';
      else
        wrAckBlocker <= ((dCR_ack_i and dCR_Write0) or softWrite0_d1) or -- set when = '1'
                        (wrAckBlocker and -- hold  when = '1'
                        ((dCR_ack_i and dCR_Write0) or softWrite0_d1)); -- clear when = '0'
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- ACK_PROCESS
  --------------------------------------------------------------------------
  ACK_PROCESS : process (RawReset, PlbClk)
  begin
    if (PlbClk'event and PlbClk = '1') then
      if (RawReset = '1') then
        dCR_Read0_d1  <= '0';
        dCR_Write0_d1 <= '0';
        softRead0_d1  <= '0';
        softWrite0_d1 <= '0';
        iP2Bus_WrAck_i  <= '0';
        iP2Bus_RdAck_i  <= '0';
      else
        dCR_Read0_d1  <= dCR_Read0;
        dCR_Write0_d1 <= dCR_Write0;
        softRead0_d1  <= softRead0;
        softWrite0_d1 <= softWrite0;
        iP2Bus_WrAck_i  <= ((dCR_ack_i and dCR_Write0) or softWrite0_d1) and not(wrAckBlocker);
        iP2Bus_RdAck_i  <= ((dCR_ack_i and dCR_Read0)  or softRead0_d1) and not(rdAckBlocker);
      end if;
    end if;
  end process;

  dCR_Read1_d1  <= '0';
  dCR_Write1_d1 <= '0';

  TPReq1	<= '0';
  Intrpt1  	<= '0';
  Is1RegData    <= (others => '0');
  Ie1RegData    <= (others => '0');
  Cr1RegData  	<= (others => '0');
  Tp1RegData  	<= (others => '0');
  Ifgp1RegData	<= (others => '0');
  Ip1RegData  	<= (others => '0');
  Ttag1RegData	<= (others => '0');
  Rtag1RegData	<= (others => '0');
  Tpid10RegData <= (others => '0');
  Tpid11RegData <= (others => '0');
  UawL1RegData  <= (others => '0');
  UawU1RegData  <= (others => '0');

  DCR_Clk     <= PlbClk;
  dCR_Read_i    <= dCR_Read0;
  dCR_Read0   <= Bus2IP_RdCE(8) or
                 Bus2IP_RdCE(9) or
                 Bus2IP_RdCE(10)or
                 Bus2IP_RdCE(11);
  dCR_Read1   <= '0';
  softRead0   <= Bus2IP_RdCE(0) or
                 Bus2IP_RdCE(1) or
                 Bus2IP_RdCE(2) or
                 Bus2IP_RdCE(3) or
                 Bus2IP_RdCE(4) or
                 Bus2IP_RdCE(5) or
                 Bus2IP_RdCE(6) or
                 Bus2IP_RdCE(7) or
                 Bus2IP_RdCE(12) or
                 Bus2IP_RdCE(13) or
                 Bus2IP_RdCE(14) or
                 Bus2IP_RdCE(15) or
                 --Bus2IP_RdCE(32) or
                 Bus2IP_RdCE(33) or
                 Bus2IP_RdCE(34) or
                 Bus2IP_RdCE(35) or
                 Bus2IP_RdCE(36);
  softRead1   <= '0';
  dCR_Write_i   <= dCR_Write0;
  dCR_Write0  <= Bus2IP_WrCE(8) or
                 Bus2IP_WrCE(9) or
                 Bus2IP_WrCE(10)or
                 Bus2IP_WrCE(11);
  dCR_Write1  <= '0';
  softWrite0  <= Bus2IP_WrCE(0) or
                 Bus2IP_WrCE(1) or
                 Bus2IP_WrCE(2) or
                 Bus2IP_WrCE(3) or
                 Bus2IP_WrCE(4) or
                 Bus2IP_WrCE(5) or
                 Bus2IP_WrCE(6) or
                 Bus2IP_WrCE(7) or
                 Bus2IP_WrCE(12) or
                 Bus2IP_WrCE(13) or
                 Bus2IP_WrCE(14) or
                 Bus2IP_WrCE(15) or
                 --Bus2IP_WrCE(32) or
                 Bus2IP_WrCE(33) or
                 Bus2IP_WrCE(34) or
                 Bus2IP_WrCE(35) or
                 Bus2IP_WrCE(36);
  softWrite1  <= '0';
  dcrTemac1Op <= '0';
  dCR_ABus_i    <= "00000000" & Bus2IP_Addr(28 to 29);
  dCR_ack_i   <= DCR_Ack;
  
  dCRTemac_DBus_i   <= Bus2IP_Data;
  temacDcr_DBus_i <= TemacDcr_DBus;

  rdData  <= (
              ("000000000000000000" & cr0RdData) or
              ("0000000000000000" & tp0RdData) or
              ("000000000000000000000000" & ifgp0RdData)or
              ("000000000000000000000000" & is0RdData) or
              ("000000000000000000000000" & ie0RdData) or
              ("000000000000000000000000" & ip0RdData) or
              ttag0RdData or
              rtag0RdData or
              tpid00RdData or
              tpid01RdData or
              uawL0RdData or
              ("0000000000000000" & uawU0RdData) or
              ("0000000000000000000000000000000" & plbClkMcast0RdData) or
              ("000000000000000000" & plbClkTxVlan0RdData) or
              ("000000000000000000" & plbClkRxVlan0RdData)
             );
  IP2Bus_Data <= rdData when (dCR_Read0 = '0') else
                 temacDcr_DBus_i;

end generate SINGLE_SYS;

end imp;
