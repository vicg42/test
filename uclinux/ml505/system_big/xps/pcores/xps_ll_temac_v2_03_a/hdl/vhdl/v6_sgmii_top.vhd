------------------------------------------------------------------------------
-- $Id: v6_sgmii_top.vhd,v 1.1.4.39 2009/11/17 07:11:38 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : Virtex-6 Ethernet MAC Wrapper Top Level
-- Project    : Virtex-6 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v6_sgmii_top.vhd
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
--------------------------------------------------------------------------------
-- Description:  This is the EMAC top level VHDL design for the Virtex-6
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
entity v6_sgmii_top is
  generic (
           C_INCLUDE_IO                : integer          := 1;
           C_EMAC_DCRBASEADDR          : bit_vector       := "0000000000";
           C_TEMAC_PHYADDR             : std_logic_vector(4 downto 0) := "00010"
          );
   port(

      -- 125MHz clock output from transceiver
      CLK125_OUT               : out std_logic;
      -- 125MHz clock input from BUFG
      CLK125                   : in  std_logic;
      -- Tri-speed clock output
      CLIENT_CLK_OUT           : out std_logic;
      -- Tri-speed clock input from BUFG
      CLIENT_CLK               : in  std_logic;

      -- Client receiver interface
      EMACCLIENTRXD            : out std_logic_vector(7 downto 0);
      EMACCLIENTRXDVLD         : out std_logic;
      EMACCLIENTRXGOODFRAME    : out std_logic;
      EMACCLIENTRXBADFRAME     : out std_logic;
      EMACCLIENTRXFRAMEDROP    : out std_logic;
      EMACCLIENTRXSTATS        : out std_logic_vector(6 downto 0);
      EMACCLIENTRXSTATSVLD     : out std_logic;
      EMACCLIENTRXSTATSBYTEVLD : out std_logic;

      -- Client transmitter interface
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

      -- EMAC-transceiver link status
      EMACCLIENTSYNCACQSTATUS  : out std_logic;

      -- Auto-Negotiation interrupt
      EMACANINTERRUPT          : out std_logic;

      -- SGMII interface
      TXP                      : out std_logic;
      TXN                      : out std_logic;
      RXP                      : in  std_logic;
      RXN                      : in  std_logic;
      PHYAD                    : in  std_logic_vector(4 downto 0);
      RESETDONE                : out std_logic;

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

      -- SGMII transceiver clock buffer input
      CLK_DS                   : in  std_logic;

      -- Asynchronous reset
      RESET                    : in  std_logic

   );
end v6_sgmii_top;


architecture TOP_LEVEL of v6_sgmii_top is






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

    -- Physical interface signals
    signal emac_locked_i              : std_logic;
    signal mgt_rx_data_i              : std_logic_vector(7 downto 0);
    signal mgt_tx_data_i              : std_logic_vector(7 downto 0);
    signal signal_detect_i            : std_logic;
    signal elecidle_i                 : std_logic;
    signal resetdone_i                : std_logic;
    signal encommaalign_i             : std_logic;
    signal loopback_i                 : std_logic;
    signal mgt_rx_reset_i             : std_logic;
    signal mgt_tx_reset_i             : std_logic;
    signal powerdown_i                : std_logic;
    signal rxclkcorcnt_i              : std_logic_vector(2 downto 0);
    signal rxchariscomma_i            : std_logic;
    signal rxcharisk_i                : std_logic;
    signal rxdisperr_i                : std_logic;
    signal rxnotintable_i             : std_logic;
    signal rxrundisp_i                : std_logic;
    signal txbuferr_i                 : std_logic;
    signal txchardispmode_i           : std_logic;
    signal txchardispval_i            : std_logic;
    signal txcharisk_i                : std_logic;
    signal gtx_clk_ibufg_i            : std_logic;
    signal rxbufstatus_i              : std_logic;
    signal rxchariscomma_r            : std_logic;
    signal rxcharisk_r                : std_logic;
    signal rxclkcorcnt_r              : std_logic_vector(2 downto 0);
    signal mgt_rx_data_r              : std_logic_vector(7 downto 0);
    signal rxdisperr_r                : std_logic;
    signal rxnotintable_r             : std_logic;
    signal rxrundisp_r                : std_logic;
    signal txchardispmode_r           : std_logic;
    signal txchardispval_r            : std_logic;
    signal txcharisk_r                : std_logic;
    signal mgt_tx_data_r              : std_logic_vector(7 downto 0);

    -- Transceiver clocking signals
    signal usrclk2                    : std_logic;
    signal txoutclk                   : std_logic;
    signal plllock_i                  : std_logic;

    -- MDIO signals
    signal mdc_out_i                  : std_logic;
    signal mdio_in_i                  : std_logic;
    signal mdio_out_i                 : std_logic;
    signal mdio_tri_i                 : std_logic;

-------------------------------------------------------------------------------
-- Attribute declarations
-------------------------------------------------------------------------------

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of reset_r : signal is "TRUE";

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

    -- Synchronize and extend the external reset signal
    process(usrclk2, reset_ibuf_i)
    begin
        if (reset_ibuf_i = '1') then
            reset_r <= "1111";
        elsif usrclk2'event and usrclk2 = '1' then
          if (plllock_i = '1') then
            reset_r <= reset_r(2 downto 0) & reset_ibuf_i;
          end if;
        end if;
    end process;

    -- Apply the extended reset pulse to the EMAC
    reset_i <= reset_r(3);

    ---------------------------------------------------------------------------
    -- Instantiate RocketIO for SGMII or 1000BASE-X PCS/PMA physical interface
    ---------------------------------------------------------------------------

    rocketio_wrapper_top_inst : entity xps_ll_temac_v2_03_a.v6_sgmii_rocketio_wrapper_top(RTL)
      PORT MAP (
         RESETDONE      => resetdone_i,
         ENMCOMMAALIGN  => encommaalign_i,
         ENPCOMMAALIGN  => encommaalign_i,
         LOOPBACK       => loopback_i,
         POWERDOWN      => powerdown_i,
         RXUSRCLK2      => usrclk2,
         RXRESET        => mgt_rx_reset_i,
         TXCHARDISPMODE => txchardispmode_r,
         TXCHARDISPVAL  => txchardispval_r,
         TXCHARISK      => txcharisk_r,
         TXDATA         => mgt_tx_data_r,
         TXUSRCLK2      => usrclk2,
         TXRESET        => mgt_tx_reset_i,
         RXCHARISCOMMA  => rxchariscomma_i,
         RXCHARISK      => rxcharisk_i,
         RXCLKCORCNT    => rxclkcorcnt_i,
         RXDATA         => mgt_rx_data_i,
         RXDISPERR      => rxdisperr_i,
         RXNOTINTABLE   => rxnotintable_i,
         RXRUNDISP      => rxrundisp_i,
         RXBUFERR       => rxbufstatus_i,
         TXBUFERR       => txbuferr_i,
         PLLLKDET       => plllock_i,
         TXOUTCLK       => txoutclk,
         RXELECIDLE     => elecidle_i,
         TXN            => TXN,
         TXP            => TXP,
         RXN            => RXN,
         RXP            => RXP,
         CLK_DS         => CLK_DS,
         PMARESET       => reset_ibuf_i
    );

   RESETDONE <= resetdone_i;

   --------------------------------------------------------------------------
   -- Register the signals between EMAC and transceiver for timing purposes
   --------------------------------------------------------------------------
   regrx : process (usrclk2, reset_i)
   begin
        if reset_i = '1' then
            rxchariscomma_r  <= '0';
            rxcharisk_r      <= '0';
            rxclkcorcnt_r    <= (others => '0');
            mgt_rx_data_r    <= (others => '0');
            rxdisperr_r      <= '0';
            rxnotintable_r   <= '0';
            rxrundisp_r      <= '0';
            txchardispmode_r <= '0';
            txchardispval_r  <= '0';
            txcharisk_r      <= '0';
            mgt_tx_data_r    <= (others => '0');
        elsif usrclk2'event and usrclk2 = '1' then
            rxchariscomma_r  <= rxchariscomma_i;
            rxcharisk_r      <= rxcharisk_i;
            rxclkcorcnt_r    <= rxclkcorcnt_i;
            mgt_rx_data_r    <= mgt_rx_data_i;
            rxdisperr_r      <= rxdisperr_i;
            rxnotintable_r   <= rxnotintable_i;
            rxrundisp_r      <= rxrundisp_i;
            txchardispmode_r <= txchardispmode_i after 1 ns;
            txchardispval_r  <= txchardispval_i after 1 ns;
            txcharisk_r      <= txcharisk_i after 1 ns;
            mgt_tx_data_r    <= mgt_tx_data_i after 1 ns;
        end if;
   end process regrx;

    -- Detect when there has been a disconnect
    signal_detect_i <= not(elecidle_i);

    --------------------------------------------------------------------
    -- RocketIO clock management
    --------------------------------------------------------------------
    -- 125MHz clock is used for GT user clocks and used
    -- to clock all Ethernet core logic
    usrclk2        <= CLK125;

    -- GTX reference clock
    gtx_clk_ibufg_i <= usrclk2;

    -- PLL locks
    emac_locked_i <= plllock_i;

    -- SGMII client-side transmit clock
    tx_client_clk_in_i <= CLIENT_CLK;

    -- SGMII client-side receive clock
    rx_client_clk_in_i <= CLIENT_CLK;

    -- 125MHz clock output from transceiver
    CLK125_OUT <= txoutclk;

    -- Tri-speed clock output
    CLIENT_CLK_OUT <= tx_client_clk_out_i;

    --------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper (v6_sgmii.vhd)
    --------------------------------------------------------------------------
    v6_emac_wrapper : entity xps_ll_temac_v2_03_a.v6_sgmii(WRAPPER)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC_DCRBASEADDR      => C_EMAC_DCRBASEADDR,
                 C_TEMAC_PHYADDR         => C_TEMAC_PHYADDR
                )
    port map (
        -- Client receiver interface
        EMACCLIENTRXCLIENTCLKOUT    => rx_client_clk_out_i,
        CLIENTEMACRXCLIENTCLKIN     => rx_client_clk_in_i,
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
        EMACCLIENTTXCLIENTCLKOUT    => tx_client_clk_out_i,
        CLIENTEMACTXCLIENTCLKIN     => tx_client_clk_in_i,
        CLIENTEMACTXD               => CLIENTEMACTXD,
        CLIENTEMACTXDVLD            => CLIENTEMACTXDVLD,
        CLIENTEMACTXDVLDMSW         => gnd_i,
        EMACCLIENTTXACK             => EMACCLIENTTXACK,
        CLIENTEMACTXFIRSTBYTE       => CLIENTEMACTXFIRSTBYTE,
        CLIENTEMACTXUNDERRUN        => CLIENTEMACTXUNDERRUN,
        EMACCLIENTTXCOLLISION       => EMACCLIENTTXCOLLISION,
        EMACCLIENTTXRETRANSMIT      => EMACCLIENTTXRETRANSMIT,
        CLIENTEMACTXIFGDELAY        => CLIENTEMACTXIFGDELAY,
        EMACCLIENTTXSTATS           => EMACCLIENTTXSTATS,
        EMACCLIENTTXSTATSVLD        => EMACCLIENTTXSTATSVLD,
        EMACCLIENTTXSTATSBYTEVLD    => EMACCLIENTTXSTATSBYTEVLD,

        -- MAC control interface
        CLIENTEMACPAUSEREQ          => CLIENTEMACPAUSEREQ,
        CLIENTEMACPAUSEVAL          => CLIENTEMACPAUSEVAL,

        -- Clock signals
        GTX_CLK                     => usrclk2,
        EMACPHYTXGMIIMIICLKOUT      => open,
        PHYEMACTXGMIIMIICLKIN       => gnd_i,

        -- SGMII interface
        RXDATA                      => mgt_rx_data_r,
        TXDATA                      => mgt_tx_data_i,
        MMCM_LOCKED                 => emac_locked_i,
        AN_INTERRUPT                => EMACANINTERRUPT,
        SIGNAL_DETECT               => signal_detect_i,
        PHYAD                       => PHYAD,
        ENCOMMAALIGN                => encommaalign_i,
        LOOPBACKMSB                 => loopback_i,
        MGTRXRESET                  => mgt_rx_reset_i,
        MGTTXRESET                  => mgt_tx_reset_i,
        POWERDOWN                   => powerdown_i,
        SYNCACQSTATUS               => EMACCLIENTSYNCACQSTATUS,
        RXCLKCORCNT                 => rxclkcorcnt_r,
        RXBUFSTATUS                 => rxbufstatus_i,
        RXCHARISCOMMA               => rxchariscomma_r,
        RXCHARISK                   => rxcharisk_r,
        RXDISPERR                   => rxdisperr_r,
        RXNOTINTABLE                => rxnotintable_r,
        RXREALIGN                   => '0',
        RXRUNDISP                   => rxrundisp_r,
        TXBUFERR                    => txbuferr_i,
        TXCHARDISPMODE              => txchardispmode_i,
        TXCHARDISPVAL               => txchardispval_i,
        TXCHARISK                   => txcharisk_i,

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
