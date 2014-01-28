------------------------------------------------------------------------------
-- $Id: addr_response_shim.vhd,v 1.1.4.39 2009/11/17 07:11:34 tomaik Exp $
------------------------------------------------------------------------------
-- xps_ll_temac.vhd
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
-- Filename:        xps_ll_temac.vhd
-- Version:         v2.00a
-- Description:     top level of xps_ll_temac
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--            -- xps_ll_temac.vhd
--               -- addr_response_shim.vhd    ******
--               -- soft_temac_wrap.vhd
--               -- v4_temac_wrap.vhd
--               -- v5_temac_wrap.vhd
--               -- tx_llink_top.vhd
--                  -- tx_temac_if.vhd
--                     -- tx_temac_if_sm.vhd
--                     -- tx_csum_mux.vhd
--                     -- tx_data_mux.vhd
--                     -- tx_cl_if.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.

------------------------------------------------------------------------------
-- Author:
-- History:
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
--      combinatorial signals:                  "*_com"
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
use ieee.numeric_std.all;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

entity addr_response_shim is
   generic (

      C_BUS2CORE_CLK_RATIO      : integer range 1 to 2    := 1;
      C_SPLB_AWIDTH             : integer range 32 to 32  := 32;
      C_SPLB_DWIDTH             : integer range 32 to 128 := 32;
      C_SIPIF_DWIDTH            : integer range 32 to 32  := 32;
      C_NUM_CS                  : integer                 := 10;
      C_NUM_CE                  : integer                 := 41;
      C_FAMILY                  : string                  := "virtex6"
      );
   port (
      --Clock and Reset
      intPlbClk                 : in  std_logic;
      SPLB_Reset                : in  std_logic;

      -- PLB Slave Interface with Shim
      Bus2Shim_Addr             : in  std_logic_vector(0 to C_SPLB_AWIDTH - 1 );
      Bus2Shim_Data             : in  std_logic_vector(0 to C_SIPIF_DWIDTH - 1 );
      Bus2Shim_RNW              : in  std_logic;
      Bus2Shim_CS               : in  std_logic_vector(0 to 0);
      Bus2Shim_RdCE             : in  std_logic_vector(0 to 0);
      Bus2Shim_WrCE             : in  std_logic_vector(0 to 0);

      Shim2Bus_Data             : out std_logic_vector (0 to C_SIPIF_DWIDTH - 1 );
      Shim2Bus_WrAck            : out std_logic;
      Shim2Bus_RdAck            : out std_logic;

      -- TEMAC Interface with Shim
      Shim2IP_Addr              : out std_logic_vector(0 to C_SPLB_AWIDTH - 1 );
      Shim2IP_Data              : out std_logic_vector(0 to C_SIPIF_DWIDTH - 1 );
      Shim2IP_RNW               : out std_logic;
      Shim2IP_CS                : out std_logic_vector(0 to C_NUM_CS);
      Shim2IP_RdCE              : out std_logic_vector(0 to C_NUM_CE);
      Shim2IP_WrCE              : out std_logic_vector(0 to C_NUM_CE);

      IP2Shim_Data              : in  std_logic_vector (0 to C_SIPIF_DWIDTH - 1 );
      IP2Shim_WrAck             : in  std_logic;
      IP2Shim_RdAck             : in  std_logic
   );

end addr_response_shim;

architecture rtl of addr_response_shim is


   signal bus2Shim_Addr_reg    : std_logic_vector(0 to C_SPLB_AWIDTH - 1 );
   signal bus2Shim_CS_reg      : std_logic;
   signal shim2IP_RNW_int      : std_logic;
   signal bus2Shim_RdCE_reg    : std_logic;
   signal bus2Shim_WrCE_reg    : std_logic;
   signal invalidAddrRspns     : std_logic;
   signal invalidAddrRspns_reg : std_logic;
   signal invalidRdReq         : std_logic;
   signal invalidWrReq         : std_logic;
   signal shim2IP_CS_int       : std_logic_vector(0 to C_NUM_CS);
   signal shim2IP_RdCE_int     : std_logic_vector(0 to C_NUM_CE);
   signal shim2IP_WrCE_int     : std_logic_vector(0 to C_NUM_CE);
   signal IP2Shim_WrAck_int    : std_logic;
   signal IP2Shim_RdAck_int    : std_logic;

   begin


      IP2Shim_WrAck_int <= IP2Shim_WrAck or invalidWrReq;
      IP2Shim_RdAck_int <= IP2Shim_RdAck or invalidRdReq;

      Shim2IP_Data      <= Bus2Shim_Data ;  --write data

      Shim2Bus_Data     <= IP2Shim_Data;    --read data
      Shim2Bus_WrAck    <= IP2Shim_WrAck_int;
      Shim2Bus_RdAck    <= IP2Shim_rDAck_int;

      ----------------------------------------------------------------------------
      -- Use Chip Select to register the address data; Otherwise Zeros
      ----------------------------------------------------------------------------
      ADDR_REG : process (intPlbClk)
      begin

         if rising_edge(intPlbClk) then
            if SPLB_Reset = '1' or (IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1') then
               bus2Shim_Addr_reg <= (others => '0');
            elsif Bus2Shim_CS(0) = '1' then
               bus2Shim_Addr_reg <= Bus2Shim_Addr;
            else
               bus2Shim_Addr_reg <= bus2Shim_Addr_reg;
            end if;
         end if;
      end process;

      ----------------------------------------------------------------------------
      -- Use Chip Select to register Chip Select; Otherwise Zero
      ----------------------------------------------------------------------------
      CS_REG : process (intPlbClk)
      begin

         if rising_edge(intPlbClk) then
            if SPLB_Reset = '1' or (IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1') then
               bus2Shim_CS_reg <= '0';
            elsif Bus2Shim_CS(0) = '1' then
               bus2Shim_CS_reg <= Bus2Shim_CS(0);
            else
               bus2Shim_CS_reg <= bus2Shim_CS_reg;
            end if;
         end if;
      end process;

      ----------------------------------------------------------------------------
      -- Use Chip Select to register Read Not Write; Otherwise Zero
      ----------------------------------------------------------------------------
      RNW_REG : process (intPlbClk)
      begin

         if rising_edge(intPlbClk) then
            if SPLB_Reset = '1' or (IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1') then
               shim2IP_RNW_int <= '0';
            elsif Bus2Shim_CS(0) = '1' then
               shim2IP_RNW_int <= Bus2Shim_RNW;
            else
               shim2IP_RNW_int <= shim2IP_RNW_int;
            end if;
         end if;
      end process;

      ----------------------------------------------------------------------------
      -- Use Chip Select and Bus2Shim_RNW to register Read Chip Enable
      -- Otherwise Zero
      ----------------------------------------------------------------------------
      RDCE_REG : process (intPlbClk)
      begin

         if rising_edge(intPlbClk) then
            if SPLB_Reset = '1' or (IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1') then
               bus2Shim_RdCE_reg <= '0';
            elsif Bus2Shim_CS(0) = '1' and Bus2Shim_RNW = '1' then
               bus2Shim_RdCE_reg <= Bus2Shim_RdCE(0);
            else
               bus2Shim_RdCE_reg <= bus2Shim_RdCE_reg;
            end if;
         end if;
      end process;

      ----------------------------------------------------------------------------
      -- Use Chip Select and Bus2Shim_RNW to register Write Chip Enable
      -- Otherwise Zero
      ----------------------------------------------------------------------------
      WRCE_REG : process (intPlbClk)
      begin

         if rising_edge(intPlbClk) then
            if SPLB_Reset = '1' or (IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1') then
               bus2Shim_WrCE_reg <= '0';
            elsif Bus2Shim_CS(0) = '1' and Bus2Shim_RNW = '0' then
               bus2Shim_WrCE_reg <= Bus2Shim_WrCE(0);
            else
               bus2Shim_WrCE_reg <= bus2Shim_WrCE_reg;
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- Decode the address and set appropriate CE
      --    If the Address does not exist, ie it is in a gap,
      --    then set invalidAddrRspns
      ----------------------------------------------------------------------------
      ADDR_DECODE : process (bus2Shim_CS_reg,bus2Shim_RdCE_reg,bus2Shim_WrCE_reg,
                             bus2Shim_Addr_reg)
      begin


         if bus2Shim_CS_reg = '1' then
            -- Temac 0 Registers
               -- Temac 0 Direct Registers
--            if bus2Shim_Addr_reg(12 to 31) >= X"00000" and bus2Shim_Addr_reg(12 to 31) <= X"00003" then
            if bus2Shim_Addr_reg(13 to 29) = "00000000000000000" then   --0x0
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- RAF 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(0)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(1 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(1 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00004" and bus2Shim_Addr_reg(12 to 31) <= X"00007" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000000001" then --0x4
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TPF 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0)               <= '0';
               shim2IP_WrCE_int(0)               <= '0';
               shim2IP_RdCE_int(1)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(1)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(2 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(2 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00008" and bus2Shim_Addr_reg(12 to 31) <= X"0000B" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000000010" then --0x8
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IFGP 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 1)          <= (others => '0');
               shim2IP_WrCE_int(0 to 1)          <= (others => '0');
               shim2IP_RdCE_int(2)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(2)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(3 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(3 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"0000C" and bus2Shim_Addr_reg(12 to 31) <= X"0000F" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000000011" then --0xC
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IS 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 2)          <= (others => '0');
               shim2IP_WrCE_int(0 to 2)          <= (others => '0');
               shim2IP_RdCE_int(3)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(3)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(4 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(4 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00010" and bus2Shim_Addr_reg(12 to 31) <= X"00013" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000000100" then --0x10
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IP 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 3)          <= (others => '0');
               shim2IP_WrCE_int(0 to 3)          <= (others => '0');
               shim2IP_RdCE_int(4)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(4)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(5 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(5 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00014" and bus2Shim_Addr_reg(12 to 31) <= X"00017" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000000101" then --0x14
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IE 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 4)          <= (others => '0');
               shim2IP_WrCE_int(0 to 4)          <= (others => '0');
               shim2IP_RdCE_int(5)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(5)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(6 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(6 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00018" and bus2Shim_Addr_reg(12 to 31) <= X"0001B" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000000110" then --0x18
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TTAG 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 5)          <= (others => '0');
               shim2IP_WrCE_int(0 to 5)          <= (others => '0');
               shim2IP_RdCE_int(6)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(6)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(7 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(7 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"0001C" and bus2Shim_Addr_reg(12 to 31) <= X"0001F" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000000111" then --0x1C
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- RTAG 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 6)          <= (others => '0');
               shim2IP_WrCE_int(0 to 6)          <= (others => '0');
               shim2IP_RdCE_int(7)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(7)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(8 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(8 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';

               -- Temac 0 Indirect Register Access
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00020" and bus2Shim_Addr_reg(12 to 31) <= X"00023" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000001000" then --0x20
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- MSW 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 7)          <= (others => '0');
               shim2IP_WrCE_int(0 to 7)          <= (others => '0');
               shim2IP_RdCE_int(8)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(8)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(9 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(9 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00024" and bus2Shim_Addr_reg(12 to 31) <= X"00027" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000001001" then --0x24
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- LSW 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 8)          <= (others => '0');
               shim2IP_WrCE_int(0 to 8)          <= (others => '0');
               shim2IP_RdCE_int(9)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(9)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(10 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(10 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00028" and bus2Shim_Addr_reg(12 to 31) <= X"0002B" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000001010" then --0x28
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- CTL 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 9)          <= (others => '0');
               shim2IP_WrCE_int(0 to 9)          <= (others => '0');
               shim2IP_RdCE_int(10)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(10)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(11 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(11 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"0002C" and bus2Shim_Addr_reg(12 to 31) <= X"0002F" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000001011" then --0x2C
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- RDY 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 10)         <= (others => '0');
               shim2IP_WrCE_int(0 to 10)         <= (others => '0');
               shim2IP_RdCE_int(11)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(11)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(12 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(12 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';

               --Temac 0 Direct Registers
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00030" and bus2Shim_Addr_reg(12 to 31) <= X"00033" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000001100" then --0x30
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- UAWL 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 11)         <= (others => '0');
               shim2IP_WrCE_int(0 to 11)         <= (others => '0');
               shim2IP_RdCE_int(12)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(12)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(13 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(13 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00034" and bus2Shim_Addr_reg(12 to 31) <= X"00037" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000001101" then --0x34
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- UAWU 0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 12)         <= (others => '0');
               shim2IP_WrCE_int(0 to 12)         <= (others => '0');
               shim2IP_RdCE_int(13)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(13)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(14 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(14 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                 <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00038" and bus2Shim_Addr_reg(12 to 31) <= X"0003B" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000001110" then --0x38
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TPID 00
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 13)         <= (others => '0');
               shim2IP_WrCE_int(0 to 13)         <= (others => '0');
               shim2IP_RdCE_int(14)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(14)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(15 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(15 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"0003C" and bus2Shim_Addr_reg(12 to 31) <= X"0003F" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000001111" then --0x3C
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TPID 01
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 14)         <= (others => '0');
               shim2IP_WrCE_int(0 to 14)         <= (others => '0');
               shim2IP_RdCE_int(15)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(15)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(16 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(16 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';

            -- Temac 1 Registers
               -- Temac 1 Direct Registers
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00040" and bus2Shim_Addr_reg(12 to 31) <= X"00043" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000010000" then --0x40
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- RAF 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 15)         <= (others => '0');
               shim2IP_WrCE_int(0 to 15)         <= (others => '0');
               shim2IP_RdCE_int(16)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(16)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(17 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(17 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00044" and bus2Shim_Addr_reg(12 to 31) <= X"00047" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000010001" then --0x44
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TPF 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 16)         <= (others => '0');
               shim2IP_WrCE_int(0 to 16)         <= (others => '0');
               shim2IP_RdCE_int(17)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(17)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(18 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(18 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00048" and bus2Shim_Addr_reg(12 to 31) <= X"0004B" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000010010" then --0x48
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IFGP 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 17)         <= (others => '0');
               shim2IP_WrCE_int(0 to 17)         <= (others => '0');
               shim2IP_RdCE_int(18)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(18)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(19 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(19 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"0004C" and bus2Shim_Addr_reg(12 to 31) <= X"0004F" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000010011" then --0x4C
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IS 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 18)         <= (others => '0');
               shim2IP_WrCE_int(0 to 18)         <= (others => '0');
               shim2IP_RdCE_int(19)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(19)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(20 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(20 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00050" and bus2Shim_Addr_reg(12 to 31) <= X"00053" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000010100" then --0x50
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IP 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 19)         <= (others => '0');
               shim2IP_WrCE_int(0 to 19)         <= (others => '0');
               shim2IP_RdCE_int(20)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(20)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(21 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(21 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00054" and bus2Shim_Addr_reg(12 to 31) <= X"00057" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000010101"  then --0x54
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IE 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 20)         <= (others => '0');
               shim2IP_WrCE_int(0 to 20)         <= (others => '0');
               shim2IP_RdCE_int(21)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(21)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(22 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(22 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00058" and bus2Shim_Addr_reg(12 to 31) <= X"0005B" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000010110" then --0x58
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TTAG 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 21)         <= (others => '0');
               shim2IP_WrCE_int(0 to 21)         <= (others => '0');
               shim2IP_RdCE_int(22)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(22)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(23 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(23 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"0005C" and bus2Shim_Addr_reg(12 to 31) <= X"0005F" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000010111" then --0x5C
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- RTAG 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 22)         <= (others => '0');
               shim2IP_WrCE_int(0 to 22)         <= (others => '0');
               shim2IP_RdCE_int(23)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(23)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(24 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(24 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';

               -- Temac 1 Indirect Register Access
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00060" and bus2Shim_Addr_reg(12 to 31) <= X"00063" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000011000" then --0x60
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- MSW 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 23)         <= (others => '0');
               shim2IP_WrCE_int(0 to 23)         <= (others => '0');
               shim2IP_RdCE_int(24)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(24)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(25 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(25 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00064" and bus2Shim_Addr_reg(12 to 31) <= X"00067" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000011001" then --0x64
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- LSW 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 24)         <= (others => '0');
               shim2IP_WrCE_int(0 to 24)         <= (others => '0');
               shim2IP_RdCE_int(25)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(25)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(26 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(26 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00068" and bus2Shim_Addr_reg(12 to 31) <= X"0006B" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000011010" then --0x68
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- CTL 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 25)         <= (others => '0');
               shim2IP_WrCE_int(0 to 25)         <= (others => '0');
               shim2IP_RdCE_int(26)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(26)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(27 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(27 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"0006C" and bus2Shim_Addr_reg(12 to 31) <= X"0006F" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000011011" then --0x6C
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- RDY 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 26)         <= (others => '0');
               shim2IP_WrCE_int(0 to 26)         <= (others => '0');
               shim2IP_RdCE_int(27)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(27)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(28 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(28 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';

               --Temac 1 Direct Registers
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00070" and bus2Shim_Addr_reg(12 to 31) <= X"00073" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000011100" then --0x70
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- UAWL 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 27)         <= (others => '0');
               shim2IP_WrCE_int(0 to 27)         <= (others => '0');
               shim2IP_RdCE_int(28)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(28)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(29 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(29 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00074" and bus2Shim_Addr_reg(12 to 31) <= X"00077" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000011101" then --0x74
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- UAWU 1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 28)         <= (others => '0');
               shim2IP_WrCE_int(0 to 28)         <= (others => '0');
               shim2IP_RdCE_int(29)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(29)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(30 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(30 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00078" and bus2Shim_Addr_reg(12 to 31) <= X"0007B" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000011110" then --0x78
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TPID 10
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 29)         <= (others => '0');
               shim2IP_WrCE_int(0 to 29)         <= (others => '0');
               shim2IP_RdCE_int(30)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(30)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(31 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(31 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"0007C" and bus2Shim_Addr_reg(12 to 31) <= X"0007F" then
            elsif bus2Shim_Addr_reg(13 to 29) = "00000000000011111" then --0x7C
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TPID 11
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 30)         <= (others => '0');
               shim2IP_WrCE_int(0 to 30)         <= (others => '0');
               shim2IP_RdCE_int(31)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(31)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(32 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(32 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';

               --Temac 0 Statistics Counters
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"00200" and bus2Shim_Addr_reg(12 to 31) <= X"003FF" then
            elsif bus2Shim_Addr_reg(13 to 22) = "0000000001" then --0x200 - 0x3ff
               shim2IP_CS_int(0)                 <= '0';
               shim2IP_CS_int(1)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(2 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 31)         <= (others => '0');
               shim2IP_WrCE_int(0 to 31)         <= (others => '0');
               shim2IP_RdCE_int(32)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(32)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(33 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(33 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
               --Temac 0  Transmit VLAN Translation, Tag, Strip Table 0 (BRAM)
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"04000" and bus2Shim_Addr_reg(12 to 31) <= X"07FFF" then
            elsif bus2Shim_Addr_reg(13 to 17) = "00001" then --0x4000 - 0x7FFF
               shim2IP_CS_int(0 to 1)            <= (others => '0');
               shim2IP_CS_int(2)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(3 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 32)         <= (others => '0');
               shim2IP_WrCE_int(0 to 32)         <= (others => '0');
               shim2IP_RdCE_int(33)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(33)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(34 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(34 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
               --Temac 0  Receive VLAN Translation, Tag, Strip Table 0 (BRAM)
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"08000" and bus2Shim_Addr_reg(12 to 31) <= X"0BFFF" then
            elsif bus2Shim_Addr_reg(13 to 18) = "000100" or          --0x8000 - 0x9FFF
                  bus2Shim_Addr_reg(13 to 18) = "000101" then        --0xA000 - 0xBFFF
               shim2IP_CS_int(0 to 2)            <= (others => '0');
               shim2IP_CS_int(3)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(4 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 33)         <= (others => '0');
               shim2IP_WrCE_int(0 to 33)         <= (others => '0');
               shim2IP_RdCE_int(34)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(34)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(35 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(35 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
               --Temac 0 Ethernet AVB
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"10000" and bus2Shim_Addr_reg(12 to 31) <= X"13FFF" then
            elsif bus2Shim_Addr_reg(13 to 18) = "001000" or           --0x10000 - 0x11FFF
                  bus2Shim_Addr_reg(13 to 18) = "001001" then         --0x12000 - 0x13FFF
               shim2IP_CS_int(0 to 3)            <= (others => '0');
               shim2IP_CS_int(4)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(5 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 34)         <= (others => '0');
               shim2IP_WrCE_int(0 to 34)         <= (others => '0');
               shim2IP_RdCE_int(35)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(35)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(36 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(36 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
               --Temac 0 Multicast Address Table (BRAM)
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"20000" and bus2Shim_Addr_reg(12 to 31) <= X"3FFFF" then
            elsif bus2Shim_Addr_reg(13 to 14) = "01" then              --0x20000 - 0X3FFFF
               shim2IP_CS_int(0 to 4)            <= (others => '0');
               shim2IP_CS_int(5)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(6 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 35)         <= (others => '0');
               shim2IP_WrCE_int(0 to 35)         <= (others => '0');
               shim2IP_RdCE_int(36)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(36)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(37 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(37 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';

               --Temac 1 Statistics Counters
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"40200" and bus2Shim_Addr_reg(12 to 31) <= X"403FF" then
            elsif bus2Shim_Addr_reg(13 to 22) = "1000000001" then    --0x40200 - 0x403FF
               shim2IP_CS_int(0 to 5)            <= (others => '0');
               shim2IP_CS_int(6)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(7 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 36)         <= (others => '0');
               shim2IP_WrCE_int(0 to 36)         <= (others => '0');
               shim2IP_RdCE_int(37)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(37)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(38 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(38 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
               --Temac 1  Transmit VLAN Translation, Tag, Strip Table 1 (BRAM)
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"44000" and bus2Shim_Addr_reg(12 to 31) <= X"47FFF" then
            elsif bus2Shim_Addr_reg(13 to 18) = "100010" or           --0x44000 - 0x45FFF
                  bus2Shim_Addr_reg(13 to 18) = "100011" then         --0x46000 - 0x47FFF
               shim2IP_CS_int(0 to 6)            <= (others => '0');
               shim2IP_CS_int(7)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(8 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 37)         <= (others => '0');
               shim2IP_WrCE_int(0 to 37)         <= (others => '0');
               shim2IP_RdCE_int(38)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(38)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(39 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(39 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
               --Temac 1  Receive VLAN Translation, Tag, Strip Table 1 (BRAM)
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"48000" and bus2Shim_Addr_reg(12 to 31) <= X"4BFFF" then
            elsif bus2Shim_Addr_reg(13 to 18) = "100100" or           --0x48000 - 0x49FFF
                  bus2Shim_Addr_reg(13 to 18) = "100101" then         --0x4A000 - 0x4BFFF
               shim2IP_CS_int(0 to 7)            <= (others => '0');
               shim2IP_CS_int(8)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(9 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 38)         <= (others => '0');
               shim2IP_WrCE_int(0 to 38)         <= (others => '0');
               shim2IP_RdCE_int(39)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(39)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(40 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(40 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
               --Temac 1 Ethernet AVB
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"50000" and bus2Shim_Addr_reg(12 to 31) <= X"53FFF" then
            elsif bus2Shim_Addr_reg(13 to 18) = "101000" or           --0x50000 - 0x51FFF
                  bus2Shim_Addr_reg(13 to 18) = "101001" then         --0x52000 - 0x53FFF
               shim2IP_CS_int(0 to 8)            <= (others => '0');
               shim2IP_CS_int(9)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(C_NUM_CS)          <= '0';
               shim2IP_RdCE_int(0 to 39)         <= (others => '0');
               shim2IP_WrCE_int(0 to 39)         <= (others => '0');
               shim2IP_RdCE_int(40)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(40)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(C_NUM_CE)        <= '0';
               shim2IP_WrCE_int(C_NUM_CE)        <= '0';
               invalidAddrRspns                  <= '0';
               --Temac 1 Multicast Address Table (BRAM)
--            elsif bus2Shim_Addr_reg(12 to 31) >= X"60000" and bus2Shim_Addr_reg(12 to 31) <= X"7FFFF" then
            elsif bus2Shim_Addr_reg(13) = '1' then               --0x60000 - 0x7FFFF
               shim2IP_CS_int(0 to 9)            <= (others => '0');
               shim2IP_CS_int(C_NUM_CS)          <= bus2Shim_CS_reg;
               shim2IP_RdCE_int(0 to 40)         <= (others => '0');
               shim2IP_WrCE_int(0 to 40)         <= (others => '0');
               shim2IP_RdCE_int(C_NUM_CE)        <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(C_NUM_CE)        <= bus2Shim_WrCE_reg;
               invalidAddrRspns                  <= '0';
            else
               shim2IP_CS_int       <= (others => '0');
               shim2IP_RdCE_int     <= (others => '0');
               shim2IP_WrCE_int     <= (others => '0');
               invalidAddrRspns     <= '1';
            end if;
         else
            shim2IP_CS_int       <= (others => '0');
            shim2IP_RdCE_int     <= (others => '0');
            shim2IP_WrCE_int     <= (others => '0');
            invalidAddrRspns     <= '0';
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- Register Address Decode Signals for timing
      ----------------------------------------------------------------------------
      REG_DECODE_SIGNALS : process (intPlbClk)
      begin

         if rising_edge(intPlbClk) then
            if SPLB_Reset = '1' or IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1' then
               shim2IP_CS   <= (others => '0');
               shim2IP_RdCE <= (others => '0');
               shim2IP_WrCE <= (others => '0');
               shim2IP_RNW  <= '0';
               Shim2IP_Addr <= (others => '0');
            else
               shim2IP_CS   <= shim2IP_CS_int  ;
               shim2IP_RdCE <= shim2IP_RdCE_int;
               shim2IP_WrCE <= shim2IP_WrCE_int;
               shim2IP_RNW  <= shim2IP_RNW_int;
               Shim2IP_Addr <= bus2Shim_Addr_reg;
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- Delay invalid response for rising edge detect
      ----------------------------------------------------------------------------
      DELAY_INVALID_RESPONSE : process (intPlbClk)
      begin

         if rising_edge(intPlbClk) then
            if bus2Shim_CS_reg = '1' then
               invalidAddrRspns_reg <= invalidAddrRspns;
            else
               invalidAddrRspns_reg <= '0';
            end if;
         end if;
      end process;



      ----------------------------------------------------------------------------
      -- Set invalid Request for Read transaction if it occured
      ----------------------------------------------------------------------------
      SET_INVALID_READ : process (intPlbClk)
      begin

         if rising_edge(intPlbClk) then
            if bus2Shim_RdCE_reg = '1' then
               --Pulse signal using rising edge detection
               invalidRdReq <= invalidAddrRspns and not invalidAddrRspns_reg;
            else
               invalidRdReq <= '0';
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- Set invalid Request for Write transaction if it occured
      ----------------------------------------------------------------------------
      SET_INVALID_WRITE : process (intPlbClk)
      begin

         if rising_edge(intPlbClk) then
            if bus2Shim_WrCE_reg = '1' then
               --Pulse signal using rising edge detection
               invalidWrReq <= invalidAddrRspns and not invalidAddrRspns_reg;
            else
               invalidWrReq <= '0';
            end if;
         end if;
      end process;


end rtl;