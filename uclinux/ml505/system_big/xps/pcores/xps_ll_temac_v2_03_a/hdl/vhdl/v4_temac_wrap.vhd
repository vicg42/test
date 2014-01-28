------------------------------------------------------------------------------
-- $Id: v4_temac_wrap.vhd,v 1.1.4.39 2009/11/17 07:11:36 tomaik Exp $
------------------------------------------------------------------------------
-- v4_temac_wrap.vhd
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
-- Filename:        v4_temac_wrap.vhd
-- Version:         v3.00a
-- Description:     top level of v4_temac_wrap
--
------------------------------------------------------------------------------
-- Structure:   
--              v4_temac_wrap.vhd
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

-- synopsys translate_off
Library XilinxCoreLib;
library simprim;
-- synopsys translate_on

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity v4_temac_wrap is
  generic (
           C_NUM_IDELAYCTRL            : integer range 0 to 16 := 1;
             -- RANGE = (0:16)
           C_RESERVED                  : integer          := 0;  
           C_PHY_TYPE                  : integer          := 1;
             -- 0 - MII                
             -- 1 - GMII               
             -- 2 - RGMII V1.3         
             -- 3 - RGMII V2.0         
             -- 4 - SGMII         
             -- 5 - 1000Base-X PCS/PMA 
             -- 6 - None (not used)
           C_INCLUDE_IO                : integer          := 1;
           C_EMAC1_PRESENT             : integer          := 0;
             -- 0 - EMAC 0 used but EMAC 1 not used
             -- 1 - EMAC 0 and EMAC 1 used
           C_EMAC0_DCRBASEADDR         : bit_vector       := "0000000000";
           C_EMAC1_DCRBASEADDR         : bit_vector       := "0000000000";
           C_TEMAC0_PHYADDR            : std_logic_vector(4 downto 0) := "00001";
           C_TEMAC1_PHYADDR            : std_logic_vector(4 downto 0) := "00010"
          );

  port (
        -- Client Receiver Interface - EMAC0
        EMAC0CLIENTRXD             : out std_logic_vector(7 downto  0);
        EMAC0CLIENTRXDVLD          : out std_logic;
        EMAC0CLIENTRXDVLDMSW       : out std_logic;
        EMAC0CLIENTRXGOODFRAME     : out std_logic;
        EMAC0CLIENTRXBADFRAME      : out std_logic;
        EMAC0CLIENTRXFRAMEDROP     : out std_logic;
        EMAC0CLIENTRXDVREG6        : out std_logic;
        EMAC0CLIENTRXSTATS         : out std_logic_vector(6  downto  0);
        EMAC0CLIENTRXSTATSVLD      : out std_logic;
        EMAC0CLIENTRXSTATSBYTEVLD  : out std_logic;

        -- Client Transmitter Interface - EMAC0
        CLIENTEMAC0TXD             : in  std_logic_vector(7 downto  0);
        CLIENTEMAC0TXDVLD          : in  std_logic;
        CLIENTEMAC0TXDVLDMSW       : in  std_logic;
        EMAC0CLIENTTXACK           : out std_logic;
        CLIENTEMAC0TXFIRSTBYTE     : in  std_logic;
        CLIENTEMAC0TXUNDERRUN      : in  std_logic;
        EMAC0CLIENTTXCOLLISION     : out std_logic;
        EMAC0CLIENTTXRETRANSMIT    : out std_logic;
        CLIENTEMAC0TXIFGDELAY      : in  std_logic_vector(7  downto  0);
        EMAC0CLIENTTXSTATS         : out std_logic;
        EMAC0CLIENTTXSTATSVLD      : out std_logic;
        EMAC0CLIENTTXSTATSBYTEVLD  : out std_logic;

        -- MAC Control Interface - EMAC0
        CLIENTEMAC0PAUSEREQ        : in  std_logic;
        CLIENTEMAC0PAUSEVAL        : in  std_logic_vector(15 downto  0);

        -- GTX_CLK 125 MHz clock frequency supplied by the user
        GTX_CLK_0                  : in  std_logic;           

        RX_CLIENT_CLK_0            : out std_logic;      
        TX_CLIENT_CLK_0            : out std_logic;      

        -- MII Interface - EMAC0
        MII_TXD_0                  : out std_logic_vector(3 downto 0);
        MII_TX_EN_0                : out std_logic;
        MII_TX_ER_0                : out std_logic;
        MII_RXD_0                  : in  std_logic_vector(3 downto 0);
        MII_RX_DV_0                : in  std_logic;
        MII_RX_ER_0                : in  std_logic;
        MII_RX_CLK_0               : in  std_logic;

        -- MII & GMII Interface - EMAC0
        MII_TX_CLK_0               : in  std_logic;

        -- GMII Interface - EMAC0
        GMII_TXD_0                 : out std_logic_vector(7 downto 0);
        GMII_TX_EN_0               : out std_logic;
        GMII_TX_ER_0               : out std_logic;
        GMII_TX_CLK_0              : out std_logic;
        GMII_RXD_0                 : in  std_logic_vector(7 downto 0);
        GMII_RX_DV_0               : in  std_logic;
        GMII_RX_ER_0               : in  std_logic;
        GMII_RX_CLK_0              : in  std_logic;

        -- SGMII Interface - EMAC0
        TXP_0                      : out std_logic;
        TXN_0                      : out std_logic;
        RXP_0                      : in  std_logic;
        RXN_0                      : in  std_logic;

        -- RGMII Interface - EMAC0
        RGMII_TXD_0                : out std_logic_vector(3 downto 0);
        RGMII_TX_CTL_0             : out std_logic;
        RGMII_TXC_0                : out std_logic;
        RGMII_RXD_0                : in  std_logic_vector(3 downto 0);
        RGMII_RX_CTL_0             : in  std_logic;
        RGMII_RXC_0                : in  std_logic;
        RGMII_IOB_0                : inout std_logic;

        -- MDIO Interface - EMAC0
        MDC_0                      : out std_logic;
        MDIO_0_I                   : in  std_logic;
        MDIO_0_O                   : out std_logic;
        MDIO_0_T                   : out std_logic;

        EMAC0CLIENTANINTERRUPT     : out std_logic;
        EMAC0ResetDoneInterrupt    : out std_logic;

        -- Client Receiver Interface - EMAC1
        EMAC1CLIENTRXD             : out std_logic_vector(7 downto  0);
        EMAC1CLIENTRXDVLD          : out std_logic;
        EMAC1CLIENTRXDVLDMSW       : out std_logic;
        EMAC1CLIENTRXGOODFRAME     : out std_logic;
        EMAC1CLIENTRXBADFRAME      : out std_logic;
        EMAC1CLIENTRXFRAMEDROP     : out std_logic;
        EMAC1CLIENTRXDVREG6        : out std_logic;
        EMAC1CLIENTRXSTATS         : out std_logic_vector(6  downto  0);
        EMAC1CLIENTRXSTATSVLD      : out std_logic;
        EMAC1CLIENTRXSTATSBYTEVLD  : out std_logic;

        -- Client Transmitter Interface - EMAC1
        CLIENTEMAC1TXD             : in  std_logic_vector(7 downto  0);
        CLIENTEMAC1TXDVLD          : in  std_logic;
        CLIENTEMAC1TXDVLDMSW       : in  std_logic;
        EMAC1CLIENTTXACK           : out std_logic;
        CLIENTEMAC1TXFIRSTBYTE     : in  std_logic;
        CLIENTEMAC1TXUNDERRUN      : in  std_logic;
        EMAC1CLIENTTXCOLLISION     : out std_logic;
        EMAC1CLIENTTXRETRANSMIT    : out std_logic;
        CLIENTEMAC1TXIFGDELAY      : in  std_logic_vector(7  downto  0);
        EMAC1CLIENTTXSTATS         : out std_logic;
        EMAC1CLIENTTXSTATSVLD      : out std_logic;
        EMAC1CLIENTTXSTATSBYTEVLD  : out std_logic;

        -- MAC Control Interface - EMAC1
        CLIENTEMAC1PAUSEREQ        : in  std_logic;
        CLIENTEMAC1PAUSEVAL        : in  std_logic_vector(15 downto  0);

        RX_CLIENT_CLK_1            : out std_logic;
        TX_CLIENT_CLK_1            : out std_logic;

        -- MII Interface - EMAC1
        MII_TXD_1                  : out std_logic_vector(3 downto 0);
        MII_TX_EN_1                : out std_logic;
        MII_TX_ER_1                : out std_logic;
        MII_RXD_1                  : in  std_logic_vector(3 downto 0);
        MII_RX_DV_1                : in  std_logic;
        MII_RX_ER_1                : in  std_logic;
        MII_RX_CLK_1               : in  std_logic;

        -- MII & GMII Interface - EMAC0
        MII_TX_CLK_1               : in  std_logic;

        -- GMII Interface - EMAC1
        GMII_TXD_1                 : out std_logic_vector(7 downto 0);
        GMII_TX_EN_1               : out std_logic;
        GMII_TX_ER_1               : out std_logic;
        GMII_TX_CLK_1              : out std_logic;
        GMII_RXD_1                 : in  std_logic_vector(7 downto 0);
        GMII_RX_DV_1               : in  std_logic;
        GMII_RX_ER_1               : in  std_logic;
        GMII_RX_CLK_1              : in  std_logic;

        -- SGMII Interface - EMAC1
        TXP_1                      : out std_logic;
        TXN_1                      : out std_logic;
        RXP_1                      : in  std_logic;
        RXN_1                      : in  std_logic;

        -- RGMII Interface - EMAC1
        RGMII_TXD_1                : out std_logic_vector(3 downto 0);
        RGMII_TX_CTL_1             : out std_logic;
        RGMII_TXC_1                : out std_logic;
        RGMII_RXD_1                : in  std_logic_vector(3 downto 0);
        RGMII_RX_CTL_1             : in  std_logic;
        RGMII_RXC_1                : in  std_logic;
        RGMII_IOB_1                : inout std_logic;

        -- MDIO Interface - EMAC1
        MDC_1                      : out std_logic;
        MDIO_1_I                   : in  std_logic;
        MDIO_1_O                   : out std_logic;
        MDIO_1_T                   : out std_logic;

        EMAC1CLIENTANINTERRUPT     : out std_logic;
        EMAC1ResetDoneInterrupt    : out std_logic;

        -- Host Interface
        HOSTMIIMSEL                : in  std_logic;
        HOSTWRDATA                 : in  std_logic_vector(31 downto 0);
        HOSTMIIMRDY                : out std_logic;
        HOSTRDDATA                 : out std_logic_vector(31 downto 0);

        HOSTCLK                    : in  std_logic;

        -- DCR Interface
        DCREMACCLK                 : in  std_logic;
        DCREMACABUS                : in  std_logic_vector(0 to 9);
        DCREMACREAD                : in  std_logic;
        DCREMACWRITE               : in  std_logic;
        DCREMACDBUS                : in  std_logic_vector(0 to 31);
        EMACDCRACK                 : out std_logic;
        EMACDCRDBUS                : out std_logic_vector(0 to 31);
        DCREMACENABLE              : in  std_logic;
        DCRHOSTDONEIR              : out std_logic;

        -- SGMII MGT Clock buffer inputs 
        MGTCLK_P                   : in  std_logic;
        MGTCLK_N                   : in  std_logic;

        -- Dynamic Reconfiguration Port Clock Must be between 25MHz - 50 MHz                 
        DCLK                       : in  std_logic;
        
        -- Asynchronous Reset
        RESET                      : in  std_logic;

       -- Reference clock for RGMII IODELAYs Need to supply a 200MHz clock
        REFCLK                     : in  std_logic
       );
    
end v4_temac_wrap;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture imp of v4_temac_wrap is

------------------------------------------------------------------------------
--  Constant Declarations
------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Function declarations
-----------------------------------------------------------------------------


------------------------------------------------------------------------------
-- Signal and Type Declarations
------------------------------------------------------------------------------

  signal gnd_i          : std_logic;
  signal vcc_i          : std_logic;

  signal hOSTOPCODE_i   : std_logic_vector(1 downto 0);
  signal hOSTREQ_i      : std_logic;
  signal hOSTMIIMSEL_i : std_logic;
  signal hOSTADDR_i     : std_logic_vector(9 downto 0);
  signal hOSTWRDATA_i   : std_logic_vector(31 downto 0);
  signal hOSTMIIMRDY_i  : std_logic;
  signal hOSTRDDATA_i   : std_logic_vector(31 downto 0);
  signal hOSTEMAC1SEL_i : std_logic;

  signal mDC_0_i        : std_logic;
  signal mDIO_0_T_i     : std_logic;
  signal mDIO_0_O_i     : std_logic;

  signal mDC_1_i        : std_logic;
  signal mDIO_1_T_i     : std_logic;
  signal mDIO_1_O_i     : std_logic;

-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin

    gnd_i <= '0';
    vcc_i <= '1';
    EMAC0CLIENTANINTERRUPT <= '0';
    EMAC1CLIENTANINTERRUPT <= '0';

------------------------------------------------------------------------------
-- Concurrent Signal Assignments
------------------------------------------------------------------------------

  HOSTMIIMRDY <= '0';
  HOSTRDDATA  <= (others => '0');
  
  EMAC0CLIENTRXDVLDMSW <= '0';
  EMAC0CLIENTRXDVREG6  <= '0';
  EMAC1CLIENTRXDVLDMSW <= '0';
  EMAC1CLIENTRXDVREG6  <= '0';

  MDC_0    <= mDC_0_i;
  MDIO_0_O <= mDIO_0_O_i;
  MDIO_0_T <= mDIO_0_T_i;

  MDC_1    <= mDC_1_i;
  MDIO_1_O <= mDIO_1_O_i;
  MDIO_1_T <= mDIO_1_T_i;

------------------------------------------------------------------------------
-- Component Instantiations
------------------------------------------------------------------------------
I_DCR2GHI : entity xps_ll_temac_v2_03_a.dcr2ghi(imP)
  generic map (
    C_EMAC1_PRESENT => C_EMAC1_PRESENT
  )
  port map (
    -- DCR Interface
    DcrEmacClk      => DcrEmacClk,     --in  
    DcrEmacAbus     => DcrEmacAbus,    --in  
    DcrEmacRead     => DcrEmacRead,    --in  
    DcrEmacWrite    => DcrEmacWrite,   --in  
    DcrEmacDbus     => DcrEmacDbus,    --in  
    EmacDcrAck      => EmacDcrAck,     --out 
    EmacDcrDbus     => EmacDcrDbus,    --out 
    DcrEmacEnable   => DcrEmacEnable,  --in  
    DcrHostDoneIR   => DcrHostDoneIR,  --out 

    -- Asynchronous Reset
    Reset           => Reset,          --in  
       
    -- Generic Host Interface
    HostOpcode      => hOSTOPCODE_i,   --out 
    HostReq         => hOSTREQ_i,      --out 
    HostMiiMSel     => hOSTMIIMSEL_i,  --out 
    HostAddr        => hOSTADDR_i,     --out 
    HostWrData      => hOSTWRDATA_i,   --out 
    HostMiimRdy     => hOSTMIIMRDY_i,  --in  
    HostRdData      => hOSTRDDATA_i,   --in  
    HostEmac1Sel    => hOSTEMAC1SEL_i, --out 
    HostClk         => HOSTCLK         --in  must be the same as DCR clock
    );   

SINGLE_MII: if(C_PHY_TYPE = 0 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is MII and EMAC1 is not used
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_single_mii_top(TOP_LEVEL)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 
          
          
      -- Clock Signal - EMAC0
      -- MII Interface - EMAC0
      MII_TXD_0                 => MII_TXD_0,                 --out
      MII_TX_EN_0               => MII_TX_EN_0,               --out
      MII_TX_ER_0               => MII_TX_ER_0,               --out
      MII_TX_CLK_0              => MII_TX_CLK_0,              --in
      MII_RXD_0                 => MII_RXD_0,                 --in
      MII_RX_DV_0               => MII_RX_DV_0,               --in
      MII_RX_ER_0               => MII_RX_ER_0,               --in
      MII_RX_CLK_0              => MII_RX_CLK_0,              --in
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in 
          
          
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate SINGLE_MII;

DUAL_MII: if(C_PHY_TYPE = 0 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are MII
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_dual_mii_top(TOP_LEVEL)
    generic map (
                 C_RESERVED              => C_RESERVED,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 

                   
      -- Clock Signal - EMAC0
      -- MII Interface - EMAC0
      MII_TXD_0                 => MII_TXD_0,                 --out
      MII_TX_EN_0               => MII_TX_EN_0,               --out
      MII_TX_ER_0               => MII_TX_ER_0,               --out
      MII_TX_CLK_0              => MII_TX_CLK_0,              --in
      MII_RXD_0                 => MII_RXD_0,                 --in
      MII_RX_DV_0               => MII_RX_DV_0,               --in
      MII_RX_ER_0               => MII_RX_ER_0,               --in
      MII_RX_CLK_0              => MII_RX_CLK_0,              --in
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out                 
        -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_1           => RX_CLIENT_CLK_1,           --out
      EMAC1CLIENTRXD            => EMAC1CLIENTRXD,            --out
      EMAC1CLIENTRXDVLD         => EMAC1CLIENTRXDVLD,         --out
      EMAC1CLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out
      EMAC1CLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_1           => TX_CLIENT_CLK_1,           --out
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMAC1TXFIRSTBYTE    => CLIENTEMAC1TXFIRSTBYTE,                       --in
      CLIENTEMAC1TXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in 
      EMAC1CLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out
      EMAC1CLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC1TXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in 
      EMAC1CLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out
      EMAC1CLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out
      EMAC1CLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface - EMAC1
      CLIENTEMAC1PAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in 
      CLIENTEMAC1PAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in 

                   
      -- Clock Signal - EMAC1
      -- MII Interface - EMAC1
      MII_TXD_1                 => MII_TXD_1,                 --out
      MII_TX_EN_1               => MII_TX_EN_1,               --out
      MII_TX_ER_1               => MII_TX_ER_1,               --out
      MII_TX_CLK_1              => MII_TX_CLK_1,              --in
      MII_RXD_1                 => MII_RXD_1,                 --in
      MII_RX_DV_1               => MII_RX_DV_1,               --in
      MII_RX_ER_1               => MII_RX_ER_1,               --in
      MII_RX_CLK_1              => MII_RX_CLK_1,              --in
                         
      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in 
          
          
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate DUAL_MII;

SINGLE_GMII: if(C_PHY_TYPE = 1 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is GMII and EMAC1 is not used
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_single_gmii_top(TOP_LEVEL)
    generic map (
                 C_NUM_IDELAYCTRL        => C_NUM_IDELAYCTRL,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out      
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out      
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 
         
         
      -- GTX_CLK 125 MHz clock frequency supplied by the user
      GTX_CLK_0                 => GTX_CLK_0,                 --in            
      -- GMII Interface - EMAC0
      GMII_TXD_0                => GMII_TXD_0,                --out
      GMII_TX_EN_0              => GMII_TX_EN_0,              --out
      GMII_TX_ER_0              => GMII_TX_ER_0,              --out
      GMII_TX_CLK_0             => GMII_TX_CLK_0,             --in
      GMII_RXD_0                => GMII_RXD_0,                --in
      GMII_RX_DV_0              => GMII_RX_DV_0,              --in
      GMII_RX_ER_0              => GMII_RX_ER_0,              --in
      GMII_RX_CLK_0             => GMII_RX_CLK_0,             --in

      MII_TX_CLK_0              => MII_TX_CLK_0,              --in
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in 
      -- Reference clock for RGMII IODELAYs Need to supply a 200MHz clock
      REFCLK                    => REFCLK,                    --in 

                    
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate SINGLE_GMII;

DUAL_GMII: if(C_PHY_TYPE = 1 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are GMII
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_dual_gmii_top(TOP_LEVEL)
    generic map (
                 C_NUM_IDELAYCTRL        => C_NUM_IDELAYCTRL,
                 C_RESERVED              => C_RESERVED,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out      
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out      
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 
                   

      -- Clock Signals - EMAC0
      -- GMII Interface - EMAC0
      GMII_TXD_0                => GMII_TXD_0,                --out
      GMII_TX_EN_0              => GMII_TX_EN_0,              --out
      GMII_TX_ER_0              => GMII_TX_ER_0,              --out
      GMII_TX_CLK_0             => GMII_TX_CLK_0,             --in
      GMII_RXD_0                => GMII_RXD_0,                --in
      GMII_RX_DV_0              => GMII_RX_DV_0,              --in
      GMII_RX_ER_0              => GMII_RX_ER_0,              --in
      GMII_RX_CLK_0             => GMII_RX_CLK_0,             --in

      MII_TX_CLK_0              => MII_TX_CLK_0,              --in
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out                
      -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_1           => RX_CLIENT_CLK_1,           --out
      EMAC1CLIENTRXD            => EMAC1CLIENTRXD,            --out
      EMAC1CLIENTRXDVLD         => EMAC1CLIENTRXDVLD,         --out
      EMAC1CLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out
      EMAC1CLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_1           => TX_CLIENT_CLK_1,           --out
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMAC1TXFIRSTBYTE    => CLIENTEMAC1TXFIRSTBYTE,                       --in
      CLIENTEMAC1TXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in 
      EMAC1CLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out
      EMAC1CLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC1TXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in 
      EMAC1CLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out
      EMAC1CLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out
      EMAC1CLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface - EMAC1
      CLIENTEMAC1PAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in 
      CLIENTEMAC1PAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in 

                   
      -- Clock Signal - EMAC1
      -- GMII Interface - EMAC1
      GMII_TXD_1                => GMII_TXD_1,                --out
      GMII_TX_EN_1              => GMII_TX_EN_1,              --out
      GMII_TX_ER_1              => GMII_TX_ER_1,              --out
      GMII_TX_CLK_1             => GMII_TX_CLK_1,             --in
      GMII_RXD_1                => GMII_RXD_1,                --in
      GMII_RX_DV_1              => GMII_RX_DV_1,              --in
      GMII_RX_ER_1              => GMII_RX_ER_1,              --in
      GMII_RX_CLK_1             => GMII_RX_CLK_1,             --in

      MII_TX_CLK_1              => MII_TX_CLK_1,              --in
                         
      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out
      -- Generic Host Interface
     HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in 
      -- Reference clock for RGMII IODELAYs Need to supply a 200MHz clock
      REFCLK                    => REFCLK,                    --in 

      -- GTX_CLK 125 MHz clock frequency supplied by the user
      GTX_CLK                   => GTX_CLK_0,                 --in            


      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate DUAL_GMII;

SINGLE_SGMII: if(C_PHY_TYPE = 4 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is SGMII and EMAC1 is not used
begin
  EMAC1ResetDoneInterrupt <= '1';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_single_sgmii_top(TOP_LEVEL)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 

      --EMAC-MGT link status
      EMAC0CLIENTSYNCACQSTATUS  => open,                     --out

                   
      -- Clock Signal - EMAC0
      -- SGMII Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,                      --out

      -- unused transceiver
      TXN_1_UNUSED              => open,                      --out
      TXP_1_UNUSED              => open,                      --out
      RXN_1_UNUSED              => '0',                       --in
      RXP_1_UNUSED              => '1',                       --in
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in 
      -- SGMII MGT Clock buffer inputs 
      MGTCLK_P                  => MGTCLK_P,                  --in
      MGTCLK_N                  => MGTCLK_N,                  --in

      -- Dynamic Reconfiguration Port Clock 
      -- Must be between 25MHz - 50 MHz                 
      DCLK                      => DCLK,                      --in



      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate SINGLE_SGMII;

DUAL_SGMII: if(C_PHY_TYPE = 4 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are SGMII
begin

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_dual_sgmii_top(TOP_LEVEL)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 

      --EMAC-MGT link status
      EMAC0CLIENTSYNCACQSTATUS  => open,                     --out

                   
      -- Clock Signal - EMAC0
      -- SGMII Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,                      --out
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out                
      -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_1           => RX_CLIENT_CLK_1,           --out
      EMAC1CLIENTRXD            => EMAC1CLIENTRXD,            --out
      EMAC1CLIENTRXDVLD         => EMAC1CLIENTRXDVLD,         --out
      EMAC1CLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out
      EMAC1CLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_1           => TX_CLIENT_CLK_1,           --out
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMAC1TXFIRSTBYTE    => CLIENTEMAC1TXFIRSTBYTE,                       --in
      CLIENTEMAC1TXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in 
      EMAC1CLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out
      EMAC1CLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC1TXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in 
      EMAC1CLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out
      EMAC1CLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out
      EMAC1CLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface - EMAC1
      CLIENTEMAC1PAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in 
      CLIENTEMAC1PAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in 
                   
      --EMAC-MGT link status
      EMAC1CLIENTSYNCACQSTATUS  => open,                     --out

                   
      -- Clock Signal - EMAC1
      -- SGMII Interface - EMAC1
      TXP_1                     => TXP_1,                     --out
      TXN_1                     => TXN_1,                     --out
      RXP_1                     => RXP_1,                     --in
      RXN_1                     => RXN_1,                     --in
      PHYAD_1                   => C_TEMAC1_PHYADDR,          --in
      RESETDONE_1               => EMAC1ResetDoneInterrupt,                      --out
                         
      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in 
      -- SGMII MGT Clock buffer inputs 
      MGTCLK_P                  => MGTCLK_P,                  --in
      MGTCLK_N                  => MGTCLK_N,                  --in

      -- Dynamic Reconfiguration Port Clock 
      -- Must be between 25MHz - 50 MHz                 
      DCLK                      => DCLK,                      --in



      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate DUAL_SGMII;

SINGLE_RGMII13: if(C_PHY_TYPE = 2 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is RGMII v1.3 and EMAC1 is not used
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_single_rgmii13_top(TOP_LEVEL)
    generic map (
                 C_NUM_IDELAYCTRL        => C_NUM_IDELAYCTRL,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out      
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out      
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out      
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out      
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out      
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out      
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in       
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out      
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out      
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in       
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out      
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out      
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in       

      -- Clock Signals - EMAC0
     -- GTX_CLK 125 MHz clock frequency supplied by the user
      GTX_CLK_0                 => GTX_CLK_0,                 --in            
      -- RGMII Interface - EMAC0
      RGMII_TXD_0               => RGMII_TXD_0,               --out
      RGMII_TX_CTL_0            => RGMII_TX_CTL_0,            --out
      RGMII_TXC_0               => RGMII_TXC_0,               --out
      RGMII_RXD_0               => RGMII_RXD_0,               --in 
      RGMII_RX_CTL_0            => RGMII_RX_CTL_0,            --in 
      RGMII_RXC_0               => RGMII_RXC_0,               --in 

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in 
      -- Reference clock for RGMII IODELAYs Need to supply a 200MHz clock
      REFCLK                    => REFCLK,                    --in 
       
       
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

end generate SINGLE_RGMII13;

DUAL_RGMII13: if(C_PHY_TYPE = 2 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are RGMII v1.3
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_dual_rgmii13_top(TOP_LEVEL)
    generic map (
                 C_NUM_IDELAYCTRL        => C_NUM_IDELAYCTRL,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out      
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out      
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out      
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out      
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out      
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out      
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in       
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out      
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out      
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in       
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out      
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out      
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      
 
 
      -- Clock Signals - EMAC0
      -- RGMII Interface - EMAC0
      RGMII_TXD_0               => RGMII_TXD_0,               --out
      RGMII_TX_CTL_0            => RGMII_TX_CTL_0,            --out
      RGMII_TXC_0               => RGMII_TXC_0,               --out
      RGMII_RXD_0               => RGMII_RXD_0,               --in 
      RGMII_RX_CTL_0            => RGMII_RX_CTL_0,            --in 
      RGMII_RXC_0               => RGMII_RXC_0,               --in 

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
      -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_1           => RX_CLIENT_CLK_1,           --out      
      EMAC1CLIENTRXD            => EMAC1CLIENTRXD,            --out      
      EMAC1CLIENTRXDVLD         => EMAC1CLIENTRXDVLD,         --out      
      EMAC1CLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out      
      EMAC1CLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out      
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out      
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out      
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out      
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_1           => TX_CLIENT_CLK_1,           --out      
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in       
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in       
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out      
      CLIENTEMAC1TXFIRSTBYTE    => CLIENTEMAC1TXFIRSTBYTE,                       --in
      CLIENTEMAC1TXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in       
      EMAC1CLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out      
      EMAC1CLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out      
      CLIENTEMAC1TXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in       
      EMAC1CLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out      
      EMAC1CLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out      
      EMAC1CLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface - EMAC1
      CLIENTEMAC1PAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in      
      CLIENTEMAC1PAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in      

           
      -- Clock Signals - EMAC1
      -- RGMII Interface - EMAC1
      RGMII_TXD_1               => RGMII_TXD_1,               --out 
      RGMII_TX_CTL_1            => RGMII_TX_CTL_1,            --out 
      RGMII_TXC_1               => RGMII_TXC_1,               --out 
      RGMII_RXD_1               => RGMII_RXD_1,               --in  
      RGMII_RX_CTL_1            => RGMII_RX_CTL_1,            --in  
      RGMII_RXC_1               => RGMII_RXC_1,               --in  

      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in        
      -- Reference clock for RGMII IODELAYs Need to supply a 200MHz clock
      REFCLK                    => REFCLK,                    --in 

      -- GTX_CLK 125 MHz clock frequency supplied by the user
      GTX_CLK                   => GTX_CLK_0,                 --in            

        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

end generate DUAL_RGMII13;


SINGLE_RGMII2: if(C_PHY_TYPE = 3 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is RGMII v2 and EMAC1 is not used
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_single_rgmii2_top(TOP_LEVEL)
    generic map (
                 C_NUM_IDELAYCTRL        => C_NUM_IDELAYCTRL,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out      
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out      
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out      
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out      
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out      
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out      
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in       
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out      
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out      
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in       
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out      
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out      
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      
 
      -- Clock Signals - EMAC0
     -- GTX_CLK 125 MHz clock frequency supplied by the user
      GTX_CLK_0                 => GTX_CLK_0,                 --in            
      -- RGMII Interface - EMAC0
      RGMII_TXD_0               => RGMII_TXD_0,               --out
      RGMII_TX_CTL_0            => RGMII_TX_CTL_0,            --out
      RGMII_TXC_0               => RGMII_TXC_0,               --out
      RGMII_RXD_0               => RGMII_RXD_0,               --in 
      RGMII_RX_CTL_0            => RGMII_RX_CTL_0,            --in 
      RGMII_RXC_0               => RGMII_RXC_0,               --in 
      RGMII_IOB_0               => RGMII_IOB_0,               --inout

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in         
      -- Reference clock for RGMII IODELAYs Need to supply a 200MHz clock
      REFCLK                    => REFCLK,                    --in 

        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

end generate SINGLE_RGMII2;

DUAL_RGMII2: if(C_PHY_TYPE = 3 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are RGMII v2
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_dual_rgmii2_top(TOP_LEVEL)
    generic map (
      C_NUM_IDELAYCTRL        => C_NUM_IDELAYCTRL,
      C_INCLUDE_IO            => C_INCLUDE_IO,
      C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out      
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out      
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out      
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out      
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out      
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out      
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in       
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out      
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out      
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in       
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out      
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out      
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      
 
 
      -- Clock Signals - EMAC0
      -- RGMII Interface - EMAC0
      RGMII_TXD_0               => RGMII_TXD_0,               --out
      RGMII_TX_CTL_0            => RGMII_TX_CTL_0,            --out
      RGMII_TXC_0               => RGMII_TXC_0,               --out
      RGMII_RXD_0               => RGMII_RXD_0,               --in 
      RGMII_RX_CTL_0            => RGMII_RX_CTL_0,            --in 
      RGMII_RXC_0               => RGMII_RXC_0,               --in 
      RGMII_IOB_0               => RGMII_IOB_0,               --inout

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
      -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_1           => RX_CLIENT_CLK_1,           --out      
      EMAC1CLIENTRXD            => EMAC1CLIENTRXD,            --out      
      EMAC1CLIENTRXDVLD         => EMAC1CLIENTRXDVLD,         --out      
      EMAC1CLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out      
      EMAC1CLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out      
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out      
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out      
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out      
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_1           => TX_CLIENT_CLK_1,           --out      
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in       
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in       
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out      
      CLIENTEMAC1TXFIRSTBYTE    => CLIENTEMAC1TXFIRSTBYTE,                       --in
      CLIENTEMAC1TXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in       
      EMAC1CLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out      
      EMAC1CLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out      
      CLIENTEMAC1TXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in       
      EMAC1CLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out      
      EMAC1CLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out      
      EMAC1CLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface - EMAC1
      CLIENTEMAC1PAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in      
      CLIENTEMAC1PAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in      
         
         
      -- Clock Signals - EMAC1
      -- RGMII Interface - EMAC1
      RGMII_TXD_1               => RGMII_TXD_1,               --out 
      RGMII_TX_CTL_1            => RGMII_TX_CTL_1,            --out 
      RGMII_TXC_1               => RGMII_TXC_1,               --out 
      RGMII_RXD_1               => RGMII_RXD_1,               --in  
      RGMII_RX_CTL_1            => RGMII_RX_CTL_1,            --in  
      RGMII_RXC_1               => RGMII_RXC_1,               --in  
      RGMII_IOB_1               => RGMII_IOB_1,               --inout

      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in         
      -- Reference clock for RGMII IODELAYs Need to supply a 200MHz clock
      REFCLK                    => REFCLK,                    --in 

      -- GTX_CLK 125 MHz clock frequency supplied by the user
      GTX_CLK                   => GTX_CLK_0,                 --in            
        
        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

end generate DUAL_RGMII2;

SINGLE_1000BASEX: if(C_PHY_TYPE = 5 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is 1000Base-X and EMAC1 is not used
begin
  EMAC1ResetDoneInterrupt <= '1';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_single_1000basex_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO            => C_INCLUDE_IO,
      C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out      
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out      
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      

      --EMAC-MGT link status
      EMAC0CLIENTSYNCACQSTATUS  => open,                      --out 


      -- Clock Signals - EMAC0 
      -- 1000BASE-X PCS/PMA Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,                      --out

      -- unused transceiver
      TXN_1_UNUSED              => open,                      --out
      TXP_1_UNUSED              => open,                      --out
      RXN_1_UNUSED              => '0',                       --in
      RXP_1_UNUSED              => '1',                       --in

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in 
      -- 1000BASE-X PCS/PMA RocketIO Reference Clock buffer inputs 
      MGTCLK_P                  => MGTCLK_P,                  --in
      MGTCLK_N                  => MGTCLK_N,                  --in

      -- Dynamic Reconfiguration Port Clock Must be between 25MHz - 50 MHz                 
      DCLK                      => DCLK,                      --in
        
        
        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
   );
end generate SINGLE_1000BASEX;

DUAL_1000BASEX: if(C_PHY_TYPE = 5 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are 1000Base-X
begin

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v4_dual_1000basex_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO            => C_INCLUDE_IO,
      C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0           => RX_CLIENT_CLK_0,           --out      
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => EMAC0CLIENTRXDVLD,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0           => TX_CLIENT_CLK_0,           --out      
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => CLIENTEMAC0TXFIRSTBYTE,                       --in
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      

      --EMAC-MGT link status
      EMAC0CLIENTSYNCACQSTATUS  => open,                      --out 


      -- Clock Signals - EMAC0 
      -- 1000BASE-X PCS/PMA Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,                      --out

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
      -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_1           => RX_CLIENT_CLK_1,           --out      
      EMAC1CLIENTRXD            => EMAC1CLIENTRXD,            --out
      EMAC1CLIENTRXDVLD         => EMAC1CLIENTRXDVLD,         --out
      EMAC1CLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out
      EMAC1CLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_1           => TX_CLIENT_CLK_1,           --out      
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMAC1TXFIRSTBYTE    => CLIENTEMAC1TXFIRSTBYTE,                       --in
      CLIENTEMAC1TXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in 
      EMAC1CLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out
      EMAC1CLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out
      CLIENTEMAC1TXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in 
      EMAC1CLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out
      EMAC1CLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out
      EMAC1CLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out

      -- MAC Control Interface - EMAC1
      CLIENTEMAC1PAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in      
      CLIENTEMAC1PAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in      

      --EMAC-MGT link status
      EMAC1CLIENTSYNCACQSTATUS  => open,                      --out 


      -- Clock Signals - EMAC1 
      -- 1000BASE-X PCS/PMA Interface - EMAC1
      TXP_1                     => TXP_1,                     --out
      TXN_1                     => TXN_1,                     --out
      RXP_1                     => RXP_1,                     --in
      RXN_1                     => RXN_1,                     --in
      PHYAD_1                   => C_TEMAC1_PHYADDR,          --in
      RESETDONE_1               => EMAC1ResetDoneInterrupt,                      --out

      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out
      -- Generic Host Interface
      HOSTOPCODE                => hOSTOPCODE_i,              --in  
      HOSTREQ                   => hOSTREQ_i,                 --in  
      HOSTMIIMSEL               => hOSTMIIMSEL_i,             --in  
      HOSTADDR                  => hOSTADDR_i,                --in  
      HOSTWRDATA                => hOSTWRDATA_i,              --in  
      HOSTMIIMRDY               => hOSTMIIMRDY_i,             --out 
      HOSTRDDATA                => hOSTRDDATA_i,              --out 
      HOSTEMAC1SEL              => hOSTEMAC1SEL_i,            --in  
      HOSTCLK                   => HOSTCLK,                   --in 
      -- 1000BASE-X PCS/PMA RocketIO Reference Clock buffer inputs 
      MGTCLK_P                  => MGTCLK_P,                  --in
      MGTCLK_N                  => MGTCLK_N,                  --in

      -- Dynamic Reconfiguration Port Clock Must be between 25MHz - 50 MHz                 
      DCLK                      => DCLK,                      --in


        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
   );
end generate DUAL_1000BASEX;

end imp;
