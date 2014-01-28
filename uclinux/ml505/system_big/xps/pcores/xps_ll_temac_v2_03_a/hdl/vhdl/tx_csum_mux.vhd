------------------------------------------------------------------------------
-- $Id: tx_csum_mux.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- tx_csum_mux.vhd
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
-- Filename:        tx_csum_mux.vhd
-- Version:         v1.00a
-- Description:     Counts upto the csum offset value and sets csum
--                  select output
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
use ieee.numeric_std.all;


library unisim;
use unisim.vcomponents.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.all;

------------------------------------------------------------------------------
-- Port Declaration
------------------------------------------------------------------------------

entity tx_csum_mux is
   generic(
      C_BUS_DWIDTH        : integer := 32
      );
   port(
      Clk                 : in  std_logic;
      Rst                 : in  std_logic;
      Tx_Sop              : in  std_logic;
      Tx_Eop              : in  std_logic;
      Csum_data           : in  std_logic_vector(0 to 15);
      TXFIFO_data         : in  std_logic_vector(0 to C_BUS_DWIDTH-1);
      Csum_insert         : in  std_logic_vector(0 to 15);
      Csum_en             : in  std_logic;
      IP2TXFIFO_RdReq     : in  std_logic;
      Csum_Txdata_mux     : out std_logic_vector(0 to 31)
      );
end tx_csum_mux;

------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
--
------------------------------------------------------------------------------


architecture beh of tx_csum_mux is

------------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------------
constant TRUE                 : boolean := true;
constant CSUM_INSERT_WIDTH    : integer := 16;
constant RESET_VALUE          : std_logic_vector(0 to 15) := x"0001";--(others=>'0');
constant ADJ_WIDTH            : integer := 4;

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------


signal byte_cnt_en   : std_logic;
signal byte_cnt_rst  : std_logic;
signal mux_sel       : std_logic;
signal count_adj     : std_logic_vector(0 to ADJ_WIDTH-1) := X"1";
signal mux_data_out  : std_logic_vector(0 to C_BUS_DWIDTH-1);
signal sig_tx_eop    : std_logic;
signal sig_csum_en   : std_logic;
signal sop           : std_logic;
signal  byte_cnt_data, byte_cnt_data_d1, offset, sig_debug        : integer;

begin


------------------------------------------------------------------------------
-- Concurrent assignments
------------------------------------------------------------------------------


Csum_Txdata_mux <= mux_data_out;


-- ------------------------------------------------------------------------------
-- -- This process counts the packet bytes
-- ------------------------------------------------------------------------------

process(clk)
  begin
    if(rising_edge(clk)) then
      if(rst='1') then
        byte_cnt_data    <= 1;
        sig_tx_eop       <= '0';
        sig_csum_en      <= '0';
        byte_cnt_data_d1 <= 0;
        offset           <= 1;
        sop              <= '1';
      else

        sig_tx_eop       <= tx_eop;

        if(sig_tx_eop='1') then
          sop <= '1';
        end if;

        if(Tx_Sop='1') then
          sig_csum_en    <= Csum_en;
          offset         <= conv_integer(csum_insert)/4;
          sop            <= '0';
        end if;

        if(IP2TXFIFO_RdReq='1' and sop='1') then
          byte_cnt_data <= 1;
          byte_cnt_data_d1 <= 1;
        else
          if(IP2TXFIFO_RdReq='1') then
            byte_cnt_data    <= byte_cnt_data + 1;
          end if;
          byte_cnt_data_d1 <= byte_cnt_data;
        end if;

        if(byte_cnt_data_d1>offset and IP2TXFIFO_RdReq='1') then
          sig_csum_en      <= '0';
        end if;

      end if;
    end if;
end process;


mux_data_out <= TXFIFO_data                      when byte_cnt_data<=offset or sig_csum_en='0' else
                TXFIFO_data(0 to 15) & Csum_data when Csum_insert(14)='1'                      else
                Csum_data & TXFIFO_data(16 to 31);


end beh;

