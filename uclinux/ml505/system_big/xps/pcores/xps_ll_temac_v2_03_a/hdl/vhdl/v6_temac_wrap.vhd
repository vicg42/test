------------------------------------------------------------------------------
-- $Id: v6_temac_wrap.vhd,v 1.1.4.39 2009/11/17 07:11:38 tomaik Exp $
------------------------------------------------------------------------------
-- v6_temac_wrap.vhd
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
-- Filename:        v6_temac_wrap.vhd
-- Version:         v2.01a
-- Description:     top level of v6_temac_wrap
--
------------------------------------------------------------------------------
-- Structure:   
--              v6_temac_wrap.vhd
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


entity v6_temac_wrap is
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
        -- Client Receiver Interface
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

        -- Client Transmitter Interface
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

        -- MAC Control Interface
        CLIENTEMAC0PAUSEREQ        : in  std_logic;
        CLIENTEMAC0PAUSEVAL        : in  std_logic_vector(15 downto  0);

        -- GTX_CLK 125 MHz clock frequency supplied by the user
        GTX_CLK_0                  : in  std_logic;

        RX_CLIENT_CLK_0            : out std_logic;
        TX_CLIENT_CLK_0            : out std_logic;

        -- MII Interface
        MII_TXD_0                  : out std_logic_vector(3 downto 0);
        MII_TX_EN_0                : out std_logic;
        MII_TX_ER_0                : out std_logic;
        MII_RXD_0                  : in  std_logic_vector(3 downto 0);
        MII_RX_DV_0                : in  std_logic;
        MII_RX_ER_0                : in  std_logic;
        MII_RX_CLK_0               : in  std_logic;

        -- MII & GMII Interface
        MII_TX_CLK_0               : in  std_logic;

        -- GMII Interface
        GMII_TXD_0                 : out std_logic_vector(7 downto 0);
        GMII_TX_EN_0               : out std_logic;
        GMII_TX_ER_0               : out std_logic;
        GMII_TX_CLK_0              : out std_logic;
        GMII_RXD_0                 : in  std_logic_vector(7 downto 0);
        GMII_RX_DV_0               : in  std_logic;
        GMII_RX_ER_0               : in  std_logic;
        GMII_RX_CLK_0              : in  std_logic;

        -- SGMII Interface
        TXP_0                      : out std_logic;
        TXN_0                      : out std_logic;
        RXP_0                      : in  std_logic;
        RXN_0                      : in  std_logic;

        -- RGMII Interface
        RGMII_TXD_0                : out std_logic_vector(3 downto 0);
        RGMII_TX_CTL_0             : out std_logic;
        RGMII_TXC_0                : out std_logic;
        RGMII_RXD_0                : in  std_logic_vector(3 downto 0);
        RGMII_RX_CTL_0             : in  std_logic;
        RGMII_RXC_0                : in  std_logic;

        -- MDIO Interface
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
    
end v6_temac_wrap;


architecture imp of v6_temac_wrap is

------------------------------------------------------------------------------
--  Constant Declarations
------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Function declarations
-----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Component
  -----------------------------------------------------------------------------
  
component IBUFDS_GTXE1
  generic (
     CLKCM_CFG : boolean := TRUE;
     CLKRCV_TRST : boolean := TRUE;
     REFCLKOUT_DLY : bit_vector := b"0000000000"
  );
  port (
     O : out std_ulogic;
     ODIV2 : out std_ulogic;
     CEB : in std_ulogic;
     I : in std_ulogic;
     IB : in std_ulogic
  );
end component;

------------------------------------------------------------------------------
-- Signal and Type Declarations
------------------------------------------------------------------------------
  signal eMACDCRACK0                : std_logic;
  signal eMACDCRACK1                : std_logic;
  signal eMACDCRDBUS0               : std_logic_vector(0 to 31);
  signal dCRHOSTDONEIR0             : std_logic;
  signal dCRHOSTDONEIR1             : std_logic;

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

  -- 1.25/12.5/125MHz clock signals for tri-speed SGMII
  signal client_clk_0_o            : std_logic;
  signal client_clk_0              : std_logic;
  signal client_clk_1_o            : std_logic;
  signal client_clk_1              : std_logic;

  attribute buffer_type : string;
  signal gtx_clk_0_i               : std_logic;
  attribute buffer_type of gtx_clk_0_i  : signal is "none";
  signal gtx_clk_i               : std_logic;
  attribute buffer_type of gtx_clk_i  : signal is "none";

  -- GMII input clocks to wrappers
  signal tx_clk_0                  : std_logic;
  signal gmii_rx_clk_0_delay       : std_logic;
  signal gmii_rx_clk_0_bufio       : std_logic;
  signal rgmii_rx_clk_0_bufio       : std_logic;
  signal rgmii_rx_clk_0_delay        : std_logic;
  -- GMII input clocks to wrappers
  signal tx_clk_1                  : std_logic;
  signal gmii_rx_clk_1_delay       : std_logic;
  signal gmii_rx_clk_1_bufio       : std_logic;
  signal rgmii_rx_clk_1_bufio       : std_logic;
  signal rgmii_rx_clk_1_delay        : std_logic;

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
    -- Globally-buffer the transmit and receive physical interface
    -- clocks used by the EMAC wrappers
    bufg_tx_0 : BUFG port map (
      I => MII_TX_CLK_0, 
      O => tx_clk_0_i
    );
    bufg_rx_0 : BUFG port map (
      I => MII_RX_CLK_0, 
      O => rx_clk_0_i
    );
  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i <= MII_TX_CLK_0;
    rx_clk_0_i <= MII_RX_CLK_0;
  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v6_mii_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
      )
    port map (
      -- TX clock input from BUFG
      TX_CLK                    => tx_clk_0_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE      => rx_enable_0_i,
      EMACCLIENTRXD            => rx_data_0_i,
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD,
               
      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE      => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMACTXD            => CLIENTEMAC0TXD,
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,
      CLIENTEMACTXFIRSTBYTE    => '0',
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD,
                   
      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 
                   
      -- MII Interface
      MII_TXD                 => MII_TXD_0,                 --out
      MII_TX_EN               => MII_TX_EN_0,               --out
      MII_TX_ER               => MII_TX_ER_0,               --out
      MII_TX_CLK              => tx_clk_0_i,            --in
      MII_RXD                 => MII_RXD_0,                 --in
      MII_RX_DV               => MII_RX_DV_0,               --in
      MII_RX_ER               => MII_RX_ER_0,               --in
      MII_RX_CLK              => rx_clk_0_i,            --in
                         
      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out
                 
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
    -- Globally-buffer the transmit and receive physical interface
    -- clocks used by the EMAC wrappers
    bufg_tx_0 : BUFG port map (
      I => MII_TX_CLK_0, 
      O => tx_clk_0_i
    );
    bufg_rx_0 : BUFG port map (
      I => MII_RX_CLK_0, 
      O => rx_clk_0_i
    );
    bufg_tx_1 : BUFG port map (
      I => MII_TX_CLK_1, 
      O => tx_clk_1_i
    );
    bufg_rx_1 : BUFG port map (
      I => MII_RX_CLK_1, 
      O => rx_clk_1_i
    );
  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i <= MII_TX_CLK_0;
    rx_clk_0_i <= MII_RX_CLK_0;
    tx_clk_1_i <= MII_TX_CLK_1;
    rx_clk_1_i <= MII_RX_CLK_1;
  end generate IO_NO_01;

  I_EMAC0_TOP : entity xps_ll_temac_v2_03_a.v6_mii_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
      )
    port map (
      -- TX Clock input from BUFG
      TX_CLK                    => tx_clk_0_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE      => rx_enable_0_i,
      EMACCLIENTRXD            => rx_data_0_i,
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD,
               
      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE      => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMACTXD            => CLIENTEMAC0TXD,
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,
      CLIENTEMACTXFIRSTBYTE    => '0',
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD,
                   
      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in          
         
      -- Clock Signal
      -- MII Interface
      MII_TXD                 => MII_TXD_0,                 --out
      MII_TX_EN               => MII_TX_EN_0,               --out
      MII_TX_ER               => MII_TX_ER_0,               --out
      MII_TX_CLK              => tx_clk_0_i,             --in
      MII_RXD                 => MII_RXD_0,                 --in
      MII_RX_DV               => MII_RX_DV_0,               --in
      MII_RX_ER               => MII_RX_ER_0,               --in
      MII_RX_CLK              => rx_clk_0_i,             --in
                         
      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out
                                 
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => eMACDCRACK0,                --out 
      EMACDCRDBUS               => eMACDCRDBUS0,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR0,             --out 
               
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );

  I_EMAC1_TOP : entity xps_ll_temac_v2_03_a.v6_mii_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC1_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC1_PHYADDR
      )
    port map (
      -- TX Clock input from BUFG
      TX_CLK                    => tx_clk_1_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE      => rx_enable_1_i,
      EMACCLIENTRXD            => rx_data_1_i,
      EMACCLIENTRXDVLD         => rx_data_valid_1_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_1_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_1_i,
      EMACCLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,
      EMACCLIENTRXSTATS        => EMAC1CLIENTRXSTATS,
      EMACCLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,
      EMACCLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD,
               
      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE      => TX_CLIENT_CLK_ENABLE_1,
      CLIENTEMACTXD            => CLIENTEMAC1TXD,
      CLIENTEMACTXDVLD         => CLIENTEMAC1TXDVLD,
      EMACCLIENTTXACK          => EMAC1CLIENTTXACK,
      CLIENTEMACTXFIRSTBYTE    => '0',
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,
      EMACCLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,
      EMACCLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,
      EMACCLIENTTXSTATS        => EMAC1CLIENTTXSTATS,
      EMACCLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,
      EMACCLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD,
                   
      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in 
      CLIENTEMACPAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in          
         
      -- Clock Signal
      -- MII Interface
      MII_TXD                 => MII_TXD_1,                 --out
      MII_TX_EN               => MII_TX_EN_1,               --out
      MII_TX_ER               => MII_TX_ER_1,               --out
      MII_TX_CLK              => tx_clk_1_i,             --in
      MII_RXD                 => MII_RXD_1,                 --in
      MII_RX_DV               => MII_RX_DV_1,               --in
      MII_RX_ER               => MII_RX_ER_1,               --in
      MII_RX_CLK              => rx_clk_1_i,             --in
                         
      -- MDIO Interface
      MDC                     => mDC_1_i,                   --out
      MDIO_I                  => MDIO_1_I,                  --in 
      MDIO_O                  => mDIO_1_O_i,                --out
      MDIO_T                  => mDIO_1_T_i,                --out
                                 
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => eMACDCRDBUS0,               --in  
      EMACDCRACK                => eMACDCRACK1,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR1,             --out 
               
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );    

  EMACDCRACK    <= eMACDCRACK0 or eMACDCRACK1;
  DCRHOSTDONEIR <= dCRHOSTDONEIR0 or dCRHOSTDONEIR1;
    
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

    ---------------------------------------------------------------------------
    -- Removed delay on clock due to clock uncertainty which causes contraints     
    -- to fail                                                                     
    ---------------------------------------------------------------------------                                                                                       
    
    -- -- *** PLEASE MODIFY THE IDELAY VALUE ACCORDING TO YOUR DESIGN ***
    -- -- The IDELAY value set here is tuned to this example design.
    -- -- For more information on IDELAYCTRL and IODELAY, please
    -- -- refer to the Virtex-6 User Guide.
    -- gmii_rxc0_delay : IODELAY
    -- generic map (
    --   IDELAY_TYPE           => "FIXED",
    --   IDELAY_VALUE          => 0,
    --   DELAY_SRC             => "I",
    --   SIGNAL_PATTERN        => "CLOCK",
    --   HIGH_PERFORMANCE_MODE => TRUE
    -- )
    -- port map
    -- (IDATAIN => GMII_RX_CLK_0,
    --  ODATAIN => '0',
    --  DATAOUT => gmii_rx_clk_0_delay,
    --  DATAIN  => '0',
    --  C       => '0',
    --  T       => '0',
    --  CE      => '0',
    --  INC     => '0',
    --  RST     => '0');
    
    gmii_rx_clk_0_delay <= GMII_RX_CLK_0;
    
    -- Clock the transmit-side function of the EMAC wrappers:
    -- Use the 125MHz reference clock when running at 1000Mb/s and
    -- the 2.5/25MHz transmit-side PHY clock when running at 100 or 10Mb/s.
    -- This selection is handled by the EMAC automatically.
    bufg_tx_0 : BUFGMUX port map (
      I0 => GTX_CLK_0,
      I1 => MII_TX_CLK_0,
      S => speed_vector_0_i,
      O => tx_clk_0_i
    );

    -- Use a low-skew BUFIO on the delayed RX_CLK, which will be used in the
    -- GMII phyical interface block to capture incoming data and control.
    bufio_rx_0 : BUFIO port map (
      I => gmii_rx_clk_0_delay,
      O => gmii_rx_clk_0_bufio
    );

    -- Regionally-buffer the receive-side GMII physical interface clock
    -- for use with receive-side functions of the EMAC
    bufr_rx_0 : BUFR port map (
      I   => gmii_rx_clk_0_delay,
      O   => rx_clk_0_i,
      CE  => '1',
      CLR => '0'
    );

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

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v6_gmii_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
      )
    port map (
      -- TX Clock output
      TX_CLK_OUT              => open,
      -- TX Clock input from BUFG
      TX_CLK                  => tx_clk_0_i,
      -- Speed indicator
      -- Used in clocking circuitry.
      EMACSPEEDIS10100         => speed_vector_0_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE    => rx_enable_0_i,
      EMACCLIENTRXD            => rx_data_0_i,
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMACTXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMACTXFIRSTBYTE    => '0',
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 

      -- Receive-side PHY clock on regional buffer, to EMAC
      PHY_RX_CLK              =>  rx_clk_0_i,               --in
                   
      -- Clock Signal
      GTX_CLK                 => '0',                       --in
      
      -- GMII Interface
      GMII_TXD                => GMII_TXD_0,                --out
      GMII_TX_EN              => GMII_TX_EN_0,              --out
      GMII_TX_ER              => GMII_TX_ER_0,              --out
      GMII_TX_CLK             => GMII_TX_CLK_0,             --in
      GMII_RXD                => GMII_RXD_0,                --in
      GMII_RX_DV              => GMII_RX_DV_0,              --in
      GMII_RX_ER              => GMII_RX_ER_0,              --in
      GMII_RX_CLK             => gmii_rx_clk_0_bufio,             --in
      MII_TX_CLK              => MII_TX_CLK_0,              --in
                         
      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out               

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

    ---------------------------------------------------------------------------
    -- Removed delay on clock due to clock uncertainty which causes contraints 
    -- to fail
    ---------------------------------------------------------------------------

    -- -- *** PLEASE MODIFY THE IDELAY VALUE ACCORDING TO YOUR DESIGN ***
    -- -- The IDELAY value set here is tuned to this example design.
    -- -- For more information on IDELAYCTRL and IODELAY, please
    -- -- refer to the Virtex-6 User Guide.
    -- gmii_rxc0_delay : IODELAY
    -- generic map (
    --   IDELAY_TYPE           => "FIXED",
    --   IDELAY_VALUE          => 0,
    --   DELAY_SRC             => "I",
    --   SIGNAL_PATTERN        => "CLOCK",
    --   HIGH_PERFORMANCE_MODE => TRUE
    --   )
    -- port map
    -- (IDATAIN => GMII_RX_CLK_0,
    --  ODATAIN => '0',
    --  DATAOUT => gmii_rx_clk_0_delay,
    --  DATAIN  => '0',
    --  C       => '0',
    --  T       => '0',
    --  CE      => '0',
    --  INC     => '0',
    --  RST     => '0');
    
    gmii_rx_clk_0_delay <= GMII_RX_CLK_0;

    ---------------------------------------------------------------------------
    -- Removed delay on clock due to clock uncertainty which causes contraints 
    -- to fail                                                                 
    ---------------------------------------------------------------------------
                                                                                   
    -- -- *** PLEASE MODIFY THE IDELAY VALUE ACCORDING TO YOUR DESIGN ***
    -- -- The IDELAY value set here is tuned to this example design.
    -- -- For more information on IDELAYCTRL and IODELAY, please
    -- -- refer to the Virtex-6 User Guide.
    -- gmii_rxc1_delay : IODELAY
    -- generic map (
    --   IDELAY_TYPE           => "FIXED",
    --   IDELAY_VALUE          => 0,
    --   DELAY_SRC             => "I",
    --   SIGNAL_PATTERN        => "CLOCK",
    --   HIGH_PERFORMANCE_MODE => TRUE
    --   )
    -- port map
    -- (IDATAIN => GMII_RX_CLK_1,
    --  ODATAIN => '0',
    --  DATAOUT => gmii_rx_clk_1_delay,
    --  DATAIN  => '0',
    --  C       => '0',
    --  T       => '0',
    --  CE      => '0',
    --  INC     => '0',
    --  RST     => '0');
    
    gmii_rx_clk_1_delay <= GMII_RX_CLK_1;

    -- Clock the transmit-side function of the EMAC wrappers:
    -- Use the 125MHz reference clock when running at 1000Mb/s and
    -- the 2.5/25MHz transmit-side PHY clock when running at 100 or 10Mb/s.
    -- This selection is handled by the EMAC automatically.
    bufg_tx_0 : BUFGMUX port map (
       I0 => GTX_CLK_0, 
       I1 => MII_TX_CLK_0, 
       S => speed_vector_0_i, 
       O => tx_clk_0_i
     );
    bufg_tx_1 : BUFGMUX port map (
       I0 => GTX_CLK_0, 
       I1 => MII_TX_CLK_1, 
       S => speed_vector_1_i, 
       O => tx_clk_1_i
     );

    -- Use a low-skew BUFIO on the delayed RX_CLK, which will be used in the
    -- GMII phyical interface block to capture incoming data and control.
    bufio_rx_0 : BUFIO port map (
      I => gmii_rx_clk_0_delay, 
      O => gmii_rx_clk_0_bufio
    );
    bufio_rx_1 : BUFIO port map (
      I => gmii_rx_clk_1_delay, 
      O => gmii_rx_clk_1_bufio
    );

    -- Regionally-buffer the receive-side GMII physical interface clock
    -- for use with receive-side functions of the EMAC
    bufr_rx0 : BUFR port map (
      I   => gmii_rx_clk_0_delay,
      O   => rx_clk_0_i,
      CE  => '1',
      CLR => '0'
    );
    bufr_rx1 : BUFR port map (
      I   => gmii_rx_clk_1_delay,
      O   => rx_clk_1_i,
      CE  => '1',
      CLR => '0'
    );

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    rx_clk_0_i          <= GMII_RX_CLK_0;
    gmii_rx_clk_0_bufio <= GMII_RX_CLK_0;
    mux0 : process(GTX_CLK_0, MII_TX_CLK_0, speed_vector_0_i)
    begin
      if (speed_vector_0_i = '0') then
        tx_clk_0_i <= GTX_CLK_0;
      else
        tx_clk_0_i <= MII_TX_CLK_0;
      end if;
    end process mux0;
    
    rx_clk_1_i          <= GMII_RX_CLK_1;
    gmii_rx_clk_1_bufio <= GMII_RX_CLK_1;

    mux1 : process(GTX_CLK_0, MII_TX_CLK_1, speed_vector_1_i)
    begin
      if (speed_vector_1_i = '0') then
        tx_clk_1_i <= GTX_CLK_0;
      else
        tx_clk_1_i <= MII_TX_CLK_1;
      end if;
    end process mux1;
 
  end generate IO_NO_01;

  I_EMAC0_TOP : entity xps_ll_temac_v2_03_a.v6_gmii_top(TOP_LEVEL)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC_DCRBASEADDR      => C_EMAC0_DCRBASEADDR,
                 C_TEMAC_PHYADDR         => C_TEMAC0_PHYADDR
                )
    port map (
      -- TX Clock output
      TX_CLK_OUT              => open,
      -- TX Clock input from BUFG
      TX_CLK                  => tx_clk_0_i,

      -- Speed indicator
      EMACSPEEDIS10100         => speed_vector_0_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE    => rx_enable_0_i,
      EMACCLIENTRXD            => rx_data_0_i,
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMACTXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 

      -- Receive-side PHY clock on regional buffer, to EMAC
      PHY_RX_CLK              =>  rx_clk_0_i,               --in
                   
      -- Clock Signal
      GTX_CLK                 => '0',                       --in

      -- GMII Interface
      GMII_TXD                => GMII_TXD_0,                --out
      GMII_TX_EN              => GMII_TX_EN_0,              --out
      GMII_TX_ER              => GMII_TX_ER_0,              --out
      GMII_TX_CLK             => GMII_TX_CLK_0,             --in
      GMII_RXD                => GMII_RXD_0,                --in
      GMII_RX_DV              => GMII_RX_DV_0,              --in
      GMII_RX_ER              => GMII_RX_ER_0,              --in
      GMII_RX_CLK             => gmii_rx_clk_0_bufio,             --in
      MII_TX_CLK              => MII_TX_CLK_0,              --in
                         
      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out
                  
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => eMACDCRACK0,                --out 
      EMACDCRDBUS               => eMACDCRDBUS0,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR0,             --out 
                    
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );

  I_EMAC1_TOP : entity xps_ll_temac_v2_03_a.v6_gmii_top(TOP_LEVEL)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC_DCRBASEADDR      => C_EMAC1_DCRBASEADDR,
                 C_TEMAC_PHYADDR         => C_TEMAC1_PHYADDR
                )
    port map (
      -- TX Clock output
      TX_CLK_OUT              => open,
      -- TX Clock input from BUFG
      TX_CLK                  => tx_clk_1_i,

      -- Speed indicator
      EMACSPEEDIS10100         => speed_vector_1_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE     => rx_enable_1_i,
      EMACCLIENTRXD            => rx_data_1_i,
      EMACCLIENTRXDVLD         => rx_data_valid_1_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_1_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_1_i,
      EMACCLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMACCLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMACCLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMACCLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE    => TX_CLIENT_CLK_ENABLE_1,
      CLIENTEMACTXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMACTXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMACCLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in 
      EMACCLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out
      EMACCLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in 
      EMACCLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out
      EMACCLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out
      EMACCLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in 
      CLIENTEMACPAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in 

      -- Receive-side PHY clock on regional buffer, to EMAC
      PHY_RX_CLK              =>  rx_clk_1_i,               --in
                   
      -- Clock Signal
      GTX_CLK                 => '0',                       --in

      -- GMII Interface
      GMII_TXD                => GMII_TXD_1,                --out
      GMII_TX_EN              => GMII_TX_EN_1,              --out
      GMII_TX_ER              => GMII_TX_ER_1,              --out
      GMII_TX_CLK             => GMII_TX_CLK_1,             --in
      GMII_RXD                => GMII_RXD_1,                --in
      GMII_RX_DV              => GMII_RX_DV_1,              --in
      GMII_RX_ER              => GMII_RX_ER_1,              --in
      GMII_RX_CLK             => gmii_rx_clk_1_bufio,             --in
      MII_TX_CLK              => MII_TX_CLK_1,              --in
                         
      -- MDIO Interface
      MDC                     => mDC_1_i,                   --out
      MDIO_I                  => MDIO_1_I,                  --in 
      MDIO_O                  => mDIO_1_O_i,                --out
      MDIO_T                  => mDIO_1_T_i,                --out
                  
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => eMACDCRDBUS0,               --in  
      EMACDCRACK                => eMACDCRACK1,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR1,             --out 
                    
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
    
  EMACDCRACK    <= eMACDCRACK0 or eMACDCRACK1;
  DCRHOSTDONEIR <= dCRHOSTDONEIR0 or dCRHOSTDONEIR1;
    
end generate DUAL_GMII;

SINGLE_SGMII: if(C_PHY_TYPE = 4 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is SGMII and EMAC1 is not used
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

    -- Generate the clock input to the transceiver
    -- (clk_ds can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    clkingen : IBUFDS_GTXE1 port map (
      I     => MGTCLK_P,
      IB    => MGTCLK_N,
      CEB   => '0',
      O     => clk_ds,
      ODIV2 => open
    );

    -- The 125MHz clock from the transceiver is routed through a BUFG and
    -- input to the MAC wrappers
    -- (clk125 can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    bufg_clk125 : BUFG port map (
      I => clk125_o,
      O => clk125
    );

    -- The 1.25/12.5/125MHz clock from the EMAC is routed through
    -- a BUFG and to the EMAC wrappers to clock the client interface
    bufg_client : BUFG port map (
      I => client_clk_0_o,
      O => client_clk_0
    );
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    clk_ds  <= MGTCLK_P;

    -- The 125MHz clock from the transceiver is routed through a BUFG and
    -- input to the MAC wrappers
    -- (clk125 can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    bufg_clk125 : BUFG port map (
      I => clk125_o,
      O => clk125
    );

    -- The 1.25/12.5/125MHz clock from the EMAC is routed through
    -- a BUFG and to the EMAC wrappers to clock the client interface
    bufg_client : BUFG port map (
      I => client_clk_0_o,
      O => client_clk_0
    );
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   
  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= '0';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v6_sgmii_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
                )
    port map (
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;
      -- Tri-speed clock output
      CLIENT_CLK_OUT            => client_clk_0_o,        -- out std_logic;
      --  Tri-speed clock input from BUFG
      CLIENT_CLK                => client_clk_0,            -- in  std_logic;

      -- Client Receiver Interface
      EMACCLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMACCLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMACCLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface
      CLIENTEMACTXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 

      --EMAC-MGT link status
      EMACCLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      --  Interrupt
      EMACANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;

                   
      -- Clock Signal
      -- SGMII Interface
      TXP                     => TXP_0,                     --out
      TXN                     => TXN_0,                     --out
      RXP                     => RXP_0,                     --in
      RXN                     => RXN_0,                     --in
      PHYAD                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE               => EMAC0ResetDoneInterrupt,             -- out std_logic;
                         
      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out
                
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
                 
      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );
end generate SINGLE_SGMII;

DUAL_SGMII: if(C_PHY_TYPE = 4 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are SGMII
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

    -- Generate the clock input to the transceiver
    -- (clk_ds can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    clkingen : IBUFDS_GTXE1 port map (
      I     => MGTCLK_P,
      IB    => MGTCLK_N,
      CEB   => '0',
      O     => clk_ds,
      ODIV2 => open
    );

    -- The 125MHz clock from the transceiver is routed through a BUFG and
    -- input to the MAC wrappers
    -- (clk125 can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    bufg_clk125 : BUFG port map (
      I => clk125_o,
      O => clk125
    );

    -- The 1.25/12.5/125MHz clock from the EMAC is routed through
    -- a BUFG and to the EMAC wrappers to clock the client interface
    bufg_client : BUFG port map (
      I => client_clk_0_o,
      O => client_clk_0
    );
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_1 : BUFG port map (I => client_clk_1_o, O => client_clk_1);
    
    TX_CLIENT_CLK_1 <= client_clk_1;
    RX_CLIENT_CLK_1 <= client_clk_1;   
  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    clk_ds  <= MGTCLK_P;

    -- The 125MHz clock from the transceiver is routed through a BUFG and
    -- input to the MAC wrappers
    -- (clk125 can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    bufg_clk125 : BUFG port map (
      I => clk125_o,
      O => clk125
    );

    -- The 1.25/12.5/125MHz clock from the EMAC is routed through
    -- a BUFG and to the EMAC wrappers to clock the client interface
    bufg_client : BUFG port map (
      I => client_clk_0_o,
      O => client_clk_0
    );
    
    TX_CLIENT_CLK_0 <= client_clk_0;
    RX_CLIENT_CLK_0 <= client_clk_0;   

    -- 1.25/12.5/125MHz clock from the MAC is routed through a BUFG and  
    -- input to the MAC wrappers to clock the client interface.
    bufg_client_1 : BUFG port map (I => client_clk_1_o, O => client_clk_1);
    
    TX_CLIENT_CLK_1 <= client_clk_1;
    RX_CLIENT_CLK_1 <= client_clk_1;   
  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= eMAC1ANINTERRUPT_i;

  I_EMAC0_TOP : entity xps_ll_temac_v2_03_a.v6_sgmii_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
                )
    port map (
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;
      -- Tri-speed clock output
      CLIENT_CLK_OUT          => client_clk_0_o,        -- out std_logic;
      --  Tri-speed clock input from BUFG
      CLIENT_CLK              => client_clk_0,            -- in  std_logic;

      -- Client Receiver Interface
      EMACCLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMACCLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMACCLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface
      CLIENTEMACTXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in 
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in 

      --EMAC-MGT link status
      EMACCLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      --  Interrupt
      EMACANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;

                   
      -- Clock Signal
      -- SGMII Interface
      TXP                     => TXP_0,                     --out
      TXN                     => TXN_0,                     --out
      RXP                     => RXP_0,                     --in
      RXN                     => RXN_0,                     --in
      PHYAD                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE               => EMAC0ResetDoneInterrupt,             -- out std_logic;
                         
      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => eMACDCRACK0,                --out 
      EMACDCRDBUS               => eMACDCRDBUS0,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR0,             --out 

      -- SGMII RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in

      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );

  I_EMAC1_TOP : entity xps_ll_temac_v2_03_a.v6_sgmii_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC1_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC1_PHYADDR
                )
    port map (
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;
      -- Tri-speed clock output
      CLIENT_CLK_OUT          => client_clk_1_o,        -- out std_logic;
      --  Tri-speed clock input from BUFG
      CLIENT_CLK              => client_clk_1,            -- in  std_logic;

      -- Client Receiver Interface
      EMACCLIENTRXD            => EMAC1CLIENTRXD,            --out
      EMACCLIENTRXDVLD         => rx_data_valid_1_i,         --out
      EMACCLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out
      EMACCLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out
      EMACCLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMACCLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMACCLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMACCLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out
               
      -- Client Transmitter Interface
      CLIENTEMACTXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMACTXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMACCLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in 
      EMACCLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out
      EMACCLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in 
      EMACCLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out
      EMACCLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out
      EMACCLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out
                   
      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in 
      CLIENTEMACPAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in 

      --EMAC-MGT link status
      EMACCLIENTSYNCACQSTATUS  => eMAC1CLIENTSYNCACQSTATUS_i,-- out std_logic;
      --  Interrupt
      EMACANINTERRUPT          => eMAC1ANINTERRUPT_i,        -- out std_logic;

                   
      -- Clock Signal
      -- SGMII Interface
      TXP                     => TXP_1,                     --out
      TXN                     => TXN_1,                     --out
      RXP                     => RXP_1,                     --in
      RXN                     => RXN_1,                     --in
      PHYAD                   => C_TEMAC1_PHYADDR,          --in
      RESETDONE               => EMAC1ResetDoneInterrupt,             -- out std_logic;
                         
      -- MDIO Interface
      MDC                     => mDC_1_i,                   --out
      MDIO_I                  => MDIO_1_I,                  --in 
      MDIO_O                  => mDIO_1_O_i,                --out
      MDIO_T                  => mDIO_1_T_i,                --out

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in 
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => eMACDCRDBUS0,               --in  
      EMACDCRACK                => eMACDCRACK1,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR1,             --out 

      -- SGMII RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in



      -- Asynchronous Reset
      RESET                     => RESET                      --in 
    );

  EMACDCRACK    <= eMACDCRACK0 or eMACDCRACK1;
  DCRHOSTDONEIR <= dCRHOSTDONEIR0 or dCRHOSTDONEIR1;
    
end generate DUAL_SGMII;

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
                                                                              
    -- *** PLEASE MODIFY THE IDELAY VALUE ACCORDING TO YOUR DESIGN ***
    -- The IDELAY value set here is tuned to this example design.
    -- For more information on IDELAYCTRL and IODELAY, please
    -- refer to the Virtex-6 User Guide.
    rgmii_rxc0_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      DELAY_SRC             => "I",
      SIGNAL_PATTERN        => "CLOCK",
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN    => RGMII_RXC_0,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rx_clk_0_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );
    

    -- Use the 2.5/25/125MHz reference clock from the EMAC
    -- to clock the transmit-side functions of the wrappers
    bufg_tx_0 : BUFG port map (
      I => tx_clk_0_o, 
      O => tx_clk_0_i
    );

    -- Use a low-skew BUFIO on the delayed RX_CLK, which will be used in the
    -- RGMII phyical interface block to capture incoming data and control.
    bufg_rx_0 : BUFIO port map (
      I => rgmii_rx_clk_0_delay, 
      O => rgmii_rx_clk_0_bufio
    );

    -- Regionally-buffer the receive-side RGMII physical interface clock
    -- for use with receive-side functions of the EMAC
    bufr_rx0 : BUFR port map (
      I   => rgmii_rx_clk_0_delay,
      O   => rx_clk_0_i,
      CE  => '1',
      CLR => '0'
    );

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i           <=  tx_clk_0_o;
    rx_clk_0_i           <=  RGMII_RXC_0;
    rgmii_rx_clk_0_bufio <=  RGMII_RXC_0;
  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v6_rgmii13_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
      )
    port map (
      -- TX Clock output 
      TX_CLK_OUT                    => tx_clk_0_o,
      --  TX Clock input from BUFG
      TX_CLK                        => tx_clk_0_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE    => rx_enable_0_i,
      EMACCLIENTRXD            => rx_data_0_i,
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMACTXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in       
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out      
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out      
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in       
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out      
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out      
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      

      -- Receive-side PHY clock on regional buffer, to EMAC
      PHY_RX_CLK               => rx_clk_0_i,
 
      -- Reference clock
      GTX_CLK                 => GTX_CLK_0,                 --in            

      -- RGMII Interface
      RGMII_TXD               => RGMII_TXD_0,               --out
      RGMII_TX_CTL            => RGMII_TX_CTL_0,            --out
      RGMII_TXC               => RGMII_TXC_0,               --out
      RGMII_RXD               => RGMII_RXD_0,               --in 
      RGMII_RX_CTL            => RGMII_RX_CTL_0,            --in 
      RGMII_RXC               => rgmii_rx_clk_0_bufio,               --in 

      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out

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

    -- *** PLEASE MODIFY THE IDELAY VALUE ACCORDING TO YOUR DESIGN ***
    -- The IDELAY value set here is tuned to this example design.
    -- For more information on IDELAYCTRL and IODELAY, please
    -- refer to the Virtex-6 User Guide.
    rgmii_rxc0_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      DELAY_SRC             => "I",
      SIGNAL_PATTERN        => "CLOCK",
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN    => RGMII_RXC_0,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rx_clk_0_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );
    

    -- *** PLEASE MODIFY THE IDELAY VALUE ACCORDING TO YOUR DESIGN ***
    -- The IDELAY value set here is tuned to this example design.
    -- For more information on IDELAYCTRL and IODELAY, please
    -- refer to the Virtex-6 User Guide.     
    rgmii_rxc1_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      DELAY_SRC             => "I",
      SIGNAL_PATTERN        => "CLOCK",
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN    => RGMII_RXC_1,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rx_clk_1_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );

    
    -- Use the 2.5/25/125MHz reference clock from the EMAC
    -- to clock the transmit-side functions of the wrappers
    bufg_tx_0 : BUFG port map (
      I => tx_clk_0_o, 
      O => tx_clk_0_i
    );
    bufg_tx_1 : BUFG port map (
      I => tx_clk_1_o, 
      O => tx_clk_1_i
    );

    -- Use a low-skew BUFIO on the delayed RX_CLK, which will be used in the
    -- RGMII phyical interface block to capture incoming data and control.
    bufg_rx_0 : BUFIO port map (
      I => rgmii_rx_clk_0_delay, 
      O => rgmii_rx_clk_0_bufio
    );
    bufg_rx_1 : BUFIO port map (
      I => rgmii_rx_clk_1_delay, 
      O => rgmii_rx_clk_1_bufio
    );

    -- Regionally-buffer the receive-side RGMII physical interface clock
    -- for use with receive-side functions of the EMAC
    bufr_rx0 : BUFR port map (
      I   => rgmii_rx_clk_0_delay,
      O   => rx_clk_0_i,
      CE  => '1',
      CLR => '0'
    );
    bufr_rx1 : BUFR port map (
      I   => rgmii_rx_clk_1_delay,
      O   => rx_clk_1_i,
      CE  => '1',
      CLR => '0'
    );
      
  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i    <=  tx_clk_0_o;
    rx_clk_0_i    <=  RGMII_RXC_0;
    rgmii_rx_clk_0_bufio <=  RGMII_RXC_0;
    tx_clk_1_i    <=  tx_clk_1_o;
    rx_clk_1_i    <=  RGMII_RXC_1;
    rgmii_rx_clk_1_bufio <=  RGMII_RXC_1;

  end generate IO_NO_01;

  I_EMAC0_TOP : entity xps_ll_temac_v2_03_a.v6_rgmii13_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
      )
    port map (
      -- TX Clock output
      TX_CLK_OUT                    => tx_clk_0_o,
      --  TX Clock input from BUFG
      TX_CLK                        => tx_clk_0_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE    => rx_enable_0_i,
      EMACCLIENTRXD            => rx_data_0_i,
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMACTXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in       
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out      
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out      
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in       
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out      
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out      
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      

      -- Receive-side PHY clock on regional buffer, to EMAC
      PHY_RX_CLK               => rx_clk_0_i,
 
      -- Reference clock
      GTX_CLK                 => GTX_CLK_0,                 --in            
 
      -- RGMII Interface
      RGMII_TXD               => RGMII_TXD_0,               --out
      RGMII_TX_CTL            => RGMII_TX_CTL_0,            --out
      RGMII_TXC               => RGMII_TXC_0,               --out
      RGMII_RXD               => RGMII_RXD_0,               --in 
      RGMII_RX_CTL            => RGMII_RX_CTL_0,            --in 
      RGMII_RXC               => rgmii_rx_clk_0_bufio,               --in 

      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out
                  
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => eMACDCRACK0,                --out 
      EMACDCRDBUS               => eMACDCRDBUS0,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR0,             --out 
        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

  I_EMAC1_TOP : entity xps_ll_temac_v2_03_a.v6_rgmii13_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC1_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC1_PHYADDR
      )
    port map (
      -- TX Clock output
      TX_CLK_OUT                    => tx_clk_1_o,
      --  TX Clock input from BUFG
      TX_CLK                        => tx_clk_1_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE    => rx_enable_1_i,
      EMACCLIENTRXD            => rx_data_1_i,
      EMACCLIENTRXDVLD         => rx_data_valid_1_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_1_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_1_i,
      EMACCLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out      
      EMACCLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out      
      EMACCLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out      
      EMACCLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE    => TX_CLIENT_CLK_ENABLE_1,
      CLIENTEMACTXD            => CLIENTEMAC1TXD,            --in       
      CLIENTEMACTXDVLD         => CLIENTEMAC1TXDVLD,         --in       
      EMACCLIENTTXACK          => EMAC1CLIENTTXACK,          --out      
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in       
      EMACCLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out      
      EMACCLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out      
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in       
      EMACCLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out      
      EMACCLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out      
      EMACCLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in      
      CLIENTEMACPAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in      

      -- Receive-side PHY clock on regional buffer, to EMAC
      PHY_RX_CLK               => rx_clk_1_i,
 
      -- Reference clock
      GTX_CLK                 => GTX_CLK_0,                 --in            
 
      -- RGMII Interface
      RGMII_TXD               => RGMII_TXD_1,               --out
      RGMII_TX_CTL            => RGMII_TX_CTL_1,            --out
      RGMII_TXC               => RGMII_TXC_1,               --out
      RGMII_RXD               => RGMII_RXD_1,               --in 
      RGMII_RX_CTL            => RGMII_RX_CTL_1,            --in 
      RGMII_RXC               => rgmii_rx_clk_1_bufio,               --in 

      -- MDIO Interface
      MDC                     => mDC_1_i,                   --out
      MDIO_I                  => MDIO_1_I,                  --in 
      MDIO_O                  => mDIO_1_O_i,                --out
      MDIO_T                  => mDIO_1_T_i,                --out
                  
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => eMACDCRDBUS0,               --in  
      EMACDCRACK                => eMACDCRACK1,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR1,             --out 
        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

  EMACDCRACK    <= eMACDCRACK0 or eMACDCRACK1;
  DCRHOSTDONEIR <= dCRHOSTDONEIR0 or dCRHOSTDONEIR1;
    
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
    
    -- *** PLEASE MODIFY THE IDELAY VALUE ACCORDING TO YOUR DESIGN ***
    -- The IDELAY value set here is tuned to this example design.
    -- For more information on IDELAYCTRL and IODELAY, please
    -- refer to the Virtex-6 User Guide.
    rgmii_rxc0_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      DELAY_SRC             => "I",
      SIGNAL_PATTERN        => "CLOCK",
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN    => RGMII_RXC_0,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rx_clk_0_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );

    
    -- Use the 2.5/25/125MHz reference clock from the EMAC
    -- to clock the transmit-side functions of the wrappers
    bufg_tx_0 : BUFG port map (
      I => tx_clk_0_o,
      O => tx_clk_0_i
    );

    -- Use a low-skew BUFIO on the delayed RX_CLK, which will be used in the
    -- RGMII phyical interface block to capture incoming data and control.
    bufg_rx_0 : BUFIO port map (
      I => rgmii_rx_clk_0_delay, 
      O => rgmii_rx_clk_0_bufio
    );

    -- Regionally-buffer the receive-side RGMII physical interface clock
    -- for use with receive-side functions of the EMAC
    bufr_rx0 : BUFR port map (
      I   => rgmii_rx_clk_0_delay,
      O   => rx_clk_0_i,
      CE  => '1',
      CLR => '0'
    );

  end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i    <=  tx_clk_0_o;
    rx_clk_0_i    <=  RGMII_RXC_0;
    rgmii_rx_clk_0_bufio <= RGMII_RXC_0;
  end generate IO_NO_01;

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v6_rgmii2_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
      )
    port map (
      -- TX Clock output
      TX_CLK_OUT                    => tx_clk_0_o,
      --  TX Clock input from BUFG
      TX_CLK                        => tx_clk_0_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE    => rx_enable_0_i,
      EMACCLIENTRXD            => rx_data_0_i,
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMACTXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in       
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out      
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out      
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in       
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out      
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out      
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      

      -- Receive-side PHY clock on regional buffer, to EMAC
      PHY_RX_CLK               => rx_clk_0_i,

      -- Reference clock
      GTX_CLK                 => GTX_CLK_0,                 --in            

      -- RGMII Interface
      RGMII_TXD               => RGMII_TXD_0,               --out
      RGMII_TX_CTL            => RGMII_TX_CTL_0,            --out
      RGMII_TXC               => RGMII_TXC_0,               --out
      RGMII_RXD               => RGMII_RXD_0,               --in 
      RGMII_RX_CTL            => RGMII_RX_CTL_0,            --in 
      RGMII_RXC               => rgmii_rx_clk_0_bufio,               --in 

      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out

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
    
    -- *** PLEASE MODIFY THE IDELAY VALUE ACCORDING TO YOUR DESIGN ***
    -- The IDELAY value set here is tuned to this example design.
    -- For more information on IDELAYCTRL and IODELAY, please
    -- refer to the Virtex-6 User Guide.
    rgmii_rxc0_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      DELAY_SRC             => "I",
      SIGNAL_PATTERN        => "CLOCK",
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN    => RGMII_RXC_0,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rx_clk_0_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );
    
    
    -- *** PLEASE MODIFY THE IDELAY VALUE ACCORDING TO YOUR DESIGN ***
    -- The IDELAY value set here is tuned to this example design.
    -- For more information on IDELAYCTRL and IODELAY, please
    -- refer to the Virtex-6 User Guide.
    rgmii_rxc1_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      DELAY_SRC             => "I",
      SIGNAL_PATTERN        => "CLOCK",
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN    => RGMII_RXC_1,
      ODATAIN    => '0',
      DATAOUT    => rgmii_rx_clk_1_delay,
      DATAIN     => '0',
      C          => '0',
      T          => '0',
      CE         => '0',
      INC        => '0',
      RST        => '0'
      );
    
    
    -- Use the 2.5/25/125MHz reference clock from the EMAC
    -- to clock the transmit-side functions of the wrappers
    bufg_tx_0 : BUFG port map (
      I => tx_clk_0_o,
      O => tx_clk_0_i
    );
    bufg_tx_1 : BUFG port map (
      I => tx_clk_1_o,
      O => tx_clk_1_i
    );

    -- Use a low-skew BUFIO on the delayed RX_CLK, which will be used in the
    -- RGMII phyical interface block to capture incoming data and control.
    bufg_rx_0 : BUFIO port map (
      I => rgmii_rx_clk_0_delay, 
      O => rgmii_rx_clk_0_bufio
    );
    bufg_rx_1 : BUFIO port map (
      I => rgmii_rx_clk_1_delay, 
      O => rgmii_rx_clk_1_bufio
    );

    -- Regionally-buffer the receive-side RGMII physical interface clock
    -- for use with receive-side functions of the EMAC
    bufr_rx0 : BUFR port map (
      I   => rgmii_rx_clk_0_delay,
      O   => rx_clk_0_i,
      CE  => '1',
      CLR => '0'
    );
    bufr_rx1 : BUFR port map (
      I   => rgmii_rx_clk_1_delay,
      O   => rx_clk_1_i,
      CE  => '1',
      CLR => '0'
    );

 end generate IO_YES_01;

  IO_NO_01: if(C_INCLUDE_IO = 0) generate  -- no Io
  begin
    tx_clk_0_i    <=  tx_clk_0_o;
    rx_clk_0_i    <=  RGMII_RXC_0;
    rgmii_rx_clk_0_bufio <= RGMII_RXC_0;
    tx_clk_1_i    <=  tx_clk_1_o;
    rx_clk_1_i    <=  RGMII_RXC_1;
    rgmii_rx_clk_1_bufio <= RGMII_RXC_1;

  end generate IO_NO_01;

  I_EMAC0_TOP : entity xps_ll_temac_v2_03_a.v6_rgmii2_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
      )
    port map (
      -- TX Clock output
      TX_CLK_OUT                    => tx_clk_0_o,
      --  TX Clock input from BUFG
      TX_CLK                        => tx_clk_0_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE    => rx_enable_0_i,
      EMACCLIENTRXD            => rx_data_0_i,
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_0_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_0_i,
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out      
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out      
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out      
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE    => TX_CLIENT_CLK_ENABLE_0,
      CLIENTEMACTXD            => CLIENTEMAC0TXD,            --in       
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,         --in       
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,          --out      
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in       
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out      
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out      
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in       
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out      
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out      
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      

      -- Receive-side PHY clock on regional buffer, to EMAC
      PHY_RX_CLK               => rx_clk_0_i,
            
      -- GTX Clock signal
      GTX_CLK                   => GTX_CLK_0,                 --in            
 
      -- RGMII Interface
      RGMII_TXD               => RGMII_TXD_0,               --out
      RGMII_TX_CTL            => RGMII_TX_CTL_0,            --out
      RGMII_TXC               => RGMII_TXC_0,               --out
      RGMII_RXD               => RGMII_RXD_0,               --in 
      RGMII_RX_CTL            => RGMII_RX_CTL_0,            --in 
      RGMII_RXC               => rgmii_rx_clk_0_bufio,               --in 

      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out
                  
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => eMACDCRACK0,                --out 
      EMACDCRDBUS               => eMACDCRDBUS0,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR0,             --out 
        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

  I_EMAC1_TOP : entity xps_ll_temac_v2_03_a.v6_rgmii2_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC1_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC1_PHYADDR
      )
    port map (
      -- TX Clock output
      TX_CLK_OUT                    => tx_clk_1_o,
      --  TX Clock input from BUFG
      TX_CLK                        => tx_clk_1_i,

      -- Client Receiver Interface
      RX_CLIENT_CLK_ENABLE     => rx_enable_1_i,
      EMACCLIENTRXD            => rx_data_1_i,
      EMACCLIENTRXDVLD         => rx_data_valid_1_i,
      EMACCLIENTRXGOODFRAME    => rx_good_frame_1_i,
      EMACCLIENTRXBADFRAME     => rx_bad_frame_1_i,
      EMACCLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out      
      EMACCLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out      
      EMACCLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out      
      EMACCLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out      

      -- Client Transmitter Interface
      TX_CLIENT_CLK_ENABLE    => TX_CLIENT_CLK_ENABLE_1,
      CLIENTEMACTXD            => CLIENTEMAC1TXD,            --in       
      CLIENTEMACTXDVLD         => CLIENTEMAC1TXDVLD,         --in       
      EMACCLIENTTXACK          => EMAC1CLIENTTXACK,          --out      
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in       
      EMACCLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out      
      EMACCLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out      
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in       
      EMACCLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out      
      EMACCLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out      
      EMACCLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out      

      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in      
      CLIENTEMACPAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in      

      -- Receive-side PHY clock on regional buffer, to EMAC
      PHY_RX_CLK               => rx_clk_1_i,
            
      -- GTX Clock signal
      GTX_CLK                   => GTX_CLK_0,                 --in            
 
      -- RGMII Interface
      RGMII_TXD               => RGMII_TXD_1,               --out
      RGMII_TX_CTL            => RGMII_TX_CTL_1,            --out
      RGMII_TXC               => RGMII_TXC_1,               --out
      RGMII_RXD               => RGMII_RXD_1,               --in 
      RGMII_RX_CTL            => RGMII_RX_CTL_1,            --in 
      RGMII_RXC               => rgmii_rx_clk_1_bufio,               --in 

      -- MDIO Interface
      MDC                     => mDC_1_i,                   --out
      MDIO_I                  => MDIO_1_I,                  --in 
      MDIO_O                  => mDIO_1_O_i,                --out
      MDIO_T                  => mDIO_1_T_i,                --out
                  
      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => eMACDCRDBUS0,               --in  
      EMACDCRACK                => eMACDCRACK1,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR1,             --out 
                   
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
    );

  EMACDCRACK    <= eMACDCRACK0 or eMACDCRACK1;
  DCRHOSTDONEIR <= dCRHOSTDONEIR0 or dCRHOSTDONEIR1;
    
end generate DUAL_RGMII2;

SINGLE_1000BASEX: if(C_PHY_TYPE = 5 and C_EMAC1_PRESENT = 0) generate  -- EMAC0 is 1000Base-X and EMAC1 is not used
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

    -- Generate the clock input to the transceiver
    -- (clk_ds can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    clkingen : IBUFDS_GTXE1 port map (
      I     => MGTCLK_P,
      IB    => MGTCLK_N,
      CEB   => '0',
      O     => clk_ds,
      ODIV2 => open
    );

    -- The 125MHz clock from the transceiver is routed through a BUFG and
    -- input to the MAC wrappers
    -- (clk125 can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    bufg_clk125 : BUFG port map (
      I => clk125_o,
      O => clk125
    );
    
    TX_CLIENT_CLK_0 <= clk125;
    RX_CLIENT_CLK_0 <= clk125;   
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
  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= '0';

  I_EMAC_TOP : entity xps_ll_temac_v2_03_a.v6_1000basex_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
                )
    port map (
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;

      -- Client Receiver Interface
      EMACCLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMACCLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMACCLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface
      CLIENTEMACTXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out

      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      

      --EMAC-MGT link status
      EMACCLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      --  Interrupt
      EMACANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;


      -- Clock Signals
      -- 1000BASE-X PCS/PMA Interface
      TXP                     => TXP_0,                     --out
      TXN                     => TXN_0,                     --out
      RXP                     => RXP_0,                     --in
      RXN                     => RXN_0,                     --in
      PHYAD                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE               => EMAC0ResetDoneInterrupt,             -- out std_logic;

      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out

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


        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
   );
end generate SINGLE_1000BASEX;

DUAL_1000BASEX: if(C_PHY_TYPE = 5 and C_EMAC1_PRESENT = 1) generate  -- EMAC0 & EMAC1 are 1000Base-X
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

    -- Generate the clock input to the transceiver
    -- (clk_ds can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    clkingen : IBUFDS_GTXE1 port map (
      I     => MGTCLK_P,
      IB    => MGTCLK_N,
      CEB   => '0',
      O     => clk_ds,
      ODIV2 => open
    );

    -- The 125MHz clock from the transceiver is routed through a BUFG and
    -- input to the MAC wrappers
    -- (clk125 can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    bufg_clk125 : BUFG port map (
      I => clk125_o,
      O => clk125
    );
    
    TX_CLIENT_CLK_0 <= clk125;
    RX_CLIENT_CLK_0 <= clk125;   
    
    TX_CLIENT_CLK_1 <= clk125;
    RX_CLIENT_CLK_1 <= clk125;   
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
  end generate IO_NO_01;

  EMAC0CLIENTANINTERRUPT <= eMAC0ANINTERRUPT_i;
  EMAC1CLIENTANINTERRUPT <= eMAC1ANINTERRUPT_i;

  I_EMAC0_TOP : entity xps_ll_temac_v2_03_a.v6_1000basex_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC0_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC0_PHYADDR
                )
    port map (
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;

      -- Client Receiver Interface
      EMACCLIENTRXD            => EMAC0CLIENTRXD,            --out
      EMACCLIENTRXDVLD         => rx_data_valid_0_i,         --out
      EMACCLIENTRXGOODFRAME    => EMAC0CLIENTRXGOODFRAME,    --out
      EMACCLIENTRXBADFRAME     => EMAC0CLIENTRXBADFRAME,     --out
      EMACCLIENTRXFRAMEDROP    => EMAC0CLIENTRXFRAMEDROP,    --out
      EMACCLIENTRXSTATS        => EMAC0CLIENTRXSTATS,        --out
      EMACCLIENTRXSTATSVLD     => EMAC0CLIENTRXSTATSVLD,     --out
      EMACCLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface
      CLIENTEMACTXD            => CLIENTEMAC0TXD,            --in 
      CLIENTEMACTXDVLD         => CLIENTEMAC0TXDVLD,         --in 
      EMACCLIENTTXACK          => EMAC0CLIENTTXACK,          --out
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC0TXUNDERRUN,     --in 
      EMACCLIENTTXCOLLISION    => EMAC0CLIENTTXCOLLISION,    --out
      EMACCLIENTTXRETRANSMIT   => EMAC0CLIENTTXRETRANSMIT,   --out
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC0TXIFGDELAY,     --in 
      EMACCLIENTTXSTATS        => EMAC0CLIENTTXSTATS,        --out
      EMACCLIENTTXSTATSVLD     => EMAC0CLIENTTXSTATSVLD,     --out
      EMACCLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD, --out

      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC0PAUSEREQ,       --in      
      CLIENTEMACPAUSEVAL       => CLIENTEMAC0PAUSEVAL,       --in      

      --EMAC-MGT link status
      EMACCLIENTSYNCACQSTATUS  => eMAC0CLIENTSYNCACQSTATUS_i,-- out std_logic;
      --  Interrupt
      EMACANINTERRUPT          => eMAC0ANINTERRUPT_i,        -- out std_logic;

 
      -- Clock Signals
      -- 1000BASE-X PCS/PMA Interface
      TXP                     => TXP_0,                     --out
      TXN                     => TXN_0,                     --out
      RXP                     => RXP_0,                     --in
      RXN                     => RXN_0,                     --in
      PHYAD                   => C_TEMAC0_PHYADDR,          --in
      RESETDONE               => EMAC0ResetDoneInterrupt,             -- out std_logic;

      -- MDIO Interface
      MDC                     => mDC_0_i,                   --out
      MDIO_I                  => MDIO_0_I,                  --in 
      MDIO_O                  => mDIO_0_O_i,                --out
      MDIO_T                  => mDIO_0_T_i,                --out

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => DCREMACDBUS,               --in  
      EMACDCRACK                => eMACDCRACK0,                --out 
      EMACDCRDBUS               => eMACDCRDBUS0,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR0,             --out 

      -- 1000BASE-X PCS/PMA RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in


        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
   );

  I_EMAC1_TOP : entity xps_ll_temac_v2_03_a.v6_1000basex_top(TOP_LEVEL)
    generic map (
      C_INCLUDE_IO        => C_INCLUDE_IO,
      C_EMAC_DCRBASEADDR  => C_EMAC1_DCRBASEADDR,
      C_TEMAC_PHYADDR     => C_TEMAC1_PHYADDR
                )
    port map (
      -- 125MHz clock output from transceiver
      CLK125_OUT                => clk125_o,              -- out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                    => clk125,                  -- in  std_logic;

      -- Client Receiver Interface
      EMACCLIENTRXD            => EMAC1CLIENTRXD,            --out
      EMACCLIENTRXDVLD         => rx_data_valid_1_i,         --out
      EMACCLIENTRXGOODFRAME    => EMAC1CLIENTRXGOODFRAME,    --out
      EMACCLIENTRXBADFRAME     => EMAC1CLIENTRXBADFRAME,     --out
      EMACCLIENTRXFRAMEDROP    => EMAC1CLIENTRXFRAMEDROP,    --out
      EMACCLIENTRXSTATS        => EMAC1CLIENTRXSTATS,        --out
      EMACCLIENTRXSTATSVLD     => EMAC1CLIENTRXSTATSVLD,     --out
      EMACCLIENTRXSTATSBYTEVLD => EMAC1CLIENTRXSTATSBYTEVLD, --out

      -- Client Transmitter Interface
      CLIENTEMACTXD            => CLIENTEMAC1TXD,            --in 
      CLIENTEMACTXDVLD         => CLIENTEMAC1TXDVLD,         --in 
      EMACCLIENTTXACK          => EMAC1CLIENTTXACK,          --out
      CLIENTEMACTXFIRSTBYTE    => '0',                       --in
      CLIENTEMACTXUNDERRUN     => CLIENTEMAC1TXUNDERRUN,     --in 
      EMACCLIENTTXCOLLISION    => EMAC1CLIENTTXCOLLISION,    --out
      EMACCLIENTTXRETRANSMIT   => EMAC1CLIENTTXRETRANSMIT,   --out
      CLIENTEMACTXIFGDELAY     => CLIENTEMAC1TXIFGDELAY,     --in 
      EMACCLIENTTXSTATS        => EMAC1CLIENTTXSTATS,        --out
      EMACCLIENTTXSTATSVLD     => EMAC1CLIENTTXSTATSVLD,     --out
      EMACCLIENTTXSTATSBYTEVLD => EMAC1CLIENTTXSTATSBYTEVLD, --out

      -- MAC Control Interface
      CLIENTEMACPAUSEREQ       => CLIENTEMAC1PAUSEREQ,       --in      
      CLIENTEMACPAUSEVAL       => CLIENTEMAC1PAUSEVAL,       --in      

      --EMAC-MGT link status
      EMACCLIENTSYNCACQSTATUS  => eMAC1CLIENTSYNCACQSTATUS_i,-- out std_logic;
      --  Interrupt
      EMACANINTERRUPT          => eMAC1ANINTERRUPT_i,        -- out std_logic;

 
      -- Clock Signals
      -- 1000BASE-X PCS/PMA Interface
      TXP                     => TXP_1,                     --out
      TXN                     => TXN_1,                     --out
      RXP                     => RXP_1,                     --in
      RXN                     => RXN_1,                     --in
      PHYAD                   => C_TEMAC1_PHYADDR,          --in
      RESETDONE               => EMAC1ResetDoneInterrupt,             -- out std_logic;

      -- MDIO Interface
      MDC                     => mDC_1_i,                   --out
      MDIO_I                  => MDIO_1_I,                  --in 
      MDIO_O                  => mDIO_1_O_i,                --out
      MDIO_T                  => mDIO_1_T_i,                --out

      -- DCR Interface
      HOSTCLK                   => HOSTCLK,                   --in      
      DCREMACCLK                => DCREMACCLK,                --in  
      DCREMACABUS               => DCREMACABUS,               --in  
      DCREMACREAD               => DCREMACREAD,               --in  
      DCREMACWRITE              => DCREMACWRITE,              --in  
      DCREMACDBUS               => eMACDCRDBUS0,               --in  
      EMACDCRACK                => eMACDCRACK1,                --out 
      EMACDCRDBUS               => EMACDCRDBUS,               --out 
      DCREMACENABLE             => DCREMACENABLE,             --in  
      DCRHOSTDONEIR             => dCRHOSTDONEIR1,             --out 

      -- 1000BASE-X PCS/PMA RocketIO Reference Clock buffer inputs 
      CLK_DS                    => clk_ds,                  --in


        
      -- Asynchronous Reset
      RESET                     => RESET                      --in      
   );

  EMACDCRACK    <= eMACDCRACK0 or eMACDCRACK1;
  DCRHOSTDONEIR <= dCRHOSTDONEIR0 or dCRHOSTDONEIR1;
    
end generate DUAL_1000BASEX;

end imp;
