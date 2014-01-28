------------------------------------------------------------------------------
-- $Id: v5_single_mii_top.vhd,v 1.1.4.39 2009/11/17 07:11:37 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : Virtex-5 Ethernet MAC Wrapper Top Level
-- Project    : Virtex-5 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v5_single_mii_top.vhd
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
entity v5_single_mii_top is
  generic (
           C_INCLUDE_IO                : integer          := 1;
           C_EMAC0_DCRBASEADDR         : bit_vector       := "0000000000";
           C_EMAC1_DCRBASEADDR         : bit_vector       := "0000000000";
           C_TEMAC0_PHYADDR            : std_logic_vector(4 downto 0) := "00001";
           C_TEMAC1_PHYADDR            : std_logic_vector(4 downto 0) := "00010"
          );
   port(
      -- EMAC0 Clocking
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
      -- MII Interface - EMAC0
      MII_TXD_0                       : out std_logic_vector(3 downto 0);
      MII_TX_EN_0                     : out std_logic;
      MII_TX_ER_0                     : out std_logic;
      MII_TX_CLK_0                    : in  std_logic;
      MII_RXD_0                       : in  std_logic_vector(3 downto 0);
      MII_RX_DV_0                     : in  std_logic;
      MII_RX_ER_0                     : in  std_logic;
      MII_RX_CLK_0                    : in  std_logic;

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
end v5_single_mii_top;


architecture TOP_LEVEL of v5_single_mii_top is





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
    signal mii_tx_clk_0_i                 : std_logic;
    signal mii_tx_en_0_i                  : std_logic;
    signal mii_tx_er_0_i                  : std_logic;
    signal mii_txd_0_i                    : std_logic_vector(3 downto 0);
    signal mii_rx_clk_0_i                 : std_logic;
    signal mii_rx_dv_0_r                  : std_logic;
    signal mii_rx_er_0_r                  : std_logic;
    signal mii_rxd_0_r                    : std_logic_vector(3 downto 0);




    -- EMAC0 MDIO signals
    signal mdc_out_0_i                    : std_logic;
    signal mdio_in_0_i                    : std_logic;
    signal mdio_out_0_i                   : std_logic;
    signal mdio_tri_0_i                   : std_logic;


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
    -- MII circuitry for the Physical Interface of EMAC0
    ---------------------------------------------------------------------------

    mii0 : entity xps_ll_temac_v2_03_a.v5_mii_if(PHY_IF)
    generic map (
        C_INCLUDE_IO            => C_INCLUDE_IO)
    port map (
        RESET                         => reset_i,
        MII_TXD                       => MII_TXD_0,
        MII_TX_EN                     => MII_TX_EN_0,
        MII_TX_ER                     => MII_TX_ER_0,
        MII_RXD                       => MII_RXD_0,
        MII_RX_DV                     => MII_RX_DV_0,
        MII_RX_ER                     => MII_RX_ER_0,
        TXD_FROM_MAC                  => mii_txd_0_i,
        TX_EN_FROM_MAC                => mii_tx_en_0_i,
        TX_ER_FROM_MAC                => mii_tx_er_0_i,
        TX_CLK                        => tx_gmii_mii_clk_in_0_i,
        RXD_TO_MAC                    => mii_rxd_0_r,
        RX_DV_TO_MAC                  => mii_rx_dv_0_r,
        RX_ER_TO_MAC                  => mii_rx_er_0_r,
        RX_CLK                        => mii_rx_clk_0_i);


 


    ------------------------------------------------------------------------
    -- MII PHY side transmit clock for EMAC0
    ------------------------------------------------------------------------
    tx_gmii_mii_clk_in_0_i <= TX_CLK_0;
 
    
    ------------------------------------------------------------------------
    -- MII PHY side Receiver Clock for EMAC0
    ------------------------------------------------------------------------
    mii_rx_clk_0_i <= MII_RX_CLK_0;    

    ------------------------------------------------------------------------
    -- MII client side transmit clock for EMAC0
    ------------------------------------------------------------------------
    tx_client_clk_in_0_i <= TX_CLK_0;

    ------------------------------------------------------------------------
    -- MII client side receive clock for EMAC0
    ------------------------------------------------------------------------
    rx_client_clk_in_0_i <= mii_rx_clk_0_i;

    ------------------------------------------------------------------------
    -- MII Transmitter Clock for EMAC0
    ------------------------------------------------------------------------
    mii_tx_clk_0_i <= MII_TX_CLK_0;

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
    tx_client_ack_sel_0_pr : process(tx_client_ack_0_r)
    begin
        EMAC0CLIENTTXACK <= tx_client_ack_0_r;
    end process tx_client_ack_sel_0_pr;




    ------------------------------------------------------------------------
    -- Connect previously derived client clocks to example design output ports
    ------------------------------------------------------------------------
    -- EMAC0 Clocking


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

    rx_en_0_pr : process(mii_rx_clk_0_i, reset_i)
    begin
        if reset_i = '1' then
            rx_enable_0_pre_r           <= '0';
            rx_enable_0_r               <= '0';
        elsif mii_rx_clk_0_i'event and mii_rx_clk_0_i = '1' then
            rx_enable_0_pre_r           <= rx_enable_0_i after 1 ps;
            rx_enable_0_r               <= rx_enable_0_pre_r after 1 ps;
        end if;
    end process rx_en_0_pr;

 

    --------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper (single_mii.vhd)
    --------------------------------------------------------------------------
    v5_emac_wrapper : entity xps_ll_temac_v2_03_a.v5_single_mii(WRAPPER)
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
        GTX_CLK_0                       => gnd_i,

        EMAC0PHYTXGMIIMIICLKOUT         => tx_gmii_mii_clk_out_0_i,
        PHYEMAC0TXGMIIMIICLKIN          => tx_gmii_mii_clk_in_0_i,

        -- MII Interface - EMAC0
        MII_TXD_0                       => mii_txd_0_i,
        MII_TX_EN_0                     => mii_tx_en_0_i,
        MII_TX_ER_0                     => mii_tx_er_0_i,
        MII_TX_CLK_0                    => mii_tx_clk_0_i,
        MII_RXD_0                       => mii_rxd_0_r,
        MII_RX_DV_0                     => mii_rx_dv_0_r,
        MII_RX_ER_0                     => mii_rx_er_0_r,
        MII_RX_CLK_0                    => mii_rx_clk_0_i,

        -- MDIO Interface - EMAC0
        MDC_0                           => mdc_out_0_i,
        MDIO_0_I                        => mdio_in_0_i,
        MDIO_0_O                        => mdio_out_0_i,
        MDIO_0_T                        => mdio_tri_0_i,

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
