------------------------------------------------------------------------------
-- $Id: tx_csum_top.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- tx_csum_top.vhd
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
-- Filename:        tx_csum_top.vhd
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
-- Author:       
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

entity tx_csum_top is
  generic(
    C_FIFO_DEPTH_LOG2X    : integer:=13
  );
  port(
    clk       : in  std_logic;
    rst       : in  std_logic;
    dp_wraddr : in  std_logic_vector(0 to C_FIFO_DEPTH_LOG2X-1);
    dp_wrdata : in  std_logic_vector(0 to 31);
    dp_wren   : in  std_logic;
    cs_insert : in  std_logic_vector(0 to 15);
    cs_begin  : in  std_logic_vector(0 to 15);
    cs_cntrl  : in  std_logic;
    cs_init   : in  std_logic_vector(0 to 15);
    eop       : in  std_logic;
    wr_addr   : out std_logic_vector(0 to C_FIFO_DEPTH_LOG2X-1);
    wr_en     : out std_logic;
    wr_data   : out std_logic_vector(0 to 31)
  );
end entity;

architecture beh of tx_csum_top is

  signal sop         : std_logic;
  signal eop_i       : std_logic;
  signal eop_1i      : std_logic;
  signal eop_2i      : std_logic;
  signal eop_3i      : std_logic;
  signal eop_4i      : std_logic;
  signal eop_5i      : std_logic;
  signal checksum_a  : std_logic_vector(16 downto 0);
  signal checksum_b  : std_logic_vector(16 downto 0);
  signal checksum    : std_logic_vector(15 downto 0);
  signal enable_a    : std_logic;
  signal enable_b    : std_logic;
  signal busy        : std_logic;
  --must be the larger of C_FIFO_DEPTH_LOG2X or 13
  signal start_addr  : std_logic_vector(C_FIFO_DEPTH_LOG2X-1 downto 0);
  signal sig_wr_addr : std_logic_vector(C_FIFO_DEPTH_LOG2X-1 downto 0);
  signal sig_wr_data : std_logic_vector(0 to 31);
  signal sig_cs_insert : std_logic_vector(15 downto 0);
  signal sig_cs_begin  : std_logic_vector(15 downto 0);
  signal wren_timeout_cnt : integer range 0 to 3;
  constant delay : integer := 7;
  signal sig_delayed_eop : std_logic_vector(delay downto 0);
  signal sig_cs_cntrl : std_logic;
  signal sig_cs_cntrl_d1 : std_logic;
  constant C_BASE : std_logic_vector(C_FIFO_DEPTH_LOG2X-1 downto 0):=(others => '0');
  
  begin


-------------------------------------------------------------------------------
-- This process creates a sticky cs_cntrl
-------------------------------------------------------------------------------
--process(clk)
--  begin
--    if(rising_edge(clk)) then
--      if(rst='1' or eop_5i='1') then
--        sig_cs_cntrl<='0';
--        sig_cs_cntrl_d1<='0';
--      else
--        sig_cs_cntrl_d1<=cs_cntrl;
--        if(cs_cntrl='1' and sig_cs_cntrl_d1='0' and busy='0') then
--          sig_cs_cntrl<='1';
--        end if;
--      end if;
--    end if;
--end process;
sig_cs_cntrl <= cs_cntrl;      

-------------------------------------------------------------------------------
-- This is the process to write the checksum into the memory
-------------------------------------------------------------------------------
    wr_addr <= sig_wr_addr(C_FIFO_DEPTH_LOG2X-1 downto 0);
    process(clk)
      variable var_checksum : std_logic_vector(15 downto 0);
      begin
        if(rising_edge(clk)) then
          if(rst='1' or eop_5i='1' or sig_cs_cntrl='0') then 
            wr_en       <= '0';
            wr_data     <= (others => '0');
          else
            if(checksum=x"0000") then
              var_checksum := not checksum(15 downto 0);
            else
              var_checksum := checksum(15 downto 0);
            end if;
            if(eop_4i='1') then
              wr_en   <= '1';
              if(cs_insert(14)='0') then
                wr_data <= var_checksum(15 downto 0) & sig_wr_data(16 to 31);
              else
                wr_data <= sig_wr_data(0 to 15) & var_checksum(15 downto 0);
              end if;
            else
              wr_en <= '0';
            end if;
          end if;
        end if;
    end process;

-------------------------------------------------------------------------------
-- This process captures the start address of the packet to generate the
-- writeback offsets
-------------------------------------------------------------------------------
    sig_cs_begin  <= cs_begin;
    sig_cs_insert <= cs_insert;
    process(clk)
      begin
        if(rising_edge(clk)) then
          if(rst='1' or eop_5i='1' or sig_cs_cntrl='0') then
            start_addr  <= (others => '0');
            sig_wr_addr <= (others => '0');
            sop         <= '1';
            sig_wr_data <= (others => '0');
          else
            if(sop='1') then
              start_addr   <= C_BASE + sig_cs_begin(C_FIFO_DEPTH_LOG2X-1 downto 2) - '1';
              sig_wr_addr  <= C_BASE + sig_cs_insert(C_FIFO_DEPTH_LOG2X-1 downto 2);
            end if;
            if(dp_wren='1') then
              if(sop='1') then
                sop          <= '0';
              end if;
              if(sig_wr_addr=dp_wraddr) then
                sig_wr_data <= dp_wrdata;
              end if;
            end if;
          end if;
        end if;
    end process;

-------------------------------------------------------------------------------
-- Add in logic to enable checksum adders
-------------------------------------------------------------------------------
   process(clk)
     begin
       if(rising_edge(clk)) then
         if(rst='1' or eop_i='1' or eop_5i='1' or sig_cs_cntrl='0') then
           enable_a  <= '0';
           enable_b  <= '0';
           busy      <= '0';
         else
           if(start_addr(C_FIFO_DEPTH_LOG2X-1 downto 0)=dp_wraddr and dp_wren='1') then
             busy <= '1';
--             if(dp_wren='1') then
--               busy       <= '1';
--             end if;
             if(cs_begin(14)='0') then
               enable_a <= '1';
               enable_b <= '1';
             else
               enable_b <= '1';
             end if;
           elsif(busy='1') then
             if(dp_wren='1') then
               enable_a   <= '1';
               enable_b   <= '1';
             end if;
           else
             enable_a   <= '0';
             enable_b   <= '0';
           end if;
         end if;
       end if;
   end process;

-------------------------------------------------------------------------------
-- This is where the checksum is actually calculated
-------------------------------------------------------------------------------
    process(clk)
      begin
        if(rising_edge(clk)) then
          if(rst='1' or eop_5i='1' or sig_cs_cntrl='0') then
            checksum_a   <= (others => '0');
          else
            if(eop_1i='1') then
              checksum_a <= '0'&checksum_a(15 downto 0) + checksum_a(16);
            elsif(sop='1' and dp_wren='1' and enable_a='1') then
              checksum_a <= '0'&cs_init + dp_wrdata(0 to 15);
            elsif(sop='1' and dp_wren='1' and enable_a='0') then
              checksum_a <= '0'&cs_init;
            elsif(enable_a='1' and dp_wren='1') then
              checksum_a <= '0'&checksum_a(15 downto 0) + dp_wrdata(0 to 15) + checksum_a(16);
            end if;
          end if;
        end if;
    end process;

    process(clk)
      begin
        if(rising_edge(clk)) then
          if(rst='1' or eop_5i='1' or sig_cs_cntrl='0') then
            eop_5i  <= '0';
            eop_4i  <= '0';
            eop_3i  <= '0';
            eop_2i  <= '0';
            eop_1i  <= '0';
            eop_i   <= '0';
            checksum_b  <= (others => '0');
            wren_timeout_cnt <= 0;
          else
            if(eop_i='1' and wren_timeout_cnt<3) then
              wren_timeout_cnt<=wren_timeout_cnt+1;
            end if;

            sig_delayed_eop<=sig_delayed_eop(delay-1 downto 0) & eop;
            
            if(sig_delayed_eop(delay)='1') then
              eop_i   <= '1';
            end if;
            
            if(eop_i='1' and (dp_wren='1' or wren_timeout_cnt=3)) then
              eop_1i  <= '1';
              eop_i   <= '0';
            else
              eop_1i  <= '0';
            end if;
            
            eop_2i  <= eop_1i;
            eop_3i  <= eop_2i;
            eop_4i  <= eop_3i;
            eop_5i  <= eop_4i;
            if(eop_1i='1' or eop_3i='1') then
              checksum_b <= '0'&checksum_b(15 downto 0) + checksum_b(16);
            elsif(eop_2i='1') then
              checksum_b <= '0'&checksum_b(15 downto 0) + checksum_a(15 downto 0);
            elsif(enable_b='1' and dp_wren='1') then
              checksum_b <= '0'&checksum_b(15 downto 0) + checksum_b(16) + dp_wrdata(16 to 31);
            end if;
          end if;
        end if;
   end process;

   checksum <= not checksum_b(15 downto 0);
        

end beh;
