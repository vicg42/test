------------------------------------------------------------------------------
-- $Id: tx_ll_if.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- tx_ll_if.vhd
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
-- Filename:        tx_ll_if.vhd
-- Version:         v1.00a
-- Description:     interface block between LL and hard fifos
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
--
-- ^^^^^^
--  MW  09/09/2008
--    -- Fixed CSUM offload build.  Broke it with the addition of VLAN.
--    -- Moved PIPE_DELAY_LL from tx_llink_top to this module       
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
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


library unisim;
use unisim.vcomponents.all;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

------------------------------------------------------------------------------
-- Port Declaration
------------------------------------------------------------------------------

entity tx_ll_if is
   generic (
      C_FAMILY               : string               := "virtex5";
      C_TEMAC_TXCSUM         : integer := 0;
      C_FIFO_DEPTH_LOG2X     : integer := 13;
      C_TEMAC_TXVLAN_TRAN    : integer range 0 to 1 :=  1;
      C_TEMAC_TXVLAN_TAG     : integer range 0 to 1 :=  1;
      C_TEMAC_TXVLAN_STRP    : integer range 0 to 1 :=  1

     );
   port(
      LLTemac_Clk            : in  std_logic;
      LLTemac_Rst            : in  std_logic;

      LLTemac_Data_inc       : in  std_logic_vector(0 to 31);
      LLTemac_SOF_n_inc      : in  std_logic;
      LLTemac_SOP_n_inc      : in  std_logic;
      LLTemac_EOF_n_inc      : in  std_logic;
      LLTemac_EOP_n_inc      : in  std_logic;
      LLTemac_SRC_RDY_n_inc  : in  std_logic;
      LLTemac_REM_inc        : in  std_logic_vector(0 to 3);
      lLTemac_DST_RDY_n_inc  : in  std_logic;

      LLTemac_SRC_RDY_dly_n1 : out  std_logic;
      LLTemac_DST_RDY_dly_n1 : out  std_logic;
      LLTemac_EOP_dly_n1     : out  std_logic;
      
      force_dest_rdy_high    : out  std_logic;

      CSFIFO2LL_full         : in  std_logic;
      LL2CSFIFO_wren         : out std_logic;
      LL2CSFIFO_data         : out std_logic_vector(0 to 35);

      TXFIFO2LL_full         : in  std_logic;
      txFIFO2IP_aFull        : in  std_logic;
      LL2TXFIFO_data         : out std_logic_vector(0 to 35);
      LL2TXFIFO_wren         : out std_logic;
      Csum_Ready             : in  std_logic;

      -- VLAN Support signals
      TtagRegData            : in  std_logic_vector(0 to 31);
      Tpid0RegData           : in  std_logic_vector(0 to 31);
      Tpid1RegData           : in  std_logic_vector(0 to 31);

      LlinkClkAddr           : out std_logic_vector(0 to 11);
      LlinkClkRdData         : in  std_logic_vector(18 to 31);
                              --    Bit         Bit         Bit   
                              -- 18 - 29        30          31                                     
                              --    VID      Strip En    Tag En   
      LlinkClkTxVlanBramEnA  : out std_logic;

      LlinkClkNewFncEnbl     : in  std_logic;
      LlinkClkTxVStrpMode    : in  std_logic_vector(0 to 1);
      LlinkClkTxVTagMode     : in  std_logic_vector(0 to 1)

      );
end tx_ll_if;
                                                                                     
------------------------------------------------------------------------------       
-- Definition of Generics:
--
-- Definition of Ports:
--
------------------------------------------------------------------------------

architecture beh of tx_ll_if is

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

signal sop                 : std_logic;
signal eop                 : std_logic;
signal csum_insert         : std_logic_vector(0 to 15);
signal csum_data           : std_logic_vector(0 to 15);
signal csum_en             : std_logic;
signal csum_wren           : std_logic;
signal wren                : std_logic;
signal tied_low            : std_logic_vector(0 to 31) := (others=>'0');
signal remainder           : integer;
signal lLTemac_Data_i      : std_logic_vector(0 to 31);

signal new_rem_encoded     : std_logic_vector(0 to 1);
signal new_lL2TXFIFO_Wren_i: std_logic;

signal LLTemac_Data_dly           : std_logic_vector(0 to 31);
signal LLTemac_SOF_dly_n          : std_logic;
signal LLTemac_SOP_dly_n          : std_logic;
signal LLTemac_EOF_dly_n          : std_logic;
signal LLTemac_EOP_dly_n          : std_logic;
signal LLTemac_SRC_RDY_dly_n      : std_logic;
signal LLTemac_REM_dly            : std_logic_vector(0 to 3);
signal LLTemac_DST_RDY_dly_n      : std_logic;

signal ll_temac_hdr             : std_logic;

begin

------------------------------------------------------------------------------
-- Concurrent assignments
------------------------------------------------------------------------------
LLTemac_SRC_RDY_dly_n1  <= LLTemac_SRC_RDY_dly_n;
LLTemac_DST_RDY_dly_n1  <= LLTemac_DST_RDY_dly_n;
LLTemac_EOP_dly_n1      <= LLTemac_EOP_dly_n;

LL2CSFIFO_Data <= csum_data&csum_insert&csum_en&tied_low(0 to 2);
LL2CSFIFO_Wren <= csum_wren;

-------------------------------------------------------------------------------
-- This generate is for the delay needed to support CSUM Offloading when VLAN
-- is not enabled.  This also must cover the case of when neither CSUM 
-- offloading nor VLAN are enabled.  CSUM Offloading and VLAN support are 
-- mutually exclusive for the EDK 11 (Lava) release.
-------------------------------------------------------------------------------
GEN_WIRES_FOR_CSUM : if C_TEMAC_TXCSUM = 1 or 
                        (C_TEMAC_TXCSUM = 0   and C_TEMAC_TXVLAN_TRAN = 0 and 
                         C_TEMAC_TXVLAN_TAG = 0 and C_TEMAC_TXVLAN_STRP = 0) generate
                         

signal LLTemac_Data_dly_csum      : std_logic_vector(0 to 31);
signal LLTemac_SOF_dly_n_csum     : std_logic;
signal LLTemac_SOP_dly_n_csum     : std_logic;
signal LLTemac_EOF_dly_n_csum     : std_logic;
signal LLTemac_EOP_dly_n_csum     : std_logic;
signal LLTemac_SRC_RDY_dly_n_csum : std_logic;
signal LLTemac_REM_dly_csum       : std_logic_vector(0 to 3);
signal LLTemac_DST_RDY_dly_n_csum : std_logic;

                         
                         
begin

   LLTemac_Data_dly        <= LLTemac_Data_dly_csum;      
   LLTemac_SOF_dly_n       <= LLTemac_SOF_dly_n_csum;     
   LLTemac_SOP_dly_n       <= LLTemac_SOP_dly_n_csum;     
   LLTemac_EOF_dly_n       <= LLTemac_EOF_dly_n_csum;     
   LLTemac_EOP_dly_n       <= LLTemac_EOP_dly_n_csum;     
   LLTemac_SRC_RDY_dly_n   <= LLTemac_SRC_RDY_dly_n_csum; 
   LLTemac_REM_dly         <= LLTemac_REM_dly_csum;       
   LLTemac_DST_RDY_dly_n   <= LLTemac_DST_RDY_dly_n_csum;

   new_lL2TXFIFO_Wren_i <= not TXFIFO2LL_Full and
                        not LLTemac_DST_RDY_dly_n and
                        not LLTemac_SRC_RDY_dly_n and
                        LLTemac_EOF_dly_n and
                        not ll_temac_hdr;
                        
   LL2TXFIFO_Wren <= new_lL2TXFIFO_Wren_i;
   LL2TXFIFO_Data <= LLTemac_Data_dly & new_rem_encoded & sop & eop;
   
   sop <= not LLTemac_DST_RDY_dly_n and not LLTemac_SRC_RDY_dly_n and not LLTemac_SOP_dly_n;
   eop <= not LLTemac_DST_RDY_dly_n and not LLTemac_SRC_RDY_dly_n and not LLTemac_EOP_dly_n; 
   
   
   LlinkClkAddr          <= (others => '0');         
   LlinkClkTxVlanBramEnA <= '0';
   force_dest_rdy_high   <= '0';
   
   -------------------------------------------------------------------------------
   -- Add pipe Line delay to keep all local link signals in sync with each other
   -- Added to support delay that is incurred from change that implemented
   -- ll_temac_hdr signal
   -------------------------------------------------------------------------------
   PIPE_DELAY_LL : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst='1' then
            LLTemac_Data_dly_csum      <= (others => '0');
            LLTemac_SOF_dly_n_csum     <= '1';
            LLTemac_SOP_dly_n_csum     <= '1';
            LLTemac_EOF_dly_n_csum     <= '1';
            LLTemac_EOP_dly_n_csum     <= '1';
            LLTemac_SRC_RDY_dly_n_csum <= '1';
            LLTemac_REM_dly_csum       <= (others => '0');
            LLTemac_DST_RDY_dly_n_csum <= '1';
         else
            LLTemac_Data_dly_csum      <= LLTemac_Data_inc;
            LLTemac_SOF_dly_n_csum     <= LLTemac_SOF_n_inc;
            LLTemac_SOP_dly_n_csum     <= LLTemac_SOP_n_inc;
            LLTemac_EOF_dly_n_csum     <= LLTemac_EOF_n_inc;
            LLTemac_EOP_dly_n_csum     <= LLTemac_EOP_n_inc;
            LLTemac_SRC_RDY_dly_n_csum <= LLTemac_SRC_RDY_n_inc;
            LLTemac_REM_dly_csum       <= LLTemac_REM_inc;
            LLTemac_DST_RDY_dly_n_csum <= lLTemac_DST_RDY_n_inc;
         end if;
      end if;
   end process;

end generate;   

   
------------------------------------------------------------------------------
-- This process uses the non delayed version of the ll_temac signals to
-- assert the delayed ll_temac_hdr signal.  This signal will get asserted when
-- LLTemac_SOF_n_inc goes LOW, will remain asserted while ll_temac_hdr is HIGH, 
-- and will be cleared when until LLTemac_SOP_n_inc goes LOW. 
------------------------------------------------------------------------------
VARIABLE_HEADER_VALID : process(LLTemac_Clk)
begin
   if(rising_edge(LLTemac_Clk))then
      if(LLTemac_Rst='1') then
         ll_temac_hdr <= '0';
      else
         ll_temac_hdr <= (not LLTemac_SOF_n_inc or --set  
                          ll_temac_hdr) and    --hold 
                          LLTemac_SOP_n_inc;       --clr         
      end if;
   end if;
end process;

remainder  <= to_integer(unsigned(LLTemac_REM_dly));

REMAINDER_PROCESS : process(LLTemac_Rst, LLTemac_Data_dly, remainder, tied_low)
   begin
      if(LLTemac_Rst='1') then
         lLTemac_Data_i <= LLTemac_Data_dly;--(others=>'0');
      else--if(Csum_Ready='1') then
         case remainder is
            when 0 =>
               lLTemac_Data_i <= LLTemac_Data_dly;

            when 1 =>
               lLTemac_Data_i <= LLTemac_Data_dly(0 to 23)&tied_low(24 to 31);

            when 3 =>
               lLTemac_Data_i <= LLTemac_Data_dly(0 to 15)&tied_low(16 to 31);

            when 7 =>
               lLTemac_Data_i <= LLTemac_Data_dly(0 to 7)&tied_low(8 to 31);

            when others =>
               lLTemac_Data_i <= LLTemac_Data_dly;--null;
         end case;
--      else
--         lLTemac_Data_i <= LLTemac_Data_dly;--(others=>'0');

      end if;
   end process;



GEN_TXCSUM : if(C_TEMAC_TXCSUM = 1) generate

   I_TXCSUM : entity xps_ll_temac_v2_03_a.tx_csum_top_wrapper
   generic map(
      C_FIFO_DEPTH_LOG2X => C_FIFO_DEPTH_LOG2X
      )
   port map(
      Clk                  => LLTemac_Clk,             -- in
      Rst                  => LLTemac_Rst,             -- in
      Din                  => lLTemac_Data_i,          -- in
      Wren                 => new_lL2TXFIFO_Wren_i,    -- in
      LLTemac_SOF_n        => LLTemac_SOF_dly_n,    -- in
      LLTemac_EOP_n        => LLTemac_EOP_dly_n,    -- in
      LLTemac_SRC_RDY_n    => LLTemac_SRC_RDY_dly_n,-- in
      LLTemac_DST_RDY_n    => LLTemac_DST_RDY_dly_n,-- in
      Csum_insert          => csum_insert,             -- out
      Csum_en              => csum_en,                 -- out
      Csum_wren            => csum_wren,               -- out
      Csum_data            => csum_data                -- out
      );
      
end generate;


GEN_NO_TXCSUM : if(C_TEMAC_TXCSUM = 0) generate

   csum_data   <= (others=>'0');
   csum_insert <= (others=>'0');
   csum_en     <= '0';
   wren        <= '0';

   csum_wren   <= not LLTemac_DST_RDY_dly_n and
                  not LLTemac_SRC_RDY_dly_n and
                  not LLTemac_EOP_dly_n;
end generate;


ENCODE_REM_PROCESS : process(LLTemac_Rst, LLTemac_REM_dly)
   begin
      if(LLTemac_Rst='1') then
         new_rem_encoded <= (others=>'0');
      else
         case LLTemac_REM_dly(0 to 3) is
            when "0111" =>
               new_rem_encoded <= "00";
            when "0011" =>
               new_rem_encoded <= "01";
            when "0001" =>
               new_rem_encoded <= "10";
            when "0000" =>
               new_rem_encoded <= "11";
            when others =>
               new_rem_encoded <= "00";
         end case;
      end if;
   end process;


GEN_VLAN_SUPPORT : if C_TEMAC_TXCSUM = 0 and
                     (C_TEMAC_TXVLAN_TRAN = 1 or C_TEMAC_TXVLAN_TAG = 1 or C_TEMAC_TXVLAN_STRP = 1) generate

signal LLTemac_Data_dly_vlan      : std_logic_vector(0 to 31);                     
signal LLTemac_SOF_dly_n_vlan     : std_logic;                                     
signal LLTemac_SOP_dly_n_vlan     : std_logic;                                     
signal LLTemac_EOF_dly_n_vlan     : std_logic;                                     
signal LLTemac_EOP_dly_n_vlan     : std_logic;                                     
signal LLTemac_SRC_RDY_dly_n_vlan : std_logic;                                     
signal LLTemac_REM_dly_vlan       : std_logic_vector(0 to 3);                                           
signal LLTemac_DST_RDY_dly_n_vlan : std_logic;                                     
                     
signal TxVlanFifoWrEn             : std_logic;  
                   
begin


   LLTemac_Data_dly      <= LLTemac_Data_dly_vlan     ;
   LLTemac_SOF_dly_n     <= LLTemac_SOF_dly_n_vlan    ;
   LLTemac_SOP_dly_n     <= LLTemac_SOP_dly_n_vlan    ;
   LLTemac_EOF_dly_n     <= LLTemac_EOF_dly_n_vlan    ;
   LLTemac_EOP_dly_n     <= LLTemac_EOP_dly_n_vlan    ;
   LLTemac_SRC_RDY_dly_n <= LLTemac_SRC_RDY_dly_n_vlan;
   LLTemac_REM_dly       <= LLTemac_REM_dly_vlan      ;
   LLTemac_DST_RDY_dly_n <= LLTemac_DST_RDY_dly_n_vlan;       
   
   LL2TXFIFO_wren <= TxVlanFifoWrEn;                     
   LL2TXFIFO_Data <= LLTemac_Data_dly & new_rem_encoded & sop & eop;
   
   sop <= not LLTemac_DST_RDY_dly_n and not LLTemac_SRC_RDY_dly_n and not LLTemac_SOP_dly_n;
   eop <= not LLTemac_DST_RDY_dly_n and not LLTemac_SRC_RDY_dly_n and not LLTemac_EOP_dly_n;

                                                                                                   
   I_TXVLAN_SUPPORT : entity  xps_ll_temac_v2_03_a.tx_vlan_support
      generic map(
         C_FAMILY                   => C_FAMILY           ,
         C_TEMAC_TXVLAN_TRAN        => C_TEMAC_TXVLAN_TRAN,
         C_TEMAC_TXVLAN_TAG         => C_TEMAC_TXVLAN_TAG ,
         C_TEMAC_TXVLAN_STRP        => C_TEMAC_TXVLAN_STRP
         )                          
                                    
       port map(                        
         LLTemac_Clk                => LLTemac_Clk,                    -- in
         LLTemac_Rst                => LLTemac_Rst,                    -- in
                                                                       
         --Local Link input delayed once in xps_ll_top                 
         LLTemac_Data_inc           => LLTemac_Data_inc     ,          -- in                
         LLTemac_SOF_n_inc          => LLTemac_SOF_n_inc    ,          -- in                
         LLTemac_SOP_n_inc          => LLTemac_SOP_n_inc    ,          -- in                
         LLTemac_EOF_n_inc          => LLTemac_EOF_n_inc    ,          -- in                
         LLTemac_EOP_n_inc          => LLTemac_EOP_n_inc    ,          -- in                
         LLTemac_SRC_RDY_n_inc      => LLTemac_SRC_RDY_n_inc,          -- in                
         LLTemac_REM_inc            => LLTemac_REM_inc      ,          -- in                
         LLTemac_DST_RDY_n_inc      => LLTemac_DST_RDY_n_inc,          -- in                
                                                                       
         -- The above *_inc signals delayed one clock                  
         LLTemac_Data_dly_vlan      => LLTemac_Data_dly_vlan,          -- out
         LLTemac_SOF_dly_n_vlan     => LLTemac_SOF_dly_n_vlan,         -- out
         LLTemac_SOP_dly_n_vlan     => LLTemac_SOP_dly_n_vlan,         -- out
         LLTemac_EOF_dly_n_vlan     => LLTemac_EOF_dly_n_vlan,         -- out
         LLTemac_EOP_dly_n_vlan     => LLTemac_EOP_dly_n_vlan,         -- out
         LLTemac_SRC_RDY_dly_n_vlan => LLTemac_SRC_RDY_dly_n_vlan,     -- out
         LLTemac_REM_dly_vlan       => LLTemac_REM_dly_vlan,           -- out
         LLTemac_DST_RDY_dly_n_vlan => LLTemac_DST_RDY_dly_n_vlan,     -- out
         
         force_dest_rdy_high        => force_dest_rdy_high,            -- out
                                                                       
         ll_temac_hdr               => ll_temac_hdr,                   -- in
         txFIFO2LL_Full             => txFIFO2LL_Full,                 -- in
         txFIFO2IP_aFull            => txFIFO2IP_aFull,                -- in
                                                                       
         TtagRegData                => TtagRegData,                    -- in
         Tpid0RegData               => Tpid0RegData,                   -- in
         Tpid1RegData               => Tpid1RegData,                   -- in
         LlinkClkAddr               => LlinkClkAddr,                   -- out
         LlinkClkRdData             => LlinkClkRdData,                 -- in
                                    --    Bit         Bit         Bit  
                                    -- 18 - 29        30          31   
                                    --    VID      Strip En    Tag En  
         LlinkClkTxVlanBramEnA      => LlinkClkTxVlanBramEnA,          -- out
         LlinkClkNewFncEnbl         => LlinkClkNewFncEnbl,             -- in
         LlinkClkTxVStrpMode        => LlinkClkTxVStrpMode,            -- in
         LlinkClkTxVTagMode         => LlinkClkTxVTagMode,             -- in
      
         TxVlanFifoWrEn             => TxVlanFifoWrEn
         );

end generate;

end beh;
