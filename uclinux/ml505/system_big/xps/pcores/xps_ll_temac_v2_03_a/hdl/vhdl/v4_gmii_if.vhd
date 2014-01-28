------------------------------------------------------------------------------
-- $Id: v4_gmii_if.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------
-- Title      : Gigabit Media Independent Interface (GMII) Physical I/F
-- Project    : Virtex-4 FX Ethernet MAC Wrappers
------------------------------------------------------------------------
-- File       : v4_gmii_if.vhd
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
-- Description:  This module creates a Gigabit Media Independent 
--               Interface (GMII) by instantiating Input/Output buffers  
--               and Input/Output flip-flops as required.
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
entity v4_gmii_if is
  generic (
           C_INCLUDE_IO               : integer          := 1
          );
    port(
        RESET                         : in  std_logic;
        -- GMII Interface
        GMII_TXD                      : out std_logic_vector(7 downto 0);
        GMII_TX_EN                    : out std_logic;
        GMII_TX_ER                    : out std_logic;
        GMII_TX_CLK                   : out std_logic;
        GMII_RXD                      : in  std_logic_vector(7 downto 0);
        GMII_RX_DV                    : in  std_logic;
        GMII_RX_ER                    : in  std_logic;
        -- MAC Interface
        TXD_FROM_MAC                  : in  std_logic_vector(7 downto 0);
        TX_EN_FROM_MAC                : in  std_logic;
        TX_ER_FROM_MAC                : in  std_logic;
        TX_CLK                        : in  std_logic;
        RXD_TO_MAC                    : out std_logic_vector(7 downto 0);
        RX_DV_TO_MAC                  : out std_logic;
        RX_ER_TO_MAC                  : out std_logic;
        RX_CLK                        : in  std_logic);
end v4_gmii_if;

architecture PHY_IF of v4_gmii_if is

  signal gmii_tx_clk_i      : std_logic;
  signal vcc_i              : std_logic;
  signal gnd_i              : std_logic;

  signal gmii_tx_en_r       : std_logic;
  signal gmii_tx_er_r       : std_logic;
  signal gmii_txd_r         : std_logic_vector(7 downto 0);

  signal gmii_rx_dv_i       : std_logic;
  signal gmii_rx_er_i       : std_logic;
  signal gmii_rxd_i         : std_logic_vector(7 downto 0);
  signal gmii_rx_dv_delay_i : std_logic;
  signal gmii_rx_er_delay_i : std_logic;
  signal gmii_rxd_delay_i   : std_logic_vector(7 downto 0);

begin

  vcc_i <= '1';
  gnd_i <= '0';

  YES_IO: if(C_INCLUDE_IO = 1) generate
  begin
    --------------------------------------------------------------------------
    -- GMII Transmitter Clock Management
    --------------------------------------------------------------------------
    -- Instantiate a DDR output register.  This is a good way to drive
    -- GMII_TX_CLK since the clock-to-PAD delay will be the same as that for
    -- data driven from IOB Ouput flip-flops eg GMII_TXD[7:0].

    gmii_tx_clk_oddr : ODDR
    port map (
        Q => gmii_tx_clk_i,
        C => TX_CLK,
        CE => vcc_i,
        D1 => gnd_i,
        D2 => vcc_i,
        R => RESET,
        S => gnd_i
    );
  
    gmii_tx_clk_obuf : OBUF 
    port map (
        I => gmii_tx_clk_i, 
        O => GMII_TX_CLK
        );
  end generate YES_IO;

  --------------------------------------------------------------------------
  -- GMII Transmitter Logic : Drive TX signals through IOBs onto GMII
  -- interface
  --------------------------------------------------------------------------
  -- Infer IOB Output flip-flops.
  gmii_output_ffs : process (TX_CLK, RESET)
  begin
      if RESET = '1' then
          gmii_tx_en_r <= '0';
          gmii_tx_er_r <= '0';
          gmii_txd_r   <= (others => '0');
      elsif TX_CLK'event and TX_CLK = '1' then
          gmii_tx_en_r <= TX_EN_FROM_MAC;
          gmii_tx_er_r <= TX_ER_FROM_MAC;
          gmii_txd_r   <= TXD_FROM_MAC;
      end if;
  end process gmii_output_ffs;

  YES_IO_1: if(C_INCLUDE_IO = 1) generate
  begin
    -- Drive GMII TX signals through Output Buffers and onto PADS
    gmii_tx_en_obuf : OBUF port map (I => gmii_tx_en_r, O => GMII_TX_EN);
    gmii_tx_er_obuf : OBUF port map (I => gmii_tx_er_r, O => GMII_TX_ER);

    gmii_txd_bus: for I in 7 downto 0 generate
        gmii_txd_0_obuf : OBUF 
        port map (
            I => gmii_txd_r(I),
            O => GMII_TXD(I)
            );
    end generate;

  --------------------------------------------------------------------------
  -- GMII Receiver Logic : Receive RX signals through IOBs from GMII
  -- interface
  --------------------------------------------------------------------------

    -- Drive input GMII Rx signals from PADS through Input Buffers and then 
    -- use IDELAYs to provide Zero-Hold Time Delay 
    gmii_rx_dv_ibuf: IBUF port map (I => GMII_RX_DV, O => gmii_rx_dv_i);

    gmii_rx_er_ibuf: IBUF port map (I => GMII_RX_ER, O => gmii_rx_er_i);

    gmii_rxd_bus: for I in 7 downto 0 generate
      gmii_rxd_ibuf: IBUF
        port map (
            I => GMII_RXD(I),
            O => gmii_rxd_i(I)
            );
    end generate;

    -- Use IDELAY to delay the data relative to the clock.
    -- The IDELAY is configured in Fixed Tap Delay Mode.  Each tap delay is 78 ps.
    -- The attributes can be changed in the UCF file.
    gmii_rxd_delay_bus: for I in 7 downto 0 generate
      gmii_rxd0_delay : IDELAY
      generic map (
        IOBDELAY_TYPE => "FIXED",
        IOBDELAY_VALUE => 60
          )
      port map (
          I   => gmii_rxd_i(I),
          O   => gmii_rxd_delay_i(I),
          C   => gnd_i,
          CE  => gnd_i,
          INC => gnd_i,
          RST => gnd_i
          );
    end generate;

    gmii_rx_dv_delay : IDELAY
    generic map (
      IOBDELAY_TYPE => "FIXED",
      IOBDELAY_VALUE => 60
        )
    port map (
        I   => gmii_rx_dv_i,
        O   => gmii_rx_dv_delay_i,
        C   => gnd_i,
        CE  => gnd_i,
        INC => gnd_i,
        RST => gnd_i
        );

    gmii_rx_er_delay : IDELAY
    generic map (
      IOBDELAY_TYPE => "FIXED",
      IOBDELAY_VALUE => 60
        )
    port map (
        I   => gmii_rx_er_i,
        O   => gmii_rx_er_delay_i,
        C   => gnd_i,
        CE  => gnd_i,
        INC => gnd_i,
        RST => gnd_i
        );
  end generate YES_IO_1;

  -- Infer IOB Input flip-flops
  gmii_input_ffs : process (RX_CLK, RESET)
  begin
      if RESET = '1' then
          RX_DV_TO_MAC <= '0';
          RX_ER_TO_MAC <= '0';
          RXD_TO_MAC   <= (others => '0');
      elsif RX_CLK'event and RX_CLK = '1' then
          RX_DV_TO_MAC <= gmii_rx_dv_delay_i;
          RX_ER_TO_MAC <= gmii_rx_er_delay_i;
          RXD_TO_MAC   <= gmii_rxd_delay_i;
      end if;
  end process gmii_input_ffs;

  NO_IO: if(C_INCLUDE_IO = 0) generate
  begin
    GMII_TX_CLK <= not(TX_CLK);

    GMII_TX_EN <= gmii_tx_en_r;
    GMII_TX_ER <= gmii_tx_er_r;
    GMII_TXD   <= gmii_txd_r;

    gmii_rx_dv_delay_i <= GMII_RX_DV;
    gmii_rx_er_delay_i <= GMII_RX_ER;
    gmii_rxd_delay_i   <= GMII_RXD;  
  end generate NO_IO;

end PHY_IF;
