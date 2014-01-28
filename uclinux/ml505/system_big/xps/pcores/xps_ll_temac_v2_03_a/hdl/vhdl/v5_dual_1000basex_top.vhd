------------------------------------------------------------------------------
-- $Id: v5_dual_1000basex_top.vhd,v 1.1.4.39 2009/11/17 07:11:36 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : Virtex-5 Ethernet MAC Wrapper Top Level
-- Project    : Virtex-5 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v5_dual_1000basex_top.vhd
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
-- Description:  This is the EMAC top level VHDL design for the Virtex-5 
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
--               This is based on Coregen Wrappers from ISE L (11.1i)
--               Wrapper version 1.6
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
entity v5_dual_1000basex_top is
  generic (
           C_INCLUDE_IO                : integer          := 1;
           C_EMAC0_DCRBASEADDR         : bit_vector       := "0000000000";
           C_EMAC1_DCRBASEADDR         : bit_vector       := "0000000000";
           C_TEMAC0_PHYADDR            : std_logic_vector(4 downto 0) := "00001";
           C_TEMAC1_PHYADDR            : std_logic_vector(4 downto 0) := "00010"
          );
   port(
      -- EMAC0 Clocking
      -- 125MHz clock output from transceiver
      CLK125_OUT                      : out std_logic;                 
      -- 125MHz clock input from BUFG
      CLK125                          : in  std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXD                  : out std_logic_vector(7 downto 0);
      EMAC0CLIENTRXDVLD               : out std_logic;
      EMAC0CLIENTRXGOODFRAME          : out std_logic;
      EMAC0CLIENTRXBADFRAME           : out std_logic;
      EMAC0CLIENTRXFRAMEDROP          : out std_logic;
      EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSVLD           : out std_logic;
      EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC0
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
      -- EMAC0 Interrupt
      EMAC0ANINTERRUPT                : out std_logic;

 
      -- Clock Signals - EMAC0
      -- 1000BASE-X PCS/PMA Interface - EMAC0
      TXP_0                           : out std_logic;
      TXN_0                           : out std_logic;
      RXP_0                           : in  std_logic;
      RXN_0                           : in  std_logic;
      PHYAD_0                         : in  std_logic_vector(4 downto 0);
      RESETDONE_0                     : out std_logic;

      -- MDIO Interface - EMAC0
      MDC_0                           : out std_logic;
      MDIO_0_I                        : in  std_logic;
      MDIO_0_O                        : out std_logic;
      MDIO_0_T                        : out std_logic;

      -- EMAC1 Clocking

      -- Client Receiver Interface - EMAC1
      EMAC1CLIENTRXD                  : out std_logic_vector(7 downto 0);
      EMAC1CLIENTRXDVLD               : out std_logic;
      EMAC1CLIENTRXGOODFRAME          : out std_logic;
      EMAC1CLIENTRXBADFRAME           : out std_logic;
      EMAC1CLIENTRXFRAMEDROP          : out std_logic;
      EMAC1CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC1CLIENTRXSTATSVLD           : out std_logic;
      EMAC1CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC1
      CLIENTEMAC1TXD                  : in  std_logic_vector(7 downto 0);
      CLIENTEMAC1TXDVLD               : in  std_logic;
      EMAC1CLIENTTXACK                : out std_logic;
      CLIENTEMAC1TXFIRSTBYTE          : in  std_logic;
      CLIENTEMAC1TXUNDERRUN           : in  std_logic;
      EMAC1CLIENTTXCOLLISION          : out std_logic;
      EMAC1CLIENTTXRETRANSMIT         : out std_logic;
      CLIENTEMAC1TXIFGDELAY           : in  std_logic_vector(7 downto 0);
      EMAC1CLIENTTXSTATS              : out std_logic;
      EMAC1CLIENTTXSTATSVLD           : out std_logic;
      EMAC1CLIENTTXSTATSBYTEVLD       : out std_logic;

      -- MAC Control Interface - EMAC1
      CLIENTEMAC1PAUSEREQ             : in  std_logic;
      CLIENTEMAC1PAUSEVAL             : in  std_logic_vector(15 downto 0);

      --EMAC-MGT link status
      EMAC1CLIENTSYNCACQSTATUS        : out std_logic;
      -- EMAC1 Interrupt
      EMAC1ANINTERRUPT                : out std_logic;

           
      -- Clock Signals - EMAC1
      -- 1000BASE-X PCS/PMA Interface - EMAC1
      TXP_1                           : out std_logic;
      TXN_1                           : out std_logic;
      RXP_1                           : in  std_logic;
      RXN_1                           : in  std_logic;
      PHYAD_1                         : in  std_logic_vector(4 downto 0);
      RESETDONE_1                     : out std_logic;

      -- MDIO Interface - EMAC1
      MDC_1                           : out std_logic;
      MDIO_1_I                        : in  std_logic;
      MDIO_1_O                        : out std_logic;
      MDIO_1_T                        : out std_logic;

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

      -- 1000BASE-X PCS/PMA RocketIO Reference Clock buffer inputs 
      CLK_DS                          : in  std_logic;
     
      -- RocketIO Reset input
      GTRESET                         : in  std_logic;

        
        
      -- Asynchronous Reset
      RESET                           : in  std_logic
   );
end v5_dual_1000basex_top;


architecture TOP_LEVEL of v5_dual_1000basex_top is


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
    -- EMAC0 Physical Interface Signals
    signal emac_locked_0_i                : std_logic;
    signal mgt_rx_data_0_i                : std_logic_vector(7 downto 0);
    signal mgt_tx_data_0_i                : std_logic_vector(7 downto 0);
    signal signal_detect_0_i              : std_logic;
    signal elecidle_0_i                   : std_logic;
    signal encommaalign_0_i               : std_logic;
    signal loopback_0_i                   : std_logic;
    signal mgt_rx_reset_0_i               : std_logic;
    signal mgt_tx_reset_0_i               : std_logic;
    signal powerdown_0_i                  : std_logic;
    signal rxclkcorcnt_0_i                : std_logic_vector(2 downto 0);
    signal rxbuferr_0_i                   : std_logic;
    signal rxchariscomma_0_i              : std_logic;
    signal rxcharisk_0_i                  : std_logic;
    signal rxdisperr_0_i                  : std_logic;
    signal rxlossofsync_0_i               : std_logic_vector(1 downto 0);
    signal rxnotintable_0_i               : std_logic;
    signal rxrundisp_0_i                  : std_logic;
    signal txbuferr_0_i                   : std_logic;
    signal txchardispmode_0_i             : std_logic;
    signal txchardispval_0_i              : std_logic;
    signal txcharisk_0_i                  : std_logic;
    signal gtx_clk_ibufg_0_i              : std_logic;
    signal resetdone_0_i                  : std_logic;
    signal rxbufstatus_0_i                : std_logic_vector(1 downto 0);
    signal txchardispmode_0_r             : std_logic;
    signal txchardispval_0_r              : std_logic;
    signal txcharisk_0_r                  : std_logic;
    signal mgt_tx_data_0_r                : std_logic_vector(7 downto 0);

    -- EMAC1 Client Clocking Signals
    signal rx_client_clk_out_1_i          : std_logic;
    signal rx_client_clk_in_1_i           : std_logic;
    signal tx_client_clk_out_1_i          : std_logic;
    signal tx_client_clk_in_1_i           : std_logic;
    -- EMAC1 Physical Interface Signals
    signal emac_locked_1_i                : std_logic;
    signal mgt_rx_data_1_i                : std_logic_vector(7 downto 0);
    signal mgt_tx_data_1_i                : std_logic_vector(7 downto 0);
    signal signal_detect_1_i              : std_logic;
    signal elecidle_1_i                   : std_logic;
    signal encommaalign_1_i               : std_logic;
    signal loopback_1_i                   : std_logic;
    signal mgt_rx_reset_1_i               : std_logic;
    signal mgt_tx_reset_1_i               : std_logic;
    signal powerdown_1_i                  : std_logic;
    signal rxclkcorcnt_1_i                : std_logic_vector(2 downto 0);
    signal rxbuferr_1_i                   : std_logic;
    signal rxchariscomma_1_i              : std_logic;
    signal rxcharisk_1_i                  : std_logic;
    signal rxdisperr_1_i                  : std_logic;
    signal rxlossofsync_1_i               : std_logic_vector(1 downto 0);
    signal rxnotintable_1_i               : std_logic;
    signal rxrundisp_1_i                  : std_logic;
    signal txbuferr_1_i                   : std_logic;
    signal txchardispmode_1_i             : std_logic;
    signal txchardispval_1_i              : std_logic;
    signal txcharisk_1_i                  : std_logic;
    signal gtx_clk_ibufg_1_i              : std_logic;
    signal resetdone_1_i                  : std_logic;
    signal rxbufstatus_1_i                : std_logic_vector(1 downto 0);
    signal txchardispmode_1_r             : std_logic;
    signal txchardispval_1_r              : std_logic;
    signal txcharisk_1_r                  : std_logic;
    signal mgt_tx_data_1_r                : std_logic_vector(7 downto 0);

    signal usrclk2                        : std_logic;
   
    signal refclkout                      : std_logic;
    signal dcm_locked_gtp                 : std_logic;  
    signal plllock_0_i                    : std_logic;     
    signal plllock_1_i                    : std_logic;


    -- EMAC0 MDIO signals
    signal mdc_out_0_i                    : std_logic;
    signal mdio_in_0_i                    : std_logic;
    signal mdio_out_0_i                   : std_logic;
    signal mdio_tri_0_i                   : std_logic;

    -- EMAC1 MDIO signals
    signal mdc_out_1_i                    : std_logic;
    signal mdio_in_1_i                    : std_logic;
    signal mdio_out_1_i                   : std_logic;
    signal mdio_tri_1_i                   : std_logic;


-------------------------------------------------------------------------------
-- Attribute Declarations 
-------------------------------------------------------------------------------

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of reset_r : signal is "TRUE";


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

    -- Asserting the reset of the EMAC for four clock cycles
    process(usrclk2, reset_ibuf_i)
    begin
        if (reset_ibuf_i = '1') then
            reset_r <= "1111";
        elsif usrclk2'event and usrclk2 = '1' then
          if (plllock_0_i = '1' and plllock_1_i = '1') then
            reset_r <= reset_r(2 downto 0) & reset_ibuf_i;
          end if;
        end if;
    end process;

    -- The reset pulse is now several clock cycles in duration
    reset_i <= reset_r(3);

 
   
    ---------------------------------------------------------------------------
    -- Instantiate RocketIO tile for SGMII or 1000BASE-X PCS/PMA Physical I/F
    ---------------------------------------------------------------------------


    --EMAC0 and EMAC1 instances
    GTP_dual_1000X_inst : entity xps_ll_temac_v2_03_a.v5_dual_1000basex_GTP_dual_1000X(structural)
    generic map (
        C_INCLUDE_IO            => C_INCLUDE_IO)
      PORT MAP (
         RESETDONE_0           =>   RESETDONE_0,
         ENMCOMMAALIGN_0       =>   encommaalign_0_i,
         ENPCOMMAALIGN_0       =>   encommaalign_0_i,
         LOOPBACK_0            =>   loopback_0_i,
         POWERDOWN_0           =>   powerdown_0_i,
         RXUSRCLK_0            =>   usrclk2,
         RXUSRCLK2_0           =>   usrclk2,
         RXRESET_0             =>   mgt_rx_reset_0_i,
         TXCHARDISPMODE_0      =>   txchardispmode_0_r,
         TXCHARDISPVAL_0       =>   txchardispval_0_r,
         TXCHARISK_0           =>   txcharisk_0_r,
         TXDATA_0              =>   mgt_tx_data_0_r,
         TXUSRCLK_0            =>   usrclk2,
         TXUSRCLK2_0           =>   usrclk2,
         TXRESET_0             =>   mgt_tx_reset_0_i,                                   
         RXCHARISCOMMA_0       =>   rxchariscomma_0_i,
         RXCHARISK_0           =>   rxcharisk_0_i,
         RXCLKCORCNT_0         =>   rxclkcorcnt_0_i,
         RXDATA_0              =>   mgt_rx_data_0_i,
         RXDISPERR_0           =>   rxdisperr_0_i,
         RXNOTINTABLE_0        =>   rxnotintable_0_i,
         RXRUNDISP_0           =>   rxrundisp_0_i,
         RXBUFERR_0            =>   rxbuferr_0_i,         
         TXBUFERR_0            =>   txbuferr_0_i,
         PLLLKDET_0            =>   plllock_0_i,
         RXELECIDLE_0          =>   elecidle_0_i,
         RX1P_0                =>   RXP_0,
         RX1N_0                =>   RXN_0,
         TX1N_0                =>   TXN_0,
         TX1P_0                =>   TXP_0,

         RESETDONE_1           =>   RESETDONE_1,
         ENMCOMMAALIGN_1       =>   encommaalign_1_i,
         ENPCOMMAALIGN_1       =>   encommaalign_1_i,
         LOOPBACK_1            =>   loopback_1_i,         
         POWERDOWN_1           =>   powerdown_1_i,
         RXUSRCLK_1            =>   usrclk2,
         RXUSRCLK2_1           =>   usrclk2,
         RXRESET_1             =>   mgt_rx_reset_1_i,         
         TXCHARDISPMODE_1      =>   txchardispmode_1_r,
         TXCHARDISPVAL_1       =>   txchardispval_1_r,
         TXCHARISK_1           =>   txcharisk_1_r,
         TXDATA_1              =>   mgt_tx_data_1_r,
         TXUSRCLK_1            =>   usrclk2,
         TXUSRCLK2_1           =>   usrclk2,
         TXRESET_1             =>   mgt_tx_reset_1_i,                                   
         RXCHARISCOMMA_1       =>   rxchariscomma_1_i,
         RXCHARISK_1           =>   rxcharisk_1_i,
         RXCLKCORCNT_1         =>   rxclkcorcnt_1_i,
         RXDATA_1              =>   mgt_rx_data_1_i,
         RXDISPERR_1           =>   rxdisperr_1_i,
         RXNOTINTABLE_1        =>   rxnotintable_1_i,
         RXRUNDISP_1           =>   rxrundisp_1_i,
         RXBUFERR_1            =>   rxbuferr_1_i,
         TXBUFERR_1            =>   txbuferr_1_i,
         PLLLKDET_1            =>   plllock_1_i,
         TXOUTCLK_1            =>   open,         
         RXELECIDLE_1          =>   elecidle_1_i,
         RX1P_1                =>   RXP_1,
         RX1N_1                =>   RXN_1,
         TX1N_1                =>   TXN_1,
         TX1P_1                =>   TXP_1,
         CLK_DS                =>   CLK_DS,
         REFCLKOUT             =>   refclkout,
         GTRESET               =>   GTRESET,
         TXOUTCLK_0            =>   open,
         PMARESET              =>   reset_ibuf_i,
         DCM_LOCKED            =>   dcm_locked_gtp
    );

   txchardispmode_0_r <= txchardispmode_0_i after 4 ns;
   txchardispval_0_r  <= txchardispval_0_i  after 4 ns;
   txcharisk_0_r      <= txcharisk_0_i      after 4 ns;
   mgt_tx_data_0_r    <= mgt_tx_data_0_i    after 4 ns;


   txchardispmode_1_r <= txchardispmode_1_i after 4 ns;
   txchardispval_1_r  <= txchardispval_1_i  after 4 ns;
   txcharisk_1_r      <= txcharisk_1_i      after 4 ns;
   mgt_tx_data_1_r    <= mgt_tx_data_1_i    after 4 ns;


    ---------------------------------------------------------------------------
    -- Generate the buffer status input to the EMAC0 from the buffer error 
    -- output of the transceiver
    ---------------------------------------------------------------------------
    rxbufstatus_0_i(1) <= rxbuferr_0_i;

    ---------------------------------------------------------------------------
    -- Detect when there has been a disconnect
    ---------------------------------------------------------------------------
    signal_detect_0_i <= not(elecidle_0_i);


    ---------------------------------------------------------------------------
    -- Generate the buffer status input to the EMAC1 from the buffer error 
    -- output of the transceiver
    ---------------------------------------------------------------------------
    rxbufstatus_1_i(1) <= rxbuferr_1_i;
    
    ---------------------------------------------------------------------------
    -- Detect when there has been a disconnect
    ---------------------------------------------------------------------------
    signal_detect_1_i <= not(elecidle_1_i);
 




    --------------------------------------------------------------------
    -- Virtex5 Rocket I/O Clock Management
    --------------------------------------------------------------------

    -- The RocketIO transceivers are available in pairs with shared
    -- clock resources
    -- 125MHz clock is used for GTP user clocks and used
    -- to clock all Ethernet core logic.
    usrclk2                   <= CLK125;

    dcm_locked_gtp            <= '1';

    -- EMAC0: PLL locks
    emac_locked_0_i           <= plllock_0_i;


    ------------------------------------------------------------------------
    -- GTX_CLK Clock Management for EMAC0 - 125 MHz clock frequency
    -- (Connected to PHYEMAC0GTXCLK of the EMAC primitive)
    ------------------------------------------------------------------------
    gtx_clk_ibufg_0_i         <= usrclk2;


    ------------------------------------------------------------------------
    -- PCS/PMA client side receive clock for EMAC0
    ------------------------------------------------------------------------
    rx_client_clk_in_0_i      <= usrclk2;


    ------------------------------------------------------------------------
    -- PCS/PMA client side transmit clock for EMAC0
    ------------------------------------------------------------------------
    tx_client_clk_in_0_i      <= usrclk2;


    -- EMAC1: PLL locks
    emac_locked_1_i           <= plllock_1_i;


    ------------------------------------------------------------------------
    -- GTX_CLK Clock Management for EMAC1 - 125 MHz clock frequency
    -- (Connected to PHYEMAC1GTXCLK of the EMAC primitive)
    ------------------------------------------------------------------------
    gtx_clk_ibufg_1_i         <= usrclk2;


    ------------------------------------------------------------------------
    -- PCS/PMA client side receive clock for EMAC1
    ------------------------------------------------------------------------
    rx_client_clk_in_1_i      <= usrclk2;


    ------------------------------------------------------------------------
    -- PCS/PMA client side transmit clock for EMAC0
    ------------------------------------------------------------------------
    tx_client_clk_in_1_i      <= usrclk2;


    ------------------------------------------------------------------------
    -- Connect previously derived client clocks to example design output ports
    ------------------------------------------------------------------------
    -- EMAC0 Clocking
    -- 125MHz clock output from transceiver
    CLK125_OUT                <= refclkout;

    -- EMAC1 Clocking

 

    --------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper (dual_1000basex.vhd)
    --------------------------------------------------------------------------
    v5_emac_wrapper : entity xps_ll_temac_v2_03_a.v5_dual_1000basex(WRAPPER)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_EMAC0_DCRBASEADDR     => C_EMAC0_DCRBASEADDR,
                 C_EMAC1_DCRBASEADDR     => C_EMAC1_DCRBASEADDR,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
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
        EMAC0PHYTXGMIIMIICLKOUT         => open,
        PHYEMAC0TXGMIIMIICLKIN          => gnd_i,

        -- 1000BASE-X PCS/PMA Interface - EMAC0
        RXDATA_0                        => mgt_rx_data_0_i,
        TXDATA_0                        => mgt_tx_data_0_i,
        DCM_LOCKED_0                    => emac_locked_0_i,
        AN_INTERRUPT_0                  => EMAC0ANINTERRUPT,
        SIGNAL_DETECT_0                 => signal_detect_0_i,
        PHYAD_0                         => PHYAD_0,
        ENCOMMAALIGN_0                  => encommaalign_0_i,
        LOOPBACKMSB_0                   => loopback_0_i,
        MGTRXRESET_0                    => mgt_rx_reset_0_i,
        MGTTXRESET_0                    => mgt_tx_reset_0_i,
        POWERDOWN_0                     => powerdown_0_i,
        SYNCACQSTATUS_0                 => EMAC0CLIENTSYNCACQSTATUS,
        RXCLKCORCNT_0                   => rxclkcorcnt_0_i,
        RXBUFSTATUS_0                   => rxbufstatus_0_i,
        RXCHARISCOMMA_0                 => rxchariscomma_0_i,
        RXCHARISK_0                     => rxcharisk_0_i,
        RXDISPERR_0                     => rxdisperr_0_i,
        RXNOTINTABLE_0                  => rxnotintable_0_i,
        RXREALIGN_0                     => '0',
        RXRUNDISP_0                     => rxrundisp_0_i,
        TXBUFERR_0                      => txbuferr_0_i,
        TXRUNDISP_0                     => '0',
        TXCHARDISPMODE_0                => txchardispmode_0_i,
        TXCHARDISPVAL_0                 => txchardispval_0_i,
        TXCHARISK_0                     => txcharisk_0_i,

        -- MDIO Interface - EMAC0
        MDC_0                           => mdc_out_0_i,
        MDIO_0_I                        => mdio_in_0_i,
        MDIO_0_O                        => mdio_out_0_i,
        MDIO_0_T                        => mdio_tri_0_i,

        -- Client Receiver Interface - EMAC1
        EMAC1CLIENTRXCLIENTCLKOUT       => rx_client_clk_out_1_i,
        CLIENTEMAC1RXCLIENTCLKIN        => rx_client_clk_in_1_i,
        EMAC1CLIENTRXD                  => EMAC1CLIENTRXD,
        EMAC1CLIENTRXDVLD               => EMAC1CLIENTRXDVLD,
        EMAC1CLIENTRXDVLDMSW            => open,
        EMAC1CLIENTRXGOODFRAME          => EMAC1CLIENTRXGOODFRAME,
        EMAC1CLIENTRXBADFRAME           => EMAC1CLIENTRXBADFRAME,
        EMAC1CLIENTRXFRAMEDROP          => EMAC1CLIENTRXFRAMEDROP,
        EMAC1CLIENTRXSTATS              => EMAC1CLIENTRXSTATS,
        EMAC1CLIENTRXSTATSVLD           => EMAC1CLIENTRXSTATSVLD,
        EMAC1CLIENTRXSTATSBYTEVLD       => EMAC1CLIENTRXSTATSBYTEVLD,

        -- Client Transmitter Interface - EMAC1
        EMAC1CLIENTTXCLIENTCLKOUT       => tx_client_clk_out_1_i,
        CLIENTEMAC1TXCLIENTCLKIN        => tx_client_clk_in_1_i,
        CLIENTEMAC1TXD                  => CLIENTEMAC1TXD,
        CLIENTEMAC1TXDVLD               => CLIENTEMAC1TXDVLD,
        CLIENTEMAC1TXDVLDMSW            => gnd_i,
        EMAC1CLIENTTXACK                => EMAC1CLIENTTXACK,
        CLIENTEMAC1TXFIRSTBYTE          => CLIENTEMAC1TXFIRSTBYTE,
        CLIENTEMAC1TXUNDERRUN           => CLIENTEMAC1TXUNDERRUN,
        EMAC1CLIENTTXCOLLISION          => EMAC1CLIENTTXCOLLISION,
        EMAC1CLIENTTXRETRANSMIT         => EMAC1CLIENTTXRETRANSMIT,
        CLIENTEMAC1TXIFGDELAY           => CLIENTEMAC1TXIFGDELAY,
        EMAC1CLIENTTXSTATS              => EMAC1CLIENTTXSTATS,
        EMAC1CLIENTTXSTATSVLD           => EMAC1CLIENTTXSTATSVLD,
        EMAC1CLIENTTXSTATSBYTEVLD       => EMAC1CLIENTTXSTATSBYTEVLD,

        -- MAC Control Interface - EMAC1
        CLIENTEMAC1PAUSEREQ             => CLIENTEMAC1PAUSEREQ,
        CLIENTEMAC1PAUSEVAL             => CLIENTEMAC1PAUSEVAL,

        -- Clock Signals - EMAC1
        GTX_CLK_1                       => usrclk2,
        EMAC1PHYTXGMIIMIICLKOUT         => open,
        PHYEMAC1TXGMIIMIICLKIN          => gnd_i,
        -- 1000BASE-X PCS/PMA Interface - EMAC1
        RXDATA_1                        => mgt_rx_data_1_i,
        TXDATA_1                        => mgt_tx_data_1_i,
        DCM_LOCKED_1                    => emac_locked_1_i,
        AN_INTERRUPT_1                  => EMAC1ANINTERRUPT,
        SIGNAL_DETECT_1                 => signal_detect_1_i,
        PHYAD_1                         => PHYAD_1,
        ENCOMMAALIGN_1                  => encommaalign_1_i,
        LOOPBACKMSB_1                   => loopback_1_i,
        MGTRXRESET_1                    => mgt_rx_reset_1_i,
        MGTTXRESET_1                    => mgt_tx_reset_1_i,
        POWERDOWN_1                     => powerdown_1_i,
        SYNCACQSTATUS_1                 => EMAC1CLIENTSYNCACQSTATUS,
        RXCLKCORCNT_1                   => rxclkcorcnt_1_i,
        RXBUFSTATUS_1                   => rxbufstatus_1_i,
        RXCHARISCOMMA_1                 => rxchariscomma_1_i,
        RXCHARISK_1                     => rxcharisk_1_i,
        RXDISPERR_1                     => rxdisperr_1_i,
        RXNOTINTABLE_1                  => rxnotintable_1_i,
        RXREALIGN_1                     => '0',
        RXRUNDISP_1                     => rxrundisp_1_i,
        TXBUFERR_1                      => txbuferr_1_i,
        TXRUNDISP_1                     => '0',
        TXCHARDISPMODE_1                => txchardispmode_1_i,
        TXCHARDISPVAL_1                 => txchardispval_1_i,
        TXCHARISK_1                     => txcharisk_1_i,

        -- MDIO Interface - EMAC1
        MDC_1                           => mdc_out_1_i,
        MDIO_1_I                        => mdio_in_1_i,
        MDIO_1_O                        => mdio_out_1_i,
        MDIO_1_T                        => mdio_tri_1_i,

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


 
  ----------------------------------------------------------------------
  -- MDIO interface for EMAC1 
  ----------------------------------------------------------------------  
  -- This example keeps the mdio_in, mdio_out, mdio_tri signals as
  -- separate connections: these could be connected to an external
  -- Tri-state buffer.  Alternatively they could be connected to a 
  -- Tri-state buffer in a Xilinx IOB and an appropriate SelectIO
  -- standard chosen.

  MDC_1       <= mdc_out_1_i;
  mdio_in_1_i <= MDIO_1_I;
  MDIO_1_O    <= mdio_out_1_i;
  MDIO_1_T    <= mdio_tri_1_i;




 
end TOP_LEVEL;
