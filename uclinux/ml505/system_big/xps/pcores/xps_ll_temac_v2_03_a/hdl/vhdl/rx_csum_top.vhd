------------------------------------------------------------------------------
-- $Id: rx_csum_top.vhd,v 1.1.4.39 2009/11/17 07:11:34 tomaik Exp $
------------------------------------------------------------------------------
-- rx_csum_top.vhd
------------------------------------------------------------------------------
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
------------------------------------------------------------------------------
-- Filename:        rx_csum_top.vhd
-- Version:         v2.00a
-- Description:      
--                   
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--              top_level.vhd
--                  -- second_level_file1.vhd
--                      -- third_level_file1.vhd
--                          -- fourth_level_file.vhd
--                      -- third_level_file2.vhd
--                  -- second_level_file2.vhd
--                  -- second_level_file3.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:      DRP
-- History:
--
--  <initials>      <date>
-- ^^^^^^
--      Description of changes. If multiple lines are needed to fully describe
--      the changes made to the design, these lines should align with each other.
-- ~~~~~~
--
--  <initials>      <date>
-- ^^^^^^
--      More changes
-- ~~~~~~
--
------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of : out   std_logic; port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Libraries used;
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rx_csum_top is
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    enable   : in  std_logic;
    data_in  : in  std_logic_vector(0 to 31);
    ready_n  : in  std_logic;
    data_out : out std_logic_vector(0 to 15)
    );
end entity;

architecture beh of rx_csum_top is

  signal checksum_a : std_logic_vector(16 downto 0);
  signal checksum_b : std_logic_vector(16 downto 0);
  signal checksum   : std_logic_vector(16 downto 0);
  signal checksum_d1: std_logic_vector(15 downto 0);
  signal enable_a   : std_logic;
  signal enable_b   : std_logic;
  signal word_cnt   : integer range 0 to 3;
  signal enable_d1  : std_logic;
  signal endOfEnablePulse    : std_logic;
  signal endOfEnablePulse_d1 : std_logic;
  signal endOfEnablePulse_d2 : std_logic;
  signal endOfEnablePulse_d3 : std_logic;
  signal data_in_d1 : std_logic_vector(0 to 31);

  begin
  
    ---------------------------------------------------------------------------
    -- This process enables the checksum after the 14 byte ethernet header
    ---------------------------------------------------------------------------
    process(clk)
      begin
        if(rising_edge(clk)) then
          if(rst='1' or enable='0') then
            enable_a<='0';
            enable_b<='0';
            word_cnt<= 0;
          else
            if(enable='1' and ready_n = '0') then
              if(word_cnt=2) then
                enable_b <= '1';
                enable_a <= enable_b;
              else
                word_cnt <= word_cnt + 1;
                enable_a <= '0';
                enable_b <= '0';
              end if;
            end if;
          end if;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- this is where the checksum is calculated
    ---------------------------------------------------------------------------

    process(clk)
      begin
        if(rising_edge(clk)) then
          if(rst='1') then
            data_out    <= (others => '0');
            data_in_d1  <= (others => '0');
            checksum    <= (others => '0');
            checksum_d1 <= (others => '0');
          else
            checksum    <= '0'&checksum_b(15 downto 0) + checksum_a(15 downto 0);
            checksum_d1 <= checksum(15 downto 0) + checksum(16);
            data_in_d1  <= data_in;
            if(endOfEnablePulse_d3='1') then
              if(conv_integer(checksum_d1)=0) then
                data_out <= not checksum_d1;
              else
                data_out <= checksum_d1;
              end if;
            end if;
          end if;
        end if;
    end process;

    process(clk)
      begin
        if(rising_edge(clk)) then
          if(rst='1'  or endOfEnablePulse_d3='1') then
            checksum_a    <= (others => '0');
          else
            if(endOfEnablePulse='1') then
              checksum_a    <= '0'&checksum_a(15 downto 0) + checksum_a(16);
            elsif(enable_a='1' and enable='1' and ready_n = '0') then
              checksum_a    <= '0'&checksum_a(15 downto 0) + data_in_d1(0 to 15) + checksum_a(16);
            end if;
          end if;
        end if;
    end process;

    process(clk)
      begin
        if(rising_edge(clk)) then
          if(rst='1'  or endOfEnablePulse_d3='1') then
            checksum_b    <= (others => '0');
          else
            if(endOfEnablePulse='1') then
              checksum_b    <= '0'&checksum_b(15 downto 0) + checksum_b(16);
            elsif(enable_b='1' and enable='1' and ready_n = '0') then
              checksum_b    <= '0'&checksum_b(15 downto 0) + data_in_d1(16 to 31) + checksum_b(16);
            end if;
          end if;
        end if;
    end process;


    process(clk)
      begin
        if(rising_edge(clk)) then
          if(rst='1'  or endOfEnablePulse_d3='1') then
            endOfEnablePulse    <= '0';
            endOfEnablePulse_d1 <= '0';
            endOfEnablePulse_d2 <= '0';
            endOfEnablePulse_d3 <= '0';
            enable_d1           <= '0';
          elsif ready_n = '0' then
            enable_d1           <= enable;
            endOfEnablePulse    <= not(enable) and enable_d1;
            endOfEnablePulse_d1 <= endOfEnablePulse;
            endOfEnablePulse_d2 <= endOfEnablePulse_d1;
            endOfEnablePulse_d3 <= endOfEnablePulse_d2;
          end if;
        end if;
   end process;

end beh;


                      
