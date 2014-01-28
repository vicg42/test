------------------------------------------------------------------------------
-- $Id: tx_cl_if.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- tx_cl_if.vhd
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
-- Filename:        tx_cl_if.vhd
-- Version:         v3.00a
-- Description:     register block for ipic_to_temac
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
--                  -- tx_temac_if.vhd
--                     -- tx_temac_if_sm.vhd
--                     -- tx_csum_mux.vhd
--                     -- tx_data_mux.vhd
--                     -- tx_cl_if.vhd       ******
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:      DCW
-- History:
--  DCW      2004.05.07      -- First version
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
-- MW    7/11/2008 
--       -- Initial Version with clock enables to reduce clock 
--          resources (v2_01_a)
--          -- Redesigned state machine to reduce states
--
--
-- MW    08/28/2008
--       -- Updated the DISCLAIMER OF LIABILITY notice
--
-- MW    09/23/2008
--       -- Added reset circuit to allow for the removal of asynchronous resets
--          -  Reset processes - DETECT_RESET and SET_RESET
--       -- Replaced all asynchronous resets with synchronous resets
--
-- MW    12/03/2008
--       -- Modified EMAC_UNDERRUN_PROCESS and EMAC_PAUSE_REQUEST_PROCESS to 
--          take into account the CE when the operating mode is 10/100
--
-- MW    02/02/2009
--       -- Timing on Rd_en going to proc_common_v3_00_a.async_fifo_fg was 
--          failing timing on a S3ADSP1800 design.  Modifed code to allow 
--          the Rd_En to be registered
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

library proc_common_v3_00_a;
use proc_common_v3_00_a.coregen_comp_defs.all;

-- synopsys translate_off
library XilinxCoreLib;
-- synopsys translate_on

------------------------------------------------------------------------------
-- Port Declaration
------------------------------------------------------------------------------

entity tx_cl_if is
    generic (
             C_FAMILY        : string               := "virtex5";
             C_RESET_ACTIVE  : std_logic            := '1';
             C_CLIENT_DWIDTH : integer              :=  8 ;
             C_TEMAC_TYPE    : integer range 0 to 3 :=  0
            );

    port    (
             LLTemac_Clk            : in  std_logic;
             LLTemac_Rst            : in  std_logic;

             Cl_Fifo_WrEn           : in  std_logic;
             TxD2Cl_fifo            : in  std_logic_vector(0 to 17);
             Cl_Fifo_Empty          : out std_logic;
             Cl_Fifo_full           : out std_logic;

             Tx2ClientUnderRun      : in  std_logic;
             Tx2ClientPauseReq      : in  std_logic;
             ClientEmacPauseReq     : out std_logic;
             Client2TxCollision     : out std_logic;
             Client2TxRetransmit    : out std_logic;

             Tx_Cl_Clk              : in  std_logic;
             ClientEmacTxd          : out std_logic_vector(7 downto 0);
             ClientEmacTxdVld       : out std_logic;
             ClientEmacTxdVldMsw    : out std_logic;
             ClientEmacTxFirstByte  : out std_logic;
             ClientEmacTxUnderRun   : out std_logic;
             EmacClientTxAck        : in  std_logic;
             EmacClientTxCollision  : in  std_logic;
             EmacClientTxRetransmit : in  std_logic;
             EmacClientTxCE         : in  std_logic

            );
end tx_cl_if;

architecture simulation of tx_cl_if is

   --------------------------------------------------------------------------
   -- Type Declarations
   --------------------------------------------------------------------------

   type TXCLSM_TYPE is (
                        IDLE,
                        RD_WAIT,
                        HBYTE,
                        LBYTE
                       );
   signal cl_cs, cl_ns              : TXCLSM_TYPE;

   --------------------------------------------------------------------------
   -- Signal Declarations
   --------------------------------------------------------------------------
   signal start_cl_sm               : std_logic;
   signal cl_sm_encoding            : std_logic_vector(0 to 2);
   signal cl_fifo_rd                : std_logic;

   signal high_byte                 : std_logic_vector(7 downto 0);
   signal low_byte                  : std_logic_vector(7 downto 0);
   signal high_byte_vld             : std_logic;
   signal low_byte_vld              : std_logic;
   signal tx_in_progress            : std_logic;

   signal mux_sel                   : std_logic;
   signal set_mux_sel               : std_logic;
   signal clr_mux_sel               : std_logic;

   signal emacClientTxAck_cmplt     : std_logic;
   signal set_emacClientTxAck_cmplt : std_logic;
   signal clr_emacClientTxAck_cmplt : std_logic;

   signal TxFirstByte               : std_logic;

   signal wr_cnt                    : std_logic_vector(3 downto 0);

   signal fifo_empty                : std_logic;
   signal fifo_empty_reg            : std_logic;
   signal fifo_full                 : std_logic;

   signal clientEmacPauseReq_i      : std_logic;
   signal tx2ClientPauseReq_d       : std_logic;

   signal client2TxColl_i           : std_logic;
   signal emacClientTxColl_d        : std_logic;

   signal client2TxRetran_i         : std_logic;
   signal emacClientTxRetran_d      : std_logic;

   signal clientEmacTxUnd_i         : std_logic;
   signal tx2ClientUnd_d            : std_logic;
   
   signal llTemacRstDetected        : std_logic;
   signal rstTxDomain               : std_logic;
   
   signal cl_fifo_rd_reg1           : std_logic;
   signal cl_fifo_rd_dly            : std_logic;
   signal emacClientTxCE_reg        : std_logic;
   
   begin

      --------------------------------------------------------------------------
      -- Concurrent signal assignments
      --------------------------------------------------------------------------
      ClientEmacPauseReq    <= clientEmacPauseReq_i;
      Client2TxCollision    <= client2TxColl_i;
      Client2TxRetransmit   <= client2TxRetran_i;
      ClientEmacTxUnderRun  <= clientEmacTxUnd_i;
      ClientEmacTxdVldMsw   <= '0';  -- not used for 8 bit Client

      Cl_Fifo_Empty         <= fifo_empty_reg;
      Cl_Fifo_full          <= (wr_cnt(3) and wr_cnt(2)) or (wr_cnt(3) and wr_cnt(1) and wr_cnt(0));

     --------------------------------------------------------------------------
     -- Component Instantiations
     --------------------------------------------------------------------------


      I_TX_CLIENT_FIFO : entity proc_common_v3_00_a.async_fifo_fg
         generic map
            (
               C_FAMILY           => C_FAMILY,
               C_DATA_WIDTH       => 18,
               C_ENABLE_RLOCS     => 0,
               C_FIFO_DEPTH       => 15,
               C_HAS_ALMOST_EMPTY => 0,
               C_HAS_ALMOST_FULL  => 0,
               C_HAS_RD_ACK       => 0,
               C_HAS_RD_COUNT     => 0,
               C_HAS_RD_ERR       => 0,
               C_HAS_WR_ACK       => 0,
               C_HAS_WR_COUNT     => 1,
               C_HAS_WR_ERR       => 0,
               C_RD_ACK_LOW       => 0,
               C_RD_COUNT_WIDTH   => 2,
               C_RD_ERR_LOW       => 0,
               C_USE_BLOCKMEM     => 1,
               C_WR_ACK_LOW       => 0,
               C_WR_COUNT_WIDTH   => 4,
               C_WR_ERR_LOW       => 0
            )

         port map
            (
               Din                => TxD2Cl_fifo,   -- in
               Wr_en              => Cl_Fifo_WrEn,  -- in
               Wr_clk             => LLTemac_Clk,   -- in
               Rd_en              => cl_fifo_rd_dly,    -- in
               Rd_clk             => Tx_Cl_Clk,     -- in
               Ainit              => LLTemac_Rst,   -- in
               Dout(7  downto 0)  => low_byte,      -- out
               Dout(15 downto 8)  => high_byte,     -- out
               Dout(16)           => low_byte_vld,  -- out
               Dout(17)           => high_byte_vld, -- out
               Full               => fifo_full,     -- out
               Empty              => fifo_empty,    -- out
               Almost_full        => open,          -- out
               Almost_empty       => open,          -- out
               Wr_count           => wr_cnt,        -- out
               Rd_count           => open,          -- out
               Rd_ack             => open,          -- out
               Rd_err             => open,          -- out
               Wr_ack             => open,          -- out
               Wr_err             => open           -- out
            );
      ----------------------------------------------------------------------------
      -- Start the client state machine when either of the the async fifo write
      -- count Bits are set (wr_cnt >=4)

      -- Original design might have been for weird fifo behavior
      -- On a reset the Full flag is asserted until the FIFO is ready to accept
      -- data.  For async FIFO this is on the first write clock after reset.
      -- For FIFO Generated FIFO this is on the 4th clk after reset.
      ----------------------------------------------------------------------------
      START_SM : process(Tx_Cl_Clk)
      begin

         if rising_edge(Tx_Cl_Clk) then
            if rstTxDomain = '1' then
               start_cl_sm <= '0';
            else
               start_cl_sm <= not fifo_empty;
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      --  Delay FIFO Empty for other modules
      ----------------------------------------------------------------------------
      REG_FIFO_EMPTY : process(Tx_Cl_Clk)
      begin

         if rising_edge(Tx_Cl_Clk) then
            if rstTxDomain = '1' then
               fifo_empty_reg <= '0';
            else
               fifo_empty_reg <= fifo_empty;
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      --  Delay read signal
      --  This process detects if emacClientTxCE toggls and applies the correct 
      --  delay based upon it
      ----------------------------------------------------------------------------
      REG_RD_EN : process(Tx_Cl_Clk)
      begin

         if rising_edge(Tx_Cl_Clk) then
            if rstTxDomain = '1' then
               cl_fifo_rd_reg1 <= '0';
               cl_fifo_rd_dly  <= '0';
               emacClientTxCE_reg <= '0';
            else
               --Always pipeline the read 
               cl_fifo_rd_reg1 <= cl_fifo_rd;
               emacClientTxCE_reg <= emacClientTxCE;
               
               if EmacClientTxCE = '0' and cl_fifo_rd_reg1 = '1' then 
                  --if 10/100 one extra delay is needed 
                  cl_fifo_rd_dly <= cl_fifo_rd_reg1;
               elsif EmacClientTxCE = '1' and emacClientTxCE_reg = '1' then
                  -- if 1000Mbs or V4 chip Enable is not used bypass one delay
                  cl_fifo_rd_dly <= cl_fifo_rd;
               else
                  cl_fifo_rd_dly <= '0';
               end if;   
            end if;
         end if;
      end process;      



     --------------------------------------------------------------------------
     -- Tx Client State Machine
     -- TXCLSM_REGS_PROCESS: registered process of the state machine
     -- TXCLSM_CMB_PROCESS:  combinatorial next-state logic
     --------------------------------------------------------------------------
     -----------------------------------------------------------------------------
     --  Wait until the FIFO receives data, then transition to the HBYTE state.
     --  IDLE:
     --     Wait for the FIFO Empty signal to deassert.  Issue read and go
     --     to RD_WAIT state
     --  RD_WAIT:
     --      Wait for EmacClientTxCE to assert then transition to HBYTE
     --      This wait is necessary for the pipelined Rd_En going to the Async 
     --      FIFO     
     --  HBYTE:
     --     If entering from IDLE State: wait for EMAC to Acknowledge
     --        At Acknowledge and EmacClientTxCE transition to LBYTE if 
     --        high_byte_vld.
     --        EmacClientTxAck will set emacClientTxAck_cmplt which will allow 
     --        subsequent transitions to LBYTE to occur.
     --     If entering from LBYTE state: It is guaranteed to at least have
     --        high_byte_vld set.  So check to see if low_byte_vld is set.
     --        If it is not set then return the high_byte and high_byte_vld then
     --        return to IDLE and wait for the next packet to come.  If it is
     --        set then transition to LBYTE then FIFO empty will cause transition
     --        to IDLE
     --     Perform a read when high_byte valid is set and the fifo is not empty
     --  LBYTE:
     --     Always entered from HBYTE state.  Transition back to HBYTE if
     --     low_byte_vld is set and the FIFO is not empty.  If the FIFO is empty,
     --     no transition to the HBYTE is needed so return to IDLE.  If the FIFO
     --     is empty, low_byte_vld can be HIGH or LOW it does not matter because
     --     it is combitorially muxed to EMAC to allow for a graceful completion.
     -----------------------------------------------------------------------------


      CL_SM_CMB: process ( cl_cs,
                           start_cl_sm,
                           EmacClientTxCE,
                           EmacClientTxAck,
                           emacClientTxAck_cmplt,
                           fifo_empty,
                           high_byte_vld,
                           low_byte_vld
                          )
      begin


         cl_fifo_rd                <= '0';
         cl_sm_encoding            <= "000";
         set_EmacClientTxAck_cmplt <= '0';
         clr_EmacClientTxAck_cmplt <= '0';
         set_mux_sel               <= '0';
         clr_mux_sel               <= '0';

         case cl_cs is
            when IDLE =>
               cl_sm_encoding            <= "000";
               
               if (start_cl_sm = '1' and EmacClientTxCE = '1') then
                  cl_fifo_rd <= '1';
                  cl_ns      <= RD_WAIT;
               else
                  cl_fifo_rd <= '0';
                  cl_ns      <= IDLE;
               end if;
               
            when RD_WAIT => 
               cl_sm_encoding            <= "001";        
               if (EmacClientTxCE = '1') then
                  cl_ns      <= HBYTE;
               else
                  cl_ns      <= RD_WAIT;
               end if;

            when HBYTE => --High Byte
               cl_sm_encoding            <= "010";
               if EmacClientTxCE = '1' and (EmacClientTxAck = '1' or emacClientTxAck_cmplt = '1') then            
                  if (low_byte_vld = '0' and fifo_empty = '1') or high_byte_vld = '0' then
                     cl_fifo_rd                <= '0';
                     set_EmacClientTxAck_cmplt <= '0';
                     set_mux_sel               <= '0';
                     clr_mux_sel               <= '1';
                     clr_EmacClientTxAck_cmplt <= '1';                  
                     cl_ns                     <= IDLE;
                  else
                     cl_fifo_rd                <= not fifo_empty; --when even bytes, do not perform another read 
                     set_EmacClientTxAck_cmplt <= '1';            --and go to LBYTE state
                     set_mux_sel               <= '1';
                     clr_mux_sel               <= '0';
                     clr_EmacClientTxAck_cmplt <= '0';                  
                     cl_ns                     <= LBYTE;
                  end if;   
               else
                  cl_fifo_rd                <= '0';
                  set_EmacClientTxAck_cmplt <= '0';
                  set_mux_sel               <= '0';
                  clr_mux_sel               <= '0';
                  clr_EmacClientTxAck_cmplt <= '0';
                  cl_ns                     <= HBYTE;
               end if;

            when LBYTE => --Low Byte
               cl_sm_encoding            <= "011";
               if (EmacClientTxCE = '1' and low_byte_vld = '1' and fifo_empty = '0') then
                  clr_mux_sel               <= '1';
                  clr_EmacClientTxAck_cmplt <= '0';
                  cl_ns                     <= HBYTE;
               elsif (EmacClientTxCE = '1' and fifo_empty = '1') then
                  cl_fifo_rd                <= '0';
                  clr_mux_sel               <= '1';
                  clr_EmacClientTxAck_cmplt <= '1';
                  cl_ns                     <= IDLE;
               else
                  cl_fifo_rd                <= '0';
                  clr_mux_sel               <= '0';
                  clr_EmacClientTxAck_cmplt <= '0';
                  cl_ns                     <= LBYTE;
               end if;

            when others   =>  -- default to IDLE
               cl_sm_encoding            <= "100";
               cl_ns                     <= IDLE;

         end case;
      end process;

      ----------------------------------------------------------------------------
      --  State machine sequencer
      ----------------------------------------------------------------------------
      CL_SM_SEQUENCER: process (Tx_Cl_Clk )
      begin

         if rising_edge(Tx_Cl_Clk) then
            if (rstTxDomain = '1') then
               cl_cs <= IDLE;
            else  
               cl_cs <= cl_ns;
            end if;
         end if;
      end process;

      ----------------------------------------------------------------------------
      -- Mux control for passing high or low byte of data and the high or low byte
      -- valid bit.  Set and clr signals come from the state machine and are
      -- asserted with EmacClientTxCE to allow sor proper switching synchronization
      ----------------------------------------------------------------------------
      MUX_CONTROL : process(Tx_Cl_Clk)
      begin

         if rising_edge(Tx_Cl_Clk) then
            if rstTxDomain = '1' or clr_mux_sel = '1' then
               mux_sel <= '0';
            elsif set_mux_sel = '1' then
               mux_sel <= '1';
            else
               mux_sel <= mux_sel;
            end if;
         end if;
      end process;

      ----------------------------------------------------------------------------
      -- Eight bit data mux that uses the registered mux_sel signal to provide the
      -- switching control.  Muxes the high 8-bits of data, or the low 8-bits of
      -- data from the FIFO.
      ----------------------------------------------------------------------------
      DATA_MUX : process(mux_sel,high_byte,low_byte)
      begin

         case mux_sel is
            when '1' =>
               ClientEmacTxd <= low_byte;
            when others =>
               ClientEmacTxd <= high_byte;
         end case;
      end process;


      ----------------------------------------------------------------------------
      -- Use theis signal to clear ClientEmacTxdVld in the following case(s):
      --    1. After the last cl_fifo_rd and both high_byte_vld and low_byte_vld
      --       are HIGH.  The state machine transitions correctly but when the
      --       FIFO is empty, the high_byte_vld bit will still be driven HIGH.
      --       So it needs to be cleared until the next transmission.
      ----------------------------------------------------------------------------
      TRANSMIT_IN_PROGRESS : process(Tx_Cl_Clk)
      begin

         if rising_edge(Tx_Cl_Clk) then
            if rstTxDomain = '1' then
               tx_in_progress <= '0';
            elsif clr_EmacClientTxAck_cmplt = '1' then
               tx_in_progress <= '0';
            elsif cl_fifo_rd_dly = '1' then
               tx_in_progress <= '1';
            else
               tx_in_progress <= tx_in_progress;
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- One bit data mux that uses the registered mux_sel signal to provide the
      -- switching control.  Muxes the high data valid bit, or the low data valid
      -- bit from the FIFO.
      ----------------------------------------------------------------------------
      DATA_VALID_MUX : process(mux_sel,high_byte_vld,low_byte_vld,tx_in_progress)
      begin

         case mux_sel is
            when '1' =>
               ClientEmacTxdVld <= low_byte_vld and tx_in_progress;
            when others =>
               ClientEmacTxdVld <= high_byte_vld and tx_in_progress;
         end case;
      end process;


      ----------------------------------------------------------------------------
      -- This signal is not routed to soft_temac_wrap.  It is not used!
      -- This signal is routed to v5_temac_wrap.
      --    Documentation says to tied it LOW, but it is ignored and tied high in
      --    the wrapper.
      -- This signal is routed to v4_temac_wrap and used.
      --    It must be actively driven from the state machine.
      ----------------------------------------------------------------------------
      ----------------------------------------------------------------------------
      -- This signal must be driven high the same time low_byte data is sent out
      -- This is actually the second byte, not the first
      ----------------------------------------------------------------------------

      ----------------------------------------------------------------------------
      -- Generate for SPARTAN or V5
      GEN_FIRST_BYTE_NOT_V4 : if C_FAMILY /= "virtex4" generate
      begin
         TxFirstByte <= '0';
         ClientEmacTxFirstByte <= '0';
      end generate;

      GEN_FIRST_BYTE_V4 : if C_FAMILY = "virtex4" generate
      begin

         ASSERT_FIRST_BYTE : process(Tx_Cl_Clk)
         begin

            if rising_edge(Tx_Cl_Clk) then
               if rstTxDomain = '1' then
                  TxFirstByte <= '0';
               elsif EmacClientTxCE = '1' then
                  if EmacClientTxAck = '1' then
                     TxFirstByte <= '1';
                  else
                     TxFirstByte <= '0';
                  end if;
               else
                  TxFirstByte <= TxFirstByte;
               end if;
            end if;
         end process;

         ClientEmacTxFirstByte <= TxFirstByte;
      end generate;
      
      
      ----------------------------------------------------------------------------
      -- This signal is set when the hard/soft core acknowledges that it is ready
      -- to accept data.  It must remain asserted high until the end of the packet
      -- is reached.  It is cleared when the state machine returns to the IDLE
      -- state.
      ----------------------------------------------------------------------------
      ASSERT_TX_ACKNOWLEDGED : process(Tx_Cl_Clk)
      begin

         if rising_edge(Tx_Cl_Clk) then
            if rstTxDomain = '1' then
               emacClientTxAck_cmplt <= '0';
            elsif EmacClientTxCE = '1' then
               if clr_EmacClientTxAck_cmplt = '1' then
                  emacClientTxAck_cmplt <= '0';
               elsif set_EmacClientTxAck_cmplt = '1' then
                  emacClientTxAck_cmplt <= '1';
               else
                  emacClientTxAck_cmplt <= emacClientTxAck_cmplt;
               end if;
            else
               emacClientTxAck_cmplt <= emacClientTxAck_cmplt;
            end if;
         end if;
      end process;



   -------------------------------------------------------------------------------
   -- Sample, hold, and clear signals for domain crossing
   -------------------------------------------------------------------------------
      --------------------------------------------------------------------------
      -- TX_PAUSE_REQUEST_PROCESS
      --------------------------------------------------------------------------
      TX_PAUSE_REQUEST_PROCESS : process (LLTemac_Clk)
      begin

          if rising_edge(LLTemac_Clk) then
              if (LLTemac_Rst = '1') then
                  tx2ClientPauseReq_d <= '0';
              else
                  tx2ClientPauseReq_d <= Tx2ClientPauseReq or   -- set   - indicator from TPP reg
                                    (tx2ClientPauseReq_d and    -- hold  - until captured by Tx_Cl_Clk
                                    not clientEmacPauseReq_i);  -- clear - captured by Tx_Cl_Clk
              end if;
          end if;
      end process;

      --------------------------------------------------------------------------
      -- EMAC_PAUSE_REQUEST_PROCESS
      --------------------------------------------------------------------------
      EMAC_PAUSE_REQUEST_PROCESS : process (Tx_Cl_Clk)
      begin

          if rising_edge(Tx_Cl_Clk) then
            if rstTxDomain = '1' then
               clientEmacPauseReq_i <= '0';
            else  
               if EmacClientTxCE = '1' then        
                  clientEmacPauseReq_i <= tx2ClientPauseReq_d;  -- set   - from LLTemac_Clk hold circuit above
               else
                  clientEmacPauseReq_i <= clientEmacPauseReq_i;
               end if;
            end if;
          end if;
      end process;


      --------------------------------------------------------------------------
      -- EMAC_COLL_PROCESS
      --------------------------------------------------------------------------
      EMAC_COLL_PROCESS : process (Tx_Cl_Clk)
      begin

         if rising_edge(Tx_Cl_Clk) then
            if rstTxDomain = '1' then
               emacClientTxColl_d <= '0';
            else
               emacClientTxColl_d <= EmacClientTxCollision or
                                      (emacClientTxColl_d and not client2TxColl_i);
            end if;
         end if; 
      end process;

      --------------------------------------------------------------------------
      -- TX_COLL_PROCESS
      --------------------------------------------------------------------------
      TX_COLL_PROCESS : process (LLTemac_Clk)
      begin

          if rising_edge(LLTemac_Clk) then
              if (LLTemac_Rst = '1') then
                  client2TxColl_i <= '0';
              else
                  client2TxColl_i <= emacClientTxColl_d;
              end if;
          end if;
      end process;

      --------------------------------------------------------------------------
      -- EMAC_RETRAN_PROCESS
      --------------------------------------------------------------------------
      EMAC_RETRAN_PROCESS : process (Tx_Cl_Clk)
      begin


         if rising_edge(Tx_Cl_Clk) then
            if (rstTxDomain = '1') then
               emacClientTxRetran_d <= '0';          
            else   
               emacClientTxRetran_d <= EmacClientTxRetransmit or
                                      (emacClientTxRetran_d and not client2TxRetran_i);
            end if;                                   
         end if;
      end process;

      --------------------------------------------------------------------------
      -- TX_RETRAN_PROCESS
      --------------------------------------------------------------------------
      TX_RETRAN_PROCESS : process (LLTemac_Clk)
      begin

          if rising_edge(LLTemac_Clk) then
              if (LLTemac_Rst = '1') then
                  client2TxRetran_i <= '0';
              else
                  client2TxRetran_i <= emacClientTxRetran_d;
              end if;
          end if;
      end process;

      --------------------------------------------------------------------------
      -- TX_UNDERRUN_PROCESS
      --------------------------------------------------------------------------
      TX_UNDERRUN_PROCESS : process (LLTemac_Clk)
      begin

          if rising_edge(LLTemac_Clk) then
              if (LLTemac_Rst = '1') then
                  tx2ClientUnd_d <= '0';
              else
                  tx2ClientUnd_d <= Tx2ClientUnderRun or
                                    (tx2ClientUnd_d and not clientEmacTxUnd_i);
              end if;
          end if;
      end process;

      --------------------------------------------------------------------------
      -- EMAC_UNDERRUN_PROCESS
      --------------------------------------------------------------------------
      EMAC_UNDERRUN_PROCESS : process (Tx_Cl_Clk)
      begin

         if rising_edge(Tx_Cl_Clk) then
            if (rstTxDomain = '1') then
               clientEmacTxUnd_i <= '0';         
            else
               if EmacClientTxCE = '1' then        
                  clientEmacTxUnd_i <= tx2ClientUnd_d;
               else
                  clientEmacTxUnd_i <= clientEmacTxUnd_i;
               end if;               
            end if;
         end if;
      end process;
      
      
      -------------------------------------------------------------------------
      -- Detect the Local Link Reset and hold it for the other clock domain to 
      -- detect it.  After the tx_cl_clk domain detects the reset, clear the 
      -- detect signal
      -------------------------------------------------------------------------
      DETECT_RESET : process(LLTemac_Clk)
      begin
      
         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' then
               llTemacRstDetected <= '1';
            elsif rstTxDomain = '1' then
               llTemacRstDetected <= '0';  
            else
               llTemacRstDetected <= llTemacRstDetected;
            end if;
         end if;
      end process;
      
            
      -------------------------------------------------------------------------
      -- The reset has been detected, so pulse the reset for one clock in the 
      -- tx_cl_clk domain.  Use rstTxDomain to synchronously reset all logic in
      -- the in the tx_cl_clk domain.
      -------------------------------------------------------------------------
      SET_RESET : process(tx_cl_clk)
      begin
      
         if rising_edge(tx_cl_clk) then
            if llTemacRstDetected = '1' then
               rstTxDomain <= '1';
            else
               rstTxDomain <= '0';
            end if;
         end if;
      end process;  

end simulation;
