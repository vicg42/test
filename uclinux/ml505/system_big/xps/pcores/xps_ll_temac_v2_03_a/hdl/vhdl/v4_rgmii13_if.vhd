------------------------------------------------------------------------------
-- $Id: v4_rgmii13_if.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------
-- Title      : Reduced Gigabit Media Independent Interface (RGMII) v1.3
-- Project    : Virtex-4 FX Ethernet MAC Wrappers
------------------------------------------------------------------------
-- File       : v4_rgmii13_if.vhd
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
--               This is based on Coregen Wrappers from ISE J.38 (9.2i)
--               Wrapper version 4.5
------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------------------------
-- The entity declaration for the PHY IF design.
------------------------------------------------------------------------------
entity v4_rgmii13_if is
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

end v4_rgmii13_if;

architecture PHY_IF of v4_rgmii13_if is

  signal vcc_i          : std_logic;
  signal gnd_i          : std_logic;
  signal rgmii_txc_i    : std_logic;

  signal rgmii_tx_ctl_i : std_logic;
  signal rgmii_txd_i    : std_logic_vector(3 downto 0);

  signal rgmii_rx_ctl_i : std_logic;
  signal rgmii_rxd_i    : std_logic_vector(3 downto 0);

  signal rgmii_rx_ctl_delay_i : std_logic;
  signal rgmii_rxd_delay_i    : std_logic_vector(3 downto 0);

begin

    gnd_i <= '0';
    vcc_i <= '1';

    -- Instantiate a DDR output register.  This is a good way to drive
    -- RGMII_TXC since the clock-to-PAD delay will be the same as that for
    -- data driven from IOB Ouput flip-flops eg RGMII_TXD[3:0].
    rgmii_txc_oddr : ODDR
    generic map (SRTYPE => "ASYNC")
    port map(
        Q => rgmii_txc_i,
        C => TX_CLK,
        CE => vcc_i,
        D1 => vcc_i,
        D2 => gnd_i,
        R => RESET,
        S => gnd_i
    );

    -- Drive clock through Output Buffers and onto PADS.
    rgmii_txc_0_obuf: OBUF port map (I => rgmii_txc_i, O => RGMII_TXC);

    --------------------------------------------------------------------------
    -- RGMII Transmitter Logic:  Use DDR Flip-Flops to clock the TX data on
    -- both the positive edge and negative edge which is then transmitted to
    -- the PHY
    --------------------------------------------------------------------------
    rgmii_tx_ctl_oddr : ODDR
    generic map (SRTYPE => "ASYNC")
    port map (
        Q  => rgmii_tx_ctl_i,
        C  => TX_CLK,
        CE => vcc_i,
        D1 => TX_CTL_RISING_FROM_MAC,
        D2 => TX_CTL_FALLING_FROM_MAC,
        R  => RESET,
        S  => gnd_i
        );

    rgmii_txd_ddr_regs : for I in 0 to 3 generate
        rgmii_txd0_oddr : ODDR
        generic map (SRTYPE => "ASYNC")
        port map (
            Q  => rgmii_txd_i(I),
            C  => TX_CLK,
            CE => vcc_i,
            D1 => TXD_RISING_FROM_MAC(I),
            D2 => TXD_FALLING_FROM_MAC(I),
            R  => RESET,
            S  => gnd_i
            );
    end generate rgmii_txd_ddr_regs;

    -- Drive RGMII TX signals through Output Buffers and onto PADS
    rgmii_tx_ctl_obuf : OBUF
    port map (
        I => rgmii_tx_ctl_i,
        O => RGMII_TX_CTL
        );

    rgmii_txd_bus : for I in 3 downto 0 generate
        rgmii_txd_obuf : OBUF
        port map (
            I => rgmii_txd_i(I),
            O => RGMII_TXD(I)
            );
    end generate rgmii_txd_bus;

    --------------------------------------------------------------------------
    -- RGMII Receiver Logic:  Use DDR Flip-Flops to clock the RX data from the
    -- PHY on both the positive edge and negative edge
    --------------------------------------------------------------------------
    -- Drive input RGMII Rx signals from PADS through Input Buffers
    rgmii_rx_ctl_0_ibuf: IBUF
    port map (
        I => RGMII_RX_CTL,
        O => rgmii_rx_ctl_i
        );

    rgmii_rxd_bus: for I in 3 downto 0 generate
        rgmii_rxd_ibuf: IBUF
        port map (
            I => RGMII_RXD(I),
            O => rgmii_rxd_i(I)
            );
    end generate rgmii_rxd_bus;

    -- Use IDELAY to delay the data relative to the clock.
    -- The IDELAY is configured in Fixed Tap Delay Mode.  Each tap delay is 78 ps.
    -- The attribute values can be changed in the UCF file.
    rgmii_rx_ctl_delay : IDELAY
    generic map (
        IOBDELAY_TYPE => "FIXED",
        IOBDELAY_VALUE => 0
        )
    port map (
        I   => rgmii_rx_ctl_i,
        O   => rgmii_rx_ctl_delay_i,
        C   => gnd_i,
        CE  => gnd_i,
        INC => gnd_i,
        RST => gnd_i
        );

    rgmii_rxd_delay_bus: for I in 3 downto 0 generate
      rgmii_rxd0_delay : IDELAY
      generic map (
          IOBDELAY_TYPE => "FIXED",
          IOBDELAY_VALUE => 0
          )
      port map (
          I   => rgmii_rxd_i(I),
          O   => rgmii_rxd_delay_i(I),
          C   => gnd_i,
          CE  => gnd_i,
          INC => gnd_i,
          RST => gnd_i
          );
    end generate rgmii_rxd_delay_bus;

    rgmii_rx_ctl_iddr : IDDR
    port map (
        Q1 => RX_CTL_RISING_TO_MAC,
        Q2 => RX_CTL_FALLING_TO_MAC,
        C  => RX_CLK,
        CE => vcc_i,
        D  => rgmii_rx_ctl_delay_i,
        R  => gnd_i,
        S  => gnd_i
        );

    rgmii_rxd_ddr_regs : for I in 0 to 3 generate
        rgmii_rxd0_iddr : IDDR
        port map (
            Q1 => RXD_RISING_TO_MAC(I),
            Q2 => RXD_FALLING_TO_MAC(I),
            C  => RX_CLK,
            CE => vcc_i,
            D  => rgmii_rxd_delay_i(I),
            R  => gnd_i,
            S  => gnd_i
            );
    end generate rgmii_rxd_ddr_regs; 

end PHY_IF;
