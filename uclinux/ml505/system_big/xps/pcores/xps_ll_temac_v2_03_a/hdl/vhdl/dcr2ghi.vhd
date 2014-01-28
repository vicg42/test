------------------------------------------------------------------------------
-- $Id: dcr2ghi.vhd,v 1.1.4.39 2009/11/17 07:11:34 tomaik Exp $
------------------------------------------------------------------------------
-- dcr2ghi.vhd
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
-- Filename:        dcr2ghi.vhd
-- Version:         v3.00a
-- Description:     top level of dcr2ghi
--
------------------------------------------------------------------------------
-- Structure:   
--              dcr2ghi.vhd
--
------------------------------------------------------------------------------
-- Change log:
-------------------------------------------------------------------------------
-- @BEGIN_CHANGELOG EDK_J_SP2
--  ***************************************************************************
--
--   New core
--
--  ***************************************************************************
-- 
-- @END_CHANGELOG 
-------------------------------------------------------------------------------
-- Author:      MSH
-- History:
--   MSH           05/13/05    First version
-- ^^^^^^
--      First release
-- ~~~~~~
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
use ieee.numeric_std.all;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

library unisim;
use unisim.vcomponents.all;

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity dcr2ghi is
  generic (
    C_EMAC1_PRESENT : integer := 0
      -- 0 - EMAC 0 used but EMAC 1 not used
      -- 1 - EMAC 0 and EMAC 1 used
    );
  port (
    -- DCR Interface
    DcrEmacClk      : in  std_logic;
    DcrEmacAbus     : in  std_logic_vector(0 to 9);
    DcrEmacRead     : in  std_logic;
    DcrEmacWrite    : in  std_logic;
    DcrEmacDbus     : in  std_logic_vector(0 to 31);
    EmacDcrAck      : out std_logic;
    EmacDcrDbus     : out std_logic_vector(0 to 31);
    DcrEmacEnable   : in  std_logic;
    DcrHostDoneIR   : out std_logic;

    -- Asynchronous Reset
    Reset           : in  std_logic;
       
    -- Generic Host Interface
    HostOpcode      : out std_logic_vector(1 downto 0);
    HostReq         : out std_logic;
    HostMiiMSel     : out std_logic;
    HostAddr        : out std_logic_vector(9 downto 0);
    HostWrData      : out std_logic_vector(31 downto 0);
    HostMiimRdy     : in  std_logic;
    HostRdData      : in  std_logic_vector(31 downto 0);
    HostEmac1Sel    : out std_logic;
    HostClk         : in  std_logic   -- must be the same as DCR clock
    );
   
end dcr2ghi;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture imp of dcr2ghi is

------------------------------------------------------------------------------
--  Constant Declarations
------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Function declarations
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Type Declarations
-----------------------------------------------------------------------------

type HI_SM_TYPE is (
                    PRE_IDLE,
                    IDLE,
                    CFG_WR,
                    CFG_RD_0,
                    CFG_RD_1,
                    MAW1RD_0,
                    MAW1RD_1,
                    MAW1RD_2,
                    MIIMWDWR,
                    MIIMWDRD,
                    TIEWR,
                    TIERD,
                    TISWR,
                    TISRD,
                    MIIMWROP_0,
                    MIIMWROP_1,
                    MIIMRDOP_0,
                    MIIMRDOP_1,
                    MIIMRDOP_2,
                    LCLOP
                   );

------------------------------------------------------------------------------
-- Signal and Type Declarations
------------------------------------------------------------------------------

signal emacDcrDbus_int   : std_logic_vector(0 to 31);
signal dcrHostDoneIR_int : std_logic;
signal emacDcrAck_int    : std_logic;
signal hostOpcode_int    : std_logic_vector(1 downto 0);
signal hostReq_int       : std_logic;
signal hostMiiMSel_int   : std_logic;
signal hostAddr_int      : std_logic_vector(9 downto 0);
signal hostWrData_int    : std_logic_vector(31 downto 0);
signal hostEmac1Sel_int  : std_logic;

signal debug_states      : std_logic_vector(0 to 4);

signal hi_sm_ps  : HI_SM_TYPE;
signal hi_sm_ns  : HI_SM_TYPE;

signal gnd_i     : std_logic;
signal vcc_i     : std_logic;
  
signal mswReg    : std_logic_vector(0 to 31);
signal lswReg    : std_logic_vector(0 to 31);
signal ctlReg    : std_logic_vector(22 to 31);
signal ctlWrEn   : std_logic;

signal miimwdReg    : std_logic_vector(16 to 31);
signal miimwdWrData : std_logic_vector(16 to 31);
signal miimwdWrEn   : std_logic;

signal tie0Reg    : std_logic_vector(25 to 31);
signal tie0WrData : std_logic_vector(25 to 31);
signal tie0WrEn   : std_logic;

signal tie1Reg    : std_logic_vector(25 to 31);
signal tie1WrData : std_logic_vector(25 to 31);
signal tie1WrEn   : std_logic;

signal tis0Reg    : std_logic_vector(25 to 31);
signal tis0WrData : std_logic_vector(25 to 31);
signal tis0WrEn   : std_logic;

signal tis1Reg    : std_logic_vector(25 to 31);
signal tis1WrData : std_logic_vector(25 to 31);
signal tis1WrEn   : std_logic;

signal miimRr0   : std_logic;
signal miimRr1   : std_logic;
signal miimWr0   : std_logic;
signal miimWr1   : std_logic;
signal hardAcsRdy0 : std_logic;
signal hardAcsRdy1 : std_logic;

signal mswReg_i  : std_logic_vector(0 to 31);
signal lswReg_i  : std_logic_vector(0 to 31);
signal lswWrData : std_logic_vector(0 to 31);
signal mswWrData : std_logic_vector(0 to 31);
signal ctlReg_i  : std_logic_vector(22 to 31);
signal ctlWrEn_i : std_logic;

signal miimRr0_i : std_logic_vector(0 to 1);
signal miimRr1_i : std_logic_vector(0 to 1);
signal miimWr0_i : std_logic_vector(0 to 4);
signal miimWr1_i : std_logic_vector(0 to 4);
signal hardAcsRdy0_i : std_logic;
signal hardAcsRdy1_i : std_logic;

signal mswWrForTemacRd : std_logic;
signal lswWrForTemacRd : std_logic;

signal lswWrFromDCR    : std_logic;
signal ctl0Write : std_logic;
signal ctl1Write : std_logic;

signal mswRead   : std_logic;
signal lswRead   : std_logic;
signal ctlRead   : std_logic;
signal rdy0Read  : std_logic;
signal rdy1Read  : std_logic;

signal rdData    : std_logic_vector(0 to 31);

signal hostEmac1Sel_i : std_logic;
signal hostOpcode_i   : std_logic_vector(1 downto 0);

signal maw1Rd    : std_logic;
signal miimwdWrite  : std_logic;
signal miimwdRead  : std_logic;
signal tieWrite  : std_logic;
signal tieRead  : std_logic;
signal tisWrite  : std_logic;
signal tisRead  : std_logic;
signal miimaiWr  : std_logic;
signal miimaiRd  : std_logic;
signal cnfgWr    : std_logic;
signal cnfgRd    : std_logic;

signal emacDcrAck_i : std_logic;
signal lclDcrAck    : std_logic;

signal tis0MiimR      : std_logic;
signal tis0MiimW      : std_logic;
signal tis0AfR        : std_logic;
signal tis0AfW        : std_logic;
signal tis0CfgR       : std_logic;
signal tis0CfgW       : std_logic;
signal tis0Input      : std_logic_vector (25 to 31);
signal tis0Inputenbl  : std_logic_vector (25 to 31);

signal tis1MiimR      : std_logic;
signal tis1MiimW      : std_logic;
signal tis1AfR        : std_logic;
signal tis1AfW        : std_logic;
signal tis1CfgR       : std_logic;
signal tis1CfgW       : std_logic;
signal tis1Input      : std_logic_vector (25 to 31);
signal tis1Inputenbl  : std_logic_vector (25 to 31);

signal afOp  : std_logic;
signal cfgOp : std_logic;

signal captureEmac1Sel : std_logic;
signal clearEmac1Sel : std_logic;
signal savedEmac1Sel: std_logic;

-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin

------------------------------------------------------------------------------
-- Concurrent Signal Assignments
------------------------------------------------------------------------------
  EmacDcrDbus   <= emacDcrDbus_int;
  DcrHostDoneIR <= dcrHostDoneIR_int;
  EmacDcrAck    <= emacDcrAck_int;
  HostOpcode    <= hostOpcode_int;  
  HostReq       <= hostReq_int;     
  HostMiiMSel   <= hostMiiMSel_int; 
  HostAddr      <= hostAddr_int;    
  HostWrData    <= hostWrData_int;  
  HostEmac1Sel  <= hostEmac1Sel_int;

  gnd_i   <= '0';
  vcc_i   <= '1';
  
  hostEmac1Sel_int <= hostEmac1Sel_i;
  hostOpcode_int   <= hostOpcode_i;

--  HostClk <= DcrEmacClk;
  emacDcrAck_int <= emacDcrAck_i or lclDcrAck;
  -----------------------------------------------------------------------------
  -- Generate inputs to DCR Interrupt status register
  -- The DCR interrupt status register is emulated in this code and appears in
  -- the hard core only if you use the DCR interface
  -----------------------------------------------------------------------------
  tis0MiimR <= '1' when (hi_sm_ps = MIIMRDOP_2 and hostEmac1Sel_i = '0') else '0';
  tis0MiimW <= '1' when (hi_sm_ps = MIIMWROP_1 and HostMiimRdy = '1' and hostEmac1Sel_i = '0') else '0';
--  tis0AfR   <= '1' when (ctlRead = '1' and DcrEmacAbus(7) = '0' and afOp = '1') else '0';
--  tis0AfW   <= '1' when (ctl0Write = '1' and afOp = '1') else '0';
  tis0AfR   <= '1' when (ctl0Write = '1' and afOp = '1' and DcrEmacDbus(16) = '0') else '0';
  tis0AfW   <= '1' when (ctl0Write = '1' and afOp = '1' and DcrEmacDbus(16) = '1') else '0';
--  tis0CfgR  <= '1' when (ctlRead = '1' and DcrEmacAbus(7) = '0' and cfgOp = '1') else '0';
--  tis0CfgW  <= '1' when (ctl0Write = '1' and cfgOp = '1') else '0';
  tis0CfgR  <= '1' when (cnfgRd = '1' and DcrEmacAbus(7) = '0' and afOp = '0') else '0';
  tis0CfgW  <= '1' when (cnfgWr = '1' and DcrEmacAbus(7) = '0' and afOp = '0') else '0';

  NO_EMAC1_01: if(C_EMAC1_PRESENT = 0) generate
  begin
    tis1MiimR <= '0';
    tis1MiimW <= '0';
    tis1AfR   <= '0';
    tis1AfW   <= '0';
    tis1CfgR  <= '0';
    tis1CfgW  <= '0';
  end generate NO_EMAC1_01;

  YES_EMAC1_01: if(C_EMAC1_PRESENT = 1) generate
  begin
    tis1MiimR <= '1' when (hi_sm_ps = MIIMRDOP_2 and hostEmac1Sel_i = '1') else '0';
    tis1MiimW <= '1' when (hi_sm_ps = MIIMWROP_1 and HostMiimRdy = '1' and hostEmac1Sel_i = '1') else '0';
--    tis1AfR   <= '1' when (ctlRead = '1' and DcrEmacAbus(7) = '1' and afOp = '1') else '0';
--    tis1AfW   <= '1' when (ctl1Write = '1' and afOp = '1') else '0';
    tis1AfR   <= '1' when (ctl1Write = '1' and afOp = '1' and DcrEmacDbus(16) = '0') else '0';
    tis1AfW   <= '1' when (ctl1Write = '1' and afOp = '1' and DcrEmacDbus(16) = '1') else '0';
--    tis1CfgR  <= '1' when (ctlRead = '1' and DcrEmacAbus(7) = '1' and cfgOp = '1') else '0';
--    tis1CfgW  <= '1' when (ctl1Write = '1' and cfgOp = '1') else '0';
    tis1CfgR  <= '1' when (cnfgRd = '1' and DcrEmacAbus(7) = '1' and afOp = '0') else '0';
    tis1CfgW  <= '1' when (cnfgWr = '1' and DcrEmacAbus(7) = '1' and afOp = '0') else '0';
  end generate YES_EMAC1_01;

  afOp  <= '1' when (DcrEmacDbus(23) = '1' and DcrEmacDbus(24) = '1' and (DcrEmacDbus(26 to 27) = "00" or DcrEmacDbus(26 to 27) = "01")) else '0';
  cfgOp <= '1' when (DcrEmacDbus(22 to 23) = "10" or (DcrEmacDbus(22 to 23) = "11" and DcrEmacDbus(24) = '0')) else '0';

  tis0Input     <= tis0CfgW & tis0CfgR & tis0AfW & tis0AfR & tis0MiimW & tis0MiimR & '0';
  tis0Inputenbl <= tis0Input and tie0Reg;

  NO_EMAC1_02: if(C_EMAC1_PRESENT = 0) generate
  begin
    tis1Input     <= (others => '0');
    tis1Inputenbl <= (others => '0');
    dcrHostDoneIR_int <= tis0Reg(30) or tis0Reg(29) or tis0Reg(28) or tis0Reg(27) or tis0Reg(26) or tis0Reg(25);
  end generate NO_EMAC1_02;

  YES_EMAC1_02: if(C_EMAC1_PRESENT = 1) generate
  begin
    tis1Input     <= tis1CfgW & tis1CfgR & tis1AfW & tis1AfR & tis1MiimW & tis1MiimR & '0';
    tis1Inputenbl <= tis1Input and tie1Reg;
    dcrHostDoneIR_int <= tis0Reg(30) or tis0Reg(29) or tis0Reg(28) or tis0Reg(27) or tis0Reg(26) or tis0Reg(25) or 
                     tis1Reg(30) or tis1Reg(29) or tis1Reg(28) or tis1Reg(27) or tis1Reg(26) or tis1Reg(25);
  end generate YES_EMAC1_02;
   
  -----------------------------------------------------------------------------
  -- decode the DCR read and write types
  -----------------------------------------------------------------------------
  lswWrFromDCR <= (DcrEmacWrite and                          not(DcrEmacAbus(8)) and     DcrEmacAbus(9));
  ctl0Write    <= (DcrEmacWrite and not(DcrEmacAbus(7))  and     DcrEmacAbus(8)  and not(DcrEmacAbus(9)));
  mswRead      <= (DcrEmacRead  and                          not(DcrEmacAbus(8)) and not(DcrEmacAbus(9)));
  lswRead      <= (DcrEmacRead  and                          not(DcrEmacAbus(8)) and     DcrEmacAbus(9));
  ctlRead      <= (DcrEmacRead  and                              DcrEmacAbus(8)  and not(DcrEmacAbus(9)));
  rdy0Read     <= (DcrEmacRead  and not(DcrEmacAbus(7)) and      DcrEmacAbus(8)  and     DcrEmacAbus(9));

  NO_EMAC1_03: if(C_EMAC1_PRESENT = 0) generate
  begin
    rdy1Read     <= '0';
    ctl1Write    <= '0';
  end generate NO_EMAC1_03;

  YES_EMAC1_03: if(C_EMAC1_PRESENT = 1) generate
  begin
    rdy1Read     <= (DcrEmacRead  and     DcrEmacAbus(7)  and      DcrEmacAbus(8)  and     DcrEmacAbus(9));
    ctl1Write    <= (DcrEmacWrite and     DcrEmacAbus(7)   and     DcrEmacAbus(8)  and not(DcrEmacAbus(9)));
  end generate YES_EMAC1_03;

  ------------------------------------------------------------------------------
  -- Decode address code field of CTL register
  ------------------------------------------------------------------------------
  maw1Rd      <= '1' when (DcrEmacDbus(22 to 29) = "11100011" and DcrEmacDbus(16) = '1' and (ctl0Write = '1' or ctl1Write = '1')) else '0'; -- 0x38C
  miimwdWrite <= '1' when (DcrEmacDbus(22 to 29) = "11101100" and DcrEmacDbus(16) = '1' and (ctl0Write = '1' or ctl1Write = '1')) else '0'; -- 0x3B0
  miimwdRead  <= '1' when (DcrEmacDbus(22 to 29) = "11101100" and DcrEmacDbus(16) = '0' and (ctl0Write = '1' or ctl1Write = '1')) else '0'; -- 0x3B0
  tisWrite    <= '1' when (DcrEmacDbus(22 to 29) = "11101000" and DcrEmacDbus(16) = '1' and (ctl0Write = '1' or ctl1Write = '1')) else '0'; -- 0x3A0
  tisRead     <= '1' when (DcrEmacDbus(22 to 29) = "11101000" and DcrEmacDbus(16) = '0' and (ctl0Write = '1' or ctl1Write = '1')) else '0'; -- 0x3A0
  tieWrite    <= '1' when (DcrEmacDbus(22 to 29) = "11101001" and DcrEmacDbus(16) = '1' and (ctl0Write = '1' or ctl1Write = '1')) else '0'; -- 0x3A4
  tieRead     <= '1' when (DcrEmacDbus(22 to 29) = "11101001" and DcrEmacDbus(16) = '0' and (ctl0Write = '1' or ctl1Write = '1')) else '0'; -- 0x3A4
  miimaiWr    <= '1' when (DcrEmacDbus(22 to 29) = "11101101" and DcrEmacDbus(16) = '1' and (ctl0Write = '1' or ctl1Write = '1')) else '0'; -- 0x3B4
  miimaiRd    <= '1' when (DcrEmacDbus(22 to 29) = "11101101" and DcrEmacDbus(16) = '0' and (ctl0Write = '1' or ctl1Write = '1')) else '0'; -- 0x3B4

  cnfgWr      <= '1' when (maw1Rd = '0' and miimwdWrite = '0' and miimaiWr = '0' and tieWrite = '0' and tisWrite = '0' and DcrEmacDbus(16) = '1' and (ctl0Write = '1' or ctl1Write = '1')) else '0';
  cnfgRd      <= '1' when (maw1Rd = '0' and miimwdRead = '0' and miimaiRd = '0' and tieRead = '0' and tisRead = '0' and DcrEmacDbus(16) = '0' and (ctl0Write = '1' or ctl1Write = '1')) else '0';

  ------------------------------------------------------------------------------
  -- DCR ctl register bits read back control
  ------------------------------------------------------------------------------
  ctlReg_i <= ctlReg when (ctlRead = '1') else
              (others => '0');
 
  ctlWrEn_i <= ctlWrEn when (ctlRead = '1') else
               '0';

  ------------------------------------------------------------------------------
  -- Determine when MIIM access are complete for ready register bits
  ------------------------------------------------------------------------------
  miimRr0     <= '0' when ((hi_sm_ps = MIIMRDOP_0 or hi_sm_ps = MIIMRDOP_1 or hi_sm_ps = MIIMRDOP_2) and hostEmac1Sel_i = '0') else '1';
  miimWr0     <= '0' when ((hi_sm_ps = MIIMWROP_0 or hi_sm_ps = MIIMWROP_1) and hostEmac1Sel_i = '0') else '1';
  hardAcsRdy0 <= miimRr0 and miimWr0;

  NO_EMAC1_04: if(C_EMAC1_PRESENT = 0) generate
  begin
    miimWr1     <= '0';
    miimRr1     <= '0';
    hardAcsRdy1 <= '0';
  end generate NO_EMAC1_04;

  YES_EMAC1_04: if(C_EMAC1_PRESENT = 1) generate
  begin
    miimWr1     <= '0' when ((hi_sm_ps = MIIMWROP_0 or hi_sm_ps = MIIMWROP_1) and hostEmac1Sel_i = '1') else '1';
    miimRr1     <= '0' when ((hi_sm_ps = MIIMRDOP_0 or hi_sm_ps = MIIMRDOP_1 or hi_sm_ps = MIIMRDOP_2) and hostEmac1Sel_i = '1') else '1';
    hardAcsRdy1 <= miimRr1 and miimWr1;
  end generate YES_EMAC1_04;

  ------------------------------------------------------------------------------
  -- DCR ready register bits read back control
  ------------------------------------------------------------------------------
  miimRr0_i     <= miimRr0 & '1' when (rdy0Read = '1') else
                   "00";
  miimWr0_i     <= "1111" & miimWr0 when (rdy0Read = '1') else
                   "00000";
  hardAcsRdy0_i <= hardAcsRdy0 when (rdy0Read = '1') else
                   '0';

  NO_EMAC1_05: if(C_EMAC1_PRESENT = 0) generate
  begin
    miimRr1_i     <= "00";
    miimWr1_i     <= "00000";
    hardAcsRdy1_i <= '0';
  end generate NO_EMAC1_05;

  YES_EMAC1_05: if(C_EMAC1_PRESENT = 1) generate
  begin
    miimRr1_i     <= miimRr1 & '1' when (rdy1Read = '1') else
                     "00";
    miimWr1_i     <= "1111" & miimWr1 when (rdy1Read = '1') else
                     "00000";
    hardAcsRdy1_i <= hardAcsRdy1 when (rdy1Read = '1') else
                     '0';
  end generate YES_EMAC1_05;

  ------------------------------------------------------------------------------
  -- DCR read data muxing
  ------------------------------------------------------------------------------
  rdData  <= (
              (mswReg_i) or
              (lswReg_i) or
              ("0000000000000000" & ctlWrEn_i & "00000" & ctlReg_i) or
              ("000000000000000" & hardAcsRdy0_i & "000000000" & miimWr0_i & miimRr0_i) or
              ("000000000000000" & hardAcsRdy1_i & "000000000" & miimWr1_i & miimRr1_i)
             );

  emacDcrDbus_int <= rdData when (DcrEmacRead = '1') else
                 DcrEmacDbus;
  ------------------------------------------------------------------------------
  -- LOCAL_DCR_ACK_PROCESS
  ------------------------------------------------------------------------------
 
  LOCAL_DCR_ACK_PROCESS : process (DcrEmacClk)
  begin
    if (DcrEmacClk'event and DcrEmacClk = '1') then
      if (Reset = '1') then
        lclDcrAck <= '0';
      elsif (lswWrFromDCR = '1' or mswRead = '1' or lswRead = '1' or ctlRead = '1' or rdy0Read = '1' or rdy1Read = '1') then
        lclDcrAck <= DcrEmacWrite or DcrEmacRead;
      else
        lclDcrAck <= '0';
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- TIS0_WRITE_PROCESS to emulate DCR interrupt status register that is in
  -- hard core when using DCR interface
  ------------------------------------------------------------------------------
 
  TIS0_WRITE_PROCESS : process (DcrEmacClk)
  begin
    if (DcrEmacClk'event and DcrEmacClk = '1') then
      if (Reset = '1') then
        tis0Reg <= (others => '0');
      elsif (tis0WrEn = '1') then
        tis0Reg <= tis0WrData or tis0Inputenbl;
      else
        tis0Reg <= tis0Reg or tis0Inputenbl;      
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- TIS1_WRITE_PROCESS to emulate DCR interrupt status register that is in
  -- hard core when using DCR interface
  ------------------------------------------------------------------------------
  NO_EMAC1_06: if(C_EMAC1_PRESENT = 0) generate
  begin
    tis1Reg <= (others => '0');
  end generate NO_EMAC1_06;

  YES_EMAC1_06: if(C_EMAC1_PRESENT = 1) generate
  begin
    TIS1_WRITE_PROCESS : process (DcrEmacClk)
    begin
      if (DcrEmacClk'event and DcrEmacClk = '1') then
        if (Reset = '1') then
          tis1Reg <= (others => '0');
        elsif (tis1WrEn = '1') then
          tis1Reg <= tis1WrData or tis1Inputenbl;
        else
          tis1Reg <= tis1Reg or tis1Inputenbl;      
        end if;
      end if;
    end process;
  end generate YES_EMAC1_06;

  ------------------------------------------------------------------------------
  -- TIE0_WRITE_PROCESS to emulate DCR interrupt enable register that is in
  -- hard core when using DCR interface
  ------------------------------------------------------------------------------
 
  TIE0_WRITE_PROCESS : process (DcrEmacClk)
  begin
    if (DcrEmacClk'event and DcrEmacClk = '1') then
      if (Reset = '1') then
        tie0Reg <= (others => '0');
      elsif (tie0WrEn = '1') then
        tie0Reg <= tie0WrData;
      else
        null;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- TIE1_WRITE_PROCESS to emulate DCR interrupt enable register that is in
  -- hard core when using DCR interface
  ------------------------------------------------------------------------------
 
  NO_EMAC1_07: if(C_EMAC1_PRESENT = 0) generate
  begin
    tie1Reg <= (others => '0');
  end generate NO_EMAC1_07;

  YES_EMAC1_07: if(C_EMAC1_PRESENT = 1) generate
  begin
    TIE1_WRITE_PROCESS : process (DcrEmacClk)
    begin
      if (DcrEmacClk'event and DcrEmacClk = '1') then
        if (Reset = '1') then
          tie1Reg <= (others => '0');
        elsif (tie1WrEn = '1') then
          tie1Reg <= tie1WrData;
        else
          null;
        end if;
      end if;
    end process;
  end generate YES_EMAC1_07;

  ------------------------------------------------------------------------------
  -- MIIMWD_WRITE_PROCESS to emulate DCR MIIM Word register that is in
  -- hard core when using DCR interface
  ------------------------------------------------------------------------------
 
  MIIMWD_WRITE_PROCESS : process (DcrEmacClk)
  begin
    if (DcrEmacClk'event and DcrEmacClk = '1') then
      if (Reset = '1') then
        miimwdReg <= (others => '0');
      elsif (miimwdWrEn = '1') then
        miimwdReg <= miimwdWrData;
      else
        null;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- MSW_WRITE_PROCESS with read control to emulate DCR MSW register that is in
  -- hard core when using DCR interface
  ------------------------------------------------------------------------------
 
  MSW_WRITE_PROCESS : process (DcrEmacClk)
  begin
    if (DcrEmacClk'event and DcrEmacClk = '1') then
      if (Reset = '1') then
        mswReg <= (others => '0');
      elsif (mswWrForTemacRd = '1') then
        mswReg <= mswWrData;
      else
        null;
      end if;
    end if;
  end process;

  mswReg_i <= mswReg when (mswRead = '1') else
              (others => '0');
  
  ------------------------------------------------------------------------------
  -- LSW_WRITE_PROCESS with read control  to emulate DCR LSW register that is in
  -- hard core when using DCR interface
  ------------------------------------------------------------------------------
  
  LSW_WRITE_PROCESS : process (DcrEmacClk)
  begin
    if (DcrEmacClk'event and DcrEmacClk = '1') then
      if (Reset = '1') then
        lswReg <= (others => '0');
      elsif lswWrFromDCR = '1' then
        lswReg <= DcrEmacDbus;
      elsif (lswWrForTemacRd = '1') then
        lswReg <= lswWrData;
      else
        null;
      end if;
    end if;
  end process;
  
  lswReg_i <= lswReg when (lswRead = '1') else
              (others => '0');

  ------------------------------------------------------------------------------
  -- CTL_WRITE_PROCESS to emulate DCR CTL register that is in
  -- hard core when using DCR interface
  ------------------------------------------------------------------------------
  
  CTL_WRITE_PROCESS : process (DcrEmacClk)
  begin
    if (DcrEmacClk'event and DcrEmacClk = '1') then
      if (Reset = '1') then
        ctlReg       <= (others => '0');
        ctlWrEn      <= '0';
--        HostEmac1Sel_i <= '0';
      elsif (ctl0Write = '1' or ctl1Write = '1') then
        ctlReg       <= DcrEmacDbus(22 to 31);
        ctlWrEn      <= DcrEmacDbus(16);
--        HostEmac1Sel_i <= DcrEmacAbus(7);
      else
        null;
      end if;
    end if;
  end process;
  
--  CTL_WRITE_PROCESS_A : process (DcrEmacClk)
--  begin
--    if (DcrEmacClk'event and DcrEmacClk = '1') then
--      if (Reset = '1') then
--        HostEmac1Sel_i <= '0';
--      elsif (DcrEmacRead = '1' or DcrEmacWrite = '1') then
--        HostEmac1Sel_i <= DcrEmacAbus(7);
--      else
--        null;
--      end if;
--    end if;
--  end process;

  HostEmac1Sel_i <= DcrEmacAbus(7) or savedEmac1Sel;

  LATCH_EMAC1_SEL : process (DcrEmacClk)
  begin
    if (DcrEmacClk'event and DcrEmacClk = '1') then
      if (Reset = '1') then
        savedEmac1Sel <= '0';
      elsif (captureEmac1Sel = '1' or clearEmac1Sel = '1') then
        savedEmac1Sel <= DcrEmacAbus(7);
      else
        null;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- HI State Machine
  -- HI_SM_SYNC_PROCESS: synchronous process of the state machine
  -- HI_SM_CMB_PROCESS:  combinatorial next-state logic
  ------------------------------------------------------------------------------
  -- This state machine controls the DCR to generic host interface conversion
  ------------------------------------------------------------------------------
  
  HI_SM_SYNC_PROCESS : process ( DcrEmacClk )
  begin
      if (DcrEmacClk'event and DcrEmacClk = '1') then
          if (Reset = '1') then
              hi_sm_ps <= IDLE;
          else
              hi_sm_ps <= hi_sm_ns;
          end if;
      end if;
  end process;

  HI_SM_CMB_PROCESS : process (
                               hi_sm_ps,
                               HostMiimRdy,
                               HostRdData,
                               maw1Rd,  
                               miimwdWrite,
                               miimwdRead,
                               tisWrite,
                               tisRead,
                               tieWrite,
                               tieRead,
                               miimaiWr,
                               miimaiRd,
                               lswWrFromDCR,
                               mswRead,
                               lswRead,
                               ctlRead,
                               rdy0Read,
                               rdy1Read,
                               cnfgWr,
                               cnfgRd,
                               ctl0Write,
                               ctl1Write,
                               DcrEmacDbus(16),
                               ctlWrEn,
                               ctlReg,
                               lswReg,
                               miimwdReg,
                               DcrEmacAbus,
                               tis0Reg,
                               tis1Reg,
                               tie0Reg,
                               tie1Reg,
                               DcrEmacRead,
                               DcrEmacWrite
                              )  
  begin 
    hostOpcode_i    <= "10";
    hostReq_int     <= '0';
    hostMiiMSel_int <= '1';
    hostWrData_int  <= (others => '0');
    hostAddr_int    <= (others => '0');
    emacDcrAck_i    <= '0';
    lswWrForTemacRd <= '0';
    mswWrForTemacRd <= '0';
    tis0WrData      <= (others => '0');
    tis0WrEn        <= '0';
    tie0WrData      <= (others => '0');
    tie0WrEn        <= '0';
    tis1WrData      <= (others => '0');
    tis1WrEn        <= '0';
    tie1WrData      <= (others => '0');
    tie1WrEn        <= '0';
    miimwdWrData    <= (others => '0');
    miimwdWrEn      <= '0';
    lswWrData       <= (others => '0');
    mswWrData       <= (others => '0');
    captureEmac1Sel<= '0';
    clearEmac1Sel<= '0';
    
    case hi_sm_ps is 
      when IDLE =>
        debug_states <= "00000";
        if (cnfgWr = '1') then
          hi_sm_ns      <= CFG_WR;
        elsif (cnfgRd = '1') then
          hi_sm_ns      <= CFG_RD_0;
        elsif (maw1Rd = '1') then
          hi_sm_ns      <= MAW1RD_0;
        elsif (tisWrite = '1') then
          hi_sm_ns      <= TISWR;
        elsif (tisRead = '1') then
          hi_sm_ns      <= TISRD;
        elsif (tieWrite = '1') then
          hi_sm_ns      <= TIEWR;
        elsif (tieRead = '1') then
          hi_sm_ns      <= TIERD;
        elsif (miimwdWrite = '1') then
          hi_sm_ns      <= MIIMWDWR;
        elsif (miimwdRead = '1') then
          hi_sm_ns      <= MIIMWDRD;
        elsif (miimaiWr = '1') then
          hi_sm_ns      <= MIIMWROP_0;
        elsif (miimaiRd = '1') then
          hi_sm_ns      <= MIIMRDOP_0;
--        elsif (lswWrFromDCR = '1' or 
--               mswRead 	    = '1' or
--               lswRead 	    = '1' or
--               ctlRead 	    = '1' or
--               rdy0Read	    = '1' or
--               rdy1Read	    = '1') then
--          hi_sm_ns      <= LCLOP;
        else
          hi_sm_ns      <= IDLE;
        end if;                  
--      when LCLOP =>
--        EmacDcrAck      <= '1';
--        hi_sm_ns        <= PRE_IDLE;
      when CFG_WR =>
        debug_states <= "00001";
        hostMiiMSel_int <= '0';
        hostOpcode_i    <= "00";
        hostAddr_int    <= ctlReg;
        hostWrData_int  <= lswReg;
        emacDcrAck_i    <= '1';
        hi_sm_ns        <= PRE_IDLE;
      when CFG_RD_0 =>
        debug_states <= "00010";
        hostMiiMSel_int <= '0';
        hostAddr_int    <= ctlReg;
        hi_sm_ns        <= CFG_RD_1;
      when CFG_RD_1 =>
        debug_states <= "00011";
        hostMiiMSel_int <= '0';
        lswWrForTemacRd <= '1';
        lswWrData       <= HostRdData;
        emacDcrAck_i    <= '1';
        hi_sm_ns        <= PRE_IDLE;
      when MAW1RD_0 =>  
        debug_states <= "00100";
        hostMiiMSel_int <= '0';
        hostOpcode_i    <= "00";
        hostAddr_int    <= ctlReg;
        hostWrData_int  <= lswReg;
        hi_sm_ns        <= MAW1RD_1;
      when MAW1RD_1 =>  
        debug_states <= "00101";
        hostMiiMSel_int <= '0';
        hostOpcode_i    <= "00";
--        hostAddr_int    <= ctlReg;
        lswWrData       <= HostRdData;
        lswWrForTemacRd <= '1';
        hi_sm_ns        <= MAW1RD_2;
      when MAW1RD_2 =>  
        debug_states <= "00110";
        hostOpcode_i    <= "00";
        emacDcrAck_i    <= '1';
        mswWrData       <= HostRdData;
        mswWrForTemacRd <= '1';
        hi_sm_ns        <= PRE_IDLE;
      when MIIMWDWR =>
        debug_states <= "00111";
        miimwdWrData    <= lswReg(16 to 31);
        emacDcrAck_i    <= '1';
        miimwdWrEn      <= '1';
        hi_sm_ns        <= PRE_IDLE;
      when MIIMWDRD =>
        debug_states <= "01000";
        emacDcrAck_i    <= '1';
        lswWrForTemacRd <= '1';
        lswWrData(16 to 31) <= miimwdReg;
        lswWrData(0 to 15)  <= (others => '0');
        hi_sm_ns        <= PRE_IDLE;
      when TISWR =>
        debug_states <= "01001";
        if (ctl0Write = '1') then
          tis0WrData    <= lswReg(25 to 31);
          tis0WrEn      <= '1';
        else  
          tis1WrData    <= lswReg(25 to 31);
          tis1WrEn      <= '1';
        end if;                  
        emacDcrAck_i    <= '1';
        hi_sm_ns        <= PRE_IDLE;
      when TISRD =>
        debug_states <= "01010";
        if (DcrEmacAbus(7) = '0') then
          lswWrData(25 to 31) <= tis0Reg;
        else  
          lswWrData(25 to 31) <= tis1Reg;
        end if;                  
          lswWrData(0 to 24)  <= (others => '0');
        emacDcrAck_i    <= '1';
        lswWrForTemacRd <= '1';
        hi_sm_ns        <= PRE_IDLE;
      when TIEWR =>
        debug_states <= "01011";
        if (ctl0Write = '1') then
          tie0WrData    <= lswReg(25 to 31);
          tie0WrEn      <= '1';
        else  
          tie1WrData    <= lswReg(25 to 31);
          tie1WrEn      <= '1';
        end if;                  
        emacDcrAck_i    <= '1';
        hi_sm_ns        <= PRE_IDLE;
      when TIERD =>
        debug_states <= "01100";
        if (DcrEmacAbus(7) = '0') then
          lswWrData(25 to 31) <= tie0Reg;
        else  
          lswWrData(25 to 31) <= tie1Reg;
        end if;                  
          lswWrData(0 to 24)  <= (others => '0');
        emacDcrAck_i    <= '1';
        lswWrForTemacRd <= '1';
        hi_sm_ns        <= PRE_IDLE;
      when MIIMWROP_0 =>
        debug_states <= "01101";
        hostReq_int     <= '1';
        emacDcrAck_i    <= '1';
        hostOpcode_i    <= "01"; --write to PHY register
        hostAddr_int(9 downto 5) <= lswReg(22 to 26); --PHY addr
        hostAddr_int(4 downto 0) <= lswReg(27 to 31); --Reg addr
        hostWrData_int(15 downto 0) <= miimwdReg;
        hi_sm_ns        <= MIIMWROP_1;
      when MIIMWROP_1 =>
        debug_states <= "01110";
        if (HostMiimRdy = '1') then --PHY access complete
          hi_sm_ns        <= PRE_IDLE;
        else                        --PHY access still in progress
          hi_sm_ns        <= MIIMWROP_1;
        end if;                  
      when MIIMRDOP_0 =>
        debug_states <= "01111";
        captureEmac1Sel<= '1';
        clearEmac1Sel<= '0';
        hostReq_int     <= '1';
        emacDcrAck_i    <= '1';
        hostOpcode_i    <= "10"; --read from PHY register
        hostAddr_int(9 downto 5) <= lswReg(22 to 26); --PHY addr
        hostAddr_int(4 downto 0) <= lswReg(27 to 31); --Reg addr
--        miimwdWrData    <= HostRdData(15 downto 0);
        hi_sm_ns        <= MIIMRDOP_1;
      when MIIMRDOP_1 =>
        debug_states <= "10000";
        captureEmac1Sel<= '0';
        clearEmac1Sel<= '0';
--        miimwdWrData    <= HostRdData(15 downto 0);
        lswWrData(16 to 31) <=  HostRdData(15 downto 0);
        lswWrData(0 to 15) <=  (others => '0');
        if (HostMiimRdy = '1') then --PHY access complete
          hi_sm_ns        <= MIIMRDOP_2;
        else                        --PHY access still in progress
          hi_sm_ns        <= MIIMRDOP_1;
        end if;                  
      when MIIMRDOP_2 =>
        debug_states <= "10001";
        captureEmac1Sel<= '0';
        clearEmac1Sel<= '0';
--        miimwdWrData  <= HostRdData(15 downto 0);
--        miimwdWrEn    <= '1';
        lswWrData(16 to 31) <=  HostRdData(15 downto 0);
        lswWrData(0 to 15) <=  (others => '0');
        lswWrForTemacRd <= '1';
        hi_sm_ns        <= PRE_IDLE;
      when PRE_IDLE =>
        captureEmac1Sel<= '0';
        clearEmac1Sel<= '1';
        debug_states <= "10010";
        if (DcrEmacRead = '1' or DcrEmacWrite = '1') then --DCR operation still in progress
          hi_sm_ns        <= PRE_IDLE;
        else                    
          hi_sm_ns        <= IDLE;
        end if;                        
      when others   =>  -- default to IDLE
        hi_sm_ns <= IDLE;
    end case;
  end process;

end imp;
