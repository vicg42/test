------------------------------------------------------------------------------
-- $Id: tx_data_mux.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- tx_data_mux.vhd
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
-- Filename:        tx_data_mux.vhd
-- Version:         v3.00a
-- Description:     Intermediate register between WRPFIFO and the client fifo
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
-- Author:      DCW
-- History:
--  DCW      2004.06.09      -- First version
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

library unisim;
use unisim.vcomponents.all;

------------------------------------------------------------------------------
-- Port Declaration
------------------------------------------------------------------------------

entity tx_data_mux is
    generic (
             C_RESET_ACTIVE  : std_logic := '1';
             C_BUS_DWIDTH    : integer   := 32;
             C_CLIENT_DWIDTH : integer   :=  8;
             C_TX_MUX_REG    : std_logic := '0'
            );

    port    (
             LLTemac_Clk    : in  std_logic;
             LLTemac_Rst    : in  std_logic;
             TxData_Mux_Sel : in  std_logic_vector(0 to 1);
             WFIFO2IP_Data  : in  std_logic_vector(0 to C_BUS_DWIDTH-1);
             WFIFO2TxClient : out std_logic_vector(0 to 2*C_CLIENT_DWIDTH-1)
            );
end tx_data_mux;

------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
--
------------------------------------------------------------------------------

architecture simulation of tx_data_mux is

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

signal wFIFO2TxClient_i : std_logic_vector(0 to 2*C_CLIENT_DWIDTH-1);

begin

------------------------------------------------------------------------------
------------------------------------------------------------------------------
--                  GENERATE FOR BUS WIDTH 32, CLIENT WIDTH 8        
------------------------------------------------------------------------------
------------------------------------------------------------------------------

G_32_8 : if ((C_BUS_DWIDTH = 32) and (C_CLIENT_DWIDTH = 8)) generate

    --------------------------------------------------------------------------
    -- TX_DATA_MUX_PROCESS
    --------------------------------------------------------------------------

    TX_DATA_MUX_PROCESS : process ( TxData_Mux_Sel, WFIFO2IP_Data )
    begin
        case TxData_Mux_Sel is

            when  "00" | "10" =>
                wFIFO2TxClient_i <= WFIFO2IP_Data(0*C_CLIENT_DWIDTH to 2*C_CLIENT_DWIDTH-1);

            when  "01" | "11"=>
                wFIFO2TxClient_i <= WFIFO2IP_Data(2*C_CLIENT_DWIDTH to 4*C_CLIENT_DWIDTH-1);

            when others =>
                wFIFO2TxClient_i <= WFIFO2IP_Data(0*C_CLIENT_DWIDTH to 2*C_CLIENT_DWIDTH-1);

        end case;
    end process;
end generate;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
--                  GENERATE FOR BUS WIDTH 32, CLIENT WIDTH 16        
------------------------------------------------------------------------------
------------------------------------------------------------------------------

--G_32_16 : if ((C_BUS_DWIDTH = 32) and (C_CLIENT_DWIDTH = 16)) generate

    --------------------------------------------------------------------------
    -- TX_DATA_MUX_PROCESS
    --------------------------------------------------------------------------

    --TX_DATA_MUX_PROCESS : process ( TxData_Mux_Sel, WFIFO2IP_Data )
    --begin
    --    case TxData_Mux_Sel is

    --        when  "00" | "01" | "10" | "11" =>
    --            wFIFO2TxClient_i <= WFIFO2IP_Data(0*C_CLIENT_DWIDTH to 2*C_CLIENT_DWIDTH-1);

    --        when others =>
    --            wFIFO2TxClient_i <= WFIFO2IP_Data(0*C_CLIENT_DWIDTH to 2*C_CLIENT_DWIDTH-1);

    --    end case;
    --end process;
--end generate;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
--                  GENERATE FOR BUS WIDTH 64, CLIENT WIDTH 8        
------------------------------------------------------------------------------
------------------------------------------------------------------------------

--G_64_8 : if ((C_BUS_DWIDTH = 64) and (C_CLIENT_DWIDTH = 8)) generate

    --------------------------------------------------------------------------
    -- TX_DATA_MUX_PROCESS
    --------------------------------------------------------------------------

    --TX_DATA_MUX_PROCESS : process ( TxData_Mux_Sel, WFIFO2IP_Data )
    --begin
    --    case TxData_Mux_Sel is

    --        when  "00"  =>
    --            wFIFO2TxClient_i <= WFIFO2IP_Data(0*C_CLIENT_DWIDTH to 2*C_CLIENT_DWIDTH-1);

    --        when  "01"  =>
    --            wFIFO2TxClient_i <= WFIFO2IP_Data(2*C_CLIENT_DWIDTH to 4*C_CLIENT_DWIDTH-1);

    --        when  "10"  =>
    --            wFIFO2TxClient_i <= WFIFO2IP_Data(4*C_CLIENT_DWIDTH to 6*C_CLIENT_DWIDTH-1);

    --        when  "11"  =>
    --            wFIFO2TxClient_i <= WFIFO2IP_Data(6*C_CLIENT_DWIDTH to 8*C_CLIENT_DWIDTH-1);

    --        when others =>
    --            wFIFO2TxClient_i <= WFIFO2IP_Data(0*C_CLIENT_DWIDTH to 2*C_CLIENT_DWIDTH-1);

    --    end case;
    --end process;
--end generate;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
--                  GENERATE FOR BUS WIDTH 64, CLIENT WIDTH 16        
------------------------------------------------------------------------------
------------------------------------------------------------------------------

--G_64_16 : if ((C_BUS_DWIDTH = 64) and (C_CLIENT_DWIDTH = 16)) generate

    --------------------------------------------------------------------------
    -- TX_DATA_MUX_PROCESS
    --------------------------------------------------------------------------

    --TX_DATA_MUX_PROCESS : process ( TxData_Mux_Sel, WFIFO2IP_Data )
    --begin
    --    case TxData_Mux_Sel is

    --        when  "00" | "10" =>
    --            wFIFO2TxClient_i <= WFIFO2IP_Data(0*C_CLIENT_DWIDTH to 2*C_CLIENT_DWIDTH-1);

    --        when  "01" | "11" =>
    --            wFIFO2TxClient_i <= WFIFO2IP_Data(2*C_CLIENT_DWIDTH to 4*C_CLIENT_DWIDTH-1);

    --        when others =>
    --            wFIFO2TxClient_i <= WFIFO2IP_Data(0*C_CLIENT_DWIDTH to 2*C_CLIENT_DWIDTH-1);

    --    end case;
    --end process;
--end generate;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
--                  GENERATE IF PIPELINE REGISTER IS DESIRED        
------------------------------------------------------------------------------
------------------------------------------------------------------------------

G_PIPE_REG : if (C_TX_MUX_REG = '1') generate
begin

    --------------------------------------------------------------------------
    -- TX_DATA_REG_PROCESS
    --------------------------------------------------------------------------

    TX_DATA_REG_PROCESS : process (LLTemac_Clk)
    begin
    
        if (LLTemac_Clk'event and LLTemac_Clk = '1') then
            if (LLTemac_Rst = C_RESET_ACTIVE) then
                WFIFO2TxClient <= (others => '0');
            else
                WFIFO2TxClient <= wFIFO2TxClient_i;
            end if;
        end if;
    
    end process;
end generate;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
--                  GENERATE IF DATA FLOWS THROGH MUX      
------------------------------------------------------------------------------
------------------------------------------------------------------------------

G_FLOW_THRU : if (C_TX_MUX_REG /= '1') generate
begin

    --------------------------------------------------------------------------
    -- Concurent assignment
    --------------------------------------------------------------------------

    WFIFO2TxClient <= wFIFO2TxClient_i;
    
end generate;

end simulation;
