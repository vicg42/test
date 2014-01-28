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
-- Filename:        tx_csum_top_wrapper.vhd
-- Version:         v1.00a
-- Description:     tx checksum wrapper for tx_csum_top.vhd
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to
--                improve readability.
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
--  DRP      2006.04.24      -- First version
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

--library csum_v1_00_a;
--use csum_v1_00_a.all;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

------------------------------------------------------------------------------
-- Port Declaration
------------------------------------------------------------------------------

entity tx_csum_top_wrapper is
   generic(
      C_FIFO_DEPTH_LOG2X : integer := 13
      );
   port(
      Clk                  : in  std_logic;
      Rst                  : in  std_logic;
      Din                  : in  std_logic_vector(0 to 31);
      Wren                 : in  std_logic;
      LLTemac_SOF_n        : in  std_logic;
      LLTemac_EOP_n        : in  std_logic;
      LLTemac_DST_RDY_n    : in  std_logic;
      LLTemac_SRC_RDY_n    : in  std_logic;
      Csum_insert          : out std_logic_vector(0 to 15);
      Csum_en              : out std_logic;
      Csum_wren            : out std_logic;
      Csum_data            : out std_logic_vector(0 to 15)
      );
end tx_csum_top_wrapper;

------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
--
------------------------------------------------------------------------------

architecture beh of tx_csum_top_wrapper is


------------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------------
  constant DELAY : integer := 0;

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------


  signal cs_insert     : std_logic_vector(0 to 15);
  signal cs_begin      : std_logic_vector(0 to 15);
  signal cs_init       : std_logic_vector(0 to 15);
  signal cs_en         : std_logic;
  signal cs_wren       : std_logic;
  signal cs_data       : std_logic_vector(0 to 31);
  signal addr_cntr     : std_logic_vector(0 to C_FIFO_DEPTH_LOG2X-1);
  signal sof_d1        : std_logic;
  signal sof_d2        : std_logic;
  signal sof_d3        : std_logic;
  signal sof_d4        : std_logic;
  signal sof_d5        : std_logic;
  signal eop_n_i       : std_logic;
  signal eop_n_2i      : std_logic;
  signal eop_strb      : std_logic;
  signal cs_wren1      : std_logic;
  signal cs_wren2      : std_logic;
  signal cs_wren2_i    : std_logic;
  signal cs_wren2_2i   : std_logic;




  begin

-------------------------------------------------------------------------------
-- Concurrent assignments
-------------------------------------------------------------------------------

  Csum_wren    <= cs_wren1 or cs_wren2;
  Csum_insert  <= cs_insert;
  Csum_en      <= cs_en;

-------------------------------------------------------------------------------
-- This is the process that increments the dp_wraddr for tx_csum_top.vhd
-------------------------------------------------------------------------------

   CSUM_ADDR_INC : process(Clk)
      begin
         if(rising_edge(Clk)) then
            if(Rst='1' or cs_en='0')then
               addr_cntr <= (others=>'0');
            elsif(Wren='1') then
               addr_cntr <= addr_cntr + 1;
            end if;
         end if;
      end process;

-------------------------------------------------------------------------------
-- This is the process that extracts the header information
-------------------------------------------------------------------------------
   CSUM_HEADER : process(Clk)
      begin
         if(rising_edge(Clk)) then
            if(Rst = '1' or cs_wren1='1' or cs_wren2='1') then
               sof_d1      <= '0';
               sof_d2      <= '0';
               sof_d3      <= '0';
               sof_d4      <= '0';
               sof_d5      <= '0';
               cs_en       <= '0';
               cs_insert   <= (others=>'0');
               cs_begin    <= (others=>'0');
               cs_init     <= (others=>'0');
            elsif(LLTemac_SRC_RDY_n='0' and LLTemac_DST_RDY_n='0') then
--              else
               sof_d1      <= not LLTemac_SOF_n;
               sof_d2      <= sof_d1;
               sof_d3      <= sof_d2;
               sof_d4      <= sof_d3;
               sof_d5      <= sof_d4;
               if(sof_d3 = '1') then
                  cs_en <= Din(31);
               end if;
               if(sof_d4 = '1') then
                  cs_begin <= Din(0 to 15);
                  cs_insert <= Din(16 to 31);
               end if;
               if(sof_d5 = '1') then
                  cs_init <= Din(16 to 31);
               end if;
            end if;
         end if;
      end process;




-------------------------------------------------------------------------------
-- Tx csum calculation block
-------------------------------------------------------------------------------
   I_TXCSUM_CALC : entity xps_ll_temac_v2_03_a.tx_csum_top
--   I_TXCSUM_CALC : entity csum_v1_00_a.tx_csum_top
      generic map(
         C_FIFO_DEPTH_LOG2X => C_FIFO_DEPTH_LOG2X
         )
      port map(
         clk       => Clk,          -- in
         rst       => Rst,          -- in
         dp_wraddr => addr_cntr,    -- in
         dp_wrdata => Din,          -- in
         dp_wren   => Wren,         -- in
         cs_insert => cs_insert,    -- in
         cs_begin  => cs_begin,     -- in
         cs_cntrl  => cs_en   ,     -- in
         cs_init   => cs_init,      -- in
         eop       => eop_strb,     -- in
         wr_addr   => open,         -- out
         wr_en     => cs_wren1,     -- out
         wr_data   => cs_data       -- out
         );


------------------------------------------------------------------------------
-- This process produces end of packet strobe from the falling edge of
-- LLTemac_EOP_n for the the tx_csum_top module
------------------------------------------------------------------------------

process(Clk)
begin
   if(rising_edge(Clk)) then
      if(Rst='1') then
         eop_n_i <= '1';
         eop_n_2i <= '1';
         eop_strb<='0';
      elsif(LLTemac_DST_RDY_n='0' and LLTemac_SRC_RDY_n='0'
            and LLTemac_EOP_n='0') then
         eop_n_i <= LLTemac_EOP_n;
         eop_n_2i <= eop_n_i;
         eop_strb <= '1';
      else
         eop_strb <= '0';
      end if;
   end if;
end process;

--eop_strb <= eop_n_i and not LLTemac_EOP_n;


-------------------------------------------------------------------------------
-- This process retrieves the 16-bit aligned csum from 32-bit output
-------------------------------------------------------------------------------
   CSUM_DATA_ALIGN : process(Rst, cs_insert, cs_data)
      begin
         if(Rst='1') then
            Csum_data <= (others=>'0');
         elsif(cs_insert(14)='0') then
            Csum_data <= cs_data(0 to 15);
         else
            Csum_data <= cs_data(16 to 31);
         end if;
      end process;

-------------------------------------------------------------------------------
-- This process generates the cs_wren in the case the csum_ctrl=0
-- The CSFIFO needs a wren for every packet
-------------------------------------------------------------------------------

CSUM_WREN_PROC : process(Clk)
   begin
      if(rising_edge(Clk)) then
         if(Rst='1') then
--            cs_wren2_i <= '1';
--            cs_wren2_2i <= '1';
            cs_wren2 <= '0';
         elsif(cs_en='0' and LLTemac_EOP_n='0' and LLTemac_DST_RDY_n='0' and LLTemac_SRC_RDY_n='0') then
--            cs_wren2_i <= '0';
--            cs_wren2_2i <= cs_wren2_i;
            cs_wren2 <= '1';
         else
--            cs_wren2_i <= '1';
--            cs_wren2_2i <= '1';
            cs_wren2 <= '0';
         end if;
       end if;
end process;

--cs_wren2 <= not cs_wren2_i and  cs_wren2_2i;



end beh;
