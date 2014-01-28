------------------------------------------------------------------------------
-- $Id: v4_mii_if.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------
-- Title      : Media Independent Interface (MII) Physical Interface
-- Project    : Virtex-4 FX Ethernet MAC Wrappers
------------------------------------------------------------------------
-- File       : v4_mii_if.vhd
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
-- Description:  This module creates a Media Independent Interface (MII)
--               by instantiating Input/Output buffers and Input/Output 
--               flip-flops as required.
--
--               This interface is used to connect the Ethernet MAC to
--               an external 10Mb/s and 100Mb/s Ethernet PHY.
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
entity v4_mii_if is
  generic (
           C_INCLUDE_IO               : integer          := 1
          );
    port(
        RESET                         : in  std_logic;
        -- MII Interface
        MII_TXD                       : out std_logic_vector(3 downto 0);
        MII_TX_EN                     : out std_logic;
        MII_TX_ER                     : out std_logic;
        MII_RXD                       : in  std_logic_vector(3 downto 0);
        MII_RX_DV                     : in  std_logic;
        MII_RX_ER                     : in  std_logic;
        -- MAC Interface
        TXD_FROM_MAC                  : in  std_logic_vector(3 downto 0);
        TX_EN_FROM_MAC                : in  std_logic;
        TX_ER_FROM_MAC                : in  std_logic;
        TX_CLK                        : in  std_logic;
        RXD_TO_MAC                    : out std_logic_vector(3 downto 0);
        RX_DV_TO_MAC                  : out std_logic;
        RX_ER_TO_MAC                  : out std_logic;
        RX_CLK                        : in  std_logic);
end v4_mii_if;

architecture PHY_IF of v4_mii_if is

  signal vcc_i              : std_logic;
  signal gnd_i              : std_logic;

  signal mii_tx_en_r        : std_logic;
  signal mii_tx_er_r        : std_logic;
  signal mii_txd_r          : std_logic_vector(3 downto 0);

  signal mii_rx_dv_i        : std_logic;
  signal mii_rx_er_i        : std_logic;
  signal mii_rxd_i          : std_logic_vector(3 downto 0);

  signal mii_tx_clk_i       : std_logic;

begin

  vcc_i <= '1';
  gnd_i <= '0';

  --------------------------------------------------------------------------
  -- MII Transmitter Logic : Drive TX signals through IOBs onto MII
  -- interface
  --------------------------------------------------------------------------
  -- Infer IOB Output flip-flops.
  mii_output_ffs : process (TX_CLK, RESET)
  begin
      if RESET = '1' then
          mii_tx_en_r <= '0';
          mii_tx_er_r <= '0';
          mii_txd_r   <= (others => '0');
      elsif TX_CLK'event and TX_CLK = '1' then
          mii_tx_en_r <= TX_EN_FROM_MAC;
          mii_tx_er_r <= TX_ER_FROM_MAC;
          mii_txd_r   <= TXD_FROM_MAC;
      end if;
  end process mii_output_ffs;

  YES_IO_1: if(C_INCLUDE_IO = 1) generate
  begin
    -- Drive MII TX signals through Output Buffers and onto PADS
    mii_tx_en_obuf : OBUF port map (I => mii_tx_en_r, O => MII_TX_EN);
    mii_tx_er_obuf : OBUF port map (I => mii_tx_er_r, O => MII_TX_ER);

    mii_txd_bus: for I in 3 downto 0 generate
        mii_txd_obuf : OBUF
        port map (
            I => mii_txd_r(I),
            O => MII_TXD(I)
            );
    end generate;

    --------------------------------------------------------------------------
    -- MII Receiver Logic : Receive RX signals through IOBs from MII
    -- interface
    --------------------------------------------------------------------------
    -- Drive input MII Rx signals from PADS through Input Buffers and then 
    -- use IDELAYs to provide Zero-Hold Time Delay 
    mii_rx_dv_ibuf: IBUF port map (I => MII_RX_DV, O => mii_rx_dv_i);

    mii_rx_er_ibuf: IBUF port map (I => MII_RX_ER, O => mii_rx_er_i);

    mii_rxd_bus: for I in 3 downto 0 generate
        mii_rxd_ibuf: IBUF
        port map (
            I => MII_RXD(I),
            O => mii_rxd_i(I)
            );
    end generate;
  end generate YES_IO_1;

  -- Infer IOB Input flip-flops
  mii_input_ffs : process (RX_CLK, RESET)
  begin
      if RESET = '1' then
          RX_DV_TO_MAC <= '0';
          RX_ER_TO_MAC <= '0';
          RXD_TO_MAC   <= (others => '0');
      elsif RX_CLK'event and RX_CLK = '1' then
          RX_DV_TO_MAC <= mii_rx_dv_i;
          RX_ER_TO_MAC <= mii_rx_er_i;
          RXD_TO_MAC   <= mii_rxd_i;
      end if;
  end process mii_input_ffs;

  NO_IO_0: if(C_INCLUDE_IO = 0) generate
  begin
    MII_TX_EN   <= mii_tx_en_r;
    MII_TX_ER   <= mii_tx_er_r;
    MII_TXD     <= mii_txd_r;
    mii_rx_dv_i <= MII_RX_DV;
    mii_rx_er_i <= MII_RX_ER;
    mii_rxd_i   <= MII_RXD;
  end generate NO_IO_0;
end PHY_IF;