------------------------------------------------------------------------------
-- $Id: v5_rgmii13_if.vhd,v 1.1.4.39 2009/11/17 07:11:37 tomaik Exp $
------------------------------------------------------------------------
-- Title      : Reduced Gigabit Media Independent Interface (RGMII) v1.3
-- Project    : Virtex-5 Ethernet MAC Wrappers
------------------------------------------------------------------------
-- File       : v5_rgmii13_if.vhd
------------------------------------------------------------------------
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
------------------------------------------------------------------------
-- Description:  This module creates a version 1.3 Reduced Gigabit Media  
--               Independent Interface (RGMII v1.3) by instantiating   
--               Input/Output buffers and Input/Output double data rate  
--               (DDR) flip-flops as required.
--
--               This interface is used to connect the Ethernet MAC to
--               an external 1000Mb/s (or Tri-speed) Ethernet PHY.
--
--               This is based on Coregen Wrappers from ISE K (10.1i)
--               Wrapper version 1.4
------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------------------------
-- The entity declaration for the PHY IF design.
------------------------------------------------------------------------------
entity v5_rgmii13_if is
  generic (
           C_INCLUDE_IO               : integer          := 1
          );
    port(
        RESET                         : in  std_logic;
        -- RGMII Interface
        RGMII_TXD                     : out std_logic_vector(3 downto 0);
        RGMII_TX_CTL                  : out std_logic;
        RGMII_TXC                     : out std_logic;
        RGMII_RXD                     : in  std_logic_vector(3 downto 0);
        RGMII_RX_CTL                  : in  std_logic;
        -- MAC Interface
        TXD_RISING_FROM_MAC           : in  std_logic_vector(3 downto 0);
        TXD_FALLING_FROM_MAC          : in  std_logic_vector(3 downto 0);
        TX_CTL_RISING_FROM_MAC        : in  std_logic;
        TX_CTL_FALLING_FROM_MAC       : in  std_logic;
        TX_CLK                        : in  std_logic;
        RXD_RISING_TO_MAC             : out std_logic_vector(3 downto 0);
        RXD_FALLING_TO_MAC            : out std_logic_vector(3 downto 0);
        RX_CTL_RISING_TO_MAC          : out std_logic;
        RX_CTL_FALLING_TO_MAC         : out std_logic;
        RX_CLK                        : in  std_logic);

end v5_rgmii13_if;

architecture PHY_IF of v5_rgmii13_if is

  signal vcc_i          : std_logic;
  signal gnd_i          : std_logic;

  signal txd_rising_i     : std_logic_vector(3 downto 0);
  signal txd_falling_i    : std_logic_vector(3 downto 0);
  signal tx_ctl_rising_i  : std_logic;
  signal tx_ctl_falling_i : std_logic;

  signal rgmii_rxd_delay  : std_logic_vector(3 downto 0);
  signal rgmii_ctl_delay  : std_logic;

begin

    gnd_i <= '0';
    vcc_i <= '1';

    -- Instantiate a DDR output register.  This is a good way to drive
    -- RGMII_TXC since the clock-to-PAD delay will be the same as that for
    -- data driven from IOB Ouput flip-flops eg RGMII_TXD[3:0].
    rgmii_txc_oddr : ODDR
    generic map (SRTYPE => "ASYNC")
    port map(
        Q => RGMII_TXC,
        C => TX_CLK,
        CE => vcc_i,
        D1 => vcc_i,
        D2 => gnd_i,
        R => RESET,
        S => gnd_i
    );

    regrgmiirtx : process(TX_CLK, RESET)
    begin
      if RESET = '1' then
        txd_rising_i    <= (others => '0');
        tx_ctl_rising_i <= '0';
      elsif TX_CLK'event and TX_CLK = '1' then
        txd_rising_i    <= TXD_RISING_FROM_MAC;
        tx_ctl_rising_i <= TX_CTL_RISING_FROM_MAC;
      end if;
    end process regrgmiirtx;

    regrgmiiftx : process(TX_CLK, RESET)
    begin
      if RESET = '1' then
        txd_falling_i    <= (others => '0');
        tx_ctl_falling_i <= '0';
      elsif TX_CLK'event and TX_CLK = '0' then
        txd_falling_i    <= TXD_FALLING_FROM_MAC;
        tx_ctl_falling_i <= TX_CTL_FALLING_FROM_MAC;
      end if;
    end process regrgmiiftx;

    --------------------------------------------------------------------------
    -- RGMII Transmitter Logic:  Use DDR Flip-Flops to clock the TX data on
    -- both the positive edge and negative edge which is then transmitted to
    -- the PHY
    --------------------------------------------------------------------------
    rgmii_tx_ctl_oddr : ODDR
    generic map (SRTYPE => "ASYNC")
    port map (
        Q  => RGMII_TX_CTL,
        C  => TX_CLK,
        CE => vcc_i,
        D1 => tx_ctl_rising_i,
        D2 => tx_ctl_falling_i,
        R  => RESET,
        S  => gnd_i
        );

    rgmii_txd_ddr_regs : for I in 0 to 3 generate
        rgmii_txd_oddr : ODDR
        generic map (SRTYPE => "ASYNC")
        port map (
            Q  => RGMII_TXD(I),
            C  => TX_CLK,
            CE => vcc_i,
            D1 => txd_rising_i(I),
            D2 => txd_falling_i(I),
            R  => RESET,
            S  => gnd_i
            );
    end generate rgmii_txd_ddr_regs;

    --------------------------------------------------------------------------
    -- RGMII Receiver Logic:
    --------------------------------------------------------------------------
    -- Use IDELAY to align the data to the clock
    -- The IDELAY is configured in Fixed Tap Delay Mode.
    -- IDELAYCTRL primitives need to be instantiated for the Fixed Tap Delay
    -- mode of the IDELAY.
    -- All IDELAYs in Fixed Tap Delay mode and the IDELAYCTRL primitives have
    -- to be LOC'ed in the UCF file.

    -- Please modify the value of the IOBDELAYs according to your design.
    -- For more information on IDELAYCTRL and IDELAY, please refer to 
    -- the Virtex-5 User Guide.
    rgmii_rx_ctl_delay : IDELAY
    generic map (
     IOBDELAY_TYPE   => "FIXED",
     IOBDELAY_VALUE  => 0
    )
    port map (
     I    => RGMII_RX_CTL,
     O    => rgmii_ctl_delay,
     C    => gnd_i,
     CE   => gnd_i,
     INC  => gnd_i,
     RST  => gnd_i);

    rgmii_rx_d0_delay : IDELAY
    generic map (
     IOBDELAY_TYPE   => "FIXED",
     IOBDELAY_VALUE  => 0
    )
    port map (
     I    => RGMII_RXD(0),
     O    => rgmii_rxd_delay(0),
     C    => gnd_i,
     CE   => gnd_i,
     INC  => gnd_i,
     RST  => gnd_i);

    rgmii_rx_d1_delay : IDELAY
    generic map (
     IOBDELAY_TYPE   => "FIXED",
     IOBDELAY_VALUE  => 0
    )
    port map (
     I    => RGMII_RXD(1),
     O    => rgmii_rxd_delay(1),
     C    => gnd_i,
     CE   => gnd_i,
     INC  => gnd_i,
     RST  => gnd_i);

    rgmii_rx_d2_delay : IDELAY
    generic map (
     IOBDELAY_TYPE   => "FIXED",
     IOBDELAY_VALUE  => 0
    )
    port map (
     I    => RGMII_RXD(2),
     O    => rgmii_rxd_delay(2),
     C    => gnd_i,
     CE   => gnd_i,
     INC  => gnd_i,
     RST  => gnd_i);

    rgmii_rx_d3_delay : IDELAY
    generic map (
     IOBDELAY_TYPE   => "FIXED",
     IOBDELAY_VALUE  => 0
    )
    port map (
     I    => RGMII_RXD(3),
     O    => rgmii_rxd_delay(3),
     C    => gnd_i,
     CE   => gnd_i,
     INC  => gnd_i,
     RST  => gnd_i);

    -------------------------------------------------------------------------
    -- Use DDR Flip-Flops to clock the RX data from the
    -- PHY on both the positive edge and negative edge
    --------------------------------------------------------------------------
    rgmii_rx_ctl_iddr : IDDR
    port map (
        Q1 => RX_CTL_RISING_TO_MAC,
        Q2 => RX_CTL_FALLING_TO_MAC,
        C  => RX_CLK,
        CE => vcc_i,
        D  => rgmii_ctl_delay,
        R  => gnd_i,
        S  => gnd_i
        );

    rgmii_rxd_ddr_regs : for I in 0 to 3 generate
        rgmii_rxd_iddr : IDDR
        port map (
            Q1 => RXD_RISING_TO_MAC(I),
            Q2 => RXD_FALLING_TO_MAC(I),
            C  => RX_CLK,
            CE => vcc_i,
            D  => rgmii_rxd_delay(I),
            R  => gnd_i,
            S  => gnd_i
            );
    end generate rgmii_rxd_ddr_regs; 

end PHY_IF;
