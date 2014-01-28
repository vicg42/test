------------------------------------------------------------------------------
-- $Id: rx_top.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- rx.vhd
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
-- Filename:        rx_top.vhd
-- Version:         v2.00a
-- Description:     Receive interface between LL and hard Temac
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
-- Author:      DRP
-- History:
--  DRP      2006.05.18      -- First version
--
--  <initials>      <date>
-- ^^^^^^
--      Description of changes. If multiple lines are needed to fully describe
--      the changes made to the design, these lines should align with each other.
-- ~~~~~~
--
--  <initials>      <date>
-- ^^^^^^
--      More changes
-- ~~~~~~
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
--      internal version of : out   std_logic; port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Libraries used;
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.numeric_std.all;    
use ieee.std_logic_misc.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.coregen_comp_defs.all;
use proc_common_v3_00_a.proc_common_pkg.log2;
use proc_common_v3_00_a.all;

-- synopsys translate_off
library XilinxCoreLib;
-- synopsys translate_on


library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

library unisim;
use unisim.vcomponents.all;

------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
--
------------------------------------------------------------------------------

entity rx_top is
  generic (
    C_FAMILY        : string    := "virtex5";  
    C_TEMAC_TYPE    : integer   :=    0;  
      -- 0 - Virtex 5 hard TEMAC (FX, LXT, SXT devices)                
      -- 1 - Virtex 4 hard TEMAC (FX)               
      -- 2 - Soft TEMAC         
    C_TEMAC_RXCSUM       : integer  :=    0;
    C_TEMAC_RXFIFO       : integer  := 4096; 
    C_TEMAC_RXVLAN_TRAN  : integer  := 0;
    C_TEMAC_RXVLAN_TAG   : integer  := 0;
    C_TEMAC_RXVLAN_STRP  : integer  := 0;
    C_TEMAC_MCAST_EXTEND : integer  := 0;
    C_TEMAC_STATS        : integer  := 0;
    C_TEMAC_RXVLAN_WIDTH : integer  := 1
    );

  port    (
    Plb_Clk                  : in  std_logic;
    Plb_Rst                  : in  std_logic;
    LLTemac_Clk              : in  std_logic;
    LLTemac_Rst              : in  std_logic;
    TemacLL_SOF_n            : out std_logic;
    TemacLL_SOP_n            : out std_logic;
    TemacLL_EOF_n            : out std_logic;
    TemacLL_EOP_n            : out std_logic;
    TemacLL_SRC_RDY_n        : out std_logic;
    TemacLL_DST_RDY_n        : in  std_logic;
    TemacLL_REM              : out std_logic_vector(0 to 3);
    TemacLL_Data             : out std_logic_vector(0 to 31);
    
    RegCR_BrdCast_Rej        : in  std_logic;
    RegCR_MulCast_Rej        : in  std_logic;

    Rx_pckt_rej              : out std_logic;
    Rx_cmplt                 : out std_logic;
    Pckt_Ovr_Run             : out std_logic;

    Rx_Cl_Clk                : in  std_logic;
    RxClClkEn                : in  std_logic;
    EmacClientRxBadFrame     : in  std_logic;
    EmacClientRxd            : in  std_logic_vector(7 downto 0);
    EmacClientRxdVld         : in  std_logic;
    EmacClientRxFrameDrop    : in  std_logic;
    EmacClientRxGoodFrame    : in  std_logic;
    EmacClientRxStats        : in  std_logic_vector(6 downto 0);
    SoftEmacClientRxStats    : in  std_logic_vector(27 downto 0);
    EmacClientRxStatsVld     : in  std_logic;
    RtagRegData              : in  std_logic_vector(0 to 31);
    Tpid0RegData             : in  std_logic_vector(0 to 31);
    Tpid1RegData             : in  std_logic_vector(0 to 31);
    UawLRegData              : in  std_logic_vector(0 to 31);
    UawURegData              : in  std_logic_vector(16 to 31);
    RxClClkMcastAddr         : out std_logic_vector(0 to 14);
    RxClClkMcastEn           : out std_logic;
    RxClClkMcastRdData       : in  std_logic_vector(0 to 0);
    LlinkClkVlanAddr         : out std_logic_vector(0 to 11);
    LlinkClkVlanRdData       : in  std_logic_vector(18 to 31);
    LlinkClkRxVlanBramEnA    : out std_logic;

    LlinkClkEMultiFltrEnbl  : in  std_logic;
    LlinkClkNewFncEnbl      : in  std_logic;
    LlinkClkRxVStrpMode     : in  std_logic_vector(0 to 1);
    LlinkClkRxVTagMode      : in  std_logic_vector(0 to 1)
    );
end rx_top;

------------------------------------------------------------------------------
-- Architecture
------------------------------------------------------------------------------

architecture beh of rx_top is

------------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------------

constant C_MEM_DEPTH   : integer := (log2(C_TEMAC_RXFIFO/4))-1;

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

signal rxLLinkClkDPMemWrData : std_logic_vector(35 downto 0);
signal rxLLinkClkDPMemRdData : std_logic_vector(35 downto 0);
signal rxLLinkClkDPMemWrEn   : std_logic_vector(0 downto 0);
signal rxLLinkClkDPMemAddr   : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkFrameDropInt   : std_logic;
signal rxClClkFrameRejtInt   : std_logic;
signal rxClClkFrameAcptInt   : std_logic;
signal rxClClkMemFullInt     : std_logic;
signal rxLLinkRdMemPtrErrInt : std_logic;

signal rxClClkRxPcktRej_d1   : std_logic;
signal rxClClkRxPcktRej_d2   : std_logic;
signal rxClClkRxPcktRej_d3   : std_logic;
signal rxClClkRxPcktRej_d4   : std_logic;
signal rxClClkRxPcktRej_d5   : std_logic;
signal rxClClkRxPcktRej_d6   : std_logic;

signal rxLlClkRxPcktRej_d1   : std_logic;
signal rxLlClkRxPcktRej_d2   : std_logic;

signal rxClClkPcktOvrRun_d1  : std_logic;
signal rxClClkPcktOvrRun_d2  : std_logic;
signal rxClClkPcktOvrRun_d3  : std_logic;
signal rxClClkPcktOvrRun_d4  : std_logic;
signal rxClClkPcktOvrRun_d5  : std_logic;
signal rxClClkPcktOvrRun_d6  : std_logic;

signal rxLlClkPcktOvrRun_d1  : std_logic;
signal rxLlClkPcktOvrRun_d2  : std_logic;

signal rxClClkRxCmplt_d1     : std_logic;
signal rxClClkRxCmplt_d2     : std_logic;
signal rxClClkRxCmplt_d3     : std_logic;
signal rxClClkRxCmplt_d4     : std_logic;
signal rxClClkRxCmplt_d5     : std_logic;
signal rxClClkRxCmplt_d6     : std_logic;

signal rxLlClkRxCmplt_d1     : std_logic;
signal rxLlClkRxCmplt_d2     : std_logic;
signal rxLlClkLastProcessedGray : std_logic_vector(C_MEM_DEPTH downto 0);

signal temacLL_SRC_RDY_n_i   : std_logic;
signal temacLL_SOF_n_i       : std_logic;
signal temacLL_EOF_n_i       : std_logic;
   
signal llTemacRstDetected            : std_logic;
signal rstRxDomain                   : std_logic;

begin
  
  -------------------------------------------------------------------------
  -- Detect the Local Link Reset and hold it for the other clock domain to 
  -- detect it.  After the rx_cl_clk domain detects the reset, clear the 
  -- detect signal
  -------------------------------------------------------------------------
  DETECT_RESET : process(LLTemac_Clk)
  begin
  
     if rising_edge(LLTemac_Clk) then
        if LLTemac_Rst = '1' then
           llTemacRstDetected <= '1';
        elsif rstRxDomain = '1' then
           llTemacRstDetected <= '0';  
        else
           llTemacRstDetected <= llTemacRstDetected;
        end if;
     end if;
  end process;
         
  -------------------------------------------------------------------------
  -- The reset has been detected, so pulse the reset for one clock in the 
  -- rx_cl_clk domain.  Use rstRxDomain to synchronously reset all logic in
  -- the in the rx_cl_clk domain.
  -------------------------------------------------------------------------
  SET_RESET : process(Rx_Cl_Clk)
  begin
  
     if rising_edge(Rx_Cl_Clk) then
        if llTemacRstDetected = '1' then
           rstRxDomain <= '1';
        else
           rstRxDomain <= '0';
        end if;
     end if;
  end process;  

------------------------------------------------------------------------------
-- Concurrent Signal Assignments
------------------------------------------------------------------------------

TemacLL_SOF_n <= temacLL_SOF_n_i;
TemacLL_EOF_n <= temacLL_EOF_n_i;

TemacLL_SRC_RDY_n <= temacLL_SRC_RDY_n_i;

------------------------------------------------------------------------------
--  Component Instantiations
------------------------------------------------------------------------------

  RXCLCLK_STRETCH_INTRPT : process(Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (rstRxDomain = '1') then
        rxClClkRxCmplt_d1    <= '0';
        rxClClkRxCmplt_d2    <= '0';
        rxClClkRxCmplt_d3    <= '0';
        rxClClkRxCmplt_d4    <= '0';
        rxClClkRxCmplt_d5    <= '0';
        
        rxClClkRxPcktRej_d1  <= '0';
        rxClClkRxPcktRej_d2  <= '0';
        rxClClkRxPcktRej_d3  <= '0';
        rxClClkRxPcktRej_d4  <= '0';
        rxClClkRxPcktRej_d5  <= '0';
        
        rxClClkPcktOvrRun_d1 <= '0';
        rxClClkPcktOvrRun_d2 <= '0';
        rxClClkPcktOvrRun_d3 <= '0';
        rxClClkPcktOvrRun_d4 <= '0';
        rxClClkPcktOvrRun_d5 <= '0';
      else
        rxClClkRxCmplt_d1 <= rxClClkFrameAcptInt;
        rxClClkRxCmplt_d2 <= rxClClkRxCmplt_d1;
        rxClClkRxCmplt_d3 <= rxClClkRxCmplt_d2;
        rxClClkRxCmplt_d4 <= rxClClkRxCmplt_d3;
        rxClClkRxCmplt_d5 <= rxClClkRxCmplt_d4;
        rxClClkRxCmplt_d6 <= (rxClClkRxCmplt_d1 OR rxClClkRxCmplt_d2 OR rxClClkRxCmplt_d3 OR rxClClkRxCmplt_d4 OR rxClClkRxCmplt_d5);
        
        rxClClkRxPcktRej_d1 <= rxClClkFrameDropInt OR rxClClkFrameRejtInt;
        rxClClkRxPcktRej_d2 <= rxClClkRxPcktRej_d1;
        rxClClkRxPcktRej_d3 <= rxClClkRxPcktRej_d2;
        rxClClkRxPcktRej_d4 <= rxClClkRxPcktRej_d3;
        rxClClkRxPcktRej_d5 <= rxClClkRxPcktRej_d4;
        rxClClkRxPcktRej_d6 <= (rxClClkRxPcktRej_d1 OR rxClClkRxPcktRej_d2 OR rxClClkRxPcktRej_d3 OR rxClClkRxPcktRej_d4 OR rxClClkRxPcktRej_d5);
        
        rxClClkPcktOvrRun_d1 <= rxClClkMemFullInt;
        rxClClkPcktOvrRun_d2 <= rxClClkPcktOvrRun_d1;
        rxClClkPcktOvrRun_d3 <= rxClClkPcktOvrRun_d2;
        rxClClkPcktOvrRun_d4 <= rxClClkPcktOvrRun_d3;
        rxClClkPcktOvrRun_d5 <= rxClClkPcktOvrRun_d4;
        rxClClkPcktOvrRun_d6 <= (rxClClkPcktOvrRun_d1 OR rxClClkPcktOvrRun_d2 OR rxClClkPcktOvrRun_d3 OR rxClClkPcktOvrRun_d4 OR rxClClkPcktOvrRun_d5);
      end if;
    end if;
  end process;
  
  RXLLCLK_STRETCH_INTRPT : process(Plb_Clk)
  begin
    if (Plb_Clk'event and Plb_Clk = '1') then
      if (Plb_Rst = '1') then
        rxLlClkRxCmplt_d1    <= '0';
        Rx_cmplt             <= '0';
        
        rxLlClkRxPcktRej_d1  <= '0';
        Rx_pckt_rej          <= '0';
        
        rxLlClkPcktOvrRun_d1 <= '0';
        Pckt_Ovr_Run         <= '0';
      else
        rxLlClkRxCmplt_d1 <= rxClClkRxCmplt_d6;
        rxLlClkRxCmplt_d2 <= rxLlClkRxCmplt_d1;
        Rx_cmplt          <= rxLlClkRxCmplt_d1 and not(rxLlClkRxCmplt_d2);
        
        rxLlClkRxPcktRej_d1 <= rxClClkRxPcktRej_d6;
        rxLlClkRxPcktRej_d2 <= rxLlClkRxPcktRej_d1;
        Rx_pckt_rej         <= rxLlClkRxPcktRej_d1 and not(rxLlClkRxPcktRej_d2);
        
        rxLlClkPcktOvrRun_d1 <= rxClClkPcktOvrRun_d6;
        rxLlClkPcktOvrRun_d2 <= rxLlClkPcktOvrRun_d1;
        Pckt_Ovr_Run         <= rxLlClkPcktOvrRun_d1 and not(rxLlClkPcktOvrRun_d2);
      end if;
    end if;
  end process;
  
  I_RX_CL_IF : entity xps_ll_temac_v2_03_a.rx_cl_if                                   
    generic map(                                                                     
      C_FAMILY             => C_FAMILY,
      C_TEMAC_TYPE         => C_TEMAC_TYPE,                                      
      C_TEMAC_RXFIFO       => C_TEMAC_RXFIFO,
      C_TEMAC_MCAST_EXTEND => C_TEMAC_MCAST_EXTEND,
      C_MEM_DEPTH          => C_MEM_DEPTH
      )                                                                                                                                                                               
    port map(                                                                               
      LLTemac_Clk              => LLTemac_Clk,               -- in                         
      RxClClk_Rst              => rstRxDomain,               -- in                         
      Rx_Cl_Clk                => Rx_Cl_Clk,                 -- in
      RxClClkEn                => RxClClkEn,                 -- in
      RxClClkFrameDropInt      => rxClClkFrameDropInt,	     -- out
      RxClClkFrameRejtInt      => rxClClkFrameRejtInt,	     -- out
      RxClClkFrameAcptInt      => rxClClkFrameAcptInt,	     -- out
      RxClClkMemFullInt        => rxClClkMemFullInt,  	     -- out
      PlbRegCrBrdCastRej       => RegCR_BrdCast_Rej,         -- in 
      PlbRegCrMulCastRej       => RegCR_MulCast_Rej,         -- in 
      EmacClientRxBadFrame     => EmacClientRxBadFrame,      -- in
      EmacClientRxd            => EmacClientRxd,             -- in
      EmacClientRxdVld         => EmacClientRxdVld,          -- in
      EmacClientRxFrameDrop    => EmacClientRxFrameDrop,     -- in
      EmacClientRxGoodFrame    => EmacClientRxGoodFrame,     -- in
      EmacClientRxStatsVld     => EmacClientRxStatsVld,      -- in
      EmacClientRxStats        => EmacClientRxStats,         -- in
      SoftEmacClientRxStats    => SoftEmacClientRxStats,     -- in
      RxClClkMcastAddr         => RxClClkMcastAddr,          -- out
      RxClClkMcastEn           => RxClClkMcastEn,            -- out
      RxClClkMcastRdData       => RxClClkMcastRdData,        -- in
      LlinkClkEMultiFltrEnbl   => LlinkClkEMultiFltrEnbl,    -- in
      UawLRegData              => UawLRegData,               -- in
      UawURegData              => UawURegData,               -- in
      LlinkClkNewFncEnbl       => LlinkClkNewFncEnbl,        -- in
      RxLLinkClkDPMemWrData    => rxLLinkClkDPMemWrData,     -- in
      RxLLinkClkDPMemRdData    => rxLLinkClkDPMemRdData,     -- out
      RxLLinkClkDPMemWrEn      => rxLLinkClkDPMemWrEn,       -- in
      RxLLinkClkDPMemAddr      => rxLLinkClkDPMemAddr,       -- in
      RxLlClkLastProcessedGray => rxLlClkLastProcessedGray   -- in
      );

  NO_INCLUDE_RX_VLAN: if(C_TEMAC_RXVLAN_TRAN = 0 and C_TEMAC_RXVLAN_TAG = 0 and C_TEMAC_RXVLAN_STRP = 0) generate
  begin
    I_RX_LL_IF : entity xps_ll_temac_v2_03_a.rx_ll_if 
      generic map(
        C_FAMILY        => C_FAMILY,
        C_TEMAC_TYPE    => C_TEMAC_TYPE,
        C_TEMAC_RXCSUM  => C_TEMAC_RXCSUM,
        C_TEMAC_RXFIFO  => C_TEMAC_RXFIFO,
        C_TEMAC_RXVLAN_TRAN  => C_TEMAC_RXVLAN_TRAN,
        C_TEMAC_RXVLAN_TAG   => C_TEMAC_RXVLAN_TAG,
        C_TEMAC_RXVLAN_STRP  => C_TEMAC_RXVLAN_STRP,
        C_MEM_DEPTH          => C_MEM_DEPTH
        )
      port map(
        LLTemac_Clk             => LLTemac_Clk,          -- in  
        LLTemac_Rst             => LLTemac_Rst,          -- in  
        TemacLL_SOF_n           => temacLL_SOF_n_i,        -- out 
        TemacLL_SOP_n           => TemacLL_SOP_n,        -- out 
        TemacLL_EOF_n           => temacLL_EOF_n_i,        -- out 
        TemacLL_EOP_n           => TemacLL_EOP_n,        -- out 
        TemacLL_SRC_RDY_n       => temacLL_SRC_RDY_n_i,    -- out 
        TemacLL_DST_RDY_n       => TemacLL_DST_RDY_n,    -- in  
        TemacLL_REM             => TemacLL_REM,          -- out 
        TemacLL_Data            => TemacLL_Data,         -- out 
        RxLLinkClkDPMemWrData   => rxLLinkClkDPMemWrData,-- out
        RxLLinkClkDPMemRdData   => rxLLinkClkDPMemRdData,-- in
        RxLLinkClkDPMemWrEn     => rxLLinkClkDPMemWrEn,  -- out
        RxLLinkClkDPMemAddr     => rxLLinkClkDPMemAddr,  -- out
        LlinkClkNewFncEnbl      => LlinkClkNewFncEnbl,   -- in
        RtagRegData             => RtagRegData,          -- in
        Tpid0RegData            => Tpid0RegData,         -- in
        Tpid1RegData            => Tpid1RegData,         -- in
        LlinkClkVlanAddr        => LlinkClkVlanAddr,     -- out
        LlinkClkVlanRdData      => LlinkClkVlanRdData,   -- in
        LlinkClkRxVlanBramEnA   => LlinkClkRxVlanBramEnA,-- out
        RxLLinkRdMemPtrErr      => rxLLinkRdMemPtrErrInt, -- out
        RxLlClkLastProcessedGray => rxLlClkLastProcessedGray -- out
        );
  end generate NO_INCLUDE_RX_VLAN;

  INCLUDE_RX_VLAN: if(C_TEMAC_RXVLAN_TRAN = 1 or C_TEMAC_RXVLAN_TAG = 1 or C_TEMAC_RXVLAN_STRP = 1) generate
  begin
    I_RX_VLAN_LL_IF : entity xps_ll_temac_v2_03_a.rx_vlan_ll_if 
      generic map(
        C_FAMILY        => C_FAMILY,
        C_TEMAC_TYPE    => C_TEMAC_TYPE,
        C_TEMAC_RXCSUM  => C_TEMAC_RXCSUM,
        C_TEMAC_RXFIFO  => C_TEMAC_RXFIFO,
        C_TEMAC_RXVLAN_TRAN  => C_TEMAC_RXVLAN_TRAN,
        C_TEMAC_RXVLAN_TAG   => C_TEMAC_RXVLAN_TAG,
        C_TEMAC_RXVLAN_STRP  => C_TEMAC_RXVLAN_STRP,
        C_MEM_DEPTH          => C_MEM_DEPTH,
        C_TEMAC_RXVLAN_WIDTH => C_TEMAC_RXVLAN_WIDTH
        )
      port map(
        LLTemac_Clk             => LLTemac_Clk,          -- in  
        LLTemac_Rst             => LLTemac_Rst,          -- in  
        TemacLL_SOF_n           => temacLL_SOF_n_i,        -- out 
        TemacLL_SOP_n           => TemacLL_SOP_n,        -- out 
        TemacLL_EOF_n           => temacLL_EOF_n_i,        -- out 
        TemacLL_EOP_n           => TemacLL_EOP_n,        -- out 
        TemacLL_SRC_RDY_n       => temacLL_SRC_RDY_n_i,    -- out 
        TemacLL_DST_RDY_n       => TemacLL_DST_RDY_n,    -- in  
        TemacLL_REM             => TemacLL_REM,          -- out 
        TemacLL_Data            => TemacLL_Data,         -- out 
        RxLLinkClkDPMemWrData   => rxLLinkClkDPMemWrData,-- out
        RxLLinkClkDPMemRdData   => rxLLinkClkDPMemRdData,-- in
        RxLLinkClkDPMemWrEn     => rxLLinkClkDPMemWrEn,  -- out
        RxLLinkClkDPMemAddr     => rxLLinkClkDPMemAddr,  -- out
        LlinkClkNewFncEnbl      => LlinkClkNewFncEnbl,   -- in
        LlinkClkRxVStrpMode     => LlinkClkRxVStrpMode,  -- in
        LlinkClkRxVTagMode      => LlinkClkRxVTagMode,   -- in
        RtagRegData             => RtagRegData,          -- in
        Tpid0RegData            => Tpid0RegData,         -- in
        Tpid1RegData            => Tpid1RegData,         -- in
        LlinkClkVlanAddr        => LlinkClkVlanAddr,     -- out
        LlinkClkVlanRdData      => LlinkClkVlanRdData,   -- in
        LlinkClkRxVlanBramEnA   => LlinkClkRxVlanBramEnA,-- out
        RxLLinkRdMemPtrErr      => rxLLinkRdMemPtrErrInt, -- out
        RxLlClkLastProcessedGray => rxLlClkLastProcessedGray -- out
        );
  end generate INCLUDE_RX_VLAN;

end beh;
