------------------------------------------------------------------------------
-- $Id: v6_mii_top.vhd,v 1.1.4.39 2009/11/17 07:11:38 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : Virtex-6 Ethernet MAC Wrapper Top Level
-- Project    : Virtex-6 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v6_mii_top.vhd
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
-- Description:  This is the EMAC block level VHDL design for the Virtex-6
--               Tri-Mode Ethernet MAC. It is intended that this example design
--               can be quickly adapted and downloaded onto an FPGA to provide
--               a hardware test environment.
--
--               The block-level wrapper:
--
--               * instantiates appropriate PHY interface modules (GMII, MII,
--                 RGMII, SGMII or 1000BASE-X) as required per the user
--                 configuration;
--
--               * instantiates some clocking and reset resources to operate
--                 the EMAC and its example design.
--
--               Please refer to the Datasheet, Getting Started Guide, and
--               the Virtex-6 Embedded Tri-Mode Ethernet MAC User Gude for
--               further information.
--
--               This is based on Coregen Wrappers from ISE L (11.3i)
--               Wrapper version 1.3
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
entity v6_mii_top is
  generic (
           C_INCLUDE_IO                : integer          := 1;
           C_EMAC_DCRBASEADDR         : bit_vector       := "0000000000";
           C_TEMAC_PHYADDR            : std_logic_vector(4 downto 0) := "00010"
          );
   port(

      -- TX clock input from BUFG
      TX_CLK                   : in  std_logic;

      -- Client receiver interface
      RX_CLIENT_CLK_ENABLE     : out std_logic;
      EMACCLIENTRXD            : out std_logic_vector(7 downto 0);
      EMACCLIENTRXDVLD         : out std_logic;
      EMACCLIENTRXGOODFRAME    : out std_logic;
      EMACCLIENTRXBADFRAME     : out std_logic;
      EMACCLIENTRXFRAMEDROP    : out std_logic;
      EMACCLIENTRXSTATS        : out std_logic_vector(6 downto 0);
      EMACCLIENTRXSTATSVLD     : out std_logic;
      EMACCLIENTRXSTATSBYTEVLD : out std_logic;

      -- Client transmitter interface
      TX_CLIENT_CLK_ENABLE     : out std_logic;
      CLIENTEMACTXD            : in  std_logic_vector(7 downto 0);
      CLIENTEMACTXDVLD         : in  std_logic;
      EMACCLIENTTXACK          : out std_logic;
      CLIENTEMACTXFIRSTBYTE    : in  std_logic;
      CLIENTEMACTXUNDERRUN     : in  std_logic;
      EMACCLIENTTXCOLLISION    : out std_logic;
      EMACCLIENTTXRETRANSMIT   : out std_logic;
      CLIENTEMACTXIFGDELAY     : in  std_logic_vector(7 downto 0);
      EMACCLIENTTXSTATS        : out std_logic;
      EMACCLIENTTXSTATSVLD     : out std_logic;
      EMACCLIENTTXSTATSBYTEVLD : out std_logic;

      -- MAC control interface
      CLIENTEMACPAUSEREQ       : in  std_logic;
      CLIENTEMACPAUSEVAL       : in  std_logic_vector(15 downto 0);

      -- MII interface
      MII_TXD                  : out std_logic_vector(3 downto 0);
      MII_TX_EN                : out std_logic;
      MII_TX_ER                : out std_logic;
      MII_TX_CLK               : in  std_logic;
      MII_RXD                  : in  std_logic_vector(3 downto 0);
      MII_RX_DV                : in  std_logic;
      MII_RX_ER                : in  std_logic;
      MII_RX_CLK               : in  std_logic;

      -- MDIO interface
      MDC                      : out std_logic;
      MDIO_I                   : in  std_logic;
      MDIO_O                   : out std_logic;
      MDIO_T                   : out std_logic;

      -- DCR interface
      HOSTCLK                  : in  std_logic;
      DCREMACCLK               : in  std_logic;
      DCREMACABUS              : in  std_logic_vector(0 to 9);
      DCREMACREAD              : in  std_logic;
      DCREMACWRITE             : in  std_logic;
      DCREMACDBUS              : in  std_logic_vector(0 to 31);
      EMACDCRACK               : out std_logic;
      EMACDCRDBUS              : out std_logic_vector(0 to 31);
      DCREMACENABLE            : in  std_logic;
      DCRHOSTDONEIR            : out std_logic;

      -- Asynchronous reset
      RESET                    : in  std_logic

   );
end v6_mii_top;


architecture TOP_LEVEL of v6_mii_top is





-------------------------------------------------------------------------------
-- Signal declarations
-------------------------------------------------------------------------------

    -- Power and ground signals
    signal gnd_i                      : std_logic;
    signal vcc_i                      : std_logic;

    -- Asynchronous reset signals
    signal reset_ibuf_i               : std_logic;
    signal reset_i                    : std_logic;
    signal reset_r                    : std_logic_vector(3 downto 0);

    -- Client clocking signals
    signal rx_client_clk_out_i        : std_logic;
    signal rx_client_clk_in_i         : std_logic;
    signal tx_client_clk_out_i        : std_logic;
    signal tx_client_clk_in_i         : std_logic;
    signal tx_enable_i                : std_logic;
    signal tx_enable_pre_r            : std_logic;
    signal tx_enable_r                : std_logic;
    signal rx_enable_i                : std_logic;
    signal rx_enable_pre_r            : std_logic;
    signal rx_enable_r                : std_logic;

    -- Physical interface clocking signals
    signal tx_gmii_mii_clk_out_i      : std_logic;
    signal tx_gmii_mii_clk_in_i       : std_logic;

    -- Client acknowledge signals
    signal tx_client_ack_r            : std_logic;
    signal tx_client_ack_i            : std_logic;

    -- Physical interface signals
    signal mii_tx_clk_i               : std_logic;
    signal mii_tx_en_i                : std_logic;
    signal mii_tx_en_fa_i             : std_logic;
    signal mii_tx_er_i                : std_logic;
    signal mii_tx_er_fa_i             : std_logic;
    signal mii_txd_i                  : std_logic_vector(3 downto 0);
    signal mii_txd_fa_i               : std_logic_vector(3 downto 0);
    signal mii_rx_clk_i               : std_logic;
    signal mii_rx_dv_r                : std_logic;
    signal mii_rx_er_r                : std_logic;
    signal mii_rxd_r                  : std_logic_vector(3 downto 0);

    -- MDIO signals
    signal mdc_out_i                  : std_logic;
    signal mdio_in_i                  : std_logic;
    signal mdio_out_i                 : std_logic;
    signal mdio_tri_i                 : std_logic;

    -- FCS block signals
    signal tx_stats_byte_valid_i      : std_logic;
    signal tx_collision_i             : std_logic;

-------------------------------------------------------------------------------
-- Attribute declarations
-------------------------------------------------------------------------------

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of tx_enable_pre_r : signal is "TRUE";
  attribute ASYNC_REG of rx_enable_pre_r : signal is "TRUE";


-------------------------------------------------------------------------------
-- Main body of code
-------------------------------------------------------------------------------

begin

    gnd_i <= '0';
    vcc_i <= '1';

    ---------------------------------------------------------------------------
    -- Main reset circuitry
    ---------------------------------------------------------------------------

    reset_ibuf_i <= RESET;
    reset_i <= reset_ibuf_i;

    ---------------------------------------------------------------------------
    -- MII circuitry for the physical interface
    ---------------------------------------------------------------------------

    mii : entity xps_ll_temac_v2_03_a.v6_mii_if(PHY_IF)
    generic map (
        C_INCLUDE_IO            => C_INCLUDE_IO)
    port map (
        RESET          => reset_i,
        MII_TXD        => MII_TXD,
        MII_TX_EN      => MII_TX_EN,
        MII_TX_ER      => MII_TX_ER,
        MII_RXD        => MII_RXD,
        MII_RX_DV      => MII_RX_DV,
        MII_RX_ER      => MII_RX_ER,
        TXD_FROM_MAC   => mii_txd_i,
        TX_EN_FROM_MAC => mii_tx_en_i,
        TX_ER_FROM_MAC => mii_tx_er_i,
        TX_CLK         => tx_gmii_mii_clk_in_i,
        RXD_TO_MAC     => mii_rxd_r,
        RX_DV_TO_MAC   => mii_rx_dv_r,
        RX_ER_TO_MAC   => mii_rx_er_r,
        RX_CLK         => mii_rx_clk_i
    );


    -- Instantiate the FCS block to correct possible duplicate
    -- transmission of the final FCS byte
    fcs_blk_inst :  entity xps_ll_temac_v2_03_a.v6_fcs_blk_mii(rtl)
    port map (
        reset               => reset_i,
        tx_phy_clk          => tx_gmii_mii_clk_in_i,
        txd_from_mac        => mii_txd_fa_i,
        tx_en_from_mac      => mii_tx_en_fa_i,
        tx_er_from_mac      => mii_tx_er_fa_i,
        tx_client_clk       => tx_client_clk_in_i,
        tx_stats_byte_valid => tx_stats_byte_valid_i,
        tx_collision        => tx_collision_i,
        speed_is_10_100     => '1',
        txd                 => mii_txd_i,
        tx_en               => mii_tx_en_i,
        tx_er               => mii_tx_er_i
    );

    EMACCLIENTTXCOLLISION    <= tx_collision_i;
    EMACCLIENTTXSTATSBYTEVLD <= tx_stats_byte_valid_i;


    -- MII PHY-side transmit clock
    tx_gmii_mii_clk_in_i <= TX_CLK;

    -- MII PHY-side receiver clock
    mii_rx_clk_i <= MII_RX_CLK;

    -- MII client side transmit clock
    tx_client_clk_in_i <= TX_CLK;

    -- MII client-side receive clock
    rx_client_clk_in_i <= mii_rx_clk_i;

    -- MII transmitter clock
    mii_tx_clk_i <= MII_TX_CLK;

    -- Register the TX ACK signal with the TX clock
    tx_client_ack_pr : process(tx_gmii_mii_clk_in_i, reset_i)
    begin
        if reset_i = '1' then
            tx_client_ack_r <= '0';
        elsif tx_gmii_mii_clk_in_i'event and tx_gmii_mii_clk_in_i = '1' then
            tx_client_ack_r <= tx_client_ack_i;
        end if;
    end process tx_client_ack_pr;

    tx_client_ack_sel_pr : process(tx_client_ack_r)
    begin
        EMACCLIENTTXACK <= tx_client_ack_r;
    end process tx_client_ack_sel_pr;


    -- Clock enables
    TX_CLIENT_CLK_ENABLE <= tx_enable_r;
    RX_CLIENT_CLK_ENABLE <= rx_enable_r;

    -- Double register the enables to cope with any
    -- metastability during a speed change
    tx_en_pr : process(tx_gmii_mii_clk_in_i, reset_i)
    begin
        if reset_i = '1' then
            tx_enable_pre_r <= '0';
            tx_enable_r     <= '0';
        elsif tx_gmii_mii_clk_in_i'event and tx_gmii_mii_clk_in_i = '1' then
            tx_enable_pre_r <= tx_enable_i after 1 ps;
            tx_enable_r     <= tx_enable_pre_r after 1 ps;
        end if;
    end process tx_en_pr;

    rx_en_pr : process(mii_rx_clk_i, reset_i)
    begin
        if reset_i = '1' then
            rx_enable_pre_r <= '0';
            rx_enable_r     <= '0';
        elsif mii_rx_clk_i'event and mii_rx_clk_i = '1' then
            rx_enable_pre_r <= rx_enable_i after 1 ps;
            rx_enable_r     <= rx_enable_pre_r after 1 ps;
        end if;
    end process rx_en_pr;

    --------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper (v6_mii.vhd)
    --------------------------------------------------------------------------
    v6_emac_wrapper : entity xps_ll_temac_v2_03_a.v6_mii(WRAPPER)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC_DCRBASEADDR      => C_EMAC_DCRBASEADDR,
                 C_TEMAC_PHYADDR         => C_TEMAC_PHYADDR
                )
    port map (
        -- Client receiver interface
        EMACCLIENTRXCLIENTCLKOUT    => rx_enable_i,
        CLIENTEMACRXCLIENTCLKIN     => gnd_i,
        EMACCLIENTRXD               => EMACCLIENTRXD,
        EMACCLIENTRXDVLD            => EMACCLIENTRXDVLD,
        EMACCLIENTRXDVLDMSW         => open,
        EMACCLIENTRXGOODFRAME       => EMACCLIENTRXGOODFRAME,
        EMACCLIENTRXBADFRAME        => EMACCLIENTRXBADFRAME,
        EMACCLIENTRXFRAMEDROP       => EMACCLIENTRXFRAMEDROP,
        EMACCLIENTRXSTATS           => EMACCLIENTRXSTATS,
        EMACCLIENTRXSTATSVLD        => EMACCLIENTRXSTATSVLD,
        EMACCLIENTRXSTATSBYTEVLD    => EMACCLIENTRXSTATSBYTEVLD,

        -- Client transmitter interface
        EMACCLIENTTXCLIENTCLKOUT    => tx_enable_i,
        CLIENTEMACTXCLIENTCLKIN     => gnd_i,
        CLIENTEMACTXD               => CLIENTEMACTXD,
        CLIENTEMACTXDVLD            => CLIENTEMACTXDVLD,
        CLIENTEMACTXDVLDMSW         => gnd_i,
        EMACCLIENTTXACK             => tx_client_ack_i,
        CLIENTEMACTXFIRSTBYTE       => CLIENTEMACTXFIRSTBYTE,
        CLIENTEMACTXUNDERRUN        => CLIENTEMACTXUNDERRUN,
        EMACCLIENTTXCOLLISION       => tx_collision_i,
        EMACCLIENTTXRETRANSMIT      => EMACCLIENTTXRETRANSMIT,
        CLIENTEMACTXIFGDELAY        => CLIENTEMACTXIFGDELAY,
        EMACCLIENTTXSTATS           => EMACCLIENTTXSTATS,
        EMACCLIENTTXSTATSVLD        => EMACCLIENTTXSTATSVLD,
        EMACCLIENTTXSTATSBYTEVLD    => tx_stats_byte_valid_i,

        -- MAC control interface
        CLIENTEMACPAUSEREQ          => CLIENTEMACPAUSEREQ,
        CLIENTEMACPAUSEVAL          => CLIENTEMACPAUSEVAL,

        -- Clock signals
        GTX_CLK                     => gnd_i,
        EMACPHYTXGMIIMIICLKOUT      => tx_gmii_mii_clk_out_i,
        PHYEMACTXGMIIMIICLKIN       => tx_gmii_mii_clk_in_i,

        -- MII interface
        MII_TXD                     => mii_txd_fa_i,
        MII_TX_EN                   => mii_tx_en_fa_i,
        MII_TX_ER                   => mii_tx_er_fa_i,
        MII_TX_CLK                  => mii_tx_clk_i,
        MII_RXD                     => mii_rxd_r,
        MII_RX_DV                   => mii_rx_dv_r,
        MII_RX_ER                   => mii_rx_er_r,
        MII_RX_CLK                  => mii_rx_clk_i,

        -- MDIO interface
        MDC                         => mdc_out_i,
        MDIO_I                      => mdio_in_i,
        MDIO_O                      => mdio_out_i,
        MDIO_T                      => mdio_tri_i,

        -- DCR interface
        HOSTCLK                     => HOSTCLK,
        DCREMACCLK                  => DCREMACCLK,
        DCREMACABUS                 => DCREMACABUS,
        DCREMACREAD                 => DCREMACREAD,
        DCREMACWRITE                => DCREMACWRITE,
        DCREMACDBUS                 => DCREMACDBUS,
        EMACDCRACK                  => EMACDCRACK,
        EMACDCRDBUS                 => EMACDCRDBUS,
        DCREMACENABLE               => DCREMACENABLE,
        DCRHOSTDONEIR               => DCRHOSTDONEIR,

        -- MMCM lock indicator
        MMCM_LOCKED                 => vcc_i,

        -- Asynchronous reset
        RESET                       => reset_i
      );

  ----------------------------------------------------------------------
  -- MDIO interface
  ----------------------------------------------------------------------
  -- This example keeps the mdio_in, mdio_out, mdio_tri signals as
  -- separate connections: these could be connected to an external
  -- Tri-state buffer.  Alternatively they could be connected to a
  -- Tri-state buffer in a Xilinx IOB and an appropriate SelectIO
  -- standard chosen.

  MDC       <= mdc_out_i;
  mdio_in_i <= MDIO_I;
  MDIO_O    <= mdio_out_i;
  MDIO_T    <= mdio_tri_i;


end TOP_LEVEL;
