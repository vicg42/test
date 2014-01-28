-------------------------------------------------------------------------------
-- address_counter.vhd
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
-- Copyright 2005, 2006, 2007, 2008 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--
---------------------------------------------------------------------------
-- Filename:          address_counter.vhd
-- Description:       
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  sdma.vhd
--                      |- sample_cycle.vhd
--                      |- sdma_cntl.vhd
--                      |   |- ipic_if.vhd
--                      |   |   |-sample_cycle.vhd
--                      |   |- interrupt_register.vhd
--                      |   |- dmac_regfile_arb.vhd
--                      |   |- read_data_delay.vhd
--                      |   |- addr_arbiter.vhd
--                      |   |- port_arbiter.vhd
--                      |   |- tx_write_handler.vhd
--                      |   |- tx_read_handler.vhd
--                      |   |- tx_port_controller.vhd
--                      |   |- rx_read_handler.vhd
--                      |   |- rx_write_handler.vhd
--                      |   |- rx_port_controller.vhd
--                      |   |- tx_rx_state.vhd
--                      |
--                      |
--                      |- sdma_datapath.vhd
--                      |   |- reset_module.vhd
--                      |   |- channel_status_reg.vhd
--                      |   |- address_counter.vhd
--                      |   |- length_counter.vhd
--                      |   |- tx_byte_shifter.vhd
--                      |   |- rx_byte_shifter.vhd
--                  sdma_pkg.vhd
--
--
-------------------------------------------------------------------------------
-- Author:      Jeff Hao
-- History:
--  JYH     02/04/05
-- ~~~~~~
--  - Initial EDK Release
-- ^^^^^^
--  GAB     10/02/06
-- ~~~~~~
--  - Converted from verilog to vhdl
-- 
--  MHG     5/20/08
-- ~~~~~~
--  - Updated to proc_common_v3_00_a^^^^^
--^^^^^^
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "LLink_Clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_com"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;    
use ieee.std_logic_misc.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;
use proc_common_v3_00_a.proc_common_pkg.log2;
use proc_common_v3_00_a.proc_common_pkg.max2;
use proc_common_v3_00_a.family_support.all;
use proc_common_v3_00_a.ipif_pkg.all;

library unisim;
use unisim.vcomponents.all;

library mpmc_v6_06_a;
use mpmc_v6_06_a.all;
use mpmc_v6_06_a.sdma_pkg.all;

-------------------------------------------------------------------------------
entity sdma_address_counter is
    port(
        LLink_Clk       : in  std_logic;      
        LLink_Rst       : in  std_logic;      
        Address_In      : in  std_logic_vector(31 downto 0); 
        Address_Out     : out std_logic_vector(31 downto 0); 
        Address_Load    : in  std_logic;      
        INC1            : in  std_logic;                         
        INC2            : in  std_logic;      
        INC3            : in  std_logic;      
        INC4            : in  std_logic       
    );

end sdma_address_counter;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of sdma_address_counter is

-------------------------------------------------------------------------------
-- Function declarations
-------------------------------------------------------------------------------
    
-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------
signal Carry0           : std_logic;
signal Carry1           : std_logic;
signal Carry1_d1        : std_logic;
signal Address_Temp0    : std_logic_vector(1 downto 0);
signal Address_Temp1    : std_logic_vector(4 downto 0);
signal sum0             : std_logic_vector(2 downto 0);
signal sum1             : std_logic_vector(5 downto 0);
signal address_out_i    : std_logic_vector(31 downto 0);
signal a, b, c          : std_logic;

signal addr_slice0      : std_logic_vector(2 downto 0);
signal slice0_inc       : std_logic_vector(2 downto 0);
signal addr_slice1      : std_logic_vector(5 downto 0);
signal slice1_inc       : std_logic_vector(5 downto 0);


-------------------------------------------------------------------------------
-- Begin Architecture
-------------------------------------------------------------------------------
begin

a               <= (INC3 or INC2);
b               <= (INC3 or INC1);
c               <= (Carry0 or INC4);

addr_slice0     <= '0' & std_logic_vector(unsigned(address_out_i(1 downto 0)));
slice0_inc      <= '0' & a & b;
Sum0            <= std_logic_vector(unsigned(addr_slice0) + unsigned(slice0_inc));

addr_slice1     <= '0' & std_logic_vector(unsigned(address_out_i(6 downto 2)));
slice1_inc      <= "00000" & c;
Sum1            <= std_logic_vector(unsigned(addr_slice1) + unsigned(slice1_inc));


Carry0          <= sum0(2);
Address_Temp0   <= sum0(1 downto 0);
Carry1          <= sum1(5);
Address_Temp1   <= sum1(4 downto 0);
Address_Out     <= address_out_i;

  process(LLink_Clk)
  begin
    if(rising_edge(LLink_Clk)) then
      if(LLink_Rst = '1') then
        Carry1_d1 <= '0';
      else
        Carry1_d1 <= Carry1;
      end if;
    end if;
  end process;

  process(LLink_Clk)
  begin
    if(rising_edge(LLink_Clk)) then
      if(LLink_Rst = '1') then
        address_out_i(1 downto 0)     <= "00";
      else
        if (Address_Load = '1') then
          address_out_i(1 downto 0)<= Address_In(1 downto 0);
        else
          if (INC1 = '1' or INC2 = '1' or INC3 = '1') then
            address_out_i(1 downto 0) <= Address_Temp0;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(LLink_Clk)
  begin
    if(rising_edge(LLink_Clk)) then
      if(LLink_Rst = '1') then
        address_out_i(6 downto 2)     <= (others => '0');
      else
        if (Address_Load = '1') then
          address_out_i(6 downto 2)   <= Address_In(6 downto 2);
        else
          if (Carry0 = '1' or INC4 = '1') then
            address_out_i(6 downto 2) <= Address_Temp1;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(LLink_Clk)
  begin
    if(rising_edge(LLink_Clk)) then
      if(LLink_Rst = '1') then
        address_out_i(31 downto 7)     <= (others => '0');
      else
        if (Address_Load = '1') then
          address_out_i(31 downto 7)   <= Address_In(31 downto 7);
        else
          if (Carry1_d1 = '1') then
            address_out_i(31 downto 7) <= std_logic_vector(unsigned(address_out_i(31 downto 7)) + 1);
          end if;
        end if;
      end if;
    end if;
  end process;

end implementation;
