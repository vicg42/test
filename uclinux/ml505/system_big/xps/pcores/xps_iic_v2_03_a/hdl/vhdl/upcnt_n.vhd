-------------------------------------------------------------------------------
-- upcnt_n.vhd  entity/architecture pair
-------------------------------------------------------------------------------
--  ***************************************************************************
--  ** DISCLAIMER OF LIABILITY                                               **
--  **                                                                       **
--  **  This file contains proprietary and confidential information of       **
--  **  Xilinx, Inc. ("Xilinx"), that is distributed under a license         **
--  **  from Xilinx, and may be used, copied and/or disclosed only           **
--  **  pursuant to the terms of a valid license agreement with Xilinx.      **
--  **                                                                       **
--  **  XILINX is PROVIDING THIS DESIGN, CODE, OR INFORMATION                **
--  **  ("MATERIALS") "AS is" WITHOUT WARRANTY OF ANY KIND, EITHER           **
--  **  EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                  **
--  **  LIMITATION, ANY WARRANTY WITH RESPECT to NONINFRINGEMENT,            **
--  **  MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx        **
--  **  does not warrant that functions included in the Materials will       **
--  **  meet the requirements of Licensee, or that the operation of the      **
--  **  Materials will be uninterrupted or error-free, or that defects       **
--  **  in the Materials will be corrected. Furthermore, Xilinx does         **
--  **  not warrant or make any representations regarding use, or the        **
--  **  results of the use, of the Materials in terms of correctness,        **
--  **  accuracy, reliability or otherwise.                                  **
--  **                                                                       **
--  **  Xilinx products are not designed or intended to be fail-safe,        **
--  **  or for use in any application requiring fail-safe performance,       **
--  **  such as life-support or safety devices or systems, Class III         **
--  **  medical devices, nuclear facilities, applications related to         **
--  **  the deployment of airbags, or any other applications that could      **
--  **  lead to death, personal injury or severe property or                 **
--  **  environmental damage (individually and collectively, "critical       **
--  **  applications"). Customer assumes the sole risk and liability         **
--  **  of any use of Xilinx products in critical applications,              **
--  **  subject only to applicable laws and regulations governing            **
--  **  limitations on product liability.                                    **
--  **                                                                       **
--  **  Copyright 2007, 2008, 2009 Xilinx, Inc.                              **
--  **  All rights reserved.                                                 **
--  **                                                                       **
--  **  This disclaimer and copyright notice must be retained as part        **
--  **  of this file at all times.                                           **
--  ***************************************************************************
-------------------------------------------------------------------------------
-- Filename:        upcnt_n.vhd
-- Version:         v2.03.a 
--
-- Description:     
--                  This file contains a parameterizable N-bit up counter 
--                                    
-- VHDL-Standard:   VHDL'93
--
-------------------------------------------------------------------------------
-- Structure:
--
--           xps_iic.vhd
--              -- iic.vhd
--                  -- xps_ipif_ssp1.vhd
--                  -- reg_interface.vhd
--                  -- filter.vhd
--                      -- debounce.vhd
--                  -- iic_control.vhd
--                      -- upcnt_n.vhd
--                      -- shift8.vhd
--                  -- dynamic_master.vhd
--                  -- iic_pkg.vhd
--
-------------------------------------------------------------------------------
-- Author:      Kurt Conover
--
-- History:
-- Kurt Conover       04/02/01      
-- ^^^^^^^
-- First Point Design Release
-- ~~~~~~~
-- Prabhakar Moluguri 30/06/04      
-- ^^^^^^^
-- Initial version updated with little 
-- ~~~~~~~
--  PVK               12/12/08   v2.01.a
--^^^^^^^^ 
-- Updated to new version.
-- ~~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "Clk", "clk_div#", "clk_#x" 
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
use ieee.std_logic_arith.all;


-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_SIZE     -- Data width of counter
--
-- Definition of Ports:
--      Clk               -- System clock
--      Clr               -- Active low clear
--      Data              -- Serial data in
--      Cnt_en            -- Count enable
--      Load              -- Load line enable
--      Qout              -- Shift register shift enable
-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------
entity upcnt_n is
   generic(
          C_SIZE : integer :=9
          );
      
    port(
         Clr      : in std_logic;                        
         Clk      : in std_logic;                        
         Data     : in std_logic_vector (0 to C_SIZE-1); 
         Cnt_en   : in std_logic;                        
         Load     : in std_logic;                        
         Qout     : inout std_logic_vector (0 to C_SIZE-1)
         );
        
end upcnt_n;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture imp  of upcnt_n is
constant enable_n : std_logic := '0';
signal q_int : unsigned (0 to C_SIZE-1);
begin

   ----------------------------------------------------------------------------
   -- PROCESS: UP_COUNT_GEN
   -- purpose: Up counter
   ----------------------------------------------------------------------------
   UP_COUNT_GEN : process(Clk)
   begin
      if (Clk'event) and Clk = '1' then
         if (Clr = enable_n) then     -- Clear output register
            q_int <= (others => '0');
         elsif (Load = '1') then      -- Load in start value
            q_int <= unsigned(Data);
         elsif Cnt_en = '1' then      -- If count enable is high
            q_int <= q_int + 1;
         else
            q_int <= q_int;
         end if;
      end if;
   end process UP_COUNT_GEN;

   Qout <= std_logic_vector(q_int);

end architecture imp;
  

