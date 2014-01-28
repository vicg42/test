------------------------------------------------------------------------------
-- $Id: tx_temac_if.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- tx.vhd
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
-- Filename:        tx_temac_if.vhd
-- Version:         v1.00a
-- Description:     hard fifo, csum fifo, client fifo controller and muxes
--                  data from 32 bit to 8 bit
--
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--            -- xps_ll_temac.vhd
--               -- soft_temac_wrap.vhd
--               -- v4_temac_wrap.vhd
--               -- v5_temac_wrap.vhd
--               -- tx_llink_top.vhd
--                  -- tx_temac_if.vhd         ******
--                     -- tx_temac_if_sm.vhd
--                     -- tx_csum_mux.vhd
--                     -- tx_data_mux.vhd
--                     -- tx_cl_if.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:      DRP
-- History:
--  DRP      2006.04.27      -- First version
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

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

library unisim;
use unisim.vcomponents.all;

------------------------------------------------------------------------------
-- Port Declaration
------------------------------------------------------------------------------

entity tx_temac_if is
    generic (
             C_FAMILY        : string               := "virtex5";
             C_RESET_ACTIVE  : std_logic            := '1';
             C_CLIENT_DWIDTH : integer              :=  8;
             C_TEMAC_TYPE    : integer range 0 to 3 :=  0
            );

    port    (
             LLTemac_Clk            : in  std_logic;
             LLTemac_Rst            : in  std_logic;

             IP2TXFIFO_RdReq        : out std_logic;
             TXFIFO2IP_Data         : in  std_logic_vector(0 to 35);
             TXFIFO2IP_RdAck        : in  std_logic;
             TXFIFO2IP_Empty        : in  std_logic;
             TXFIFO2IP_Und          : in  std_logic;
             TXFIFO2IP_Ovr          : in  std_logic;

             TXFIFO_Und_Intr        : out std_logic;

             CSFIFO2IP_Ovr          : in  std_logic;
             CSFIFO2IP_Und          : in  std_logic;
             CSFIFO2IP_Empty        : in  std_logic;
             CSFIFO2IP_Data         : in  std_logic_vector(0 to 35);
             IP2CSFIFO_RdReq        : out std_logic;

             Tx2ClientPauseReq      : in  std_logic;
             ClientEmacPauseReq     : out std_logic;

             Tx_cmplt               : out std_logic;

             Tx_Cl_Clk              : in  std_logic;
             ClientEmacTxd          : out std_logic_vector(7 downto 0);
             ClientEmacTxdVld       : out std_logic;
             ClientEmacTxdVldMsw    : out std_logic;
             ClientEmacTxFirstByte  : out std_logic;
             ClientEmacTxUnderRun   : out std_logic;
             EmacClientTxAck        : in  std_logic;
             EmacClientTxCollision  : in  std_logic;
             EmacClientTxRetransmit : in  std_logic;
             EmacClientTxCE         : in  std_logic;
             Tx2ClientUnderRunIntrpt: out std_logic
            );
end tx_temac_if;

------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
--
------------------------------------------------------------------------------

architecture beh of tx_temac_if is

------------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------------

constant C_BUS_DWIDTH   : integer := 32;
constant TX_MUX_REG     : std_logic := '0'; -- 1 to include register
                                            -- 0 to exclude register

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

signal iP2TXFIFO_RdReq_i   : std_logic;

signal tx_cmplt_i          : std_logic;
signal tx_cmplt_d1         : std_logic;
signal tx_cmplt_d2         : std_logic;
signal tx_cmplt_d3         : std_logic;
signal tx_cmplt_d4         : std_logic;
signal tx_cmplt_d5         : std_logic;

signal cl_Fifo_WrEn        : std_logic;
signal Cl_Fifo_Empty       : std_logic;
signal cl_Fifo_full        : std_logic;
signal tx2ClientUnderRun   : std_logic := '0';
signal client2TxCollision  : std_logic;
signal client2TxRetransmit : std_logic;
signal txData_Mux_Sel      : std_logic_vector(0 to 1);
--signal TXFIFO2IP_Data_d    : std_logic_vector(0 to C_BUS_DWIDTH-1);
signal bytes_Valid         : std_logic_vector(0 to 1);
signal TXFIFO2TxClient     : std_logic_vector(0 to 15);
signal txD2Cl_fifo         : std_logic_vector(0 to 17);
signal csum_txdata_mux     : std_logic_vector(0 to C_BUS_DWIDTH-1);
signal rem_encoded         : std_logic_vector(0 to 1);
signal rem_decoded         : std_logic_vector(0 to 3);
signal csum_en             : std_logic;
signal sop                 : std_logic;
signal sop_i               : std_logic;
signal eop                 : std_logic;
signal eop_i               : std_logic;
signal eop_d1              : std_logic;
signal tx_pckt_valid       : std_logic;
signal tx_packet_valid     : std_logic;
signal csum_en_i           : std_logic;
signal sM_encoded          : std_logic_vector(0 to 2);
signal sig_tx_rdy          : std_logic;
signal ClientEmacTxdVld_samp  : std_logic;
signal ClientEmacTxdVld_i     : std_logic;
signal ClientEmacTxdVld_done  : std_logic;
signal ClientEmacTxdVld_d1    : std_logic;
------------------------------------------------------------------------------
-- Simulation architecture begin
------------------------------------------------------------------------------

begin

Tx2ClientUnderRunIntrpt <= '0';

------------------------------------------------------------------------------
-- Concurrent Signal Assignments
------------------------------------------------------------------------------

IP2TXFIFO_RdReq <= iP2TXFIFO_RdReq_i;
--Tx_cmplt <= tx_cmplt_i;
txD2Cl_fifo <= bytes_Valid & TXFIFO2TxClient;
rem_encoded <= TXFIFO2IP_data(32 to 33);

STRETCH_INTRPT : process(LLTemac_Clk)
   begin
     if (LLTemac_Clk'event and LLTemac_Clk = '1') then
       if (LLTemac_Rst = C_RESET_ACTIVE) then
         tx_cmplt_d1 <= '0';
         tx_cmplt_d2 <= '0';
         tx_cmplt_d3 <= '0';
         tx_cmplt_d4 <= '0';
         tx_cmplt_d5 <= '0';
         sig_tx_rdy  <= '1';
       else
         --need to put in a fix for 10/100 mode only
         ClientEmacTxdVld_samp <= ClientEmacTxdVld_i;
         ClientEmacTxdVld_d1   <= ClientEmacTxdVld_samp;
         ClientEmacTxdVld_done <= ClientEmacTxdVld_d1;

         if(ClientEmacTxdVld_done='1' and ClientEmacTxdVld_d1='0') then
           sig_tx_rdy    <= '1';
         end if;

         if(tx_cmplt_i='1') then
           sig_tx_rdy <= '0';
         end if;

         tx_cmplt_d1 <= tx_cmplt_i;
         tx_cmplt_d2 <= tx_cmplt_d1;
         tx_cmplt_d3 <= tx_cmplt_d2;
         tx_cmplt_d4 <= tx_cmplt_d3;
         tx_cmplt_d5 <= tx_cmplt_d4;
         Tx_cmplt    <= (tx_cmplt_i OR tx_cmplt_d1 OR tx_cmplt_d2 OR tx_cmplt_d3 OR tx_cmplt_d4 OR tx_cmplt_d5);

       end if;
     end if;
   end process;


------------------------------------------------------------------------------
-- This process makes a single clock sop and eop pulse
------------------------------------------------------------------------------

SOP_EOP_STROBE : process(LLTemac_Clk)
   begin
      if(rising_edge(LLTemac_Clk)) then
         if(LLTemac_Rst='1') then
            sop_i  <= '0';
            eop_i  <= '0';
         else
            sop_i  <= TXFIFO2IP_Data(34);
            eop_i  <= TXFIFO2IP_data(35);
         end if;
      end if;
   end process;

sop <= TXFIFO2IP_Data(34) and not sop_i;
eop <= TXFIFO2IP_Data(35) and not eop_i;

EOP_REG : process(LLTemac_Clk)
   begin
      if(rising_edge(LLTemac_Clk)) then
         if(LLTemac_Rst ='1') then
            eop_d1 <= '0';
         else
            eop_d1 <= eop;
         end if;
      end if;
   end process;

------------------------------------------------------------------------------
-- This process encodes the 4-bit remainder to 2-bit remainder
------------------------------------------------------------------------------
--TX_PACKET_VALID_PROCESS : process(LLTemac_Rst, sop, tx_cmplt_i)
--   begin
--      if(LLTemac_Rst='1' or tx_cmplt_i='1') then
--         tx_pckt_valid <= '0';
--      elsif(sop='1') then
--         tx_pckt_valid <= '1';
--      end if;
--   end process;


   process(LLTemac_Clk)
     begin
       if(rising_edge(LLTemac_Clk)) then
         if(tx_cmplt_i='1' or LLTemac_Rst='1') then
           tx_pckt_valid <= '0';
         else
           if(sop='1') then
             tx_pckt_valid <= '1';
           end if;
         end if;
       end if;
   end process;

tx_packet_valid <= (tx_pckt_valid or eop or sop) and not tx_cmplt_i;

   TX_REM_ENC : process(LLTemac_Rst, 
                        rem_encoded, tx_packet_valid)
      begin
        if(LLTemac_Rst='1') then
           rem_decoded <= (others=>'0');
        elsif(tx_packet_valid='1') then
           if(rem_encoded="00") then
              rem_decoded <= "1000";   --bytes(0 to 0) valid
           elsif(rem_encoded="01") then
              rem_decoded <= "1100";   --bytes(0 to 1) valid
           elsif(rem_encoded="10") then
              rem_decoded <= "1110";   --bytes(0 to 2) valid
           else --(rem_encoded="11") then
              rem_decoded <= "1111";   --bytes(0 to 3) valid
           end if;                      
        else
           rem_decoded <= "0000";
        end if;
      end process;


------------------------------------------------------------------------------
-- This process creates the Bytes_Valid for the hard temac
------------------------------------------------------------------------------

BYTES_VALID_PROCESS : process(LLTemac_Rst, 
                              rem_decoded, tx_packet_valid,
                              txdata_Mux_Sel)
begin
   if(LLTemac_Rst='1') then
      bytes_Valid <= "00";
   else
      if(tx_packet_valid='1') then
         if(txdata_Mux_Sel="00") then
            bytes_Valid <= rem_decoded(0 to 1);
         else   
--         elsif(txdata_Mux_Sel="01") then
            bytes_Valid<= rem_decoded(2 to 3);
            
         end if;
      else
         bytes_Valid<="00";
      end if;
   end if;
end process;




------------------------------------------------------------------------------
-- Csum enable process
------------------------------------------------------------------------------

process(LLTemac_Clk)
begin
  if(rising_edge(LLTemac_Clk)) then
    if(LLTemac_Rst='1') then
      csum_en_i <= '0';
    else
      if(CSFIFO2IP_Data(32)='1' and TXFIFO2IP_Data(34)='1' and CSFIFO2IP_Data(0 to 15)/=x"0000") then
        --should never need to insert a csum that's = zero since that means
        --csum was not calculated.
        csum_en_i <= '1';
      end if;
    end if;
  end if;
end process;

--csum_en <= '1' when csum_en_i = '1' or (CSFIFO2IP_Data(32)='1' and TXFIFO2IP_Data(34)='1' and CSFIFO2IP_Data(0 to 15)/=x"0000") else '0';

csum_en <= '1' when (CSFIFO2IP_Data(32)='1' and TXFIFO2IP_Data(34)='1') else '0';


------------------------------------------------------------------------------
--  Component Instantiations
------------------------------------------------------------------------------

I_TX_TEMAC_IF_SM : entity xps_ll_temac_v2_03_a.tx_temac_if_sm
   generic map(
      C_RESET_ACTIVE      => C_RESET_ACTIVE,
      C_CLIENT_DWIDTH     => C_CLIENT_DWIDTH
      )
   port map(
      LLTemac_Clk         => LLTemac_Clk,          -- in
      LLTemac_Rst         => LLTemac_Rst,          -- in
      TXFIFO2IP_Und       => TXFIFO2IP_Und,        -- in
      TXFIFO2IP_Ovr       => TXFIFO2IP_Ovr,        -- in
      TXFIFO2IP_Empty     => TXFIFO2IP_Empty,      -- in
      IP2TXFIFO_RdReq     => iP2TXFIFO_RdReq_i,    -- out
      CSFIFO2IP_Ovr       => CSFIFO2IP_Ovr,        -- in
      CSFIFO2IP_Und       => CSFIFO2IP_Und,        -- in
      CSFIFO2IP_Empty     => CSFIFO2IP_Empty,      -- in
      IP2CSFIFO_RdReq     => IP2CSFIFO_RdReq,      -- out
      Eop                 => TXFIFO2IP_Data(35),--eop,                  -- in
      TxData_Mux_Sel      => txData_Mux_Sel,       -- out
      TXFIFO_Und_Intr     => TXFIFO_Und_Intr,      -- out
      Cl_Fifo_Empty       => Cl_Fifo_Empty,        -- in
      Cl_Fifo_full        => Cl_Fifo_full,         -- in
      Cl_Fifo_WrEn        => cl_Fifo_WrEn,         -- out
      Tx_cmplt            => tx_cmplt_i,           -- out
      Bytes_Valid         => bytes_Valid,           -- in
      TX_RDY              => sig_tx_rdy
      );

I_CSUM_MUX : entity xps_ll_temac_v2_03_a.tx_csum_mux
   generic map(
      C_BUS_DWIDTH        => C_BUS_DWIDTH
      )
   port map(
      Clk                 => LLTemac_Clk,                -- in
      Rst                 => LLTemac_Rst,                -- in
      Tx_Eop              => eop,                        -- in
      Tx_Sop              => sop,                        -- in
      Csum_data           => CSFIFO2IP_data(0 to 15),    -- in
      TXFIFO_data         => TXFIFO2IP_data(0 to 31),    -- in
      Csum_insert         => CSFIFO2IP_data(16 to 31),   -- in
      Csum_en             => csum_en,                    -- in
      IP2TXFIFO_RdReq     => iP2TXFIFO_RdReq_i,          -- in
      Csum_Txdata_mux     => csum_txdata_mux             -- out
      );


I_TX_DATA_MUX : entity xps_ll_temac_v2_03_a.tx_data_mux(simulation)
    generic map (
                 C_RESET_ACTIVE  => C_RESET_ACTIVE,
                 C_BUS_DWIDTH    => C_BUS_DWIDTH,
                 C_CLIENT_DWIDTH => C_CLIENT_DWIDTH,
                 C_TX_MUX_REG    => TX_MUX_REG
                )

    port map    (
                 LLTemac_Clk      => LLTemac_Clk,       -- in
                 LLTemac_Rst      => LLTemac_Rst,       -- in
                 TxData_Mux_Sel   => txData_Mux_Sel,    -- in
                 WFIFO2IP_Data    => csum_txdata_mux,   -- in
                 WFIFO2TxClient   => TXFIFO2TxClient    -- out
                );

I_TX_CL_IF : entity xps_ll_temac_v2_03_a.tx_cl_if(simulation)
    generic map (
                 C_FAMILY        => C_FAMILY,
                 C_RESET_ACTIVE  => C_RESET_ACTIVE,
                 C_CLIENT_DWIDTH => C_CLIENT_DWIDTH,
                 C_TEMAC_TYPE    => C_TEMAC_TYPE
                )

    port map    (
                 LLTemac_Clk            => LLTemac_Clk,            -- in
                 LLTemac_Rst            => LLTemac_Rst,            -- in

                 Cl_Fifo_WrEn           => cl_Fifo_WrEn,           -- in
                 TxD2Cl_fifo            => txD2Cl_fifo,            -- in
                 Cl_Fifo_Empty          => Cl_Fifo_Empty,          -- out
                 Cl_Fifo_full           => cl_Fifo_full,           -- out

                 Tx2ClientUnderRun      => tx2ClientUnderRun,      -- in
                 Tx2ClientPauseReq      => Tx2ClientPauseReq,      -- in
                 ClientEmacPauseReq     => ClientEmacPauseReq,     -- out
                 Client2TxCollision     => client2TxCollision,     -- out
                 Client2TxRetransmit    => client2TxRetransmit,    -- out

                 Tx_Cl_Clk              => Tx_Cl_Clk,              -- in
                 ClientEmacTxd          => ClientEmacTxd,          -- out
                 ClientEmacTxdVld       => ClientEmacTxdVld_i,       -- out
                 ClientEmacTxdVldMsw    => ClientEmacTxdVldMsw,    -- out
                 ClientEmacTxFirstByte  => ClientEmacTxFirstByte,  -- out
                 ClientEmacTxUnderRun   => ClientEmacTxUnderRun,   -- out
                 EmacClientTxAck        => EmacClientTxAck,        -- in
                 EmacClientTxCollision  => EmacClientTxCollision,  -- in
                 EmacClientTxRetransmit => EmacClientTxRetransmit, -- in
                 EmacClientTxCE         => EmacClientTxCE          --in

                );

ClientEmacTxdVld <= ClientEmacTxdVld_i;

end beh;
