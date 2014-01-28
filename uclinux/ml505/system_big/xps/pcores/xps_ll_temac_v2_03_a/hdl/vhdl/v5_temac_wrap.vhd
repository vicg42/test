------------------------------------------------------------------------------
-- $Id: v5_temac_wrap.vhd,v 1.1.4.39 2009/11/17 07:11:38 tomaik Exp $
------------------------------------------------------------------------------
-- v5_temac_wrap.vhd
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
-- Filename:        v5_temac_wrap.vhd
-- Version:         v3.00a
-- Description:     top level of v5_temac_wrap
--
------------------------------------------------------------------------------
-- Structure:   
--              v5_temac_wrap.vhd
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

library proc_common_v3_00_a;
use proc_common_v3_00_a.family_support.all;

-- synopsys translate_off
Library XilinxCoreLib;
library simprim;
-- synopsys translate_on

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity v5_temac_wrap is
  generic (
           C_NUM_IDELAYCTRL            : integer range 0 to 16 := 1;
             -- RANGE = (0:16)
           C_SUBFAMILY                 : string           := "FX";
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
        RX_CLIENT_CLK_ENABLE_0     : out std_logic;
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
        EMAC0CLIENTRXDVLD_TOSTATS  : out std_logic;

        -- Client Transmitter Interface - EMAC0
        TX_CLIENT_CLK_ENABLE_0     : out std_logic;
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

        -- MDIO Interface - EMAC0
        MDC_0                      : out std_logic;
        MDIO_0_I                   : in  std_logic;
        MDIO_0_O                   : out std_logic;
        MDIO_0_T                   : out std_logic;

        EMAC0CLIENTANINTERRUPT     : out std_logic;
        EMAC0ResetDoneInterrupt    : out std_logic;

        -- Client Receiver Interface - EMAC1
        RX_CLIENT_CLK_ENABLE_1     : out std_logic;
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
        EMAC1CLIENTRXDVLD_TOSTATS  : out std_logic;

        -- Client Transmitter Interface - EMAC1
        TX_CLIENT_CLK_ENABLE_1     : out std_logic;
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
        MII_TX_CLK_1               : in  std_logic;
        MII_RXD_1                  : in  std_logic_vector(3 downto 0);
        MII_RX_DV_1                : in  std_logic;
        MII_RX_ER_1                : in  std_logic;
        MII_RX_CLK_1               : in  std_logic;

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

        -- Asynchronous Reset
        RESET                      : in  std_logic;

        REFCLK                     : in  std_logic
       );
    
end v5_temac_wrap;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture imp of v5_temac_wrap is

------------------------------------------------------------------------------
--  Constant Declarations
------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Function declarations
-----------------------------------------------------------------------------


------------------------------------------------------------------------------
-- Signal and Type Declarations
------------------------------------------------------------------------------

  signal gnd_i                      : std_logic;
  signal vcc_i                      : std_logic;

  signal mDC_0_i                    : std_logic;
  signal mDIO_0_T_i                 : std_logic;
  signal mDIO_0_O_i                 : std_logic;

  signal mDC_1_i                    : std_logic;
  signal mDIO_1_T_i                 : std_logic;
  signal mDIO_1_O_i                 : std_logic;

  signal eMAC0CLIENTSYNCACQSTATUS_i : std_logic;
  signal eMAC0ANINTERRUPT_i         : std_logic;
  signal rESETDONE_0_i              : std_logic;

  signal eMAC1CLIENTSYNCACQSTATUS_i : std_logic;
  signal eMAC1ANINTERRUPT_i         : std_logic;
  signal rESETDONE_1_i              : std_logic;

  -- receiver interface
  signal rx_data_0_i           : std_logic_vector(7 downto 0);
  signal rx_data_valid_0_i     : std_logic;
  signal rx_good_frame_0_i     : std_logic;
  signal rx_bad_frame_0_i      : std_logic;

  signal rx_data_1_i           : std_logic_vector(7 downto 0);
  signal rx_data_valid_1_i     : std_logic;
  signal rx_good_frame_1_i     : std_logic;
  signal rx_bad_frame_1_i      : std_logic;

  -- Speed indication from EMAC wrappers
  signal speed_vector_0_i          : std_logic;
  signal speed_vector_1_i          : std_logic;

  -- G/MII clocks from PHY
  signal tx_phy_clk_0_o            : std_logic;
  signal tx_phy_clk_0              : std_logic;
  signal rx_clk_0_i                : std_logic;
  signal tx_clk_0_i                : std_logic;
  signal rx_clk_0_o                : std_logic;
  signal tx_clk_0_o                : std_logic;
  -- G/MII clocks from PHY
  signal tx_phy_clk_1_o            : std_logic;
  signal tx_phy_clk_1              : std_logic;
  signal rx_clk_1_i                : std_logic;
  signal tx_clk_1_i                : std_logic;
  signal rx_clk_1_o                : std_logic;
  signal tx_clk_1_o                : std_logic;

  -- Client clocks at 1.25/12.5MHz
  signal tx_client_clk0           : std_logic;
  signal rx_client_clk0           : std_logic;
  signal tx_client_clk_0_o         : std_logic;
  signal rx_client_clk_0_o         : std_logic;
  -- Client clocks at 1.25/12.5MHz
  signal tx_client_clk1           : std_logic;
  signal rx_client_clk1           : std_logic;
  signal tx_client_clk_1_o         : std_logic;
  signal rx_client_clk_1_o         : std_logic;

  -- Transceiver output clock (REFCLKOUT at 125MHz)
  signal clk125_o                  : std_logic;
  -- 125MHz clock input to wrappers
  signal clk125                    : std_logic;
  -- Input 125MHz differential clock for transceiver
  signal clk_ds                    : std_logic;
  signal clk62_5                   : std_logic;
  signal clk62_5_pre_bufg          : std_logic;
  signal clk125_fb                 : std_logic;
  signal clk125_o_bufg             : std_logic;

  -- 1.25/12.5/125MHz clock signals for tri-speed SGMII
  signal client_clk_0_o            : std_logic;
  signal client_clk_0              : std_logic;
  signal client_clk_1_o            : std_logic;
  signal client_clk_1              : std_logic;

  -- GT reset signal
  signal gtreset                    : std_logic;
  signal reset_r                    : std_logic_vector(3 downto 0);
  attribute async_reg               : string;
  attribute async_reg of reset_r    : signal is "TRUE";

  attribute buffer_type : string;
  signal gtx_clk_0_i               : std_logic;
  attribute buffer_type of gtx_clk_0_i  : signal is "none";
  signal gtx_clk_i               : std_logic;
  attribute buffer_type of gtx_clk_i  : signal is "none";

  -- GMII input clocks to wrappers
  signal tx_clk_0                  : std_logic;
  signal gmii_rx_clk_0_delay       : std_logic;
  signal rgmii_rxc_0_delay         : std_logic;
  -- GMII input clocks to wrappers
  signal tx_clk_1                  : std_logic;
  signal gmii_rx_clk_1_delay       : std_logic;
  signal rgmii_rxc_1_delay         : std_logic;

  -- Reference clock for RGMII IODELAYs
  signal refclk_ibufg_i            : std_logic;
  signal refclk_bufg_i             : std_logic;

  -- IDELAY controller
  signal idelayctrl_reset_0_r      : std_logic_vector(12 downto 0);
  signal idelayctrl_reset_0_i      : std_logic;

  signal mii_tx_clk_0_i            : std_logic;
  signal mii_tx_clk_1_i            : std_logic;
  signal emac0speedis10100         : std_logic;
  signal emac1speedis10100         : std_logic;
  signal tx_gmii_mii_clk0_temp     : std_logic;
  signal tx_gmii_mii_clk1_temp     : std_logic;
  
  signal rx_enable_0_i             : std_logic;
  signal rx_enable_1_i             : std_logic;
-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin
    gnd_i <= '0';
    vcc_i <= '1';
------------------------------------------------------------------------------
-- Concurrent Signal Assignments
------------------------------------------------------------------------------

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
  
  RX_CLIENT_CLK_ENABLE_0 <= rx_enable_0_i;
  RX_CLIENT_CLK_ENABLE_1 <= rx_enable_1_i;
  
------------------------------------------------------------------------------
-- Component Instantiations
------------------------------------------------------------------------------

SINGLE_MII: if(C_PHY_TYPE = 0 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is MII and EMAC1 is not used
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  EMAC0CLIENTANINTERRUPT <= '0';
  EMAC1CLIENTANINTERRUPT <= '0';

  TX_CLIENT_CLK_0 <= tx_clk_0_i;
  RX_CLIENT_CLK_0 <= rx_clk_0_i;   

  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i;

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC0 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac0 : process(rx_clk_0_i, RESET)
  begin
    if RESET = '1' then
      EMAC0CLIENTRXD         <= (others => '0');
      EMAC0CLIENTRXDVLD      <= '0';
      EMAC0CLIENTRXGOODFRAME <= '0';
      EMAC0CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_0_i'event and rx_clk_0_i = '1' then 
      if rx_enable_0_i = '1' then
        EMAC0CLIENTRXD         <= rx_data_0_i;
        EMAC0CLIENTRXDVLD      <= rx_data_valid_0_i;
        EMAC0CLIENTRXGOODFRAME <= rx_good_frame_0_i;
        EMAC0CLIENTRXBADFRAME  <= rx_bad_frame_0_i;
      end if;
    end if;
  end process regipgen_emac0;
  
  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    bufg_tx_0 : BUFG port map (I => MII_TX_CLK_0, O => tx_clk_0_i);
    bufg_rx_0 : BUFG port map (I => MII_RX_CLK_0, O => rx_clk_0_i);
  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i <= MII_TX_CLK_0;
    rx_clk_0_i <= MII_RX_CLK_0;
  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_single_mii_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR    => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR    => C_TEMAC1_PHYADDR
      )
    port map (
      -- EMAC0 Clocking
      -- EMAC0 TX Clock input from BUFG
      TX_CLK_0                  => tx_clk_0_i,

      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_ENABLE_0    => rx_enable_0_i,
      EMAC0CLIENTRXD            => rx_data_0_i,
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,
      EMAC0CLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMAC0CLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD,
               
      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_ENABLE_0    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,
      CLIENTEMAC0TXFIRSTBYTE    => '0',
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD,
                   
      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 
                   
      -- Clock Signal - EMAC0
      -- MII Interface - EMAC0
      MII_TXD_0                 => MII_TXD_0,                 --out
      MII_TX_EN_0               => MII_TX_EN_0,               --out
      MII_TX_ER_0               => MII_TX_ER_0,               --out
      MII_TX_CLK_0              => tx_clk_0_i,            --in
      MII_RXD_0                 => MII_RXD_0,                 --in
      MII_RX_DV_0               => MII_RX_DV_0,               --in
      MII_RX_ER_0               => MII_RX_ER_0,               --in
      MII_RX_CLK_0              => rx_clk_0_i,            --in
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
                 
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 
                          
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate SINGLE_MII;

DUAL_MII: if(C_PHY_TYPE = 0 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are MII
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  EMAC0CLIENTANINTERRUPT <= '0';
  EMAC1CLIENTANINTERRUPT <= '0';

  TX_CLIENT_CLK_0 <= tx_clk_0_i;
  RX_CLIENT_CLK_0 <= rx_clk_0_i;   

  TX_CLIENT_CLK_1 <= tx_clk_1_i;
  RX_CLIENT_CLK_1 <= rx_clk_1_i;   
  
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 
  EMAC1CLIENTRXDVLD_TOSTATS <= rx_data_valid_1_i;

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC0 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac0 : process(rx_clk_0_i, RESET)
  begin
    if RESET = '1' then
      EMAC0CLIENTRXD         <= (others => '0');
      EMAC0CLIENTRXDVLD      <= '0';
      EMAC0CLIENTRXGOODFRAME <= '0';
      EMAC0CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_0_i'event and rx_clk_0_i = '1' then 
      if rx_enable_0_i = '1' then
        EMAC0CLIENTRXD         <= rx_data_0_i;
        EMAC0CLIENTRXDVLD      <= rx_data_valid_0_i;
        EMAC0CLIENTRXGOODFRAME <= rx_good_frame_0_i;
        EMAC0CLIENTRXBADFRAME  <= rx_bad_frame_0_i;
      end if;
    end if;
  end process regipgen_emac0;

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC1 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac1 : process(rx_clk_1_i, RESET)
  begin
    if RESET = '1' then
      EMAC1CLIENTRXD         <= (others => '0');
      EMAC1CLIENTRXDVLD      <= '0';
      EMAC1CLIENTRXGOODFRAME <= '0';
      EMAC1CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_1_i'event and rx_clk_1_i = '1' then 
      if rx_enable_1_i = '1' then
        EMAC1CLIENTRXD         <= rx_data_1_i;
        EMAC1CLIENTRXDVLD      <= rx_data_valid_1_i;
        EMAC1CLIENTRXGOODFRAME <= rx_good_frame_1_i;
        EMAC1CLIENTRXBADFRAME  <= rx_bad_frame_1_i;
      end if;
    end if;
  end process regipgen_emac1;

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    bufg_tx_0 : BUFG port map (I => MII_TX_CLK_0, O => tx_clk_0_i);
    bufg_rx_0 : BUFG port map (I => MII_RX_CLK_0, O => rx_clk_0_i);
    bufg_tx_1 : BUFG port map (I => MII_TX_CLK_1, O => tx_clk_1_i);
    bufg_rx_1 : BUFG port map (I => MII_RX_CLK_1, O => rx_clk_1_i);
  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i <= MII_TX_CLK_0;
    rx_clk_0_i <= MII_RX_CLK_0;
    tx_clk_1_i <= MII_TX_CLK_1;
    rx_clk_1_i <= MII_RX_CLK_1;
  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_dual_mii_top(TOP_LEVEL)
    generic map (
      C_RESERVED          => C_RESERVED,
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR    => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR    => C_TEMAC1_PHYADDR
      )
    port map (
      -- EMAC0 Clocking
      -- EMAC0 TX Clock input from BUFG
      TX_CLK_0                  => tx_clk_0_i,

      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_ENABLE_0    => rx_enable_0_i,
      EMAC0CLIENTRXD            => rx_data_0_i,
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,
      EMAC0CLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMAC0CLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD,
               
      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_ENABLE_0    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,
      CLIENTEMAC0TXFIRSTBYTE    => '0',
      CLIENTEMAC0TXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,
      EMAC0CLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,
      EMAC0CLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,
      CLIENTEMAC0TXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,
      EMAC0CLIENTTXSTATS        => EMAC0CLIENTTXSTATS,
      EMAC0CLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,
      EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD,
                   
      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMAC0PAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in          
         
      -- Clock Signal - EMAC0
      -- MII Interface - EMAC0
      MII_TXD_0                 => MII_TXD_0,                 --out
      MII_TX_EN_0               => MII_TX_EN_0,               --out
      MII_TX_ER_0               => MII_TX_ER_0,               --out
      MII_TX_CLK_0              => tx_clk_0_i,             --in
      MII_RXD_0                 => MII_RXD_0,                 --in
      MII_RX_DV_0               => MII_RX_DV_0,               --in
      MII_RX_ER_0               => MII_RX_ER_0,               --in
      MII_RX_CLK_0              => rx_clk_0_i,             --in
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
                  
      -- EMAC1 Clocking
      -- EMAC1 TX Clock input from BUFG
      TX_CLK_1                  => tx_clk_1_i,

        -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_ENABLE_1    => rx_enable_1_i,
      EMAC1CLIENTRXD            => rx_data_1_i,
      EMAC1CLIENTRXDVLD         => rx_data_valid_1_i,
      EMAC1CLIENTRXGOODFRAME    => rx_good_frame_1_i,
      EMAC1CLIENTRXBADFRAME     => rx_bad_frame_1_i,
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_ENABLE_1    => TX_CLIENT_CLK_ENABLE_1,
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,
      CLIENTEMAC1TXFIRSTBYTE    => '0',
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
      MII_TX_CLK_1              => tx_clk_1_i,            --in
      MII_RXD_1                 => MII_RXD_1,                 --in
      MII_RX_DV_1               => MII_RX_DV_1,               --in
      MII_RX_ER_1               => MII_RX_ER_1,               --in
      MII_RX_CLK_1              => rx_clk_1_i,            --in
                         
      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out
                
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 
               
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate DUAL_MII;

SINGLE_GMII: if(C_PHY_TYPE = 1 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is GMII and EMAC1 is not used
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  EMAC0CLIENTANINTERRUPT <= '0';
  EMAC1CLIENTANINTERRUPT <= '0';

  TX_CLIENT_CLK_0 <= tx_clk_0_i;
  RX_CLIENT_CLK_0 <= rx_clk_0_i;   

  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 
  
  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC0 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac0 : process(rx_clk_0_i, RESET)
  begin
    if RESET = '1' then
      EMAC0CLIENTRXD         <= (others => '0');
      EMAC0CLIENTRXDVLD      <= '0';
      EMAC0CLIENTRXGOODFRAME <= '0';
      EMAC0CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_0_i'event and rx_clk_0_i = '1' then 
      if rx_enable_0_i = '1' then
        EMAC0CLIENTRXD         <= rx_data_0_i;
        EMAC0CLIENTRXDVLD      <= rx_data_valid_0_i;
        EMAC0CLIENTRXGOODFRAME <= rx_good_frame_0_i;
        EMAC0CLIENTRXBADFRAME  <= rx_bad_frame_0_i;
      end if;
    end if;
  end process regipgen_emac0;

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking

    -- Use IDELAY on GMII_RX_CLK_0 to move the clock into
    -- alignment with the data

    -- Instantiate IDELAYCTRL for the IDELAY in Fixed Tap Delay Mode

    GEN_INSTANTIATE_IDELAYCTRLS: for I in 0 to (C_NUM_IDELAYCTRL-1) generate
      idelayctrl0 : IDELAYCTRL
      port map (
        RDY    => open,
        REFCLK => REFCLK,
        RST    => idelayctrl_reset_0_i
      );
    end generate;

    delay0rstgen :process (REFCLK, RESET)
    begin
      if (RESET = '1') then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= (others => '1');
      elsif REFCLK'event and REFCLK = '1' then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= idelayctrl_reset_0_r(11 downto 0);
      end if;
    end process delay0rstgen;

    idelayctrl_reset_0_i <= idelayctrl_reset_0_r(12);

    -- Please modify the value of the IOBDELAYs according to your design.
    -- For more information on IDELAYCTRL and IDELAY, please refer to
    -- the Virtex-5 User Guide.
    gmii_rxc0_delay : IODELAY
    generic map (
        IDELAY_TYPE    => "FIXED",
        IDELAY_VALUE   => 0,
        DELAY_SRC      => "I",
        SIGNAL_PATTERN => "CLOCK"
    )
    port map
    (IDATAIN => GMII_RX_CLK_0,
     ODATAIN => '0',
     DATAOUT => gmii_rx_clk_0_delay,
     DATAIN  => '0',
     C       => '0',
     T       => '0',
     CE      => '0',
     INC     => '0',
     RST     => '0');

    -- Clock the TX section of the wrappers. 
    -- Use the 125MHz reference clock when running at 1000Mb/s and 
    -- the 2.5/25MHz PHY clock when running at 100 or 10Mb/s.
    -- Alternatively the TX_CLK_OUT_0 output from the wrappers may be used
    -- at all speeds.
    bufg_tx_0 : BUFGMUX port map (I0 => GTX_CLK_0, I1 => MII_TX_CLK_0, S => speed_vector_0_i, O => tx_clk_0_i);

    -- Put the RX PHY clock through a BUFG.
    -- Used to clock the RX section of the EMAC wrappers.
    bufg_rx_0 : BUFG port map (I => gmii_rx_clk_0_delay, O => rx_clk_0_i);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    rx_clk_0_i <= GMII_RX_CLK_0;

    mux0 : process(GTX_CLK_0, MII_TX_CLK_0, speed_vector_0_i)
    begin
      if (speed_vector_0_i = '0') then
        tx_clk_0_i <= GTX_CLK_0;
      else
        tx_clk_0_i <= MII_TX_CLK_0;
      end if;
    end process mux0;
    
  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_single_gmii_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR    => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR    => C_TEMAC1_PHYADDR
      )
    port map (
      -- EMAC0 Clocking
      -- TX Clock output from EMAC0
      TX_CLK_OUT_0              => open,
      -- EMAC0 TX Clock input from BUFG
      TX_CLK_0                  => tx_clk_0_i,
      -- Speed indicator for EMAC0
      -- Used in clocking circuitry.
      EMAC0SPEEDIS10100         => speed_vector_0_i,

      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_ENABLE_0    => rx_enable_0_i,
      EMAC0CLIENTRXD            => rx_data_0_i,
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,
      EMAC0CLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMAC0CLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_ENABLE_0    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => '0',
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
      GTX_CLK_0                 => GTX_CLK_0,               --in
      -- GMII Interface - EMAC0
      GMII_TXD_0                => GMII_TXD_0,                --out
      GMII_TX_EN_0              => GMII_TX_EN_0,              --out
      GMII_TX_ER_0              => GMII_TX_ER_0,              --out
      GMII_TX_CLK_0             => GMII_TX_CLK_0,             --in
      GMII_RXD_0                => GMII_RXD_0,                --in
      GMII_RX_DV_0              => GMII_RX_DV_0,              --in
      GMII_RX_ER_0              => GMII_RX_ER_0,              --in
      GMII_RX_CLK_0             => rx_clk_0_i,             --in

      MII_TX_CLK_0              => MII_TX_CLK_0,              --in
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out               

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 
                 
                 
                 
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate SINGLE_GMII;

DUAL_GMII: if(C_PHY_TYPE = 1 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are GMII
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  EMAC0CLIENTANINTERRUPT <= '0';
  EMAC1CLIENTANINTERRUPT <= '0';

  TX_CLIENT_CLK_0 <= tx_clk_0_i;
  RX_CLIENT_CLK_0 <= rx_clk_0_i;   

  TX_CLIENT_CLK_1 <= tx_clk_1_i;
  RX_CLIENT_CLK_1 <= rx_clk_1_i;   
  
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 
  EMAC1CLIENTRXDVLD_TOSTATS <= rx_data_valid_1_i;  

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC0 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac0 : process(rx_clk_0_i, RESET)
  begin
    if RESET = '1' then
      EMAC0CLIENTRXD         <= (others => '0');
      EMAC0CLIENTRXDVLD      <= '0';
      EMAC0CLIENTRXGOODFRAME <= '0';
      EMAC0CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_0_i'event and rx_clk_0_i = '1' then 
      if rx_enable_0_i = '1' then
        EMAC0CLIENTRXD         <= rx_data_0_i;
        EMAC0CLIENTRXDVLD      <= rx_data_valid_0_i;
        EMAC0CLIENTRXGOODFRAME <= rx_good_frame_0_i;
        EMAC0CLIENTRXBADFRAME  <= rx_bad_frame_0_i;
      end if;
    end if;
  end process regipgen_emac0;

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC0 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac1 : process(rx_clk_1_i, RESET)
  begin
    if RESET = '1' then
      EMAC1CLIENTRXD         <= (others => '0');
      EMAC1CLIENTRXDVLD      <= '0';
      EMAC1CLIENTRXGOODFRAME <= '0';
      EMAC1CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_1_i'event and rx_clk_1_i = '1' then 
      if rx_enable_1_i = '1' then
        EMAC1CLIENTRXD         <= rx_data_1_i;
        EMAC1CLIENTRXDVLD      <= rx_data_valid_1_i;
        EMAC1CLIENTRXGOODFRAME <= rx_good_frame_1_i;
        EMAC1CLIENTRXBADFRAME  <= rx_bad_frame_1_i;
      end if;
    end if;
  end process regipgen_emac1;

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking

    -- Use IDELAY on GMII_RX_CLK_0 to move the clock into
    -- alignment with the data

    -- Instantiate IDELAYCTRL for the IDELAY in Fixed Tap Delay Mode

    GEN_INSTANTIATE_IDELAYCTRLS: for I in 0 to (C_NUM_IDELAYCTRL-1) generate
      idelayctrl0 : IDELAYCTRL
      port map (
        RDY    => open,
        REFCLK => REFCLK,
        RST    => idelayctrl_reset_0_i
      );
    end generate;

    delay0rstgen :process (REFCLK, RESET)
    begin
      if (RESET = '1') then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= (others => '1');
      elsif REFCLK'event and REFCLK = '1' then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= idelayctrl_reset_0_r(11 downto 0);
      end if;
    end process delay0rstgen;

    idelayctrl_reset_0_i <= idelayctrl_reset_0_r(12);

    -- Please modify the value of the IOBDELAYs according to your design.
    -- For more information on IDELAYCTRL and IDELAY, please refer to
    -- the Virtex-5 User Guide.
    gmii_rxc0_delay : IODELAY
    generic map (
      IDELAY_TYPE    => "FIXED",
      IDELAY_VALUE   => 0,
      DELAY_SRC      => "I",
      SIGNAL_PATTERN => "CLOCK"
      )
    port map
    (IDATAIN => GMII_RX_CLK_0,
     ODATAIN => '0',
     DATAOUT => gmii_rx_clk_0_delay,
     DATAIN  => '0',
     C       => '0',
     T       => '0',
     CE      => '0',
     INC     => '0',
     RST     => '0');

    -- Please modify the value of the IOBDELAYs according to your design.
    -- For more information on IDELAYCTRL and IDELAY, please refer to
    -- the Virtex-5 User Guide.
    gmii_rxc1_delay : IODELAY
    generic map (
      IDELAY_TYPE    => "FIXED",
      IDELAY_VALUE   => 0,
      DELAY_SRC      => "I",
      SIGNAL_PATTERN => "CLOCK"
      )
    port map
    (IDATAIN => GMII_RX_CLK_1,
     ODATAIN => '0',
     DATAOUT => gmii_rx_clk_1_delay,
     DATAIN  => '0',
     C       => '0',
     T       => '0',
     CE      => '0',
     INC     => '0',
     RST     => '0');

    -- Clock the TX section of the wrappers. 
    -- Use the 125MHz reference clock when running at 1000Mb/s and 
    -- the 2.5/25MHz PHY clock when running at 100 or 10Mb/s.
    -- Alternatively the TX_CLK_OUT_0 output from the wrappers may be used
    -- at all speeds.
    bufg_tx_0 : BUFGMUX port map (I0 => GTX_CLK_0, I1 => MII_TX_CLK_0, S => speed_vector_0_i, O => tx_clk_0_i);
    bufg_tx_1 : BUFGMUX port map (I0 => GTX_CLK_0, I1 => MII_TX_CLK_1, S => speed_vector_1_i, O => tx_clk_1_i);

    -- Put the RX PHY clock through a BUFG.
    -- Used to clock the RX section of the EMAC wrappers.
    bufg_rx_0 : BUFG port map (I => gmii_rx_clk_0_delay, O => rx_clk_0_i);
    bufg_rx_1 : BUFG port map (I => gmii_rx_clk_1_delay, O => rx_clk_1_i);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    rx_clk_0_i <= GMII_RX_CLK_0;

    mux0 : process(GTX_CLK_0, MII_TX_CLK_0, speed_vector_0_i)
    begin
      if (speed_vector_0_i = '0') then
        tx_clk_0_i <= GTX_CLK_0;
      else
        tx_clk_0_i <= MII_TX_CLK_0;
      end if;
    end process mux0;
    
    rx_clk_1_i <= GMII_RX_CLK_1;

    mux1 : process(GTX_CLK_0, MII_TX_CLK_1, speed_vector_1_i)
    begin
      if (speed_vector_1_i = '0') then
        tx_clk_1_i <= GTX_CLK_0;
      else
        tx_clk_1_i <= MII_TX_CLK_1;
      end if;
    end process mux1;
 
  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_dual_gmii_top(TOP_LEVEL)
    generic map (
                 C_RESERVED              => C_RESERVED,
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
                 C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- EMAC0 Clocking
      -- TX Clock output from EMAC0
      TX_CLK_OUT_0              => open,
      -- EMAC0 TX Clock input from BUFG
      TX_CLK_0                  => tx_clk_0_i,
      -- Speed indicator for EMAC0
      -- Used in clocking circuitry.
      EMAC0SPEEDIS10100         => speed_vector_0_i,

      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_ENABLE_0    => rx_enable_0_i,
      EMAC0CLIENTRXD            => rx_data_0_i,
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,
      EMAC0CLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMAC0CLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_ENABLE_0    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      GMII_RX_CLK_0             => rx_clk_0_i,             --in

      MII_TX_CLK_0              => MII_TX_CLK_0,              --in
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out

      -- EMAC1 Clocking
      -- TX Clock output from EMAC1
      TX_CLK_OUT_1              => open,
      -- EMAC1 TX Clock input from BUFG
      TX_CLK_1                  => tx_clk_1_i,
      -- Speed indicator for EMAC1
      -- Used in clocking circuitry.
      EMAC1SPEEDIS10100         => speed_vector_1_i,
                
      -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_ENABLE_1    => rx_enable_1_i,
      EMAC1CLIENTRXD            => rx_data_1_i,
      EMAC1CLIENTRXDVLD         => rx_data_valid_1_i,
      EMAC1CLIENTRXGOODFRAME    => rx_good_frame_1_i,
      EMAC1CLIENTRXBADFRAME     => rx_bad_frame_1_i,
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_ENABLE_1    => TX_CLIENT_CLK_ENABLE_1,
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMAC1TXFIRSTBYTE    => '0',                       --in
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
      GMII_RX_CLK_1             => rx_clk_1_i,             --in

      MII_TX_CLK_1              => MII_TX_CLK_1,              --in
                         
      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out
                  
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 


      -- Clock Signal - EMAC0
      GTX_CLK                   => GTX_CLK_0,               --in

                    
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate DUAL_GMII;

SINGLE_SGMII_NOTFX: if(C_PHY_TYPE = 4 and C_EMAC1_PRESENT = 0 and (equalIgnoringCase(C_SUBFAMILY, "fx")= FALSE)) generate  -- EMAC0 is SGMII and EMAC1 is not used
begin
  EMAC1ResetDoneInterrupt <= '1';
  rx_enable_0_i  <= '1';
  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_0  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD         <= rx_data_valid_0_i;
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i;   

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking

    -- Generate the clock input to the GTP
    -- clk_ds can be shared between multiple MAC instances.
    clkingen : IBUFDS port map (
      I  => MGTCLK_P,
      IB => MGTCLK_N,
      O  => clk_ds);

    -- 125MHz from transceiver is routed through a BUFG and 
    -- input to the MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map (I => clk125_o, O => clk125);

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_0 : BUFG port map (I => client_clk_0_o, O => client_clk_0);
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125'event and clk125 = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);


  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    clk_ds  <= MGTCLK_P;
    -- 125MHz from transceiver is routed through a BUFG and 
    -- input to the MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map (I => clk125_o, O => clk125);

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_0 : BUFG port map (I => client_clk_0_o, O => client_clk_0);
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125'event and clk125 = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= '0';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_single_sgmii_top(TOP_LEVEL)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
                 C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- EMAC0 Clocking
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;
      -- Tri-speed clock output from EMAC0
      CLIENT_CLK_OUT_0          => client_clk_0_o,        -- out std_logic;
      -- EMAC0 Tri-speed clock input from BUFG
      CLIENT_CLK_0              => client_clk_0,            -- in  std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out                                                                       
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out                       
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out                       
               
      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      EMAC0CLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC0ANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;

                   
      -- Clock Signal - EMAC0
      -- SGMII Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,             -- out std_logic;

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
                
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 

      -- SGMII RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in

      -- RocketIO Reset input
      GTRESET                         => gtreset,


                 
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate SINGLE_SGMII_NOTFX;

DUAL_SGMII_NOTFX: if(C_PHY_TYPE = 4 and C_EMAC1_PRESENT = 1 and (equalIgnoringCase(C_SUBFAMILY, "fx")= FALSE)) generate  -- EMAC0 & EMAC1 are SGMII
begin
  rx_enable_0_i  <= '1';
  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_0  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD         <= rx_data_valid_0_i;
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 
  EMAC1CLIENTRXDVLD         <= rx_data_valid_1_i;
  EMAC1CLIENTRXDVLD_TOSTATS <= rx_data_valid_1_i;  

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking

    -- Generate the clock input to the GTP
    -- clk_ds can be shared between multiple MAC instances.
    clkingen : IBUFDS port map (
      I  => MGTCLK_P,
      IB => MGTCLK_N,
      O  => clk_ds);

    -- 125MHz from transceiver is routed through a BUFG and 
    -- input to the MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map (I => clk125_o, O => clk125);

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_0 : BUFG port map (I => client_clk_0_o, O => client_clk_0);
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_1 : BUFG port map (I => client_clk_1_o, O => client_clk_1);
    
    TX_CLIENT_CLK_1 <= client_clk_1;
    RX_CLIENT_CLK_1 <= client_clk_1;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125'event and clk125 = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    clk_ds  <= MGTCLK_P;
    -- 125MHz from transceiver is routed through a BUFG and 
    -- input to the MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map (I => clk125_o, O => clk125);

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_0 : BUFG port map (I => client_clk_0_o, O => client_clk_0);
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_1 : BUFG port map (I => client_clk_1_o, O => client_clk_1);
    
    TX_CLIENT_CLK_1 <= client_clk_1;
    RX_CLIENT_CLK_1 <= client_clk_1;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125'event and clk125 = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= eMAC1ANINTERRUPT_i;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_dual_sgmii_top(TOP_LEVEL)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
                 C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- EMAC0 Clocking
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;
      -- Tri-speed clock output from EMAC0
      CLIENT_CLK_OUT_0          => client_clk_0_o,        -- out std_logic;
      -- EMAC0 Tri-speed clock input from BUFG
      CLIENT_CLK_0              => client_clk_0,            -- in  std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      EMAC0CLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC0ANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;

                   
      -- Clock Signal - EMAC0
      -- SGMII Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,             -- out std_logic;
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out

      -- EMAC1 Clocking
      -- Tri-speed clock output from EMAC0
      CLIENT_CLK_OUT_1          => client_clk_1_o,        -- out std_logic;
      -- EMAC0 Tri-speed clock input from BUFG
      CLIENT_CLK_1              => client_clk_1,            -- in  std_logic;
                
      -- Client Receiver Interface - EMAC1
      EMAC1CLIENTRXD            => EMAC1CLIENTRXD,            --out
      EMAC1CLIENTRXDVLD         => rx_data_valid_1_i,         --out
      EMAC1CLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out
      EMAC1CLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC1
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMAC1TXFIRSTBYTE    => '0',                       --in
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
      EMAC1CLIENTSYNCACQSTATUS  => eMAC1CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC1ANINTERRUPT          => eMAC1ANINTERRUPT_i,        -- out std_logic;
                   
                   
      -- Clock Signal - EMAC1
      -- SGMII Interface - EMAC1
      TXP_1                     => TXP_1,                     --out
      TXN_1                     => TXN_1,                     --out
      RXP_1                     => RXP_1,                     --in
      RXN_1                     => RXN_1,                     --in
      PHYAD_1                   => C_TEMAC1_PHYADDR,          --in
      RESETDONE_1               => EMAC1ResetDoneInterrupt,             -- out std_logic;
                         
      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out
                  
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 

      -- SGMII RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in

      -- RocketIO Reset input
      GTRESET                         => gtreset,



      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate DUAL_SGMII_NOTFX;

SINGLE_SGMII_FX: if(C_PHY_TYPE = 4 and C_EMAC1_PRESENT = 0 and (equalIgnoringCase(C_SUBFAMILY, "fx")= TRUE)) generate  -- EMAC0 is SGMII and EMAC1 is not used
begin
  EMAC1ResetDoneInterrupt <= '1';
  rx_enable_0_i  <= '1';
  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_0  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD         <= rx_data_valid_0_i;
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i;   

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking

    -- Generate the clock input to the GTP
    -- clk_ds can be shared between multiple MAC instances.
    clkingen : IBUFDS port map (
      I  => MGTCLK_P,
      IB => MGTCLK_N,
      O  => clk_ds);

    -- 125MHz from transceiver is routed through a BUFG and input 
    -- to DCM.
    bufg_clk125_o: BUFG port map(I => clk125_o, O => clk125_o_bufg);

    -- 125MHz from DCM is routed through a BUFG and input to the 
    -- MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map(I => clk125_fb, O => clk125);

    -- Divide 125MHz reference clock down by 2 to get
    -- 62.5MHz clock for 2 byte GTX internal datapath.
    clk62_5_dcm : DCM_BASE port map 
    (CLKIN      => clk125_o_bufg,
     CLK0       => clk125_fb,
     CLK180     => open,
     CLK270     => open,
     CLK2X      => open,
     CLK2X180   => open,
     CLK90      => open,
     CLKDV      => clk62_5_pre_bufg,
     CLKFX      => open,
     CLKFX180   => open,
     LOCKED     => open,
     CLKFB      => clk125,
     RST        => RESET);

    clk62_5_bufg : BUFG port map(I => clk62_5_pre_bufg, O => clk62_5);

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_0 : BUFG port map (I => client_clk_0_o, O => client_clk_0);
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125_o_bufg)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125_o_bufg'event and clk125_o_bufg = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    clk_ds  <= MGTCLK_P;

    -- 125MHz from transceiver is routed through a BUFG and input 
    -- to DCM.
    bufg_clk125_o: BUFG port map(I => clk125_o, O => clk125_o_bufg);

    -- 125MHz from DCM is routed through a BUFG and input to the 
    -- MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map(I => clk125_fb, O => clk125);

    -- Divide 125MHz reference clock down by 2 to get
    -- 62.5MHz clock for 2 byte GTX internal datapath.
    clk62_5_dcm : DCM_BASE port map 
    (CLKIN      => clk125_o_bufg,
     CLK0       => clk125_fb,
     CLK180     => open,
     CLK270     => open,
     CLK2X      => open,
     CLK2X180   => open,
     CLK90      => open,
     CLKDV      => clk62_5_pre_bufg,
     CLKFX      => open,
     CLKFX180   => open,
     LOCKED     => open,
     CLKFB      => clk125,
     RST        => RESET);

    clk62_5_bufg : BUFG port map(I => clk62_5_pre_bufg, O => clk62_5);

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_0 : BUFG port map (I => client_clk_0_o, O => client_clk_0);
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125_o_bufg)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125_o_bufg'event and clk125_o_bufg = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= '0';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5fxt_single_sgmii_top(TOP_LEVEL)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
                 C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- EMAC0 Clocking
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;
      -- 62.5MHz clock input from BUFG
      CLK62_5                   => clk62_5,
      -- Tri-speed clock output from EMAC0
      CLIENT_CLK_OUT_0          => client_clk_0_o,        -- out std_logic;
      -- EMAC0 Tri-speed clock input from BUFG
      CLIENT_CLK_0              => client_clk_0,            -- in  std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      EMAC0CLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC0ANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;

                   
      -- Clock Signal - EMAC0
      -- SGMII Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,             -- out std_logic;

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
                
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 

      -- SGMII RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in

      -- RocketIO Reset input
      GTRESET                         => gtreset,
                 
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate SINGLE_SGMII_FX;

DUAL_SGMII_FX: if(C_PHY_TYPE = 4 and C_EMAC1_PRESENT = 1 and (equalIgnoringCase(C_SUBFAMILY, "fx")= TRUE)) generate  -- EMAC0 & EMAC1 are SGMII
begin
  rx_enable_0_i  <= '1';
  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_0  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD         <= rx_data_valid_0_i;
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 
  EMAC1CLIENTRXDVLD         <= rx_data_valid_1_i;
  EMAC1CLIENTRXDVLD_TOSTATS <= rx_data_valid_1_i;  

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking

    -- Generate the clock input to the GTP
    -- clk_ds can be shared between multiple MAC instances.
    clkingen : IBUFDS port map (
      I  => MGTCLK_P,
      IB => MGTCLK_N,
      O  => clk_ds);

    -- 125MHz from transceiver is routed through a BUFG and input 
    -- to DCM.
    bufg_clk125_o: BUFG port map(I => clk125_o, O => clk125_o_bufg);

    -- 125MHz from DCM is routed through a BUFG and input to the 
    -- MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map(I => clk125_fb, O => clk125);

    -- Divide 125MHz reference clock down by 2 to get
    -- 62.5MHz clock for 2 byte GTX internal datapath.
    clk62_5_dcm : DCM_BASE port map 
    (CLKIN      => clk125_o_bufg,
     CLK0       => clk125_fb,
     CLK180     => open,
     CLK270     => open,
     CLK2X      => open,
     CLK2X180   => open,
     CLK90      => open,
     CLKDV      => clk62_5_pre_bufg,
     CLKFX      => open,
     CLKFX180   => open,
     LOCKED     => open,
     CLKFB      => clk125,
     RST        => RESET);

    clk62_5_bufg : BUFG port map(I => clk62_5_pre_bufg, O => clk62_5);

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_0 : BUFG port map (I => client_clk_0_o, O => client_clk_0);
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_1 : BUFG port map (I => client_clk_1_o, O => client_clk_1);
    
    TX_CLIENT_CLK_1 <= client_clk_1;
    RX_CLIENT_CLK_1 <= client_clk_1;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125_o_bufg)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125_o_bufg'event and clk125_o_bufg = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    clk_ds  <= MGTCLK_P;

    -- 125MHz from transceiver is routed through a BUFG and input 
    -- to DCM.
    bufg_clk125_o: BUFG port map(I => clk125_o, O => clk125_o_bufg);

    -- 125MHz from DCM is routed through a BUFG and input to the 
    -- MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map(I => clk125_fb, O => clk125);

    -- Divide 125MHz reference clock down by 2 to get
    -- 62.5MHz clock for 2 byte GTX internal datapath.
    clk62_5_dcm : DCM_BASE port map 
    (CLKIN      => clk125_o_bufg,
     CLK0       => clk125_fb,
     CLK180     => open,
     CLK270     => open,
     CLK2X      => open,
     CLK2X180   => open,
     CLK90      => open,
     CLKDV      => clk62_5_pre_bufg,
     CLKFX      => open,
     CLKFX180   => open,
     LOCKED     => open,
     CLKFB      => clk125,
     RST        => RESET);

    clk62_5_bufg : BUFG port map(I => clk62_5_pre_bufg, O => clk62_5);

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_0 : BUFG port map (I => client_clk_0_o, O => client_clk_0);
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_1 : BUFG port map (I => client_clk_1_o, O => client_clk_1);
    
    TX_CLIENT_CLK_1 <= client_clk_1;
    RX_CLIENT_CLK_1 <= client_clk_1;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125_o_bufg)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125_o_bufg'event and clk125_o_bufg = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= eMAC1ANINTERRUPT_i;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5fxt_dual_sgmii_top(TOP_LEVEL)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
                 C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- EMAC0 Clocking
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;
      -- 62.5MHz clock input from BUFG
      CLK62_5                   => clk62_5,
      -- Tri-speed clock output from EMAC0
      CLIENT_CLK_OUT_0          => client_clk_0_o,        -- out std_logic;
      -- EMAC0 Tri-speed clock input from BUFG
      CLIENT_CLK_0              => client_clk_0,            -- in  std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      EMAC0CLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC0ANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;

                   
      -- Clock Signal - EMAC0
      -- SGMII Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,             -- out std_logic;
                         
      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out

      -- EMAC1 Clocking
      -- Tri-speed clock output from EMAC0
      CLIENT_CLK_OUT_1          => client_clk_1_o,        -- out std_logic;
      -- EMAC0 Tri-speed clock input from BUFG
      CLIENT_CLK_1              => client_clk_1,            -- in  std_logic;
                
      -- Client Receiver Interface - EMAC1
      EMAC1CLIENTRXD            => EMAC1CLIENTRXD,            --out
      EMAC1CLIENTRXDVLD         => rx_data_valid_1_i,         --out
      EMAC1CLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out
      EMAC1CLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface - EMAC1
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMAC1TXFIRSTBYTE    => '0',                       --in
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
      EMAC1CLIENTSYNCACQSTATUS  => eMAC1CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC1ANINTERRUPT          => eMAC1ANINTERRUPT_i,        -- out std_logic;
                   
                   
      -- Clock Signal - EMAC1
      -- SGMII Interface - EMAC1
      TXP_1                     => TXP_1,                     --out
      TXN_1                     => TXN_1,                     --out
      RXP_1                     => RXP_1,                     --in
      RXN_1                     => RXN_1,                     --in
      PHYAD_1                   => C_TEMAC1_PHYADDR,          --in
      RESETDONE_1               => EMAC1ResetDoneInterrupt,             -- out std_logic;
                         
      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out
                  
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 

      -- SGMII RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in

      -- RocketIO Reset input
      GTRESET                         => gtreset,



      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate DUAL_SGMII_FX;

SINGLE_RGMII13: if(C_PHY_TYPE = 2 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is RGMII v1.3 and EMAC1 is not used
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  EMAC0CLIENTANINTERRUPT <= '0';
  EMAC1CLIENTANINTERRUPT <= '0';
    
  TX_CLIENT_CLK_0 <= tx_clk_0_i;
  RX_CLIENT_CLK_0 <= rx_clk_0_i;   

  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC0 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac0 : process(rx_clk_0_i, RESET)
  begin
    if RESET = '1' then
      EMAC0CLIENTRXD         <= (others => '0');
      EMAC0CLIENTRXDVLD      <= '0';
      EMAC0CLIENTRXGOODFRAME <= '0';
      EMAC0CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_0_i'event and rx_clk_0_i = '1' then 
      if rx_enable_0_i = '1' then
        EMAC0CLIENTRXD         <= rx_data_0_i;
        EMAC0CLIENTRXDVLD      <= rx_data_valid_0_i;
        EMAC0CLIENTRXGOODFRAME <= rx_good_frame_0_i;
        EMAC0CLIENTRXBADFRAME  <= rx_bad_frame_0_i;
      end if;
    end if;
  end process regipgen_emac0;

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking
   
    -- Use IDELAY on RGMII_RXC_0 to move the clock into
    -- alignment with the data

    -- Instantiate IDELAYCTRL for the IDELAY in Fixed Tap Delay Mode

    GEN_INSTANTIATE_IDELAYCTRLS: for I in 0 to (C_NUM_IDELAYCTRL-1) generate
      idelayctrl0 : IDELAYCTRL
      port map (
        RDY    => open,
        REFCLK => REFCLK,
        RST    => idelayctrl_reset_0_i
      );
    end generate;

    delay0rstgen :process (REFCLK, RESET)
    begin
      if (RESET = '1') then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= (others => '1');
      elsif REFCLK'event and REFCLK = '1' then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= idelayctrl_reset_0_r(11 downto 0);
      end if;
    end process delay0rstgen;

    idelayctrl_reset_0_i <= idelayctrl_reset_0_r(12);

    -- Please modify the value of the IOBDELAYs according to your design.
    -- For more information on IDELAYCTRL and IDELAY, please refer to
    -- the Virtex-5 User Guide.
    rgmii_rxc0_delay : IODELAY
    generic map (
        IDELAY_TYPE    => "FIXED",
       	IDELAY_VALUE   => 0,
        DELAY_SRC      => "I",
        SIGNAL_PATTERN => "CLOCK"
    )
    port map (
      IDATAIN    => RGMII_RXC_0,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rxc_0_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );

    -- Use the 2.5/25/125MHz reference clock from the EMAC 
    -- to clock the TX section of the wrappers.
    bufg_tx_0 : BUFG port map (I => tx_clk_0_o, O => tx_clk_0_i);

    -- Put the RX PHY clock through a BUFG.
    -- Used to clock the RX section of the EMAC wrappers.
    bufg_rx_0 : BUFG port map (I => rgmii_rxc_0_delay, O => rx_clk_0_i);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i    <=  tx_clk_0_o;
    rx_clk_0_i    <=  RGMII_RXC_0;
  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_single_rgmii13_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR    => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR    => C_TEMAC1_PHYADDR
      )
    port map (
      -- EMAC0 Clocking
      -- TX Clock output from EMAC0
      TX_CLK_OUT_0                    => tx_clk_0_o,
      -- EMAC0 TX Clock input from BUFG
      TX_CLK_0                        => tx_clk_0_i,

      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_ENABLE_0    => rx_enable_0_i,
      EMAC0CLIENTRXD            => rx_data_0_i,
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,
      EMAC0CLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMAC0CLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_ENABLE_0    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      GTX_CLK_0                 => GTX_CLK_0,                 --in            
      -- RGMII Interface - EMAC0
      RGMII_TXD_0               => RGMII_TXD_0,               --out
      RGMII_TX_CTL_0            => RGMII_TX_CTL_0,            --out
      RGMII_TXC_0               => RGMII_TXC_0,               --out
      RGMII_RXD_0               => RGMII_RXD_0,               --in 
      RGMII_RX_CTL_0            => RGMII_RX_CTL_0,            --in 
      RGMII_RXC_0               => rx_clk_0_i,               --in 

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 
        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

end generate SINGLE_RGMII13;

DUAL_RGMII13: if(C_PHY_TYPE = 2 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are RGMII v1.3
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  EMAC0CLIENTANINTERRUPT <= '0';
  EMAC1CLIENTANINTERRUPT <= '0';
    
  TX_CLIENT_CLK_0 <= tx_clk_0_i;
  RX_CLIENT_CLK_0 <= rx_clk_0_i;   
  TX_CLIENT_CLK_1 <= tx_clk_1_i;
  RX_CLIENT_CLK_1 <= rx_clk_1_i;   
  
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 
  EMAC1CLIENTRXDVLD_TOSTATS <= rx_data_valid_1_i; 

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC0 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac0 : process(rx_clk_0_i, RESET)
  begin
    if RESET = '1' then
      EMAC0CLIENTRXD         <= (others => '0');
      EMAC0CLIENTRXDVLD      <= '0';
      EMAC0CLIENTRXGOODFRAME <= '0';
      EMAC0CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_0_i'event and rx_clk_0_i = '1' then 
      if rx_enable_0_i = '1' then
        EMAC0CLIENTRXD         <= rx_data_0_i;
        EMAC0CLIENTRXDVLD      <= rx_data_valid_0_i;
        EMAC0CLIENTRXGOODFRAME <= rx_good_frame_0_i;
        EMAC0CLIENTRXBADFRAME  <= rx_bad_frame_0_i;
      end if;
    end if;
  end process regipgen_emac0;

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC1 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac1 : process(rx_clk_1_i, RESET)
  begin
    if RESET = '1' then
      EMAC1CLIENTRXD         <= (others => '0');
      EMAC1CLIENTRXDVLD      <= '0';
      EMAC1CLIENTRXGOODFRAME <= '0';
      EMAC1CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_1_i'event and rx_clk_1_i = '1' then 
      if rx_enable_1_i = '1' then
        EMAC1CLIENTRXD         <= rx_data_1_i;
        EMAC1CLIENTRXDVLD      <= rx_data_valid_1_i;
        EMAC1CLIENTRXGOODFRAME <= rx_good_frame_1_i;
        EMAC1CLIENTRXBADFRAME  <= rx_bad_frame_1_i;
      end if;
    end if;
  end process regipgen_emac1;

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking
   
    -- Use IDELAY on RGMII_RXC_0 to move the clock into
    -- alignment with the data

    -- Instantiate IDELAYCTRL for the IDELAY in Fixed Tap Delay Mode

    GEN_INSTANTIATE_IDELAYCTRLS: for I in 0 to (C_NUM_IDELAYCTRL-1) generate
      idelayctrl0 : IDELAYCTRL
      port map (
        RDY    => open,
        REFCLK => REFCLK,
        RST    => idelayctrl_reset_0_i
      );
    end generate;

    delay0rstgen :process (REFCLK, RESET)
    begin
      if (RESET = '1') then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= (others => '1');
      elsif REFCLK'event and REFCLK = '1' then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= idelayctrl_reset_0_r(11 downto 0);
      end if;
    end process delay0rstgen;

    idelayctrl_reset_0_i <= idelayctrl_reset_0_r(12);

    -- Please modify the value of the IOBDELAYs according to your design.
    -- For more information on IDELAYCTRL and IDELAY, please refer to
    -- the Virtex-5 User Guide.
    rgmii_rxc0_delay : IODELAY
    generic map (
        IDELAY_TYPE    => "FIXED",
       	IDELAY_VALUE   => 0,
        DELAY_SRC      => "I",
        SIGNAL_PATTERN => "CLOCK"
    )
    port map (
      IDATAIN    => RGMII_RXC_0,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rxc_0_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );
      
    rgmii_rxc1_delay : IODELAY
    generic map (
        IDELAY_TYPE    => "FIXED",
       	IDELAY_VALUE   => 0,
        DELAY_SRC      => "I",
        SIGNAL_PATTERN => "CLOCK"
    )
    port map (
      IDATAIN    => RGMII_RXC_1,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rxc_1_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );

    -- Use the 2.5/25/125MHz reference clock from the EMAC 
    -- to clock the TX section of the wrappers.
    bufg_tx_0 : BUFG port map (I => tx_clk_0_o, O => tx_clk_0_i);
    bufg_tx_1 : BUFG port map (I => tx_clk_1_o, O => tx_clk_1_i);

    -- Put the RX PHY clock through a BUFG.
    -- Used to clock the RX section of the EMAC wrappers.
    bufg_rx_0 : BUFG port map (I => rgmii_rxc_0_delay, O => rx_clk_0_i);
    bufg_rx_1 : BUFG port map (I => rgmii_rxc_1_delay, O => rx_clk_1_i);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i    <=  tx_clk_0_o;
    rx_clk_0_i    <=  RGMII_RXC_0;
    tx_clk_1_i    <=  tx_clk_1_o;
    rx_clk_1_i    <=  RGMII_RXC_1;

  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_dual_rgmii13_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR    => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR    => C_TEMAC1_PHYADDR
      )
    port map (
      -- EMAC0 Clocking
      -- TX Clock output from EMAC0
      TX_CLK_OUT_0                    => tx_clk_0_o,
      -- EMAC0 TX Clock input from BUFG
      TX_CLK_0                        => tx_clk_0_i,

      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_ENABLE_0    => rx_enable_0_i,
      EMAC0CLIENTRXD            => rx_data_0_i,
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,
      EMAC0CLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMAC0CLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_ENABLE_0    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      RGMII_RXC_0               => rx_clk_0_i,               --in 

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
                  
      -- EMAC1 Clocking
      -- TX Clock output from EMAC1
      TX_CLK_OUT_1                    => tx_clk_1_o,
      -- EMAC1 TX Clock input from BUFG
      TX_CLK_1                        => tx_clk_1_i,

      -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_ENABLE_1    => rx_enable_1_i,
      EMAC1CLIENTRXD            => rx_data_1_i,
      EMAC1CLIENTRXDVLD         => rx_data_valid_1_i,
      EMAC1CLIENTRXGOODFRAME    => rx_good_frame_1_i,
      EMAC1CLIENTRXBADFRAME     => rx_bad_frame_1_i,
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out      
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out      
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out      
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_ENABLE_1    => TX_CLIENT_CLK_ENABLE_1,
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in       
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in       
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out      
      CLIENTEMAC1TXFIRSTBYTE    => '0',                       --in
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
      RGMII_RXC_1               => rx_clk_1_i,               --in  

      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 
        
      -- GTX Clock signal
      GTX_CLK                   => GTX_CLK_0,                 --in            
        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

end generate DUAL_RGMII13;


SINGLE_RGMII2: if(C_PHY_TYPE = 3 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is RGMII v2 and EMAC1 is not used
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  EMAC0CLIENTANINTERRUPT <= '0';
  EMAC1CLIENTANINTERRUPT <= '0';
    
  TX_CLIENT_CLK_0 <= tx_clk_0_i;
  RX_CLIENT_CLK_0 <= rx_clk_0_i;   

  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC0 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac0 : process(rx_clk_0_i, RESET)
  begin
    if RESET = '1' then
      EMAC0CLIENTRXD         <= (others => '0');
      EMAC0CLIENTRXDVLD      <= '0';
      EMAC0CLIENTRXGOODFRAME <= '0';
      EMAC0CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_0_i'event and rx_clk_0_i = '1' then 
      if rx_enable_0_i = '1' then
        EMAC0CLIENTRXD         <= rx_data_0_i;
        EMAC0CLIENTRXDVLD      <= rx_data_valid_0_i;
        EMAC0CLIENTRXGOODFRAME <= rx_good_frame_0_i;
        EMAC0CLIENTRXBADFRAME  <= rx_bad_frame_0_i;
      end if;
    end if;
  end process regipgen_emac0;

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking
   
    -- Use IDELAY on RGMII_RXC_0 to move the clock into
    -- alignment with the data

    -- Instantiate IDELAYCTRL for the IDELAY in Fixed Tap Delay Mode

    GEN_INSTANTIATE_IDELAYCTRLS: for I in 0 to (C_NUM_IDELAYCTRL-1) generate
      idelayctrl0 : IDELAYCTRL
      port map (
        RDY    => open,
        REFCLK => REFCLK,
        RST    => idelayctrl_reset_0_i
      );
    end generate;

    delay0rstgen :process (REFCLK, RESET)
    begin
      if (RESET = '1') then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= (others => '1');
      elsif REFCLK'event and REFCLK = '1' then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= idelayctrl_reset_0_r(11 downto 0);
      end if;
    end process delay0rstgen;

    idelayctrl_reset_0_i <= idelayctrl_reset_0_r(12);

    -- Please modify the value of the IOBDELAYs according to your design.
    -- For more information on IDELAYCTRL and IDELAY, please refer to
    -- the Virtex-5 User Guide.
    rgmii_rxc0_delay : IODELAY
    generic map (
        IDELAY_TYPE    => "FIXED",
       	IDELAY_VALUE   => 0,
        DELAY_SRC      => "I",
        SIGNAL_PATTERN => "CLOCK"
    )
    port map (
      IDATAIN    => RGMII_RXC_0,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rxc_0_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );

    -- Use the 2.5/25/125MHz reference clock from the EMAC 
    -- to clock the TX section of the wrappers.
    bufg_tx_0 : BUFG port map (I => tx_clk_0_o, O => tx_clk_0_i);

    -- Put the RX PHY clock through a BUFG.
    -- Used to clock the RX section of the EMAC wrappers.
    bufg_rx_0 : BUFG port map (I => rgmii_rxc_0_delay, O => rx_clk_0_i);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i    <=  tx_clk_0_o;
    rx_clk_0_i    <=  RGMII_RXC_0;
  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_single_rgmii2_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR    => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR    => C_TEMAC1_PHYADDR
      )
    port map (
      -- EMAC0 Clocking
      -- TX Clock output from EMAC0
      TX_CLK_OUT_0                    => tx_clk_0_o,
      -- EMAC0 TX Clock input from BUFG
      TX_CLK_0                        => tx_clk_0_i,

      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_ENABLE_0    => rx_enable_0_i,
      EMAC0CLIENTRXD            => rx_data_0_i,
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,
      EMAC0CLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMAC0CLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_ENABLE_0    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      GTX_CLK_0                 => GTX_CLK_0,                 --in            
      -- RGMII Interface - EMAC0
      RGMII_TXD_0               => RGMII_TXD_0,               --out
      RGMII_TX_CTL_0            => RGMII_TX_CTL_0,            --out
      RGMII_TXC_0               => RGMII_TXC_0,               --out
      RGMII_RXD_0               => RGMII_RXD_0,               --in 
      RGMII_RX_CTL_0            => RGMII_RX_CTL_0,            --in 
      RGMII_RXC_0               => rx_clk_0_i,               --in 

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 
        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

end generate SINGLE_RGMII2;

DUAL_RGMII2: if(C_PHY_TYPE = 3 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are RGMII v2
begin
  EMAC0ResetDoneInterrupt <= '1';
  EMAC1ResetDoneInterrupt <= '1';

  EMAC0CLIENTANINTERRUPT <= '0';
  EMAC1CLIENTANINTERRUPT <= '0';
    
  TX_CLIENT_CLK_0 <= tx_clk_0_i;
  RX_CLIENT_CLK_0 <= rx_clk_0_i;   
  TX_CLIENT_CLK_1 <= tx_clk_1_i;
  RX_CLIENT_CLK_1 <= rx_clk_1_i;   
  
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 
  EMAC1CLIENTRXDVLD_TOSTATS <= rx_data_valid_1_i; 

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC0 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac0 : process(rx_clk_0_i, RESET)
  begin
    if RESET = '1' then
      EMAC0CLIENTRXD         <= (others => '0');
      EMAC0CLIENTRXDVLD      <= '0';
      EMAC0CLIENTRXGOODFRAME <= '0';
      EMAC0CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_0_i'event and rx_clk_0_i = '1' then 
      if rx_enable_0_i = '1' then
        EMAC0CLIENTRXD         <= rx_data_0_i;
        EMAC0CLIENTRXDVLD      <= rx_data_valid_0_i;
        EMAC0CLIENTRXGOODFRAME <= rx_good_frame_0_i;
        EMAC0CLIENTRXBADFRAME  <= rx_bad_frame_0_i;
      end if;
    end if;
  end process regipgen_emac0;

  ----------------------------------------------------------------------
  -- Register the receiver outputs from EMAC1 before routing 
  -- to the client
  ----------------------------------------------------------------------
  regipgen_emac1 : process(rx_clk_1_i, RESET)
  begin
    if RESET = '1' then
      EMAC1CLIENTRXD         <= (others => '0');
      EMAC1CLIENTRXDVLD      <= '0';
      EMAC1CLIENTRXGOODFRAME <= '0';
      EMAC1CLIENTRXBADFRAME  <= '0';
    elsif rx_clk_1_i'event and rx_clk_1_i = '1' then 
      if rx_enable_1_i = '1' then
        EMAC1CLIENTRXD         <= rx_data_1_i;
        EMAC1CLIENTRXDVLD      <= rx_data_valid_1_i;
        EMAC1CLIENTRXGOODFRAME <= rx_good_frame_1_i;
        EMAC1CLIENTRXBADFRAME  <= rx_bad_frame_1_i;
      end if;
    end if;
  end process regipgen_emac1;

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking
   
    -- Use IDELAY on RGMII_RXC_0 to move the clock into
    -- alignment with the data

    -- Instantiate IDELAYCTRL for the IDELAY in Fixed Tap Delay Mode

    GEN_INSTANTIATE_IDELAYCTRLS: for I in 0 to (C_NUM_IDELAYCTRL-1) generate
      idelayctrl0 : IDELAYCTRL
      port map (
        RDY    => open,
        REFCLK => REFCLK,
        RST    => idelayctrl_reset_0_i
      );
    end generate;

    delay0rstgen :process (REFCLK, RESET)
    begin
      if (RESET = '1') then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= (others => '1');
      elsif REFCLK'event and REFCLK = '1' then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= idelayctrl_reset_0_r(11 downto 0);
      end if;
    end process delay0rstgen;

    idelayctrl_reset_0_i <= idelayctrl_reset_0_r(12);

    -- Please modify the value of the IOBDELAYs according to your design.
    -- For more information on IDELAYCTRL and IDELAY, please refer to
    -- the Virtex-5 User Guide.
    rgmii_rxc0_delay : IODELAY
    generic map (
        IDELAY_TYPE    => "FIXED",
       	IDELAY_VALUE   => 0,
        DELAY_SRC      => "I",
        SIGNAL_PATTERN => "CLOCK"
    )
    port map (
      IDATAIN    => RGMII_RXC_0,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rxc_0_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );
      
    rgmii_rxc1_delay : IODELAY
    generic map (
        IDELAY_TYPE    => "FIXED",
       	IDELAY_VALUE   => 0,
        DELAY_SRC      => "I",
        SIGNAL_PATTERN => "CLOCK"
    )
    port map (
      IDATAIN    => RGMII_RXC_1,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rxc_1_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );

    -- Use the 2.5/25/125MHz reference clock from the EMAC 
    -- to clock the TX section of the wrappers.
    bufg_tx_0 : BUFG port map (I => tx_clk_0_o, O => tx_clk_0_i);
    bufg_tx_1 : BUFG port map (I => tx_clk_1_o, O => tx_clk_1_i);

    -- Put the RX PHY clock through a BUFG.
    -- Used to clock the RX section of the EMAC wrappers.
    bufg_rx_0 : BUFG port map (I => rgmii_rxc_0_delay, O => rx_clk_0_i);
    bufg_rx_1 : BUFG port map (I => rgmii_rxc_1_delay, O => rx_clk_1_i);

 end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i    <=  tx_clk_0_o;
    rx_clk_0_i    <=  RGMII_RXC_0;
    tx_clk_1_i    <=  tx_clk_1_o;
    rx_clk_1_i    <=  RGMII_RXC_1;

  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_dual_rgmii2_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO            => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
      )
    port map (
      -- EMAC0 Clocking
      -- TX Clock output from EMAC0
      TX_CLK_OUT_0                    => tx_clk_0_o,
      -- EMAC0 TX Clock input from BUFG
      TX_CLK_0                        => tx_clk_0_i,

      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_ENABLE_0    => rx_enable_0_i,
      EMAC0CLIENTRXD            => rx_data_0_i,
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,
      EMAC0CLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMAC0CLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_ENABLE_0    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      RGMII_RXC_0               => rx_clk_0_i,               --in 

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out
                  
      -- EMAC1 Clocking
      -- TX Clock output from EMAC1
      TX_CLK_OUT_1                    => tx_clk_1_o,
      -- EMAC1 TX Clock input from BUFG
      TX_CLK_1                        => tx_clk_1_i,

      -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_ENABLE_1    => rx_enable_1_i,
      EMAC1CLIENTRXD            => rx_data_1_i,
      EMAC1CLIENTRXDVLD         => rx_data_valid_1_i,
      EMAC1CLIENTRXGOODFRAME    => rx_good_frame_1_i,
      EMAC1CLIENTRXBADFRAME     => rx_bad_frame_1_i,
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out      
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out      
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out      
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_ENABLE_1    => TX_CLIENT_CLK_ENABLE_1,
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in       
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in       
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out      
      CLIENTEMAC1TXFIRSTBYTE    => '0',                       --in
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
      RGMII_RXC_1               => rx_clk_1_i,               --in  

      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 
            
      -- GTX Clock signal
      GTX_CLK                   => GTX_CLK_0,                 --in            
        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

end generate DUAL_RGMII2;

SINGLE_1000BASEX_NOTFX: if(C_PHY_TYPE = 5 and C_EMAC1_PRESENT = 0 and (equalIgnoringCase(C_SUBFAMILY, "fx")= FALSE)) generate  -- EMAC0 is 1000Base-X and EMAC1 is not used
begin
  EMAC1ResetDoneInterrupt <= '1';
  rx_enable_0_i  <= '1';
  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_0  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD         <= rx_data_valid_0_i;
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i;   

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking

    -- Generate the clock input to the GTP
    -- clk_ds can be shared between multiple MAC instances.
    clkingen : IBUFDS port map (
      I  => MGTCLK_P,
      IB => MGTCLK_N,
      O  => clk_ds);

    -- 125MHz from transceiver is routed through a BUFG and 
    -- input to the MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map (I => clk125_o, O => clk125);
    
    TX_CLIENT_CLK_0 <= clk125;
    RX_CLIENT_CLK_0 <= clk125;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125'event and clk125 = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
     clk_ds     <= MGTCLK_P;

    -- 125MHz from transceiver is routed through a BUFG and 
    -- input to the MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map (I => clk125_o, O => clk125);
    
    TX_CLIENT_CLK_0 <= clk125;
    RX_CLIENT_CLK_0 <= clk125;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125'event and clk125 = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= '0';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_single_1000basex_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO            => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- EMAC0 Clocking
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      EMAC0CLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC0ANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;


      -- Clock Signals - EMAC0
      -- 1000BASE-X PCS/PMA Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,             -- out std_logic;

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

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 

      -- 1000BASE-X PCS/PMA RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in

      -- RocketIO Reset input
      GTRESET                         => gtreset,


        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
   );
end generate SINGLE_1000BASEX_NOTFX;

DUAL_1000BASEX_NOTFX: if(C_PHY_TYPE = 5 and C_EMAC1_PRESENT = 1 and (equalIgnoringCase(C_SUBFAMILY, "fx")= FALSE)) generate  -- EMAC0 & EMAC1 are 1000Base-X
begin
  rx_enable_0_i  <= '1';
  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_0  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD         <= rx_data_valid_0_i;
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 
  EMAC1CLIENTRXDVLD         <= rx_data_valid_1_i;
  EMAC1CLIENTRXDVLD_TOSTATS <= rx_data_valid_1_i;  

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking

    -- Generate the clock input to the GTP
    -- clk_ds can be shared between multiple MAC instances.
    clkingen : IBUFDS port map (
      I  => MGTCLK_P,
      IB => MGTCLK_N,
      O  => clk_ds);

    -- 125MHz from transceiver is routed through a BUFG and 
    -- input to the MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map (I => clk125_o, O => clk125);
    
    TX_CLIENT_CLK_0 <= clk125;
    RX_CLIENT_CLK_0 <= clk125;   
    
    TX_CLIENT_CLK_1 <= clk125;
    RX_CLIENT_CLK_1 <= clk125;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125'event and clk125 = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    clk_ds    <= MGTCLK_P;

    -- 125MHz from transceiver is routed through a BUFG and 
    -- input to the MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map (I => clk125_o, O => clk125);
    
    TX_CLIENT_CLK_0 <= clk125;
    RX_CLIENT_CLK_0 <= clk125;   
    
    TX_CLIENT_CLK_1 <= clk125;
    RX_CLIENT_CLK_1 <= clk125;   
    
   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125'event and clk125 = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= eMAC1ANINTERRUPT_i;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5_dual_1000basex_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO            => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- EMAC0 Clocking
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      EMAC0CLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC0ANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;

 
      -- Clock Signals - EMAC0
      -- 1000BASE-X PCS/PMA Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,             -- out std_logic;

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out

      -- EMAC1 Clocking
                  
      -- Client Receiver Interface - EMAC1
      EMAC1CLIENTRXD            => EMAC1CLIENTRXD,            --out
      EMAC1CLIENTRXDVLD         => rx_data_valid_1_i,         --out
      EMAC1CLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out
      EMAC1CLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface - EMAC1
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMAC1TXFIRSTBYTE    => '0',                       --in
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
      EMAC1CLIENTSYNCACQSTATUS  => eMAC1CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC1ANINTERRUPT          => eMAC1ANINTERRUPT_i,        -- out std_logic;


      -- Clock Signals - EMAC1
      -- 1000BASE-X PCS/PMA Interface - EMAC1
      TXP_1                     => TXP_1,                     --out
      TXN_1                     => TXN_1,                     --out
      RXP_1                     => RXP_1,                     --in
      RXN_1                     => RXN_1,                     --in
      PHYAD_1                   => C_TEMAC1_PHYADDR,          --in
      RESETDONE_1               => EMAC1ResetDoneInterrupt,             -- out std_logic;

      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 

      -- 1000BASE-X PCS/PMA RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in

      -- RocketIO Reset input
      GTRESET                         => gtreset,


        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
   );
end generate DUAL_1000BASEX_NOTFX;

SINGLE_1000BASEX_FX: if(C_PHY_TYPE = 5 and C_EMAC1_PRESENT = 0 and (equalIgnoringCase(C_SUBFAMILY, "fx")= TRUE)) generate  -- EMAC0 is 1000Base-X and EMAC1 is not used
begin
  EMAC1ResetDoneInterrupt <= '1';
  rx_enable_0_i  <= '1';
  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_0  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD         <= rx_data_valid_0_i;
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i;   

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking

    -- Generate the clock input to the GTP
    -- clk_ds can be shared between multiple MAC instances.
    clkingen : IBUFDS port map (
      I  => MGTCLK_P,
      IB => MGTCLK_N,
      O  => clk_ds);

    -- 125MHz from transceiver is routed through a BUFG and input 
    -- to DCM.
    bufg_clk125_o: BUFG port map(I => clk125_o, O => clk125_o_bufg);

    -- 125MHz from DCM is routed through a BUFG and input to the 
    -- MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map(I => clk125_fb, O => clk125);

    -- Divide 125MHz reference clock down by 2 to get
    -- 62.5MHz clock for 2 byte GTX internal datapath.
    clk62_5_dcm : DCM_BASE 
    port map 
    (CLKIN      => clk125_o_bufg,
     CLK0       => clk125_fb,
     CLK180     => open,
     CLK270     => open,
     CLK2X      => open,
     CLK2X180   => open,
     CLK90      => open,
     CLKDV      => clk62_5_pre_bufg,
     CLKFX      => open,
     CLKFX180   => open,
     LOCKED     => open,
     CLKFB      => clk125,
     RST        => RESET);

    clk62_5_bufg : BUFG port map(I => clk62_5_pre_bufg, O => clk62_5);
    
    TX_CLIENT_CLK_0 <= clk125;
    RX_CLIENT_CLK_0 <= clk125;   

   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125_o_bufg)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125_o_bufg'event and clk125_o_bufg = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
     clk_ds     <= MGTCLK_P;

    -- 125MHz from transceiver is routed through a BUFG and input 
    -- to DCM.
    bufg_clk125_o: BUFG port map(I => clk125_o, O => clk125_o_bufg);

    -- 125MHz from DCM is routed through a BUFG and input to the 
    -- MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map(I => clk125_fb, O => clk125);

    -- Divide 125MHz reference clock down by 2 to get
    -- 62.5MHz clock for 2 byte GTX internal datapath.
    clk62_5_dcm : DCM_BASE 
    port map 
    (CLKIN      => clk125_o_bufg,
     CLK0       => clk125_fb,
     CLK180     => open,
     CLK270     => open,
     CLK2X      => open,
     CLK2X180   => open,
     CLK90      => open,
     CLKDV      => clk62_5_pre_bufg,
     CLKFX      => open,
     CLKFX180   => open,
     LOCKED     => open,
     CLKFB      => clk125,
     RST        => RESET);

    clk62_5_bufg : BUFG port map(I => clk62_5_pre_bufg, O => clk62_5);
    
    TX_CLIENT_CLK_0 <= clk125;
    RX_CLIENT_CLK_0 <= clk125;   

   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125_o_bufg)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125_o_bufg'event and clk125_o_bufg = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= '0';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5fxt_single_1000basex_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO            => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- EMAC0 Clocking
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;
      -- 62.5MHz clock input from BUFG
      CLK62_5                   => clk62_5,

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      EMAC0CLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC0ANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;


      -- Clock Signals - EMAC0
      -- 1000BASE-X PCS/PMA Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,             -- out std_logic;

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

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 

      -- 1000BASE-X PCS/PMA RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in

      -- RocketIO Reset input
      GTRESET                         => gtreset,


        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
   );
end generate SINGLE_1000BASEX_FX;

DUAL_1000BASEX_FX: if(C_PHY_TYPE = 5 and C_EMAC1_PRESENT = 1 and (equalIgnoringCase(C_SUBFAMILY, "fx")= TRUE)) generate  -- EMAC0 & EMAC1 are 1000Base-X
begin
  rx_enable_0_i  <= '1';
  rx_enable_1_i  <= '1';
  TX_CLIENT_CLK_ENABLE_0  <= '1';
  TX_CLIENT_CLK_ENABLE_1  <= '1';
  
  EMAC0CLIENTRXDVLD         <= rx_data_valid_0_i;
  EMAC0CLIENTRXDVLD_TOSTATS <= rx_data_valid_0_i; 
  EMAC1CLIENTRXDVLD         <= rx_data_valid_1_i;
  EMAC1CLIENTRXDVLD_TOSTATS <= rx_data_valid_1_i;  

  IO_YES_01: if(C_INCLUDE_IO = 1) generate  -- include Io
  begin
    -- EMAC0 Clocking

    -- Generate the clock input to the GTP
    -- clk_ds can be shared between multiple MAC instances.
    clkingen : IBUFDS port map (
      I  => MGTCLK_P,
      IB => MGTCLK_N,
      O  => clk_ds);

    -- 125MHz from transceiver is routed through a BUFG and input 
    -- to DCM.
    bufg_clk125_o: BUFG port map(I => clk125_o, O => clk125_o_bufg);

    -- 125MHz from DCM is routed through a BUFG and input to the 
    -- MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map(I => clk125_fb, O => clk125);

    -- Divide 125MHz reference clock down by 2 to get
    -- 62.5MHz clock for 2 byte GTX internal datapath.
    clk62_5_dcm : DCM_BASE 
    port map 
    (CLKIN      => clk125_o_bufg,
     CLK0       => clk125_fb,
     CLK180     => open,
     CLK270     => open,
     CLK2X      => open,
     CLK2X180   => open,
     CLK90      => open,
     CLKDV      => clk62_5_pre_bufg,
     CLKFX      => open,
     CLKFX180   => open,
     LOCKED     => open,
     CLKFB      => clk125,
     RST        => RESET);

    clk62_5_bufg : BUFG port map(I => clk62_5_pre_bufg, O => clk62_5);
    
    TX_CLIENT_CLK_0 <= clk125;
    RX_CLIENT_CLK_0 <= clk125;   
    
    TX_CLIENT_CLK_1 <= clk125;
    RX_CLIENT_CLK_1 <= clk125;   

   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125_o_bufg)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125_o_bufg'event and clk125_o_bufg = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    clk_ds    <= MGTCLK_P;

    -- 125MHz from transceiver is routed through a BUFG and input 
    -- to DCM.
    bufg_clk125_o: BUFG port map(I => clk125_o, O => clk125_o_bufg);

    -- 125MHz from DCM is routed through a BUFG and input to the 
    -- MAC wrappers.
    -- This clock can be shared between multiple MAC instances.
    bufg_clk125 : BUFG port map(I => clk125_fb, O => clk125);

    -- Divide 125MHz reference clock down by 2 to get
    -- 62.5MHz clock for 2 byte GTX internal datapath.
    clk62_5_dcm : DCM_BASE 
    port map 
    (CLKIN      => clk125_o_bufg,
     CLK0       => clk125_fb,
     CLK180     => open,
     CLK270     => open,
     CLK2X      => open,
     CLK2X180   => open,
     CLK90      => open,
     CLKDV      => clk62_5_pre_bufg,
     CLKFX      => open,
     CLKFX180   => open,
     LOCKED     => open,
     CLKFB      => clk125,
     RST        => RESET);

    clk62_5_bufg : BUFG port map(I => clk62_5_pre_bufg, O => clk62_5);
    
    TX_CLIENT_CLK_0 <= clk125;
    RX_CLIENT_CLK_0 <= clk125;   
    
    TX_CLIENT_CLK_1 <= clk125;
    RX_CLIENT_CLK_1 <= clk125;   

   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------
   process(RESET, clk125_o_bufg)
   begin
     if (RESET = '1') then
       reset_r <= "1111";
     elsif clk125_o_bufg'event and clk125_o_bufg = '1' then
       reset_r <= reset_r(2 downto 0) & RESET;
     end if;
   end process;
  
   gtreset <= reset_r(3);

  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= eMAC1ANINTERRUPT_i;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v5fxt_dual_1000basex_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO            => C_INCLUDE_IO,
      C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
      C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
      C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
      C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
      -- EMAC0 Clocking
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;
      -- 62.5MHz clock input from BUFG
      CLK62_5                   => clk62_5,

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMAC0CLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMAC0CLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMAC0CLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMAC0CLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMAC0CLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMAC0CLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMAC0TXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMAC0CLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMAC0TXFIRSTBYTE    => '0',                       --in
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
      EMAC0CLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC0ANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;

 
      -- Clock Signals - EMAC0
      -- 1000BASE-X PCS/PMA Interface - EMAC0
      TXP_0                     => TXP_0,                     --out
      TXN_0                     => TXN_0,                     --out
      RXP_0                     => RXP_0,                     --in
      RXN_0                     => RXN_0,                     --in
      PHYAD_0                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE_0               => EMAC0ResetDoneInterrupt,             -- out std_logic;

      -- MDIO Interface - EMAC0
      MDC_0                     => mDC_0_i,                   --out
      MDIO_0_I                  => MDIO_0_I,                  --in 
      MDIO_0_O                  => mDIO_0_O_i,                --out
      MDIO_0_T                  => mDIO_0_T_i,                --out

      -- EMAC1 Clocking
                  
      -- Client Receiver Interface - EMAC1
      EMAC1CLIENTRXD            => EMAC1CLIENTRXD,            --out
      EMAC1CLIENTRXDVLD         => rx_data_valid_1_i,         --out
      EMAC1CLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out
      EMAC1CLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out
      EMAC1CLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMAC1CLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMAC1CLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMAC1CLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface - EMAC1
      CLIENTEMAC1TXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMAC1TXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMAC1CLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMAC1TXFIRSTBYTE    => '0',                       --in
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
      EMAC1CLIENTSYNCACQSTATUS  => eMAC1CLIENTSYNCACQSTATUS_i,-- out std_logic;
      -- EMAC0 Interrupt
      EMAC1ANINTERRUPT          => eMAC1ANINTERRUPT_i,        -- out std_logic;


      -- Clock Signals - EMAC1
      -- 1000BASE-X PCS/PMA Interface - EMAC1
      TXP_1                     => TXP_1,                     --out
      TXN_1                     => TXN_1,                     --out
      RXP_1                     => RXP_1,                     --in
      RXN_1                     => RXN_1,                     --in
      PHYAD_1                   => C_TEMAC1_PHYADDR,          --in
      RESETDONE_1               => EMAC1ResetDoneInterrupt,             -- out std_logic;

      -- MDIO Interface - EMAC1
      MDC_1                     => mDC_1_i,                   --out
      MDIO_1_I                  => MDIO_1_I,                  --in 
      MDIO_1_O                  => mDIO_1_O_i,                --out
      MDIO_1_T                  => mDIO_1_T_i,                --out

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => EMACDCRACK,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => DCRHOSTDONEIR,             --out 

      -- 1000BASE-X PCS/PMA RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in

      -- RocketIO Reset input
      GTRESET                         => gtreset,


        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
   );
end generate DUAL_1000BASEX_FX;
end imp;
