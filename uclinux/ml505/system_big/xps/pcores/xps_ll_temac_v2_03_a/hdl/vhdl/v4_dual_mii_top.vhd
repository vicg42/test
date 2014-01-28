------------------------------------------------------------------------------
-- $Id: v4_dual_mii_top.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : Virtex-4 FX Ethernet MAC Wrapper Top Level
-- Project    : Virtex-4 FX Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v4_dual_mii_top.vhd
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
entity v4_dual_mii_top is
  generic (
           C_RESERVED                  : integer          := 0;  
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
      -- Client Receiver Interface - EMAC1
      RX_CLIENT_CLK_1                 : out std_logic;
      EMAC1CLIENTRXD                  : out std_logic_vector(7 downto 0);
      EMAC1CLIENTRXDVLD               : out std_logic;
      EMAC1CLIENTRXGOODFRAME          : out std_logic;
      EMAC1CLIENTRXBADFRAME           : out std_logic;
      EMAC1CLIENTRXFRAMEDROP          : out std_logic;
      EMAC1CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC1CLIENTRXSTATSVLD           : out std_logic;
      EMAC1CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC1
      TX_CLIENT_CLK_1                 : out std_logic;
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

           
      -- Clock Signals - EMAC1
      -- MII Interface - EMAC1
      MII_TXD_1                       : out std_logic_vector(3 downto 0);
      MII_TX_EN_1                     : out std_logic;
      MII_TX_ER_1                     : out std_logic;
      MII_TX_CLK_1                    : in  std_logic;
      MII_RXD_1                       : in  std_logic_vector(3 downto 0);
      MII_RX_DV_1                     : in  std_logic;
      MII_RX_ER_1                     : in  std_logic;
      MII_RX_CLK_1                    : in  std_logic;

      -- MDIO Interface - EMAC1
      MDC_1                           : out std_logic;
      MDIO_1_I                        : in  std_logic;
      MDIO_1_O                        : out std_logic;
      MDIO_1_T                        : out std_logic;
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
        
        
      -- Asynchronous Reset
      RESET                           : in  std_logic
   );
end v4_dual_mii_top;



architecture TOP_LEVEL of v4_dual_mii_top is

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
    signal mii_tx_clk_0_i                 : std_logic;
    signal mii_tx_en_0_i                  : std_logic;
    signal mii_tx_er_0_i                  : std_logic;
    signal mii_txd_0_i                    : std_logic_vector(3 downto 0);
    signal mii_tx_en_0_r                  : std_logic;
    signal mii_tx_er_0_r                  : std_logic;
    signal mii_txd_0_r                    : std_logic_vector(3 downto 0);
    signal mii_rx_clk_ibufg_0_i           : std_logic;
    signal mii_rx_clk_0_i                 : std_logic;
    signal mii_rx_dv_0_i                  : std_logic;
    signal mii_rx_er_0_i                  : std_logic;
    signal mii_rxd_0_i                    : std_logic_vector(3 downto 0);
    signal mii_rx_dv_0_r                  : std_logic;
    signal mii_rx_er_0_r                  : std_logic;
    signal mii_rxd_0_r                    : std_logic_vector(3 downto 0);


    signal rx_client_clk_out_1_i          : std_logic;
    signal rx_client_clk_in_1_i           : std_logic;
    signal tx_client_clk_out_1_i          : std_logic;
    signal tx_client_clk_in_1_i           : std_logic;
    signal tx_client_clk_fb_1_i           : std_logic;
    signal tx_gmii_mii_clk_out_1_i        : std_logic;
    signal tx_gmii_mii_clk_in_1_i         : std_logic;
    signal mii_tx_clk_1_i                 : std_logic;
    signal mii_tx_en_1_i                  : std_logic;
    signal mii_tx_er_1_i                  : std_logic;
    signal mii_txd_1_i                    : std_logic_vector(3 downto 0);
    signal mii_tx_en_1_r                  : std_logic;
    signal mii_tx_er_1_r                  : std_logic;
    signal mii_txd_1_r                    : std_logic_vector(3 downto 0);
    signal mii_rx_clk_ibufg_1_i           : std_logic;
    signal mii_rx_clk_1_i                 : std_logic;
    signal mii_rx_dv_1_i                  : std_logic;
    signal mii_rx_er_1_i                  : std_logic;
    signal mii_rxd_1_i                    : std_logic_vector(3 downto 0);
    signal mii_rx_dv_1_r                  : std_logic;
    signal mii_rx_er_1_r                  : std_logic;
    signal mii_rxd_1_r                    : std_logic_vector(3 downto 0);

    signal txpmareset                      : std_logic;


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
    signal tx_data_1_i                    : std_logic_vector(7 downto 0);
    signal tx_data_valid_1_i              : std_logic;
    signal rx_data_1_i                    : std_logic_vector(7 downto 0);
    signal rx_data_valid_1_i              : std_logic;
    signal tx_underrun_1_i                : std_logic;
    signal tx_ack_1_i                     : std_logic;
    signal rx_good_frame_1_i              : std_logic;
    signal rx_bad_frame_1_i               : std_logic;
    signal tx_collision_1_i               : std_logic;
    signal tx_retransmit_1_i              : std_logic;
    signal mdc_out_1_i                    : std_logic;
    signal mdio_in_1_i                    : std_logic;
    signal mdio_out_1_i                   : std_logic;
    signal mdio_tri_1_i                   : std_logic;
    signal host_clk_i                     : std_logic;

    subtype delay is TIME;
    --Constant value1: delay := 1 ns;
    Constant value1: delay := 0 ns;

    signal tx_client_clk_in_0_i_delay     : std_logic;
    signal tx_client_clk_in_1_i_delay     : std_logic;
    signal rx_client_clk_in_0_i_delay     : std_logic;
    signal rx_client_clk_in_1_i_delay     : std_logic;


  attribute ASYNC_REG : string;
  attribute ASYNC_REG of reset_r  : signal is "TRUE";

-- Force xst to preserve the clock net names in the design
-- These clock names are referenced in the UCF file
  attribute KEEP : string;
  attribute KEEP of tx_gmii_mii_clk_in_0_i : signal is "TRUE";
  attribute KEEP of tx_gmii_mii_clk_in_1_i : signal is "TRUE";
  attribute KEEP of tx_client_clk_in_0_i   : signal is "TRUE";
  attribute KEEP of tx_client_clk_in_1_i   : signal is "TRUE";
  attribute KEEP of rx_client_clk_in_0_i   : signal is "TRUE";
  attribute KEEP of rx_client_clk_in_1_i   : signal is "TRUE";
  attribute KEEP of mii_rx_clk_0_i      : signal is "TRUE";
  attribute KEEP of mii_rx_clk_1_i      : signal is "TRUE";






-------------------------------------------------------------------------------
-- Main Body of Code
-------------------------------------------------------------------------------


begin

tx_client_clk_in_0_i_delay <= tx_client_clk_in_0_i after value1;
tx_client_clk_in_1_i_delay <= tx_client_clk_in_1_i after value1;
rx_client_clk_in_0_i_delay <= rx_client_clk_in_0_i after value1;
rx_client_clk_in_1_i_delay <= rx_client_clk_in_1_i after value1;


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



    ---------------------------------------------------------------------------
    -- MII circuitry for the Physical Interface of EMAC0
    ---------------------------------------------------------------------------

    mii0 : entity xps_ll_temac_v2_03_a.v4_mii_if(PHY_IF)
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


RSVD_NO_WRAP_01: if(C_RESERVED = 0) generate  -- no wrap
begin


    ---------------------------------------------------------------------------
    -- MII circuitry for the Physical Interface of EMAC1
    ---------------------------------------------------------------------------

    mii1 : entity xps_ll_temac_v2_03_a.v4_mii_if(PHY_IF)
    generic map (
        C_INCLUDE_IO            => C_INCLUDE_IO)
    port map (
        RESET                         => reset_i,
        MII_TXD                       => MII_TXD_1,
        MII_TX_EN                     => MII_TX_EN_1,
        MII_TX_ER                     => MII_TX_ER_1,
        MII_RXD                       => MII_RXD_1,
        MII_RX_DV                     => MII_RX_DV_1,
        MII_RX_ER                     => MII_RX_ER_1,
        TXD_FROM_MAC                  => mii_txd_1_i,
        TX_EN_FROM_MAC                => mii_tx_en_1_i,
        TX_ER_FROM_MAC                => mii_tx_er_1_i,
        TX_CLK                        => tx_gmii_mii_clk_in_1_i,
        RXD_TO_MAC                    => mii_rxd_1_r,
        RX_DV_TO_MAC                  => mii_rx_dv_1_r,
        RX_ER_TO_MAC                  => mii_rx_er_1_r,
        RX_CLK                        => mii_rx_clk_1_i);

end generate RSVD_NO_WRAP_01;





YES_IO_0: if(C_INCLUDE_IO = 1) generate
begin

    --------------------------------------------------------------------------
    -- MII PHY side transmit clock for EMAC0
    --------------------------------------------------------------------------
    tx_gmii_mii_clk_0_bufg : BUFG
    port map (
        --I => tx_gmii_mii_clk_out_0_i,
        I => mii_tx_clk_0_i,
        O => tx_gmii_mii_clk_in_0_i
        );

    --------------------------------------------------------------------------
    -- MII PHY side Receiver Clock Management for EMAC0
    --------------------------------------------------------------------------
    gmii_rx_clk_0_ibufg : IBUFG
    port map (
        I => MII_RX_CLK_0,
        O => mii_rx_clk_ibufg_0_i
        );

    gmii_rx_clk_0_bufg : BUFG
    port map (
        I => mii_rx_clk_ibufg_0_i,
        O => mii_rx_clk_0_i
        );


end generate YES_IO_0;

YES_IO_1: if(C_INCLUDE_IO = 1 and C_RESERVED = 0) generate
begin

    --------------------------------------------------------------------------
    -- MII PHY side transmit clock for EMAC1
    --------------------------------------------------------------------------
    tx_gmii_mii_clk_1_bufg : BUFG
    port map (
        --I => tx_gmii_mii_clk_out_1_i,
        I => mii_tx_clk_1_i,
        O => tx_gmii_mii_clk_in_1_i
        );

    --------------------------------------------------------------------------
    -- MII PHY side Receiver Clock Management for EMAC1
    --------------------------------------------------------------------------
    gmii_rx_clk_1_ibufg : IBUFG
    port map (
        I => MII_RX_CLK_1,
        O => mii_rx_clk_ibufg_1_i
        );

    gmii_rx_clk_1_bufg : BUFG
    port map (
        I => mii_rx_clk_ibufg_1_i,
        O => mii_rx_clk_1_i
        );


end generate YES_IO_1;
 
    --------------------------------------------------------------------------
    -- MII client side transmit clock for EMAC0
    --------------------------------------------------------------------------
    tx_client_clk_0_bufg : BUFG
    port map (
        I => tx_client_clk_out_0_i,
        O => tx_client_clk_in_0_i
        );


    --------------------------------------------------------------------------
    -- MII client side receive clock for EMAC0
    --------------------------------------------------------------------------
    rx_client_clk_0_bufg : BUFG
    port map (
        I => rx_client_clk_out_0_i,
        O => rx_client_clk_in_0_i
        );

YES_IO_2: if(C_INCLUDE_IO = 1) generate
begin

    --------------------------------------------------------------------------
    -- MII PHY side Transmitter Clock Management for EMAC0
    --------------------------------------------------------------------------
    mii_tx_clk_0_ibufg : IBUFG
    port map (
        I => MII_TX_CLK_0,
        O => mii_tx_clk_0_i
        );

end generate YES_IO_2;

    --------------------------------------------------------------------------
    -- MII client side transmit clock for EMAC1
    --------------------------------------------------------------------------
    tx_client_clk_1_bufg : BUFG
    port map (
        I => tx_client_clk_out_1_i,
        O => tx_client_clk_in_1_i
        );


    --------------------------------------------------------------------------
    -- MII client side receive clock for EMAC1
    --------------------------------------------------------------------------
    rx_client_clk_1_bufg : BUFG
    port map (
        I => rx_client_clk_out_1_i,
        O => rx_client_clk_in_1_i
        );

YES_IO_3: if(C_INCLUDE_IO = 1 and C_RESERVED = 0) generate
begin

    --------------------------------------------------------------------------
    -- MII PHY side Transmitter Clock Management for EMAC1
    --------------------------------------------------------------------------
    mii_tx_clk_1_ibufg : IBUFG
    port map (
        I => MII_TX_CLK_1,
        O => mii_tx_clk_1_i
        );

end generate YES_IO_3;

    --------------------------------------------------------------------------
    -- Connect previously derived client clocks to example design output ports
    --------------------------------------------------------------------------
    RX_CLIENT_CLK_0 <= rx_client_clk_in_0_i;
    TX_CLIENT_CLK_0 <= tx_client_clk_in_0_i;
    RX_CLIENT_CLK_1 <= rx_client_clk_in_1_i;
    TX_CLIENT_CLK_1 <= tx_client_clk_in_1_i;


    --------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper (v4_dual_mii.vhd)
    --------------------------------------------------------------------------
    v4_emac_wrapper : entity xps_ll_temac_v2_03_a.v4_dual_mii(WRAPPER)
    generic map (
                 C_INCLUDE_IO            => C_INCLUDE_IO,
                 C_TEMAC0_PHYADDR        => C_TEMAC0_PHYADDR,
                 C_TEMAC1_PHYADDR        => C_TEMAC1_PHYADDR
                )
    port map (
        -- Client Receiver Interface - EMAC0
        EMAC0CLIENTRXCLIENTCLKOUT       => rx_client_clk_out_0_i,
        CLIENTEMAC0RXCLIENTCLKIN        => rx_client_clk_in_0_i_delay,
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
        CLIENTEMAC0TXCLIENTCLKIN        => tx_client_clk_in_0_i_delay,
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
        GTX_CLK_0                       => gnd_i,

        EMAC0CLIENTTXGMIIMIICLKOUT      => tx_gmii_mii_clk_out_0_i,
        CLIENTEMAC0TXGMIIMIICLKIN       => tx_gmii_mii_clk_in_0_i,

        -- MII Interface - EMAC0
        MII_TXD_0                       => mii_txd_0_i,
        MII_TX_EN_0                     => mii_tx_en_0_i,
        MII_TX_ER_0                     => mii_tx_er_0_i,
        MII_TX_CLK_0                    => tx_gmii_mii_clk_in_0_i,
        --MII_TX_CLK_0                    => mii_tx_clk_0_i,
        MII_RXD_0                       => mii_rxd_0_r,
        MII_RX_DV_0                     => mii_rx_dv_0_r,
        MII_RX_ER_0                     => mii_rx_er_0_r,
        MII_RX_CLK_0                    => mii_rx_clk_0_i,

        -- MDIO Interface - EMAC0
        MDC_0                           => mdc_out_0_i,
        MDIO_IN_0                       => mdio_in_0_i,
        MDIO_OUT_0                      => mdio_out_0_i,
        MDIO_TRI_0                      => mdio_tri_0_i,

        -- Client Receiver Interface - EMAC1
        EMAC1CLIENTRXCLIENTCLKOUT       => rx_client_clk_out_1_i,
        CLIENTEMAC1RXCLIENTCLKIN        => rx_client_clk_in_1_i_delay,
        EMAC1CLIENTRXD                  => EMAC1CLIENTRXD,
        EMAC1CLIENTRXDVLD               => EMAC1CLIENTRXDVLD,
        EMAC1CLIENTRXDVLDMSW            => open,
        EMAC1CLIENTRXGOODFRAME          => EMAC1CLIENTRXGOODFRAME,
        EMAC1CLIENTRXBADFRAME           => EMAC1CLIENTRXBADFRAME,
        EMAC1CLIENTRXFRAMEDROP          => EMAC1CLIENTRXFRAMEDROP,
        EMAC1CLIENTRXDVREG6             => open,
        EMAC1CLIENTRXSTATS              => EMAC1CLIENTRXSTATS,
        EMAC1CLIENTRXSTATSVLD           => EMAC1CLIENTRXSTATSVLD,
        EMAC1CLIENTRXSTATSBYTEVLD       => EMAC1CLIENTRXSTATSBYTEVLD,

        -- Client Transmitter Interface - EMAC1
        EMAC1CLIENTTXCLIENTCLKOUT       => tx_client_clk_out_1_i,
        CLIENTEMAC1TXCLIENTCLKIN        => tx_client_clk_in_1_i_delay,
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
        GTX_CLK_1                       => gnd_i,

        EMAC1CLIENTTXGMIIMIICLKOUT      => tx_gmii_mii_clk_out_1_i,
        CLIENTEMAC1TXGMIIMIICLKIN       => tx_gmii_mii_clk_in_1_i,

        -- MII Interface - EMAC1
        MII_TXD_1                       => mii_txd_1_i,
        MII_TX_EN_1                     => mii_tx_en_1_i,
        MII_TX_ER_1                     => mii_tx_er_1_i,
        --MII_TX_CLK_1                    => mii_tx_clk_1_i,
        MII_TX_CLK_1                    => tx_gmii_mii_clk_in_1_i,
        MII_RXD_1                       => mii_rxd_1_r,
        MII_RX_DV_1                     => mii_rx_dv_1_r,
        MII_RX_ER_1                     => mii_rx_er_1_r,
        MII_RX_CLK_1                    => mii_rx_clk_1_i,

        -- MDIO Interface - EMAC1
        MDC_1                           => mdc_out_1_i,
        MDIO_IN_1                       => mdio_in_1_i,
        MDIO_OUT_1                      => mdio_out_1_i,
        MDIO_TRI_1                      => mdio_tri_1_i,

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

        DCM_LOCKED_0                    => vcc_i,
        DCM_LOCKED_1                    => vcc_i,

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
  MDIO_0_O  <= mdio_out_0_i;
  MDIO_0_T  <= mdio_tri_0_i;



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
  MDIO_1_O  <= mdio_out_1_i;
  MDIO_1_T  <= mdio_tri_1_i;


  -- The Host clock (HOSTCLK on EMAC primitive) must always be driven.
  -- In this example design it is kept as a standalone signal.  However,
  -- this can be shared with one of the other clock sources, for
  -- example, one of the 125MHz PHYEMAC#GTX clock inputs.

  -- host_clk : IBUF port map (I => HOSTCLK, O => host_clk_i);
  
  host_clk_i <= HOSTCLK;
    

  NO_IO_0: if(C_INCLUDE_IO = 0) generate
  begin
    mii_tx_clk_0_i         <= MII_TX_CLK_0;
    tx_gmii_mii_clk_in_0_i <= mii_tx_clk_0_i;
    mii_rx_clk_0_i         <= MII_RX_CLK_0;
  end generate NO_IO_0;

  NO_IO_1: if(C_INCLUDE_IO = 0 and C_RESERVED = 0) generate
  begin
    mii_tx_clk_1_i         <= MII_TX_CLK_1;
    tx_gmii_mii_clk_in_1_i <= mii_tx_clk_1_i;
    mii_rx_clk_1_i         <= MII_RX_CLK_1;
  end generate NO_IO_1;

  RSVD_WRAP_01: if(C_RESERVED = 1) generate  -- wrap
  begin
    mii_rx_clk_1_i <= MII_TX_CLK_0;
    tx_gmii_mii_clk_in_1_i <= mii_tx_clk_1_i;

    wrapthedata : process(RESET, tx_gmii_mii_clk_in_1_i)
    begin
        if RESET = '1' then
            mii_rxd_1_r   <= (others => '0');
            mii_rx_dv_1_r <= '0';
            mii_rx_er_1_r <= '0';
        elsif tx_gmii_mii_clk_in_1_i'event and tx_gmii_mii_clk_in_1_i = '1' then
            mii_rxd_1_r   <= mii_txd_1_i;
            mii_rx_dv_1_r <= mii_tx_en_1_i;
            mii_rx_er_1_r <= mii_tx_er_1_i;
        end if;
    end process wrapthedata;
  end generate RSVD_WRAP_01;

end TOP_LEVEL;
