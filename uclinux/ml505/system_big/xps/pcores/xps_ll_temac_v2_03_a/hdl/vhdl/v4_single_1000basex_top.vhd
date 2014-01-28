------------------------------------------------------------------------------
-- $Id: v4_single_1000basex_top.vhd,v 1.1.4.39 2009/11/17 07:11:36 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : Virtex-4 FX Ethernet MAC Wrapper Top Level
-- Project    : Virtex-4 FX Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v4_single_1000basex_top.vhd
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
-- Description:  This is the top level VHDL design for the Virtex-4 FX
--               Embedded Ethernet MAC Example Design.  It is intended that
--               this example design can be quickly adapted and downloaded onto
--               an FPGA to provide a real hardware test environment.
--
--               This top level:
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
--               the Virtex-4 Embedded Tri-Mode Ethernet MAC User Gude for
--               further information.
--               
--               This is based on Coregen Wrappers from ISE J.38 (9.2i)
--               Wrapper version 4.5
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
entity v4_single_1000basex_top is
  generic (
           C_INCLUDE_IO                : integer          := 1;
           C_TEMAC0_PHYADDR            : std_logic_vector(4 downto 0) := "00001";
           C_TEMAC1_PHYADDR            : std_logic_vector(4 downto 0) := "00010"
          );
   port(
      -- Client Receiver Interface - EMAC0
      RX_CLIENT_CLK_0                 : out std_logic;
      EMAC0CLIENTRXD                  : out std_logic_vector(7 downto 0);
      EMAC0CLIENTRXDVLD               : out std_logic;
      EMAC0CLIENTRXGOODFRAME          : out std_logic;
      EMAC0CLIENTRXBADFRAME           : out std_logic;
      EMAC0CLIENTRXFRAMEDROP          : out std_logic;
      EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSVLD           : out std_logic;
      EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC0
      TX_CLIENT_CLK_0                 : out std_logic;
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

      --EMAC-MGT link status
      EMAC0CLIENTSYNCACQSTATUS        : out std_logic;

 
      -- Clock Signals - EMAC0
      -- 1000BASE-X PCS/PMA Interface - EMAC0
      TXP_0                           : out std_logic;
      TXN_0                           : out std_logic;
      RXP_0                           : in  std_logic;
      RXN_0                           : in  std_logic;
      PHYAD_0                         : in  std_logic_vector(4 downto 0);
      RESETDONE_0                     : out std_logic;

      -- unused transceiver
      TXN_1_UNUSED                    : out std_logic;
      TXP_1_UNUSED                    : out std_logic;
      RXN_1_UNUSED                    : in  std_logic;
      RXP_1_UNUSED                    : in  std_logic;

      -- MDIO Interface - EMAC0
      MDC_0                           : out std_logic;
      MDIO_0_I                        : in  std_logic;
      MDIO_0_O                        : out std_logic;
      MDIO_0_T                        : out std_logic;
      -- Generic Host Interface
      HOSTOPCODE                      : in  std_logic_vector(1 downto 0);
      HOSTREQ                         : in  std_logic;
      HOSTMIIMSEL                     : in  std_logic;
      HOSTADDR                        : in  std_logic_vector(9 downto 0);
      HOSTWRDATA                      : in  std_logic_vector(31 downto 0);
      HOSTMIIMRDY                     : out std_logic;
      HOSTRDDATA                      : out std_logic_vector(31 downto 0);
      HOSTEMAC1SEL                    : in  std_logic;
      HOSTCLK                         : in  std_logic;
      -- 1000BASE-X PCS/PMA RocketIO Reference Clock buffer inputs 
      MGTCLK_P                        : in  std_logic;
      MGTCLK_N                        : in  std_logic;

      -- Dynamic Reconfiguration Port Clock Must be between 25MHz - 50 MHz                 
      DCLK                            : in  std_logic;

        
        
      -- Asynchronous Reset
      RESET                           : in  std_logic
   );
end v4_single_1000basex_top;



architecture TOP_LEVEL of v4_single_1000basex_top is


-------------------------------------------------------------------------------
-- Signals Declarations
-------------------------------------------------------------------------------

    signal gnd_i                          : std_logic;
    signal gnd_v48_i                      : std_logic_vector(47 downto 0);
    signal vcc_i                          : std_logic;

    signal reset_ibuf_i                   : std_logic;
    signal reset_i                        : std_logic;
    signal emac_reset                     : std_logic;
    signal reset_r                        : std_logic_vector(3 downto 0);

    signal rx_client_clk_out_0_i          : std_logic;
    signal rx_client_clk_in_0_i           : std_logic;
    signal tx_client_clk_out_0_i          : std_logic;
    signal tx_client_clk_fb_0_i           : std_logic;
    signal tx_client_clk_in_0_i           : std_logic;
    signal tx_gmii_mii_clk_out_0_i        : std_logic;
    signal tx_gmii_mii_clk_in_0_i         : std_logic;
    signal pll_not_locked_0_i             : std_logic;
    signal tx_pcs_reset_0_i               : std_logic;
    signal rx_pcs_reset_0_i               : std_logic;
    signal rx_rdy0                        : std_logic;
    signal tx_rdy0                        : std_logic;
    signal emac0_reset                    : std_logic;
    signal emac_locked_0_i                : std_logic;
    signal mgt_rx_data_0_i                : std_logic_vector(7 downto 0);
    signal mgt_tx_data_0_i                : std_logic_vector(7 downto 0);
    signal an_interrupt_0_i               : std_logic;
    signal signal_detect_0_i              : std_logic;
    signal phy_ad_0_i                     : std_logic_vector(4 downto 0);
    signal encommaalign_0_i               : std_logic;
    signal loopback_0_i                   : std_logic;
    signal loopback_0_sig                 : std_logic_vector (1 downto 0);
    signal mgt_rx_reset_0_i               : std_logic;
    signal mgt_tx_reset_0_i               : std_logic;
    signal powerdown_0_i                  : std_logic;
    signal sync_acq_status_0_i            : std_logic;
    signal rxclkcorcnt_0_i                : std_logic_vector(2 downto 0);
    signal rxbufstatus_0_i                : std_logic_vector(5 downto 0);
    signal rxbuferr_0_i                   : std_logic;
    signal rxbuferr_0                     : std_logic;
    signal rxpmareset0                    : std_logic;
    signal rxchariscomma_0_i              : std_logic;
    signal rxcharisk_0_i                  : std_logic;
    signal rxcheckingcrc_0_i              : std_logic;
    signal rxcommadet_0_i                 : std_logic;
    signal rxdisperr_0_i                  : std_logic;
    signal rxlossofsync_0_i               : std_logic_vector(1 downto 0);
    signal rxnotintable_0_i               : std_logic;
    signal rxrealign_0_i                  : std_logic;
    signal rxrundisp_0_i                  : std_logic;
    signal txbuferr_0_i                   : std_logic;
    signal txchardispmode_0_i             : std_logic;
    signal txchardispval_0_i              : std_logic;
    signal txcharisk_0_i                  : std_logic;
    signal txrundisp_0_i                  : std_logic;
    signal gtx_clk_ibufg_0_i              : std_logic;
    signal rxbuferr_cat_0_i               : std_logic_vector(1 downto 0);



    signal txpmareset                      : std_logic;
    signal reset_pma_sm                   : std_logic_vector(3 downto 0);
    signal usrclk2                        : std_logic;
    signal dclk_bufg                      : std_logic;
    signal txoutclk1                      : std_logic;
    signal txpmareset0                     : std_logic;
    signal txpmareset1                     : std_logic;
    signal tx_plllock_0                      : std_logic;
    signal rx_plllock_0                      : std_logic;
    signal phy_config_vector_0_i          : std_logic_vector(4 downto 0);
    signal has_mdio_0_i                   : std_logic;
    signal speed_0_i                      : std_logic_vector(1 downto 0);
    signal has_rgmii_0_i                  : std_logic;
    signal has_sgmii_0_i                  : std_logic;
    signal has_gpcs_0_i                   : std_logic;
    signal has_host_0_i                   : std_logic;
    signal tx_client_16_0_i               : std_logic;
    signal rx_client_16_0_i               : std_logic;
    signal addr_filter_enable_0_i         : std_logic;
    signal rx_lt_check_dis_0_i            : std_logic;
    signal flow_control_config_vector_0_i : std_logic_vector(1 downto 0);
    signal tx_config_vector_0_i           : std_logic_vector(6 downto 0);
    signal rx_config_vector_0_i           : std_logic_vector(5 downto 0);
    signal pause_address_0_i              : std_logic_vector(47 downto 0);

    signal unicast_address_0_i            : std_logic_vector(47 downto 0);

    signal refclk1                        : std_logic;
    signal refclk2                        : std_logic;

    signal tx_reset_sm_0_r                : std_logic_vector(3 downto 0);
    signal tx_pcs_reset_0_r               : std_logic;
    signal rx_reset_sm_0_r                : std_logic_vector(3 downto 0);
    signal rx_pcs_reset_0_r               : std_logic;


    signal tx_data_0_i                    : std_logic_vector(7 downto 0);
    signal tx_data_valid_0_i              : std_logic;
    signal rx_data_0_i                    : std_logic_vector(7 downto 0);
    signal rx_data_valid_0_i              : std_logic;
    signal tx_underrun_0_i                : std_logic;
    signal tx_ack_0_i                     : std_logic;
    signal rx_good_frame_0_i              : std_logic;
    signal rx_bad_frame_0_i               : std_logic;
    signal tx_collision_0_i               : std_logic;
    signal tx_retransmit_0_i              : std_logic;
    signal mdc_out_0_i                    : std_logic;
    signal mdio_in_0_i                    : std_logic;
    signal mdio_out_0_i                   : std_logic;
    signal mdio_tri_0_i                   : std_logic;
    signal host_clk_i                     : std_logic;
    signal rxsync_0                       : std_logic;

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of reset_r  : signal is "TRUE";

-- Force xst to preserve the clock net names in the design
-- These clock names are referenced in the UCF file
  attribute KEEP : string;
  attribute KEEP of usrclk2   : signal is "TRUE";






-------------------------------------------------------------------------------
-- Main Body of Code
-------------------------------------------------------------------------------


begin


    gnd_i     <= '0';
    gnd_v48_i <= (others => '0');
    vcc_i     <= '1';

    ---------------------------------------------------------------------------
    -- Main Reset Circuitry
    ---------------------------------------------------------------------------

    reset_ibuf_i <= RESET;

    -- Asserting the reset of the EMAC for four clock cycles
    -- This clock can be changed to any clock that is not derived
    -- from an output clock of the GT11.
    process(host_clk_i, reset_ibuf_i)
    begin
        if (reset_ibuf_i = '1') then
            reset_r <= "1111";
        elsif host_clk_i'event and host_clk_i = '1' then
            reset_r <= reset_r(2 downto 0) & reset_ibuf_i;
        end if;
    end process;

    -- The reset pulse is now several clock cycles in duration
    reset_i <= reset_r(3);

    --RESETDONE_0 <= not reset_i;
    RESETDONE_0 <= rx_rdy0 and tx_rdy0 and not(emac_reset);

    ---------------------------------------------------------------------------
    -- Instantiate RocketIO tile for SGMII or 1000BASE-X PCS/PMA Physical I/F
    ---------------------------------------------------------------------------

    loopback_0_sig         <=  '0' & loopback_0_i;

    --EMAC0-only instance
    GT11_dual_1000X_inst : entity xps_ll_temac_v2_03_a.v4_single_1000basex_gt11_dual_1000X(structural)
    generic map (
        C_INCLUDE_IO            => C_INCLUDE_IO)
      PORT MAP (
         ENMCOMMAALIGN_0       =>   encommaalign_0_i,
         ENPCOMMAALIGN_0       =>   encommaalign_0_i,
         LOOPBACK_0            =>   loopback_0_sig,
         REFCLK1_0             =>   refclk1,
         REFCLK2_0             =>   '0',
         RXCLKCORCNT_0         =>   rxclkcorcnt_0_i,
         RXUSRCLK_0            =>   '0',
         RXUSRCLK2_0           =>   usrclk2,
         RXRESET_0             =>   rx_pcs_reset_0_i,
         RXPMARESET0           =>   rxpmareset0,
         RX1P_0                =>   RXP_0,
         RX1N_0                =>   RXN_0,
         TXCHARDISPMODE_0      =>   txchardispmode_0_i,
         TXCHARDISPVAL_0       =>   txchardispval_0_i,
         TXCHARISK_0           =>   txcharisk_0_i,
         TXDATA_0              =>   mgt_tx_data_0_i,
         TXUSRCLK_0            =>   '0',
         TXUSRCLK2_0           =>   usrclk2,
         TXRESET_0             =>   tx_pcs_reset_0_i,
         RXBUFERR_0 	         =>   rxbuferr_0_i,
         RXCHARISCOMMA_0       =>   rxchariscomma_0_i,
         RXCHARISK_0           =>   rxcharisk_0_i,
         RXCOMMADET_0          =>   rxcommadet_0_i,
         RXDATA_0              =>   mgt_rx_data_0_i,
         RXDISPERR_0           =>   rxdisperr_0_i,
         RXNOTINTABLE_0        =>   rxnotintable_0_i,
         RXREALIGN_0           =>   rxrealign_0_i,
         RXRECCLK1_0           =>   open,
         RXRUNDISP_0           =>   rxrundisp_0_i,
         RXSTATUS_0            =>   rxbufstatus_0_i,
         TX_PLLLOCK_0             =>   tx_plllock_0,
         RX_PLLLOCK_0             =>   rx_plllock_0,
         TX1N_0                =>   TXN_0,
         TX1P_0                =>   TXP_0,
         TXBUFERR_0            =>   txbuferr_0_i,
         TXRUNDISP_0           =>   txrundisp_0_i,
         TXOUTCLK1_0           =>   txoutclk1,
         RXSYNC_0              =>   rxsync_0,
         TX1N_1_UNUSED         =>   TXN_1_UNUSED,
         TX1P_1_UNUSED         =>   TXP_1_UNUSED,
         RX1N_1_UNUSED         =>   RXN_1_UNUSED,
         RX1P_1_UNUSED         =>   RXP_1_UNUSED,
         RX_SIGNAL_DETECT_0    =>   '1',
         PMARESET_TX0           =>   txpmareset0,
         DCLK                  =>   dclk_bufg,
         DCM_LOCKED            =>   '1'
    );




  -- Implement the reset state machine described in the RocketIO User
  -- Guide (figure 2-18 "Flow Chart of Receiver Reset Sequence Where RX
  -- Buffer is Used" in UG076 v3.0 May 23, 2006)
  reset_receiver0: entity xps_ll_temac_v2_03_a.v4_gt11_init_rx(rtl)
     port map (
         clk           => dclk_bufg,
         usrclk2       => usrclk2,
         start_init    => reset_i,
         lock          => rx_plllock_0,
         usrclk_stable => tx_plllock_0,
         pcs_error     => rxbuferr_0_i,
         pma_reset     => rxpmareset0,
         sync          => rxsync_0,
         pcs_reset     => rx_pcs_reset_0_i,
         ready         => rx_rdy0
     );


  -- Implement the reset state machine described in the RocketIO User
  -- Guide (figure 2-13 "Flow Chart ot TX Reset Sequence Where TX Buffer
  -- is Used" in UG076 v3.0 May 23, 2006)
  reset_transmitter0: entity xps_ll_temac_v2_03_a.v4_gt11_init_tx(rtl)
     port map (
         clk           => dclk_bufg,
         usrclk2       => usrclk2,
         start_init    => reset_i,
         lock          => tx_plllock_0,
         usrclk_stable => tx_plllock_0,
         pcs_error     => txbuferr_0_i,
         pma_reset     => txpmareset0,
         pcs_reset     => tx_pcs_reset_0_i,
         ready         => tx_rdy0
     );


  -- The assertion of RXBUFERR from the GT11 is detected and held static until
  -- The Rx reset state machine (gt11_init) has completed
    process(dclk_bufg,reset_i)
    begin
        if (reset_i = '1') then
           rxbuferr_0 <= '1';
        elsif dclk_bufg'event and dclk_bufg = '1' then
            if (rxbuferr_0_i = '1') then
                rxbuferr_0 <= '1';
            elsif rx_rdy0 = '1' then
                rxbuferr_0 <= '0';
            end if;
        end if;
    end process;

    rxbuferr_cat_0_i <= (rxbuferr_0 & '0');


    emac0_reset <= (not tx_rdy0);




  --emac_reset <= emac0_reset or reset_i;
  emac_reset <= reset_i;

  txpmareset <= txpmareset0;




    ----------------------------------------------------------------------
    -- Virtex4 Rocket I/O Clock Management
    ----------------------------------------------------------------------

    -- The RocketIO transceivers are available in pairs with shared
    -- clock resources

    GT11CLK_MGT_inst : GT11CLK_MGT
    GENERIC MAP (
         SYNCLK1OUTEN   =>   "ENABLE",
         SYNCLK2OUTEN   =>   "DISABLE")
    PORT MAP (
         SYNCLK1OUT     =>    refclk1,
         SYNCLK2OUT     =>    open,
         MGTCLKN        =>    MGTCLK_N,
         MGTCLKP        =>    MGTCLK_P);



    -- refclk1 is obtained from the GT11 clock module at 250MHz.
    -- Outputs of the DCM are CLK0 (125MHz) and CLKDV (31.5MHz)

    -- Dynamic Reconfiguration Port Clock
    -- Must be between 25MHz - 50 MHz
    -- bufg_dclk  : BUFG port map (I => DCLK, O => dclk_bufg);
    dclk_bufg <=  DCLK;

    -- Clock provided for GT11
    -- Must be between 25MHz - 50 MHz
    bufg_userclk2  : BUFG port map (I => txoutclk1, O => usrclk2);

  YES_IO_1: if(C_INCLUDE_IO = 1) generate
  begin
    -- EMAC0: PLL locks and Synchronisation status
    sync0_obuf : OBUF port map (I => sync_acq_status_0_i, O => EMAC0CLIENTSYNCACQSTATUS);
  end generate YES_IO_1;

     --emac_locked_0_i          <= tx_plllock_0 and rx_plllock_0;
    emac_locked_0_i          <= tx_rdy0;


    --------------------------------------------------------------------------
    -- GTX_CLK Clock Management for EMAC0 - 125 MHz clock frequency
    -- (Connected to PHYEMAC0GTXCLK of the EMAC primitive)
    --------------------------------------------------------------------------
    gtx_clk_ibufg_0_i    <= usrclk2;


    --------------------------------------------------------------------------
    -- PCS/PMA client side receive clock for EMAC0
    --------------------------------------------------------------------------
	rx_client_clk_in_0_i <= usrclk2;


    --------------------------------------------------------------------------
    -- PCS/PMA client side transmit clock for EMAC0
    --------------------------------------------------------------------------
    tx_client_clk_in_0_i <= usrclk2;


    --------------------------------------------------------------------------
    -- Connect previously derived client clocks to example design output ports
    --------------------------------------------------------------------------
    RX_CLIENT_CLK_0 <= rx_client_clk_in_0_i;
    TX_CLIENT_CLK_0 <= tx_client_clk_in_0_i;


    --------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper (v4_single_1000basex.vhd)
    --------------------------------------------------------------------------
    v4_emac_top : entity xps_ll_temac_v2_03_a.v4_single_1000basex(WRAPPER)
    port map (
        -- Client Receiver Interface - EMAC0
        EMAC0CLIENTRXCLIENTCLKOUT       => rx_client_clk_out_0_i,
        CLIENTEMAC0RXCLIENTCLKIN        => rx_client_clk_in_0_i,
        EMAC0CLIENTRXD                  => EMAC0CLIENTRXD,
        EMAC0CLIENTRXDVLD               => EMAC0CLIENTRXDVLD,
        EMAC0CLIENTRXDVLDMSW            => open,
        EMAC0CLIENTRXGOODFRAME          => EMAC0CLIENTRXGOODFRAME,
        EMAC0CLIENTRXBADFRAME           => EMAC0CLIENTRXBADFRAME,
        EMAC0CLIENTRXFRAMEDROP          => EMAC0CLIENTRXFRAMEDROP,
        EMAC0CLIENTRXDVREG6             => open,
        EMAC0CLIENTRXSTATS              => EMAC0CLIENTRXSTATS,
        EMAC0CLIENTRXSTATSVLD           => EMAC0CLIENTRXSTATSVLD,
        EMAC0CLIENTRXSTATSBYTEVLD       => EMAC0CLIENTRXSTATSBYTEVLD,

        -- Client Transmitter Interface - EMAC0
        EMAC0CLIENTTXCLIENTCLKOUT       => tx_client_clk_out_0_i,
        CLIENTEMAC0TXCLIENTCLKIN        => tx_client_clk_in_0_i,
        CLIENTEMAC0TXD                  => CLIENTEMAC0TXD,
        CLIENTEMAC0TXDVLD               => CLIENTEMAC0TXDVLD,
        CLIENTEMAC0TXDVLDMSW            => gnd_i,
        EMAC0CLIENTTXACK                => EMAC0CLIENTTXACK,
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
        GTX_CLK_0                       => usrclk2,
        EMAC0CLIENTTXGMIIMIICLKOUT      => open,
        CLIENTEMAC0TXGMIIMIICLKIN       => gnd_i,

        -- 1000BASE-X PCS/PMA Interface - EMAC0
        RXDATA_0                        => mgt_rx_data_0_i,
        TXDATA_0                        => mgt_tx_data_0_i,
        DCM_LOCKED_0                    => emac_locked_0_i,
        AN_INTERRUPT_0                  => an_interrupt_0_i,
        SIGNAL_DETECT_0                 => '1',
        PHYAD_0                         => PHYAD_0,
        ENCOMMAALIGN_0                  => encommaalign_0_i,
        LOOPBACKMSB_0                   => loopback_0_i,
        MGTRXRESET_0                    => mgt_rx_reset_0_i,
        MGTTXRESET_0                    => mgt_tx_reset_0_i,
        POWERDOWN_0                     => powerdown_0_i,
        SYNCACQSTATUS_0                 => sync_acq_status_0_i,
        RXCLKCORCNT_0                   => rxclkcorcnt_0_i,
        RXBUFSTATUS_0                   => rxbuferr_cat_0_i(1 downto 0),
        RXBUFERR_0                      => '0',
        RXCHARISCOMMA_0                 => rxchariscomma_0_i,
        RXCHARISK_0                     => rxcharisk_0_i,
        RXCHECKINGCRC_0                 => '0',
        RXCOMMADET_0                    => '0',
        RXDISPERR_0                     => rxdisperr_0_i,
        RXLOSSOFSYNC_0                  => (others=>'0'),
        RXNOTINTABLE_0                  => rxnotintable_0_i,
        RXREALIGN_0                     => rxrealign_0_i,
        RXRUNDISP_0                     => rxrundisp_0_i,
        TXBUFERR_0                      => txbuferr_0_i,
        TXCHARDISPMODE_0                => txchardispmode_0_i,
        TXCHARDISPVAL_0                 => txchardispval_0_i,
        TXCHARISK_0                     => txcharisk_0_i,
        TXRUNDISP_0                     => txrundisp_0_i,

        -- MDIO Interface - EMAC0
        MDC_0                           => mdc_out_0_i,
        MDIO_IN_0                       => mdio_in_0_i,
        MDIO_OUT_0                      => mdio_out_0_i,
        MDIO_TRI_0                      => mdio_tri_0_i,

        -- Host Interface
        HOSTOPCODE                      => HOSTOPCODE,
        HOSTREQ                         => HOSTREQ,
        HOSTMIIMSEL                     => HOSTMIIMSEL,
        HOSTADDR                        => HOSTADDR,
        HOSTWRDATA                      => HOSTWRDATA,
        HOSTMIIMRDY                     => HOSTMIIMRDY,
        HOSTRDDATA                      => HOSTRDDATA,
        HOSTEMAC1SEL                    => HOSTEMAC1SEL,
        HOSTCLK                         => HOSTCLK,


        -- Asynchronous Reset
        RESET                           => emac_reset
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
  MDIO_0_O  <= mdio_out_0_i;
  MDIO_0_T  <= mdio_tri_0_i;




  -- The Host clock (HOSTCLK on EMAC primitive) must always be driven.
  -- In this example design it is kept as a standalone signal.  However,
  -- this can be shared with one of the other clock sources, for
  -- example, one of the 125MHz PHYEMAC#GTX clock inputs.

  -- host_clk : IBUF port map (I => HOSTCLK, O => host_clk_i);
  
  host_clk_i <= HOSTCLK;
    

  NO_IO_1: if(C_INCLUDE_IO = 0) generate
  begin
    -- EMAC0: PLL locks and Synchronisation status
    EMAC0CLIENTSYNCACQSTATUS  <= sync_acq_status_0_i;
  end generate NO_IO_1;




end TOP_LEVEL;
