------------------------------------------------------------------------------
-- $Id: v5_gmii_if.vhd,v 1.1.4.39 2009/11/17 07:11:37 tomaik Exp $
------------------------------------------------------------------------
-- Title      : Gigabit Media Independent Interface (GMII) Physical I/F
-- Project    : Virtex-5 Ethernet MAC Wrappers
------------------------------------------------------------------------
-- File       : v5_gmii_if.vhd
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
entity v5_gmii_if is
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
end v5_gmii_if;

architecture PHY_IF of v5_gmii_if is

  signal vcc_i              : std_logic;
  signal gnd_i              : std_logic;

  signal  GMII_RXD_DLY                      : std_logic_vector(7 downto 0);
  signal  GMII_RX_DV_DLY                    : std_logic;
  signal  GMII_RX_ER_DLY                    : std_logic;

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
        Q => GMII_TX_CLK,
        C => TX_CLK,
        CE => vcc_i,
        D1 => gnd_i,
        D2 => vcc_i,
        R => RESET,
        S => gnd_i
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
          GMII_TX_EN <= '0';
          GMII_TX_ER <= '0';
          GMII_TXD   <= (others => '0');
      elsif TX_CLK'event and TX_CLK = '1' then
          GMII_TX_EN <= TX_EN_FROM_MAC;
          GMII_TX_ER <= TX_ER_FROM_MAC;
          GMII_TXD   <= TXD_FROM_MAC;
      end if;
  end process gmii_output_ffs;

  YES_IO_1: if(C_INCLUDE_IO = 1) generate
  begin
    -- Route GMII inputs through IO delays
    ideld0 : IDELAY generic map (
      IOBDELAY_TYPE   => "FIXED",
      IOBDELAY_VALUE  => 0
      )
      port map(I => GMII_RXD(0), O => GMII_RXD_DLY(0), C => '0', CE => '0', INC => '0', RST => '0');

    ideld1 : IDELAY generic map (
      IOBDELAY_TYPE   => "FIXED",
      IOBDELAY_VALUE  => 0
      )
      port map(I => GMII_RXD(1), O => GMII_RXD_DLY(1), C => '0', CE => '0', INC => '0', RST => '0');

    ideld2 : IDELAY generic map (
      IOBDELAY_TYPE   => "FIXED",
      IOBDELAY_VALUE  => 0
      )
      port map(I => GMII_RXD(2), O => GMII_RXD_DLY(2), C => '0', CE => '0', INC => '0', RST => '0');

    ideld3 : IDELAY generic map (
      IOBDELAY_TYPE   => "FIXED",
      IOBDELAY_VALUE  => 0
      )
      port map(I => GMII_RXD(3), O => GMII_RXD_DLY(3), C => '0', CE => '0', INC => '0', RST => '0');

    ideld4 : IDELAY generic map (
      IOBDELAY_TYPE   => "FIXED",
      IOBDELAY_VALUE  => 0
      )
      port map(I => GMII_RXD(4), O => GMII_RXD_DLY(4), C => '0', CE => '0', INC => '0', RST => '0');

    ideld5 : IDELAY generic map (
      IOBDELAY_TYPE   => "FIXED",
      IOBDELAY_VALUE  => 0
      )
      port map(I => GMII_RXD(5), O => GMII_RXD_DLY(5), C => '0', CE => '0', INC => '0', RST => '0');

    ideld6 : IDELAY generic map (
      IOBDELAY_TYPE   => "FIXED",
      IOBDELAY_VALUE  => 0
      )
      port map(I => GMII_RXD(6), O => GMII_RXD_DLY(6), C => '0', CE => '0', INC => '0', RST => '0');

    ideld7 : IDELAY generic map (
      IOBDELAY_TYPE   => "FIXED",
      IOBDELAY_VALUE  => 0
      )
      port map(I => GMII_RXD(7), O => GMII_RXD_DLY(7), C => '0', CE => '0', INC => '0', RST => '0');

    ideldv : IDELAY generic map (
      IOBDELAY_TYPE   => "FIXED",
      IOBDELAY_VALUE  => 0
      )
      port map (I => GMII_RX_DV, O => GMII_RX_DV_DLY, C => '0', CE => '0', INC => '0', RST => '0');

    ideler : IDELAY generic map (
      IOBDELAY_TYPE   => "FIXED",
      IOBDELAY_VALUE  => 0
      )
      port map (I => GMII_RX_ER, O => GMII_RX_ER_DLY, C => '0', CE => '0', INC => '0', RST => '0');
  end generate YES_IO_1;

  --------------------------------------------------------------------------
  -- GMII Receiver Logic : Receive RX signals through IOBs from GMII
  -- interface
  --------------------------------------------------------------------------
  -- Infer IOB Input flip-flops
  gmii_input_ffs : process (RX_CLK, RESET)
  begin
      if RESET = '1' then
          RX_DV_TO_MAC <= '0';
          RX_ER_TO_MAC <= '0';
          RXD_TO_MAC   <= (others => '0');
      elsif RX_CLK'event and RX_CLK = '1' then
          RX_DV_TO_MAC <= GMII_RX_DV_DLY;
          RX_ER_TO_MAC <= GMII_RX_ER_DLY;
          RXD_TO_MAC   <= GMII_RXD_DLY;
      end if;
  end process gmii_input_ffs;

  NO_IO: if(C_INCLUDE_IO = 0) generate
  begin
    GMII_TX_CLK <= not(TX_CLK);

    GMII_RX_DV_DLY <= GMII_RX_DV;
    GMII_RX_ER_DLY <= GMII_RX_ER;
    GMII_RXD_DLY   <= GMII_RXD;  
  end generate NO_IO;

end PHY_IF;
