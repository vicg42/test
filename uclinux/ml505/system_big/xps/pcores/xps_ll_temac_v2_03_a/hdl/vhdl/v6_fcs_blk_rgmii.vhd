--------------------------------------------------------------------------------
-- Title      : FCS Block for the RGMII Physical Interface
-- Project    : Virtex-6 Embedded Tri-Mode Ethernet MAC Wrapper
------------------------------------------------------------------------------
-- $Id: v6_fcs_blk_rgmii.vhd,v 1.1.4.39 2009/11/17 07:11:38 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : Virtex-6 Ethernet MAC Wrapper Top Level
-- Project    : Virtex-6 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v6_fcs_blk_rgmii.vhd
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
-- Description: This file assures proper frame transmission by suppressing
--              duplicate FCS bytes should they occur.
--              This file operates with the RGMII physical interface, and the
--              Clock Enable advanced clocking scheme only.
--
--              This is based on Coregen Wrappers from ISE L (11.3i)
--              Wrapper version 1.3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity v6_fcs_blk_rgmii is
  port(
    -- Global signals
    reset                   : in  std_logic;

    -- PHY-side input signals
    tx_phy_clk              : in  std_logic;
    txd_rising_from_mac     : in  std_logic_vector(3 downto 0);
    txd_falling_from_mac    : in  std_logic_vector(3 downto 0);
    tx_ctl_rising_from_mac  : in  std_logic;
    tx_ctl_falling_from_mac : in  std_logic;

    -- Client-side signals
    tx_client_clk           : in  std_logic;
    tx_stats_byte_valid     : in  std_logic;
    tx_collision            : in  std_logic;
    speed_is_10_100         : in  std_logic;

    -- PHY outputs
    txd_rising              : out std_logic_vector(3 downto 0);
    txd_falling             : out std_logic_vector(3 downto 0);
    tx_ctl_rising           : out std_logic;
    tx_ctl_falling          : out std_logic
  );
end v6_fcs_blk_rgmii;

architecture rtl of v6_fcs_blk_rgmii is

  -- Pipeline registers
  signal txd_rising_r1         : std_logic_vector(3 downto 0);
  signal txd_rising_r2         : std_logic_vector(3 downto 0);
  signal txd_falling_r1        : std_logic_vector(3 downto 0);
  signal txd_falling_r2        : std_logic_vector(3 downto 0);
  signal tx_ctl_rising_r1      : std_logic;
  signal tx_ctl_rising_r2      : std_logic;
  signal tx_ctl_falling_r1     : std_logic;
  signal tx_ctl_falling_r2     : std_logic;

  -- For detecting frame end
  signal tx_stats_byte_valid_r : std_logic;

  -- Counters
  signal tx_en_count           : unsigned(2 downto 0);
  signal tx_byte_count         : unsigned(1 downto 0);
  signal tx_byte_count_r       : unsigned(1 downto 0);

  -- Suppression control signals
  signal collision_r           : std_logic;
  signal tx_ctl_suppress       : std_logic;
  signal tx_ctl_suppress_r     : std_logic;
  signal tx_ctl_suppress_r2    : std_logic;
  signal speed_is_10_100_r     : std_logic;

  attribute async_reg : string;
  attribute async_reg of collision_r       : signal is "true";
  attribute async_reg of speed_is_10_100_r : signal is "true";

begin

  -- Create a two-stage pipeline of PHY output signals in preparation for extra
  -- FCS byte determination and TX_CTL suppression if one is present.
  -- Rising-edge registers
  pipegenr : process(tx_phy_clk, reset)
  begin
    if reset = '1' then
      txd_rising_r1    <= X"0";
      txd_rising_r2    <= X"0";
      tx_ctl_rising_r1 <= '0';
      tx_ctl_rising_r2 <= '0';
    elsif tx_phy_clk'event and tx_phy_clk = '1' then
      txd_rising_r1    <= txd_rising_from_mac;
      txd_rising_r2    <= txd_rising_r1;
      tx_ctl_rising_r1 <= tx_ctl_rising_from_mac;
      tx_ctl_rising_r2 <= tx_ctl_rising_r1;
    end if;
  end process pipegenr;
  -- Falling-edge registers
  pipegenf : process(tx_phy_clk, reset)
  begin
    if reset = '1' then
      txd_falling_r1    <= X"0";
      txd_falling_r2    <= X"0";
      tx_ctl_falling_r1 <= '0';
      tx_ctl_falling_r2 <= '0';
    elsif tx_phy_clk'event and tx_phy_clk = '0' then
      txd_falling_r1    <= txd_falling_from_mac;
      txd_falling_r2    <= txd_falling_r1;
      tx_ctl_falling_r1 <= tx_ctl_falling_from_mac;
      tx_ctl_falling_r2 <= tx_ctl_falling_r1;
    end if;
  end process pipegenf;

  -- On the PHY-side clock, count the number of rising edges that TX_CTL
  -- remains asserted for (TX_EN cycles). Only 3 bits are needed for comparison.
  phycountgen : process(tx_phy_clk)
  begin
    if tx_phy_clk'event and tx_phy_clk = '1' then
      if tx_ctl_rising_from_mac = '1' then
        tx_en_count <= tx_en_count + 1;
      else
        tx_en_count <= (others => '0');
      end if;
    end if;
  end process phycountgen;

  -- On the client-side clock, count the number of cycles that the stats byte
  -- valid signal remains asserted for. Only 2 bits are needed for comparison.
  clientcountgen : process(tx_client_clk)
  begin
    if tx_client_clk'event and tx_client_clk = '1' then
      tx_stats_byte_valid_r <= tx_stats_byte_valid;
      speed_is_10_100_r     <= speed_is_10_100;
      if tx_stats_byte_valid = '1' then
        tx_byte_count <= tx_byte_count + 1;
      else
        tx_byte_count <= (others => '0');
      end if;
    end if;
  end process clientcountgen;

  -- Capture the final stats byte valid count for the frame.
  clientcapgen : process(tx_client_clk)
  begin
    if tx_client_clk'event and tx_client_clk = '1' then
      if tx_stats_byte_valid_r = '1' and tx_stats_byte_valid = '0' then
        tx_byte_count_r   <= tx_byte_count;
      end if;
    end if;
  end process clientcapgen;

  -- Generate a signal to suppress TX_CTL if the two counts don't match.
  -- (Both counters will be stable when this comparison happens, so clock
  -- domain crossing is not a concern.)
  -- Since the Clock Enable scheme is in use, PHY and client clocks are the same
  -- frequency, so the lower two bits of each counter are compared.
  tx_ctl_suppress <= '1' when ((tx_ctl_rising_from_mac = '0' and tx_ctl_rising_r1 = '1')
                           and (tx_en_count(1 downto 0) /= tx_byte_count_r))
                         else '0';

  -- Register the signal twice as TX_CTL needs to be suppressed over two
  -- nibbles. Also register tx_collision for use in the suppression logic.
  txsuppressgen : process(tx_phy_clk)
  begin
    if tx_phy_clk'event and tx_phy_clk = '1' then
      tx_ctl_suppress_r  <= tx_ctl_suppress;
      tx_ctl_suppress_r2 <= tx_ctl_suppress_r;
      if tx_collision = '1' then
        collision_r <= '1';
      elsif tx_ctl_rising_r2 = '0' then
        collision_r <= '0';
      end if;
    end if;
  end process txsuppressgen;

  -- Multiplex output signals. When operating at 1 Gbps, bypass this logic
  -- entirely. Otherwise, assign TXD to its pipelined outputs. If a collision
  -- has occurred, assign TX_CTL directly so as to maintain a jam sequence of
  -- 32 bits. Suppress TX_CTL if an extra FCS byte is present.
  txd_rising     <= txd_rising_from_mac     when  speed_is_10_100_r = '0' else txd_rising_r2;
  txd_falling    <= txd_falling_from_mac    when  speed_is_10_100_r = '0' else txd_falling_r2;
  tx_ctl_falling <= tx_ctl_falling_from_mac when (speed_is_10_100_r = '0' or collision_r = '1')
           else tx_ctl_falling_r2 and not (tx_ctl_suppress_r or tx_ctl_suppress_r2);
  tx_ctl_rising  <= tx_ctl_rising_from_mac  when (speed_is_10_100_r = '0' or collision_r = '1')
           else tx_ctl_rising_r2  and not (tx_ctl_suppress   or tx_ctl_suppress_r);

end rtl;

