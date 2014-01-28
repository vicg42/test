------------------------------------------------------------------------------
-- $Id: reg_cr.vhd,v 1.1.4.39 2009/11/17 07:11:34 tomaik Exp $
------------------------------------------------------------------------------
-- reg_cr - entity and arch
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
-- Filename:        reg_cr.vhd
-- Version:         v1.01a
-- Description:     Include a meaningful description of your file. Multi-line
--                  descriptions should align with each other
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
--      internal version of output port         "*_i"
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

entity reg_cr is
    port    (
             Clk      : in  std_logic;  --intPlbClk
             
             Ref_clk  : in  std_logic;
             Host_clk : in  std_logic;
             txClClk  : in  std_logic;
             rxClClk  : in  std_logic;
             
             RST      : in  std_logic;
             RawReset : in  std_logic;
             RdCE     : in  std_logic;
             WrCE     : in  std_logic;
             DataIn   : in  std_logic_vector(18 to 31);
             DataOut  : out std_logic_vector(18 to 31);
             RegData  : out std_logic_vector(18 to 31)
            );
end reg_cr;

------------------------------------------------------------------------------
-- Architecture
------------------------------------------------------------------------------

architecture imp of reg_cr is

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

signal reg_data : std_logic_vector(18 to 31);
signal reset_1_i  : std_logic;
signal reset_2_i  : std_logic;
signal resetCnt_1 : std_logic_vector(0 to 4);
                               
signal intPlbClkStatRstDetected2Tx    : std_logic;
signal statRstTxClClkDomain           : std_logic;
                                
signal intPlbClkStatRstDetected2Rx    : std_logic;
signal statRstRxClClkDomain           : std_logic;
                                
signal intPlbClkStatRstDetected2Host  : std_logic;
signal statRstHostClkDomain           : std_logic;
                                
signal intPlbClkStatRstDetected2Ref   : std_logic;
signal statRstRefClkDomain            : std_logic;

begin 

------------------------------------------------------------------------------
-- Concurrent Signal Assignments
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- REG_DATA_PROCESS
------------------------------------------------------------------------------

REG_DATA_PROCESS : process (reg_data, reset_1_i, reset_2_i)
begin
  for i in 18 to 31 loop
    if (i = 31) then
      RegData(i) <= reset_1_i;
    elsif (i = 18) then
      RegData(i) <= reset_2_i;
    else
      RegData(i) <= reg_data(i);
    end if;
  end loop;
end process;

------------------------------------------------------------------------------
-- BUS_READ_PROCESS
------------------------------------------------------------------------------

BUS_READ_PROCESS : process (RdCE, reg_data)
begin
  for i in 18 to 31 loop
     DataOut(i) <= RdCE and reg_data(i);
  end loop;
end process;

------------------------------------------------------------------------------
-- BUS_WRITE_PROCESS
------------------------------------------------------------------------------
 
BUS_WRITE_PROCESS : process (Clk)
begin
    if (Clk'event and Clk = '1')
    then
        if (Rst = '1')
        then
            reg_data <= (others => '0');
        elsif (WrCE = '1')
        then
            reg_data(19 to 30) <= DataIn(19 to 30);
            reg_data(18)       <= '0';
            reg_data(31)       <= '0';
        end if;
    end if;
end process;


RESET_GENERATION_PROCESS : process (Clk, RST, RawReset)
begin
  if (Clk'event and Clk = '1') then
    if (RawReset = '1') then
      reset_1_i  <= '0';
      resetCnt_1 <= "11111";
    elsif (WrCE = '1' and DataIn(31) = '1') then
      reset_1_i  <= '1';
      resetCnt_1 <= "00000";
    elsif (resetCnt_1(0) = '0') then
      reset_1_i  <= '1';
      resetCnt_1 <= resetCnt_1 + 1;
    else
      reset_1_i <= '0';
    end if;
  end if;
end process;


-- Statistics reset logic below


-------------------------------------------------------------------------
-- Detect the delayed and stretched SPLB_RESET (RawReset) or the PLB 
-- register Write reset and stretch it to be detected by the  
-- ethernet clock.  
-------------------------------------------------------------------------

DETECT_STATS_PLB_RESET_TX : process(Clk)
begin

   if rising_edge(Clk) then
      if RawReset = '1' or reset_1_i = '1' or (WrCE = '1' and DataIn(18) = '1') then                     
         intPlbClkStatRstDetected2Tx <= '1';                                          
      elsif statRstTxClClkDomain = '1' then                                           
         intPlbClkStatRstDetected2Tx <= '0';                                          
      else                                                                            
         intPlbClkStatRstDetected2Tx <= intPlbClkStatRstDetected2Tx;                  
      end if;                                                                         
   end if;                                                                            
end process;
          
-------------------------------------------------------------------------
-- The reset has been detected, so pulse the reset for one clock in the 
-- tx_cl_clk domain.  Use rstTxDomain to synchronously reset logic.
-------------------------------------------------------------------------
SET_STATS_TXCLCLK_RESET : process(txClClk)
begin

   if rising_edge(txClClk) then
      if intPlbClkStatRstDetected2Tx = '1' then
         statRstTxClClkDomain <= '1';
      else
         statRstTxClClkDomain <= '0';
      end if;
   end if;
end process;        


-------------------------------------------------------------------------
-- Detect the delayed and stretched SPLB_RESET (RawReset) or the PLB 
-- register Write reset and stretch it to be detected by the  
-- ethernet clock.  
-------------------------------------------------------------------------

DETECT_STATS_PLB_RESET_RX : process(Clk)
begin

   if rising_edge(Clk) then
      if RawReset = '1' or reset_1_i = '1' or (WrCE = '1' and DataIn(18) = '1') then 
         intPlbClkStatRstDetected2Rx <= '1';
      elsif statRstRxClClkDomain = '1' then
         intPlbClkStatRstDetected2Rx <= '0';
      else
         intPlbClkStatRstDetected2Rx <= intPlbClkStatRstDetected2Rx;
      end if;
   end if;
end process;
          
-------------------------------------------------------------------------
-- The reset has been detected, so pulse the reset for one clock in the 
-- rx_cl_clk domain.  Use rstRxClClkDomain to synchronously reset logic.
-------------------------------------------------------------------------
SET_STATS_RXCLCLK_RESET : process(rxClClk)
begin

   if rising_edge(rxClClk) then
      if intPlbClkStatRstDetected2Rx = '1' then
         statRstRxClClkDomain <= '1';
      else
         statRstRxClClkDomain <= '0';
      end if;
   end if;
end process;             

      
-------------------------------------------------------------------------
-- Detect the delayed and stretched SPLB_RESET (RawReset) or the PLB 
-- register Write reset and stretch it to be detected by the  
-- ethernet clock.  
-------------------------------------------------------------------------

DETECT_STATS_PLB_RESET_HOST : process(Clk)
begin

   if rising_edge(Clk) then                                                              
      if RawReset = '1' or reset_1_i = '1' or (WrCE = '1' and DataIn(18) = '1') then                         
         intPlbClkStatRstDetected2Host <= '1';                                           
      elsif statRstHostClkDomain = '1' then                                              
         intPlbClkStatRstDetected2Host <= '0';
      else
         intPlbClkStatRstDetected2Host <= intPlbClkStatRstDetected2Host;
      end if;
   end if;
end process;
          
-------------------------------------------------------------------------
-- The reset has been detected, so pulse the reset for one clock in the 
-- host clk domain.  Use rstHostClkDomain to synchronously reset logic.
-------------------------------------------------------------------------
SET_STATS_HOSTCLK_RESET : process(Host_clk)
begin

   if rising_edge(Host_clk) then
      if intPlbClkStatRstDetected2Host = '1' then
         statRstHostClkDomain <= '1';
      else
         statRstHostClkDomain <= '0';
      end if;
   end if;
end process;             


-------------------------------------------------------------------------
-- Detect the delayed and stretched SPLB_RESET (RawReset) or the PLB 
-- register Write reset and stretch it to be detected by the  
-- ethernet clock.  
-------------------------------------------------------------------------

DETECT_STATS_PLB_RESET_REFCLK : process(Clk)
begin

   if rising_edge(Clk) then
      if RawReset = '1' or reset_1_i = '1' or (WrCE = '1' and DataIn(18) = '1') then 
         intPlbClkStatRstDetected2Ref <= '1';
      elsif statRstRefClkDomain = '1' then
         intPlbClkStatRstDetected2Ref <= '0';
      else
         intPlbClkStatRstDetected2Ref <= intPlbClkStatRstDetected2Ref;
      end if;
   end if;
end process;
          
-------------------------------------------------------------------------
-- The reset has been detected, so pulse the reset for one clock in the 
-- ref clk domain.  Use rstRefClkDomain to synchronously reset logic.
-------------------------------------------------------------------------
SET_STATS_HOSTCLK_REFCLK : process(ref_clk)
begin

   if rising_edge(ref_clk) then
      if intPlbClkStatRstDetected2Ref = '1' then
         statRstRefClkDomain <= '1';
      else
         statRstRefClkDomain <= '0';
      end if;
   end if;
end process;             
   
-------------------------------------------------------------------------
-- Register the combined reset
-------------------------------------------------------------------------
REGISTER_COMBINED_RESET_2 : process(Clk)
begin

   if rising_edge(Clk) then
      if RawReset = '1' or reset_1_i = '1' or (WrCE = '1' and DataIn(18) = '1') then 
         reset_2_i <= '1';
      else
         reset_2_i <= intPlbClkStatRstDetected2Tx or 
                      intPlbClkStatRstDetected2Rx or 
                      intPlbClkStatRstDetected2Host or 
                      intPlbClkStatRstDetected2Ref;
      end if;
   end if;
end process;  




end imp;
