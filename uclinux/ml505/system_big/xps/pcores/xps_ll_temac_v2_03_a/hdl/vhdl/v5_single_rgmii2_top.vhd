------------------------------------------------------------------------------
-- $Id: v5_single_rgmii2_top.vhd,v 1.1.4.39 2009/11/17 07:11:37 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : Virtex-5 Ethernet MAC Wrapper Top Level
-- Project    : Virtex-5 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v5_single_rgmii2_top.vhd
-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
-- Description:  This is the EMAC block level VHDL design for the Virtex-5 
--               Embedded Ethernet MAC Example Design.  It is intended that
--               this example design can be quickly adapted and downloaded onto
--               an FPGA to provide a real hardware test environment.
--
--               The block level:
--
--               * instantiates all clock management logic required (BUFGs, 
--                 DCMs) to operate the EMAC and its example design;
--
--               * instantiates appropriate PHY interface modules (GMII, MII,
--                 RGMII, SGMII or 1000BASE-X) as required based on the user
--                 configuration.
--
--
--               Please refer to the Datasheet, Getting Started Guide, and
--               the Virtex-5 Embedded Tri-Mode Ethernet MAC User Gude for
--               further information.
--
--               This is based on Coregen Wrappers from ISE K (10.1i)
--               Wrapper version 1.4
-------------------------------------------------------------------------------


library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

-------------------------------------------------------------------------------
-- The entity declaration for the top level design.
-------------------------------------------------------------------------------
entity v5_single_rgmii2_top is
  generic (
           C_INCLUDE_IO                : integer          := 1;
           C_EMAC0_DCRBASEADDR         : bit_vector       := "0000000000";
           C_EMAC1_DCRBASEADDR         : bit_vector       := "0000000000";
           C_TEMAC0_PHYADDR            : std_logic_vector(4 downto 0) := "00001";
           C_TEMAC1_PHYADDR            : std_logic_vector(4 downto 0) := "00010"
          );
   port(
      -- EMAC0 Clocking
      -- TX Clock output from EMAC0
      TX_CLK_OUT_0                    : out std_logic;
      -- EMAC0 TX Clock input from BUFG
      TX_CLK_0                        : in  std_logic;

      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_ENABLE_0          : out std_logic;
      EMAC0CLIENTRXD                  : out std_logic_vector(7 downto 0);
      EMAC0CLIENTRXDVLD               : out std_logic;
      EMAC0CLIENTRXGOODFRAME          : out std_logic;
      EMAC0CLIENTRXBADFRAME           : out std_logic;
      EMAC0CLIENTRXFRAMEDROP          : out std_logic;
      EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSVLD           : out std_logic;
      EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_ENABLE_0          : out std_logic;
      CLIENTEMAC0TXD                  : in  std_logic_vector(7 downto 0);
      CLIENTEMAC0TXDVLD               : in  std_logic;
      EMAC0CLIENTTXACK                : out std_logic;
      CLIENTEMAC0TXFIRSTBYTE          : in  std_logic;
      CLIENTEMAC0TXUNDERRUN           : in  std_logic;
      EMAC0CLIENTTXCOLLISION          : out std_logic;
      EMAC0CLIENTTXRETRANSMIT         : out std_logic;
      CLIENTEMAC0TXIFGDELAY           : in  std_logic_vector(7 downto 0);
      EMAC0CLIENTTXSTATS              : out std_logic;
      EMAC0CLIENTTXSTATSVLD           : out std_logic;
      EMAC0CLIENTTXSTATSBYTEVLD       : out std_logic;

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ             : in  std_logic;
      CLIENTEMAC0PAUSEVAL             : in  std_logic_vector(15 downto 0);

 
      -- Clock Signals - EMAC0
      GTX_CLK_0                       : in  std_logic;
      -- RGMII Interface - EMAC0
      RGMII_TXD_0                     : out std_logic_vector(3 downto 0);
      RGMII_TX_CTL_0                  : out std_logic;
      RGMII_TXC_0                     : out std_logic;
      RGMII_RXD_0                     : in  std_logic_vector(3 downto 0);
      RGMII_RX_CTL_0                  : in  std_logic;
      RGMII_RXC_0                     : in  std_logic;

      -- MDIO Interface - EMAC0
      MDC_0                           : out std_logic;
      MDIO_0_I                        : in  std_logic;
      MDIO_0_O                        : out std_logic;
      MDIO_0_T                        : out std_logic;

      -- DCR Interface
      HOSTCLK                         : in  std_logic;
      DCREMACCLK                      : in  std_logic;
      DCREMACABUS                     : in  std_logic_vector(0 to 9);
      DCREMACREAD                     : in  std_logic;
      DCREMACWRITE                    : in  std_logic;
      DCREMACDBUS                     : in  std_logic_vector(0 to 31);
      EMACDCRACK                      : out std_logic;
      EMACDCRDBUS                     : out std_logic_vector(0 to 31);
      DCREMACENABLE                   : in  std_logic;
      DCRHOSTDONEIR                   : out std_logic;

        
        
      -- Asynchronous Reset
      RESET                           : in  std_logic
   );
end v5_single_rgmii2_top;


architecture TOP_LEVEL of v5_single_rgmii2_top is





-------------------------------------------------------------------------------
-- Signal Declarations
-------------------------------------------------------------------------------

    --  Power and ground signals
    signal gnd_i                          : std_logic;
    signal vcc_i                          : std_logic;

    -- Asynchronous reset signals
    signal reset_ibuf_i                   : std_logic;
    signal reset_i                        : std_logic;
    signal reset_r                        : std_logic_vector(3 downto 0);

    -- EMAC0 Client Clocking Signals
    signal rx_client_clk_out_0_i          : std_logic;
    signal rx_client_clk_in_0_i           : std_logic;
    signal tx_client_clk_out_0_i          : std_logic;
    signal tx_client_clk_in_0_i           : std_logic;
    signal tx_enable_0_i                  : std_logic;
    signal tx_enable_0_pre_r              : std_logic;
    signal tx_enable_0_r                  : std_logic;
    signal rx_enable_0_i                  : std_logic;
    signal rx_enable_0_pre_r              : std_logic;
    signal rx_enable_0_r                  : std_logic;
    -- EMAC0 Physical Interface Clocking Signals
    signal tx_gmii_mii_clk_out_0_i        : std_logic;
    signal tx_gmii_mii_clk_in_0_i         : std_logic;
    -- EMAC0 TX acknowledge signals 
    signal tx_client_ack_0_r              : std_logic;
    signal tx_client_ack_0_i              : std_logic;
    -- EMAC0 Physical Interface Signals
    signal rgmii_txc_0_i                  : std_logic;
    signal rgmii_txd_rising_0_i           : std_logic_vector(3 downto 0);
    signal rgmii_txd_falling_0_i          : std_logic_vector(3 downto 0);
    signal rgmii_tx_ctl_rising_0_i        : std_logic;
    signal rgmii_tx_ctl_falling_0_i       : std_logic;
    signal rgmii_rxc_0_i                  : std_logic;
    signal rgmii_rxd_rising_0_i           : std_logic_vector(3 downto 0);
    signal rgmii_rxd_falling_0_i          : std_logic_vector(3 downto 0);
    signal rgmii_rx_ctl_rising_0_i        : std_logic;
    signal rgmii_rx_ctl_falling_0_i       : std_logic;




    -- 125MHz reference clock for EMAC0
    signal gtx_clk_ibufg_0_i              : std_logic;

    -- EMAC0 MDIO signals
    signal mdc_out_0_i                    : std_logic;
    signal mdio_in_0_i                    : std_logic;
    signal mdio_out_0_i                   : std_logic;
    signal mdio_tri_0_i                   : std_logic;

    -- Speed output from EMAC0 for physical interface clocking
    signal speed_vector_0_i               : std_logic_vector(1 downto 0);
    signal speed_vector_0_int             : std_logic;


-------------------------------------------------------------------------------
-- Attribute Declarations 
-------------------------------------------------------------------------------

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of tx_enable_0_pre_r : signal is "TRUE";
  attribute ASYNC_REG of rx_enable_0_pre_r : signal is "TRUE";


-------------------------------------------------------------------------------
-- Main Body of Code
-------------------------------------------------------------------------------

begin

    gnd_i     <= '0';
    vcc_i     <= '1';

    ---------------------------------------------------------------------------
    -- Main Reset Circuitry
    ---------------------------------------------------------------------------
    reset_ibuf_i <= RESET;

    reset_i <= reset_ibuf_i;

    ---------------------------------------------------------------------------
    -- RGMII version 2.0 circuitry for the Physical Interface of EMAC0
    ---------------------------------------------------------------------------

    rgmii0 : entity xps_ll_temac_v2_03_a.v5_rgmii2_if(PHY_IF)
    generic map (
        C_INCLUDE_IO            => C_INCLUDE_IO)
    port map (
        RESET                         => reset_i,
        RGMII_TXD                     => RGMII_TXD_0,
        RGMII_TX_CTL                  => RGMII_TX_CTL_0,
        RGMII_TXC                     => RGMII_TXC_0,
        RGMII_RXD                     => RGMII_RXD_0,
        RGMII_RX_CTL                  => RGMII_RX_CTL_0,
        TXD_RISING_FROM_MAC           => rgmii_txd_rising_0_i,
        TXD_FALLING_FROM_MAC          => rgmii_txd_falling_0_i,
        TX_CTL_RISING_FROM_MAC        => rgmii_tx_ctl_rising_0_i,
        TX_CTL_FALLING_FROM_MAC       => rgmii_tx_ctl_falling_0_i,
        TX_CLK                        => tx_gmii_mii_clk_in_0_i,
        RXD_RISING_TO_MAC             => rgmii_rxd_rising_0_i,
        RXD_FALLING_TO_MAC            => rgmii_rxd_falling_0_i,
        RX_CTL_RISING_TO_MAC          => rgmii_rx_ctl_rising_0_i,
        RX_CTL_FALLING_TO_MAC         => rgmii_rx_ctl_falling_0_i,
        RX_CLK                        => rgmii_rxc_0_i);

 
    --------------------------------------------------------------------------
    -- GTX_CLK Clock Management - 125 MHz clock frequency supplied by the user
    -- (Connected to PHYEMAC#GTXCLK of the EMAC primitive)
    --------------------------------------------------------------------------
    gtx_clk_ibufg_0_i <= GTX_CLK_0;




    --------------------------------------------------------------------------
    -- Transmitter ACK register for EMAC0
    --------------------------------------------------------------------------
    
    -- Register TX ACK signal on the TX clock
    tx_client_ack_0_pr : process(tx_gmii_mii_clk_in_0_i, reset_i)
    begin
        if reset_i = '1' then
            tx_client_ack_0_r <= '0';
        elsif tx_gmii_mii_clk_in_0_i'event and tx_gmii_mii_clk_in_0_i = '1' then
            tx_client_ack_0_r <= tx_client_ack_0_i;
        end if;
    end process tx_client_ack_0_pr;

    -- Mux depending on speed
    tx_client_ack_sel_0_pr : process(tx_client_ack_0_r, tx_client_ack_0_i, speed_vector_0_int)
    begin
      if speed_vector_0_int = '1' then
        EMAC0CLIENTTXACK <= tx_client_ack_0_r;
      else
        EMAC0CLIENTTXACK <= tx_client_ack_0_i;
      end if;
    end process tx_client_ack_sel_0_pr;



    ------------------------------------------------------------------------
    -- RGMII PHY side transmit clock for EMAC0
    ------------------------------------------------------------------------
    tx_gmii_mii_clk_in_0_i <= TX_CLK_0;
 
    
    ------------------------------------------------------------------------
    -- RGMII PHY side Receiver Clock for EMAC0
    ------------------------------------------------------------------------
    rgmii_rxc_0_i <= RGMII_RXC_0;    

    ------------------------------------------------------------------------
    -- RGMII client side transmit clock for EMAC0
    ------------------------------------------------------------------------
    tx_client_clk_in_0_i <= TX_CLK_0;

    ------------------------------------------------------------------------
    -- RGMII client side receive clock for EMAC0
    ------------------------------------------------------------------------
    rx_client_clk_in_0_i <= rgmii_rxc_0_i;
    ------------------------------------------------------------------------
    -- Connect previously derived client clocks to example design output ports
    ------------------------------------------------------------------------
    -- EMAC0 Clocking
    -- TX Clock output from EMAC0
    TX_CLK_OUT_0              <= tx_gmii_mii_clk_out_0_i;


    TX_CLIENT_CLK_ENABLE_0 <= tx_enable_0_r;
    RX_CLIENT_CLK_ENABLE_0 <= rx_enable_0_r;

    -- Register the enable signal to cope with any meta-stability
    -- during a speed change.
    tx_en_0_pr : process(tx_gmii_mii_clk_in_0_i, reset_i)
    begin
        if reset_i = '1' then
            tx_enable_0_pre_r           <= '0';
            tx_enable_0_r               <= '0';
        elsif tx_gmii_mii_clk_in_0_i'event and tx_gmii_mii_clk_in_0_i = '1' then
            tx_enable_0_pre_r           <= tx_enable_0_i after 1 ps;
            tx_enable_0_r               <= tx_enable_0_pre_r after 1 ps;
        end if;
    end process tx_en_0_pr;

    rx_en_0_pr : process(rgmii_rxc_0_i, reset_i)
    begin
        if reset_i = '1' then
            rx_enable_0_pre_r           <= '0';
            rx_enable_0_r               <= '0';
        elsif rgmii_rxc_0_i'event and rgmii_rxc_0_i = '1' then
            rx_enable_0_pre_r           <= rx_enable_0_i after 1 ps;
            rx_enable_0_r               <= rx_enable_0_pre_r after 1 ps;
        end if;
    end process rx_en_0_pr;

 

    --------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper (single_rgmii2.vhd)
    --------------------------------------------------------------------------
    v5_emac_wrapper : entity xps_ll_temac_v2_03_a.v5_single_rgmii2(WRAPPER)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
                 C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
        -- Client Receiver Interface - EMAC0
        EMAC0CLIENTRXCLIENTCLKOUT       => rx_enable_0_i,
        CLIENTEMAC0RXCLIENTCLKIN        => gnd_i,
        EMAC0CLIENTRXD                  => EMAC0CLIENTRXD,
        EMAC0CLIENTRXDVLD               => EMAC0CLIENTRXDVLD,
        EMAC0CLIENTRXDVLDMSW            => open,
        EMAC0CLIENTRXGOODFRAME          => EMAC0CLIENTRXGOODFRAME,
        EMAC0CLIENTRXBADFRAME           => EMAC0CLIENTRXBADFRAME,
        EMAC0CLIENTRXFRAMEDROP          => EMAC0CLIENTRXFRAMEDROP,
        EMAC0CLIENTRXSTATS              => EMAC0CLIENTRXSTATS,
        EMAC0CLIENTRXSTATSVLD           => EMAC0CLIENTRXSTATSVLD,
        EMAC0CLIENTRXSTATSBYTEVLD       => EMAC0CLIENTRXSTATSBYTEVLD,

        -- Client Transmitter Interface - EMAC0
        EMAC0CLIENTTXCLIENTCLKOUT       => tx_enable_0_i,
        CLIENTEMAC0TXCLIENTCLKIN        => gnd_i,
        CLIENTEMAC0TXD                  => CLIENTEMAC0TXD,
        CLIENTEMAC0TXDVLD               => CLIENTEMAC0TXDVLD,
        CLIENTEMAC0TXDVLDMSW            => gnd_i,
        EMAC0CLIENTTXACK                => tx_client_ack_0_i,
        CLIENTEMAC0TXFIRSTBYTE          => CLIENTEMAC0TXFIRSTBYTE,
        CLIENTEMAC0TXUNDERRUN           => CLIENTEMAC0TXUNDERRUN,
        EMAC0CLIENTTXCOLLISION          => EMAC0CLIENTTXCOLLISION,
        EMAC0CLIENTTXRETRANSMIT         => EMAC0CLIENTTXRETRANSMIT,
        CLIENTEMAC0TXIFGDELAY           => CLIENTEMAC0TXIFGDELAY,
        EMAC0CLIENTTXSTATS              => EMAC0CLIENTTXSTATS,
        EMAC0CLIENTTXSTATSVLD           => EMAC0CLIENTTXSTATSVLD,
        EMAC0CLIENTTXSTATSBYTEVLD       => EMAC0CLIENTTXSTATSBYTEVLD,

        -- MAC Control Interface - EMAC0
        CLIENTEMAC0PAUSEREQ             => CLIENTEMAC0PAUSEREQ,
        CLIENTEMAC0PAUSEVAL             => CLIENTEMAC0PAUSEVAL,

        -- Clock Signals - EMAC0
        GTX_CLK_0                       => gtx_clk_ibufg_0_i,

        EMAC0PHYTXGMIIMIICLKOUT         => tx_gmii_mii_clk_out_0_i,
        PHYEMAC0TXGMIIMIICLKIN          => tx_gmii_mii_clk_in_0_i,

        -- RGMII Interface - EMAC0
        RGMII_TXD_RISING_0              => rgmii_txd_rising_0_i,
        RGMII_TXD_FALLING_0             => rgmii_txd_falling_0_i,
        RGMII_TX_CTL_RISING_0           => rgmii_tx_ctl_rising_0_i,
        RGMII_TX_CTL_FALLING_0          => rgmii_tx_ctl_falling_0_i,
        RGMII_TXC_0                     => rgmii_txc_0_i,
        RGMII_RXD_RISING_0              => rgmii_rxd_rising_0_i,
        RGMII_RXD_FALLING_0             => rgmii_rxd_falling_0_i,
        RGMII_RX_CTL_RISING_0           => rgmii_rx_ctl_rising_0_i,
        RGMII_RX_CTL_FALLING_0          => rgmii_rx_ctl_falling_0_i,
        RGMII_RXC_0                     => rgmii_rxc_0_i,

        -- MDIO Interface - EMAC0
        MDC_0                           => mdc_out_0_i,
        MDIO_0_I                        => mdio_in_0_i,
        MDIO_0_O                        => mdio_out_0_i,
        MDIO_0_T                        => mdio_tri_0_i,

        EMAC0SPEEDIS10100               => speed_vector_0_int,

        -- DCR Interface
        HOSTCLK                         => HOSTCLK,
        DCREMACCLK                      => DCREMACCLK,
        DCREMACABUS                     => DCREMACABUS,
        DCREMACREAD                     => DCREMACREAD,
        DCREMACWRITE                    => DCREMACWRITE,
        DCREMACDBUS                     => DCREMACDBUS,
        EMACDCRACK                      => EMACDCRACK,
        EMACDCRDBUS                     => EMACDCRDBUS,
        DCREMACENABLE                   => DCREMACENABLE,
        DCRHOSTDONEIR                   => DCRHOSTDONEIR,

        DCM_LOCKED_0                    => vcc_i,

        -- Asynchronous Reset
        RESET                           => reset_i
        );

  
  ----------------------------------------------------------------------
  -- MDIO interface for EMAC0 
  ----------------------------------------------------------------------  
  -- This example keeps the mdio_in, mdio_out, mdio_tri signals as
  -- separate connections: these could be connected to an external
  -- Tri-state buffer.  Alternatively they could be connected to a 
  -- Tri-state buffer in a Xilinx IOB and an appropriate SelectIO
  -- standard chosen.

  MDC_0       <= mdc_out_0_i;
  mdio_in_0_i <= MDIO_0_I;
  MDIO_0_O    <= mdio_out_0_i;
  MDIO_0_T    <= mdio_tri_0_i;


 


 
end TOP_LEVEL;