------------------------------------------------------------------------------
-- $Id: v4_gt11_to_gt_rxclkcorcnt_shim.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : Virtex-4 FX GT11 to Virtex-II Pro MGT RocketIO Logic Shim
-- Project    : Virtex-4 FX Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v4_gt11_to_gt_rxclkcorcnt_shim.vhd
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
------------------------------------------------------------------------
-- Description:  This is the VHDL instantiation of a Virtex-4 FX GT11     
--               to Virtex-II Pro MGT RocketIO Logic Shim.
--               
--               This is based on Coregen Wrappers from ISE J.38 (9.2i)
--               Wrapper version 4.5
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity v4_gt11_to_gt_rxclkcorcnt_shim IS
   port (
      rxusrclk2               : in std_logic;   
      rxstatus                : in std_logic_vector(5 downto 0);   
      rxnotintable            : in std_logic;   
      rxd_in                  : in std_logic_vector(7 downto 0);   
      rxcharisk_in            : in std_logic;   
      rxrundisp_in            : in std_logic;   
      rxclkcorcnt             : out std_logic_vector(2 downto 0);   
      rxd_out                 : out std_logic_vector(7 downto 0);   
      rxcharisk_out           : out std_logic;   
      rxrundisp_out           : out std_logic);   
end entity v4_gt11_to_gt_rxclkcorcnt_shim;


architecture rtl of v4_gt11_to_gt_rxclkcorcnt_shim is


begin


  ----------------------------------------------------------------------
  -- Generate Virtex-II Pro style "RXCLKCORCNT" signal from the Virtex4
  -- RXSTATUS signal
  ----------------------------------------------------------------------

   gen_rxclkcorcnt: process (rxusrclk2)
   begin
      if rxusrclk2'event and rxusrclk2 = '1' then
         if rxstatus(4) = '1' and rxstatus(3) = '0' then
            if rxstatus(0) = '1' then
               rxclkcorcnt <= "100";   -- An /I2/ has been inserted    
            else
               rxclkcorcnt <= "001";   -- An /I2/ has been removed
            end if; 
         else                           
            rxclkcorcnt <= "000";      -- Indicates no clock correction    
         end if;                
      end if;
   end process gen_rxclkcorcnt;



  ----------------------------------------------------------------------
  -- When the RXNOTINTABLE condition is detected, the Virtex4 RocketIO
  -- outputs the raw 10B code in a bit swapped order to that of the
  -- Virtex-II Pro RocketIO.
  ----------------------------------------------------------------------

  gen_rxdata : process (rxnotintable, rxcharisk_in, rxd_in, rxrundisp_in)
  begin
    if rxnotintable = '1' then
      rxd_out(0)    <= rxcharisk_in; 
      rxd_out(1)    <= rxrundisp_in;
      rxd_out(2)    <= rxd_in(7); 
      rxd_out(3)    <= rxd_in(6); 
      rxd_out(4)    <= rxd_in(5); 
      rxd_out(5)    <= rxd_in(4); 
      rxd_out(6)    <= rxd_in(3); 
      rxd_out(7)    <= rxd_in(2); 
      rxrundisp_out <= rxd_in(1);    
      rxcharisk_out <= rxd_in(0);    

    else
      rxd_out       <= rxd_in;
      rxrundisp_out <= rxrundisp_in;    
      rxcharisk_out <= rxcharisk_in;    

    end if;
  end process gen_rxdata;  



end architecture rtl;
