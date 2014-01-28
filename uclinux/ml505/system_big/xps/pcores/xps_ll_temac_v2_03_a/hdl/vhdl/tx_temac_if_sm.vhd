------------------------------------------------------------------------------
-- $Id: tx_temac_if_sm.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- tx_sm.vhd
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
-- Filename:        tx_temac_if_sm.vhd
-- Version:         v1.00a
-- Description:     tx state machine for xps_ll_temac
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
--  DCW      2006.04.27      -- First version
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
-- MW       08/28/2008
-- ^^^^^^
-- Updated the DISCLAIMER OF LIABILITY notice
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

library unisim;
use unisim.vcomponents.all;

------------------------------------------------------------------------------
-- Port Declaration
------------------------------------------------------------------------------

entity tx_temac_if_sm is
   generic(
      C_RESET_ACTIVE  : std_logic := '1';
      C_CLIENT_DWIDTH : integer   :=  8
      );
   port(
      LLTemac_Clk         : in  std_logic;
      LLTemac_Rst         : in  std_logic;

      TXFIFO2IP_Und       : in  std_logic;
      TXFIFO2IP_Ovr       : in  std_logic;
      TXFIFO2IP_Empty     : in  std_logic;
      IP2TXFIFO_RdReq     : out std_logic;

      CSFIFO2IP_Ovr       : in  std_logic;
      CSFIFO2IP_Und       : in  std_logic;
      CSFIFO2IP_Empty     : in  std_logic;
      IP2CSFIFO_RdReq     : out std_logic;

      Eop                 : in  std_logic;

      TxData_Mux_Sel      : out std_logic_vector(0 to 1);

      TXFIFO_Und_Intr     : out std_logic;

      Cl_Fifo_Empty       : in  std_logic;
      Cl_Fifo_full        : in  std_logic;
      Cl_Fifo_WrEn        : out std_logic;

      Tx_cmplt            : out std_logic;
      Bytes_Valid         : in  std_logic_vector(0 to 1);
      TX_RDY              : in std_logic
      );
end tx_temac_if_sm;

------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
--
------------------------------------------------------------------------------

architecture beh of tx_temac_if_sm is

------------------------------------------------------------------------------
-- Type Declarations
------------------------------------------------------------------------------

type TX_SM_TYPE is (
                    IDLE,
                    RD_CSFIFO,
                    RD_TXFIFO,
                    WR_CLFIFO_00,
                    RD_TXFIFO_WR_CLFIFO_01,
                    TX_DONE
                   );

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

signal tx_sm_ps          : TX_SM_TYPE;
signal tx_sm_ns          : TX_SM_TYPE;
signal reTrnsMit         : std_logic;
signal iP2TXFIFO_RdReq_i : std_logic;
signal iP2CSFIFO_RdReq_i : std_logic;
signal eop_i             : std_logic;
signal sm_encoded        : std_logic_vector(0 to 2);
signal txData_Mux_Sel_i  : std_logic_vector(0 to 1);
signal cl_Fifo_WrEn_i    : std_logic;
signal tx_cmplt_i        : std_logic;
signal tXFIFO_Und_Intr_i : std_logic;

begin

------------------------------------------------------------------------------
-- Concurrent Assignments
------------------------------------------------------------------------------

  TXFIFO_Und_Intr     <= tXFIFO_Und_Intr_i;
  tXFIFO_Und_Intr_i     <= (TXFIFO2IP_Empty and iP2TXFIFO_RdReq_i) or
                           (TXFIFO2IP_Empty and not CSFIFO2IP_Empty);
  IP2TXFIFO_RdReq     <= iP2TXFIFO_RdReq_i;
  IP2CSFIFO_RdReq     <= iP2CSFIFO_RdReq_i;
  TxData_Mux_Sel      <= txData_Mux_Sel_i;
  Cl_Fifo_WrEn        <= cl_Fifo_WrEn_i;
  Tx_cmplt            <= tx_cmplt_i;

------------------------------------------------------------------------------
-- This process delays eop one clock
------------------------------------------------------------------------------
EOP_REG : process(LLTemac_Clk)
   begin
      if(rising_edge(LLTemac_Clk)) then
         if(LLTemac_Rst='1') then
            eop_i <= '0';
         else
            eop_i <= Eop;
         end if;
      end if;
   end process;



------------------------------------------------------------------------------
-- TX State Machine
-- TX_SM_SYNC_PROCESS: synchronous process of the state machine
-- TX_SM_CMB_PROCESS:  combinatorial next-state logic
------------------------------------------------------------------------------
-- This state machine determines the current state of the Transmitter
------------------------------------------------------------------------------

TX_SM_SYNC_PROCESS : process ( LLTemac_Clk )
begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
        if (LLTemac_Rst = C_RESET_ACTIVE) then
            tx_sm_ps <= IDLE;
        else
            tx_sm_ps <= tx_sm_ns;
        end if;
    end if;
end process;

TX_SM_CMB_PROCESS : process (
                             tx_sm_ps,
                             TXFIFO2IP_Empty,
                             CSFIFO2IP_Empty,
                             CSFIFO2IP_Ovr,
                             CSFIFO2IP_Und,
                             Cl_Fifo_Empty,
                             Cl_Fifo_full,
                             Eop,
                             eop_i,
                             Bytes_Valid,
                             TXFIFO2IP_Ovr,
                             TXFIFO2IP_Und,
                             tx_rdy
                            )

begin

    iP2CSFIFO_RdReq_i      <= '0';
    iP2TXFIFO_RdReq_i      <= '0';
    txData_Mux_Sel_i         <= (others => '0');
    cl_Fifo_WrEn_i           <= '0';
    tx_cmplt_i               <= '0';


    case tx_sm_ps is

        when IDLE =>
            sm_encoded <= "000";
            if (CSFIFO2IP_Ovr='1') or
               (CSFIFO2IP_Und='1') or
               (TXFIFO2IP_Ovr='1') or
               (TXFIFO2IP_Und='1') then
                tx_sm_ns <= IDLE;
            elsif (Cl_Fifo_Empty = '1' and
                   CSFIFO2IP_Empty = '0' and
                   TXFIFO2IP_Empty = '0' and TX_RDY='1') then
                tx_sm_ns <= RD_CSFIFO;
            else
                tx_sm_ns <= IDLE;
            end if;

        when RD_CSFIFO =>
            sm_encoded <= "001";
            if(CSFIFO2IP_Empty='0') then
               tx_sm_ns <= RD_TXFIFO;
               iP2CSFIFO_RdReq_i <= '1';
            else
               tx_sm_ns <= RD_CSFIFO;
            end if;


        when RD_TXFIFO =>
            sm_encoded <= "010";
            if (Cl_Fifo_full = '1') then
                iP2TXFIFO_RdReq_i <= '0';
                tx_sm_ns <= RD_TXFIFO;
            else
                iP2TXFIFO_RdReq_i <= '1';
                tx_sm_ns <= WR_CLFIFO_00;

            end if;


        when WR_CLFIFO_00 =>
            sm_encoded <= "011";
            if (Cl_Fifo_full = '1') then
                txData_Mux_Sel_i <= "00";
                iP2TXFIFO_RdReq_i <= '0';
                cl_Fifo_WrEn_i <= '0';
                tx_sm_ns <= WR_CLFIFO_00;--RD_TXFIFO_WR_CLFIFO_01;
            elsif(Eop='1') then
                txData_Mux_Sel_i <= "00";
                iP2TXFIFO_RdReq_i <= '0';
                cl_Fifo_WrEn_i <= Bytes_Valid(0);--'1';
                tx_sm_ns <= RD_TXFIFO_WR_CLFIFO_01;--TX_DONE;
            else
               txData_Mux_Sel_i <= "00";
               cl_Fifo_WrEn_i   <= Bytes_Valid(0);--'1';
               tx_sm_ns <= RD_TXFIFO_WR_CLFIFO_01;
            end if;

        when RD_TXFIFO_WR_CLFIFO_01 =>
            sm_encoded <= "100";
            if (Eop_i='1') then
                txData_Mux_Sel_i <= "01";
                iP2TXFIFO_RdReq_i <= '0';
                cl_Fifo_WrEn_i <= Bytes_Valid(0);--'1';
                tx_sm_ns <= TX_DONE;
            elsif (Cl_Fifo_full = '1') then
                txData_Mux_Sel_i <= "01";
                iP2TXFIFO_RdReq_i <= '0';
                cl_Fifo_WrEn_i <= '0';
                tx_sm_ns <= RD_TXFIFO_WR_CLFIFO_01;
            else
                txData_Mux_Sel_i <= "01";
                iP2TXFIFO_RdReq_i <= '1';
                cl_Fifo_WrEn_i <= Bytes_Valid(0);--'1';
                tx_sm_ns <= WR_CLFIFO_00;
            end if;


        when TX_DONE =>
            sm_encoded <= "101";
         tx_cmplt_i <= '1';
         tx_sm_ns <= IDLE;


        when others   =>  -- default to IDLE
          sm_encoded <= "000";
          tx_sm_ns <= IDLE;

    end case;
end process;

end beh;
