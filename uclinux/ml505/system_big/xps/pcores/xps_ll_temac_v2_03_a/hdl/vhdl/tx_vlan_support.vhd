------------------------------------------------------------------------------
-- $Id: tx_vlan_support.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- tx_vlan_support.vhd
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
-- Filename:        tx_vlan_support.vhd
-- Version:         v2.00a
-- Description:     Removes one VLAN tag from frame before it is preocesssed
--                  by the hard/soft TEMAC core
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--              --  xps_ll_temac.vhd
--                  --  soft_temac_wrap.vhd
--                  --  v4_temac_wrap.vhd
--                  --  v5_temac_wrap.vhd
--                  --  tx_llink_top.vhd
--                      --  tx_temac_if.vhd
--                          --  tx_temac_if_sm.vhd
--                          --  tx_csum_mux.vhd
--                          --  tx_data_mux.vhd
--                          --  tx_vcl_if.vhd
--                  --  tx_ll_if.vhd
--                      --  tx_csum_top_wrapper
--                          --  tx_csum_top.vhd
--                      --  tx_vlan_support.vhd           ******
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:      MW
-- History:
--
-- ^^^^^^
--  MW   08/06/2008
--       -- Initial Version
-- ~~~~~~
--
-- ^^^^^^
-- MW    10/16/2008
--       -- Change to address IR 492988 and IR 492874
--          Changed SET_TAG_HIT process in GEN_TAG_HIT_WITH_STRIP and
--          GEN_TAG_HIT_NO_STRIP generates when Tag mode=10 
--          (tagMode_dly1="10") so newTagTotalHit is set when checkTag1Tpid 
--          gets set and cleared with clrAllHits.  This fixes the issue of
--          the first frame being tagged, when it should not, after the 
--          tag mode is changed from "01" to "10" on the fly.
-- ~~~~~~
--
-- ^^^^^^
-- MW    10/23/2008
--       -- Change to address IR 492693 
--          The state of the Local link signals are inconsistant during and after  
--          LLTemac_Rst.  However, when LLTemac_SRC_RDY_n is low, the signals are 
--          driven HIGH (the expected state).  The hang was cause because after 
--          reset LLTemac_EOP_n_inc was LOW and this set LLTemac_EOF_n_filter HIGH.
--          As a result force_dest_rdy_high_i was forced HIGH and never cleared.  
--          So no local link data could be received.  Made change to FILTER_EOF 
--          process to use the signals LLTemac_SRC_RDY_n_inc and 
--          LLTemac_DST_RDY_n_inc when setting LLTemac_EOF_n_filter HIGH.  
--          Verified fix on ML507-14.  
-- ~~~~~~
--
-- ^^^^^^
-- MW    10/24/2008
--       -- Change to address IR 493311 
--          LLTemac_REM_dly_vlan was not being driven properly to handle all of 
--          the VLAN cases for tagging, stripping, and/or translation.  The 
--          incomming remainder bits are only valid with SOF, SOP, EOP, and EOF.
--          Only the remainder bits when SOP and EOP are LOW are currently used, 
--          so these values are stored in a register and muxed into the pipeline.  
-- ~~~~~~
--
-- ^^^^^^
-- MW    10/27/2008
--       -- Change to address IR 493731
--          Packets with a payload size of 0xF were not properly handled by the 
--          state machine (ie total frame sizes less than 29 failed).  The state 
--          machine would stall because lltemac_src_rdy_n_inc and 
--          lltemac_dst_rdy_n_inc signals would not pulse until the next packet 
--          was received.  Created the process DETECT_PAYLOAD_SIZES_1_14 to set the 
--          signal payLoadSizes1_14 to allow the state machine to transition during 
--          this condition.  
--          Also made change to ensure the state machine does not stall after 
--          lltemac_eop_n_inc on short packets (PIPELINE_FLUSH process)
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

------------------------------------------------------------------------------
-- Port Declaration
------------------------------------------------------------------------------

entity tx_vlan_support is
   generic(
      C_FAMILY                   : string               := "virtex5";
      C_TEMAC_TXVLAN_TRAN        : integer range 0 to 1 :=  1;
      C_TEMAC_TXVLAN_TAG         : integer range 0 to 1 :=  1;
      C_TEMAC_TXVLAN_STRP        : integer range 0 to 1 :=  1
      );

    port(
      LLTemac_Clk                : in  std_logic;
      LLTemac_Rst                : in  std_logic;

      --Local Link input delayed once in xps_ll_top
      LLTemac_Data_inc           : in  std_logic_vector(0 to 31);
      LLTemac_SOF_n_inc          : in  std_logic;
      LLTemac_SOP_n_inc          : in  std_logic;
      LLTemac_EOF_n_inc          : in  std_logic;
      LLTemac_EOP_n_inc          : in  std_logic;
      LLTemac_SRC_RDY_n_inc      : in  std_logic;
      LLTemac_REM_inc            : in  std_logic_vector(0 to 3);
      LLTemac_DST_RDY_n_inc      : in  std_logic;

      -- The above *_inc signals delayed one clock
      LLTemac_Data_dly_vlan      : out std_logic_vector(0 to 31);
      LLTemac_SOF_dly_n_vlan     : out std_logic;
      LLTemac_SOP_dly_n_vlan     : out std_logic;
      LLTemac_EOF_dly_n_vlan     : out std_logic;                    
      LLTemac_EOP_dly_n_vlan     : out std_logic;                    
      LLTemac_SRC_RDY_dly_n_vlan : out std_logic;                    
      LLTemac_REM_dly_vlan       : out std_logic_vector(0 to 3);     
      LLTemac_DST_RDY_dly_n_vlan : out std_logic;                    
                                                                     
      force_dest_rdy_high        : out std_logic;

      ll_temac_hdr               : in  std_logic;
      txFIFO2LL_Full             : in  std_logic;
      txFIFO2IP_aFull            : in  std_logic;

      TtagRegData                : in  std_logic_vector(0 to 31);
      Tpid0RegData               : in  std_logic_vector(0 to 31);
      Tpid1RegData               : in  std_logic_vector(0 to 31);
      LlinkClkAddr               : out std_logic_vector(0 to 11);
      LlinkClkRdData             : in  std_logic_vector(18 to 31);
                                 --    Bit         Bit         Bit
                                 -- 18 - 29        30          31
                                 --    VID      Strip En    Tag En
      LlinkClkTxVlanBramEnA      : out std_logic;
      LlinkClkNewFncEnbl         : in  std_logic;
      LlinkClkTxVStrpMode        : in  std_logic_vector(0 to 1);
      LlinkClkTxVTagMode         : in  std_logic_vector(0 to 1);

      TxVlanFifoWrEn             : out std_logic
      );
end tx_vlan_support;

architecture implementation of tx_vlan_support is

   --------------------------------------------------------------------------
   -- Function Declarations
   --------------------------------------------------------------------------

   --------------------------------------------------------------------------
   -- Type Declarations
   --------------------------------------------------------------------------

   type TXVLAN_SM_TYPE is (
                              IDLE,
                              RCVD_SOP,
                              SET_BRAM_ENABLE,
                              TAG0_BRAM_ACCESS,
                              TAG1_BRAM_ACCESS,
                              WAIT_TPID_DECODE,
                              STRIP_TAG_TRANS_BRANCH,
                              MUX_NEW_TAG,
                              SET_MUX_TRANS,
                              MUX_TRANS,
                              WAIT_STATE,
                              SET_OUTPUT_MUX,
                              WAIT_EOP,
                              WAIT_EOF
                              );
   signal txVlanCs, txVlanNs  : TXVLAN_SM_TYPE;
   signal txVlanSmEncoding    : std_logic_vector(0 to 3);

   --------------------------------------------------------------------------
   -- Signal Declarations
   --------------------------------------------------------------------------
   -- Signals for crossing clock domain - PLB to LL TEMAC
   signal newFncEn_dly           : std_logic_vector(0 to 1);
 
   signal tagMode_dly0           : std_logic_vector( 0 to  1);
   signal tagMode_dly1           : std_logic_vector( 0 to  1);
   
   signal strpMode_dly0          : std_logic_vector( 0 to  1);   
   signal strpMode_dly1          : std_logic_vector( 0 to  1);   
     
   -- TPID Registers
   signal tpid0_dly0             : std_logic_vector( 0 to 15);
   signal tpid0_dly1             : std_logic_vector( 0 to 15);
   
   signal tpid1_dly0             : std_logic_vector( 0 to 15);
   signal tpid1_dly1             : std_logic_vector( 0 to 15);
   
   signal tpid2_dly0             : std_logic_vector( 0 to 15);
   signal tpid2_dly1             : std_logic_vector( 0 to 15);
   
   signal tpid3_dly0             : std_logic_vector( 0 to 15);   
   signal tpid3_dly1             : std_logic_vector( 0 to 15);  
  
   signal newTagData_dly0        : std_logic_vector( 0 to 31);
   signal newTagData_dly1        : std_logic_vector( 0 to 31);

   --Signals for State Machine
   signal setBramEn              : std_logic;
   signal clrBramEn              : std_logic;
   signal bramEn                 : std_logic;
   signal bramAddr               : std_logic_vector( 0 to 11);
   signal bramDin                : std_logic_vector(18 to 31);

   signal setCheckTag0Tpid       : std_logic;
   signal clrCheckTag0Tpid       : std_logic;
   signal checkTag0Tpid          : std_logic;

   signal setCheckTag1Tpid       : std_logic;
   signal clrCheckTag1Tpid       : std_logic;
   signal checkTag1Tpid          : std_logic;

   signal clrAllHits             : std_logic;

   signal setMuxNewTag           : std_logic;
   signal clrMuxNewTag           : std_logic;
   signal muxNewTag              : std_logic;

   signal setMuxTrans            : std_logic;
   signal clrMuxTrans            : std_logic;
   signal muxTrans               : std_logic;

   signal setMuxOutput           : std_logic;
   signal clrMuxOutput           : std_logic;

   signal setMuxSelDlyMod3       : std_logic;

   --  VLAN Control Signals
   signal transEn                : std_logic;
   signal tag0TpidHit            : std_logic;
   signal tag1TpidHit            : std_logic;
   signal bramDinTag0Reg         : std_logic;
   signal tag0TpidHitReg         : std_logic;
   signal tag0TotalHit           : std_logic;
   signal newTagTotalHit         : std_logic;
   signal transTotalHit          : std_logic;
   signal transReg               : std_logic_vector(0 to 11);

   -- Mux Control Signals
   signal outputMuxCase_cmb      : integer range 0 to 7 ;
   signal outputMuxCase          : integer range 0 to 7 ;

   -- Pipeline Stages Signals
   signal LLTemac_SOP_n_pipe     : std_logic_vector(1 to 8);
   signal LLTemac_EOP_n_pipe     : std_logic_vector(1 to 9);

   signal LLTemac_SRC_RDY_n_pipe : std_logic;
   signal LLTemac_DST_RDY_n_pipe : std_logic;

   signal LLTemac_Rem_sop        : std_logic_vector(0 to  3);
   signal LLTemac_Rem_eop        : std_logic_vector(0 to  3);
   
   -- Data Pipeline
   signal LLTemac_Data_pipe1     : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipe2     : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipe3     : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipe4     : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipe5     : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipe6     : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipe7     : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipe8     : std_logic_vector(0 to 31);
   
   -- Muxing Pipeline Signals   
   signal LLTemac_Data_pipeMods4  : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipeMods5  : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipeMods6  : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipeMods7  : std_logic_vector(0 to 31);
   signal LLTemac_Data_pipeMods8  : std_logic_vector(0 to 31);
   
   signal modDly3                : std_logic_vector(0 to 31);
   signal modDly4                : std_logic_vector(0 to 31);
   signal modDly5                : std_logic_vector(0 to 31);
   signal modDly6                : std_logic_vector(0 to 31);
   signal modDly7                : std_logic_vector(0 to 31);

   signal muxSelDlyMod3          : std_logic;
   signal holdModDly4MuxSel      : std_logic;

   signal finishPipeCe           : std_logic;
   signal srcRdyPipeCe           : std_logic;
   signal write_complete         : std_logic;
   signal force_dest_rdy_high_i  : std_logic;
   signal pipe_ce_DataVld        : std_logic_vector(1 to 8);

   signal maskHeader             : std_logic;

   signal LLTemac_EOF_n          : std_logic;
   signal LLTemac_EOP_n_clr      : std_logic;
   signal LLTemac_EOF_n_filter   : std_logic;
   
   signal payLoadSizes1_14       : std_logic;
   signal flushPipeline          : std_logic;

   begin

   --------------------------------------------------------------------------
   -- Concurrent signal assignments
   --------------------------------------------------------------------------
   bramDin                     <= LlinkClkRdData;

   LLTemac_SOF_dly_n_vlan      <= '1';--
   LLTemac_SOP_dly_n_vlan      <= LLTemac_SOP_n_pipe(8) ;
   LLTemac_EOF_dly_n_vlan      <= LLTemac_EOF_n;
   LLTemac_EOP_dly_n_vlan      <= LLTemac_EOP_n_clr;
   LLTemac_SRC_RDY_dly_n_vlan  <= LLTemac_SRC_RDY_n_pipe when 
                                    pipe_ce_DataVld(8) = '1' else '1';
   LLTemac_DST_RDY_dly_n_vlan  <= LLTemac_DST_RDY_n_pipe when 
                                    pipe_ce_DataVld(8) = '1' else '1';
   LLTemac_REM_dly_vlan        <= LLTemac_Rem_sop when LLTemac_SOP_n_pipe(8) = '0' else
                                  LLTemac_Rem_eop when LLTemac_EOP_n_clr = '0' else
                                  (others => '0');
  
   LLTemac_Data_dly_vlan       <= LLTemac_Data_pipeMods8;

   TxVlanFifoWrEn              <= pipe_ce_DataVld(8) and not LLTemac_SRC_RDY_n_pipe and 
                                  not LLTemac_DST_RDY_n_pipe and LLTemac_EOF_n;

   force_dest_rdy_high         <= force_dest_rdy_high_i;

   ----------------------------------------------------------------------------
   -- Start
   -- -- Double buffers for crossing clock boundaries
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Allow new function enable to be dynamically set if any of the VLAN
   -- functions are enabled
   ----------------------------------------------------------------------------
   GEN_NEW_FUNCTION_ENABLE : if (C_TEMAC_TXVLAN_STRP = 1 or
                                 C_TEMAC_TXVLAN_TAG = 1 or
                                 C_TEMAC_TXVLAN_TRAN = 1) generate
   begin


      ----------------------------------------------------------------------------
      --  Buffer 1 bit of VLAN Enable
      ----------------------------------------------------------------------------
      NEW_FUNCTION_PIPE_DELAYS : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst='1' then
               newFncEn_dly <= (others => '0');
            else
               newFncEn_dly(0) <= LlinkClkNewFncEnbl;
               newFncEn_dly(1) <= newFncEn_dly(0);
            end if;
         end if;
      end process;

   end generate;

   ----------------------------------------------------------------------------
   -- Force new function enable low if none of the VLAN functions are enabled
   ----------------------------------------------------------------------------
   GEN_NO_NEW_FUNCTION_ENABLE : if not(C_TEMAC_TXVLAN_STRP = 1 or
                                    C_TEMAC_TXVLAN_TAG = 1 or
                                    C_TEMAC_TXVLAN_TRAN = 1) generate
   begin

       newFncEn_dly(1) <= '0';

   end generate;


   ----------------------------------------------------------------------------
   -- Allow strip mode bits to be dynamically set if stripping is enabled
   ----------------------------------------------------------------------------
   GEN_STRIP_ENABLE : if C_TEMAC_TXVLAN_STRP = 1 generate
   begin

      ----------------------------------------------------------------------------
      --  Buffer 2 bits of VLAN Strip Mode Enable Bits
      ----------------------------------------------------------------------------
      STRIP_MODE_PIPE_DELAYS : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst='1' or newFncEn_dly(1) = '0' then
               strpMode_dly0  <= (others => '0');
               strpMode_dly1  <= (others => '0');
               
            else
               strpMode_dly0 <= LlinkClkTxVStrpMode;
               strpMode_dly1 <= strpMode_dly0;
            end if;
         end if;
      end process;

   end generate;


   ----------------------------------------------------------------------------
   -- Force strip mode bits low if stripping is not enabled
   ----------------------------------------------------------------------------
   GEN_NO_STRIP_ENABLE : if C_TEMAC_TXVLAN_STRP = 0 generate
   begin

      strpMode_dly1 <= (others => '0');

   end generate;


   ----------------------------------------------------------------------------
   -- Allow tag mode bits to be dynamically set if tagging is enabled
   ----------------------------------------------------------------------------
   GEN_TAG_ENABLE : if C_TEMAC_TXVLAN_TAG = 1 generate
   begin

      -------------------------------------------------------------------------
      --  Buffer 2 bits of VLAN TAG Mode Enable Bits
      -------------------------------------------------------------------------
      TAG_MODE_PIPE_DELAYS : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst='1' or newFncEn_dly(1) = '0' then
               tagMode_dly0    <= (others => '0');
               tagMode_dly1    <= (others => '0');
            else
               tagMode_dly0 <= LlinkClkTxVTagMode;
               tagMode_dly1 <= tagMode_dly0;
            end if;
         end if;
      end process;
   end generate;


   ----------------------------------------------------------------------------
   -- Force tag mode bits low if tagging is not enabled
   ----------------------------------------------------------------------------
   GEN_NO_TAG_ENABLE : if C_TEMAC_TXVLAN_TAG = 0 generate
   begin

      tagMode_dly1 <= (others => '0');

   end generate;

   ----------------------------------------------------------------------------
   --  Buffer 16 bits of VLAN TPID data
   ----------------------------------------------------------------------------
   TPID0_PIPE_DELAYS : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst='1' then
            tpid0_dly0 <= (others => '0');
            tpid0_dly1 <= (others => '0');
         else
            tpid0_dly0 <= Tpid0RegData(16 to 31);
            tpid0_dly1 <= tpid0_dly0;
         end if;
      end if;
   end process;

   ----------------------------------------------------------------------------
   --  Buffer 16 bits of VLAN TPID data
   ----------------------------------------------------------------------------
   TPID1_PIPE_DELAYS : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst='1' then
            tpid1_dly0 <= (others => '0');
            tpid1_dly1 <= (others => '0');
         else
            tpid1_dly0 <= Tpid0RegData( 0 to 15);
            tpid1_dly1 <= tpid1_dly0;
         end if;
      end if;
   end process;

   ----------------------------------------------------------------------------
   --  Buffer 16 bits of VLAN TPID data
   ----------------------------------------------------------------------------
   TPID2_PIPE_DELAYS : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst='1' then
            tpid2_dly0 <= (others => '0');
            tpid2_dly1 <= (others => '0');
         else
            tpid2_dly0 <= Tpid1RegData(16 to 31);
            tpid2_dly1 <= tpid2_dly0;
         end if;
      end if;
   end process;

   ----------------------------------------------------------------------------
   --  Buffer 16 bits of VLAN TPID data
   ----------------------------------------------------------------------------
   TPID3_PIPE_DELAYS : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst='1' then
            tpid3_dly0 <= (others => '0');
            tpid3_dly1 <= (others => '0');
         else
            tpid3_dly0 <= Tpid1RegData( 0 to 15);
            tpid3_dly1 <= tpid3_dly0;
         end if;
      end if;
   end process;



   ----------------------------------------------------------------------------
   -- Allow tag register to be dynamically set if tagging is enabled
   ----------------------------------------------------------------------------
   GEN_NEW_TAG_REGISTER : if C_TEMAC_TXVLAN_TAG = 1 generate
   begin

      -------------------------------------------------------------------------
      --  Buffer 32 bits of NEW VLAN TAG data
      -------------------------------------------------------------------------
      NEW_TAG_PIPE_DELAYS : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst='1' then
               newTagData_dly0 <= (others => '0');
               newTagData_dly1 <= (others => '0');
            else
               newTagData_dly0 <= TtagRegData;
               newTagData_dly1 <= newTagData_dly0;
            end if;
         end if;
      end process;

   end generate;


   ----------------------------------------------------------------------------
   -- Force tag register to ZEROES if tagging is NOT enabled
   ----------------------------------------------------------------------------
   GEN_NO_NEW_TAG_REGISTER : if C_TEMAC_TXVLAN_TAG = 0 generate
   begin

      newTagData_dly1 <= (others => '0');

   end generate;

   ----------------------------------------------------------------------------
   -- Set translation enable bit when translation is enabled
   ----------------------------------------------------------------------------
   GEN_TRANS_ENABLE : if C_TEMAC_TXVLAN_TRAN = 1 generate
   begin

      transEn <= newFncEn_dly(1);

   end generate;

   ----------------------------------------------------------------------------
   -- Clear translation enable bit when translation is NOT enabled
   ----------------------------------------------------------------------------
   GEN_NO_TRANS_ENABLE : if C_TEMAC_TXVLAN_TRAN = 0 generate
   begin

      transEn <= '0';

   end generate;

   ----------------------------------------------------------------------------
   -- END
   -- -  Double buffers for crossing clock boundaries
   ----------------------------------------------------------------------------
   --************************************************************************--

   --************************************************************************--
   ----------------------------------------------------------------------------
   -- START
   -- -  Strip, Tag, and Translation Hit Logic based upon parameter settings
   --    and register settings
   --
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   -- Set strip TPID hit if stripping is enabled
   ----------------------------------------------------------------------------
   GEN_TAG0_HIT : if C_TEMAC_TXVLAN_STRP = 1 generate
   begin

      -------------------------------------------------------------------------
      -- Stage 1
      -- Compare delayed TPID value from LLink against the 4 TPID values 
      -- stored in SW accessable registers -
      -------------------------------------------------------------------------
      CHECK_TAG0_TPID_HIT : process(checkTag0Tpid,LLTemac_Data_pipe1,
                                     tpid0_dly1,tpid1_dly1,tpid2_dly1,tpid3_dly1)
      begin

         if checkTag0Tpid = '1' then
            if LLTemac_Data_pipe1(0 to 15) = tpid0_dly1 or 
               LLTemac_Data_pipe1(0 to 15) = tpid1_dly1 or
               LLTemac_Data_pipe1(0 to 15) = tpid2_dly1 or 
               LLTemac_Data_pipe1(0 to 15) = tpid3_dly1 then
               tag0TpidHit <= '1';
            else
               tag0TpidHit <= '0';
            end if;
         else
            tag0TpidHit <= '0';
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- This process is needed to hold the BRAM Data and tag0 hit data until a
      -- decision can be made on which data to translate
      -- - data from this read or data from the next read
      ----------------------------------------------------------------------------
      REG_BRAM_DOUT_A_TAG_0 : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' or clrAllHits = '1' then
               bramDinTag0Reg <= '0';
            elsif checkTag0Tpid = '1' then
               bramDinTag0Reg <= bramDin(31);
            else
               bramDinTag0Reg <= bramDinTag0Reg;
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- If the TPID from tag0 is a hit then save this data in case a
      -- strip does not occure.  Then if a tag occurs, the data will be available
      ----------------------------------------------------------------------------
      REG_TAG0_TPID_HIT : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' or clrAllHits = '1' then
               tag0TpidHitReg   <= '0';
            elsif tag0TpidHit = '1' then
               tag0TpidHitReg   <= '1';
            elsif LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0' then
               tag0TpidHitReg   <= '0';
            else
               tag0TpidHitReg <= tag0TpidHitReg;
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- Stage 2
      -- If tag0TotalHit is set, then check the strip mode bits to determine
      -- how/if a total hit occurs.
      --    If strpMode_dly1 = 00 then no stripping occures
      --    If strpMode_dly1 = 01 then only strip if it is a VLAN tag
      --       ie if tag0TotalHit=1
      --    If strpMode_dly1 = 10 then do not strip anything
      --       this mode is reserved and has no function
      --    If strpMode_dly1 = 11 then strip select VLAN frames based upon:
      --       1. Must be a VLAN Hit (tag0TotalHit must be set) and
      --       2. bramDin Strip Enable bit must be set
      ----------------------------------------------------------------------------
      SET_TAG0_HIT : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' or clrAllHits = '1' then
               tag0TotalHit <= '0';
            else
               case strpMode_dly1 is
                  when "11"   =>
                  -- Strip one tag from select VLAN tagged frames
                     if tag0TpidHit = '1' then
                        tag0TotalHit <= bramDin(30);
                     else
                        tag0TotalHit <= tag0TotalHit;
                     end if;
                  when "01"   =>
                  -- Strip one tagg from all VLAN tagged frames
                     if tag0TpidHit = '1' then
                        tag0TotalHit <= '1';
                     else
                        tag0TotalHit <= tag0TotalHit;
                     end if;
                  when others =>
                  -- do not strip any tags
                     tag0TotalHit <= '0';
               end case;
            end if;
         end if;
      end process;

   end generate;


   ----------------------------------------------------------------------------
   -- Stage 1 and Stage 2
   -- Force strip hit low when stripping is not enabled
   ----------------------------------------------------------------------------
   GEN_NO_TAG0_HIT : if C_TEMAC_TXVLAN_STRP = 0 generate
   begin

      tag0TotalHit   <= '0';
      tag0TpidHit    <= '0';
      tag0TpidHitReg <= '0';
      bramDinTag0Reg <= '0';
   end generate;



   ----------------------------------------------------------------------------
   -- Stage 1
   -- Compare delayed TPID value from LLink against the 4 TPID values stored in
   -- SW accessable registers -
   -- -  Without stripping enabled checkTag0Tpid occurs on the 4th 32-bit LL
   --    Data word (the first word after the SRC Address)
   ----------------------------------------------------------------------------
   GEN_TRANS_TAG_HIT_NO_STRIP : if ((C_TEMAC_TXVLAN_TRAN = 1 or C_TEMAC_TXVLAN_TAG = 1) and 
                                     C_TEMAC_TXVLAN_STRP = 0) generate
   begin

      CHECK_TRANS_TAG_TPID_HIT : process(checkTag0Tpid,LLTemac_Data_pipe1,
                                     tpid0_dly1,tpid1_dly1,tpid2_dly1,tpid3_dly1)
      begin

         if checkTag0Tpid = '1' then 
         --need to check first incomming VLAN frame not second (checkTag1Tpid)
            if LLTemac_Data_pipe1(0 to 15) = tpid0_dly1 or 
               LLTemac_Data_pipe1(0 to 15) = tpid1_dly1 or
               LLTemac_Data_pipe1(0 to 15) = tpid2_dly1 or 
               LLTemac_Data_pipe1(0 to 15) = tpid3_dly1 then
               tag1TpidHit <= '1';
            else
               tag1TpidHit <= '0';
            end if;
         else
            tag1TpidHit <= '0';
         end if;
      end process;
   end generate;


   ----------------------------------------------------------------------------
   -- Stage 1
   -- Compare delayed TPID value from LLink against the 4 TPID values stored in
   -- SW accessable registers -
   -- -  With stripping enabled checkTag1Tpid occurs on the 5th 32-bit LL Data
   --    word (the second word after the SRC Address)
   ----------------------------------------------------------------------------
   GEN_TRANS_TAG_HIT_WITH_STRIP : if ((C_TEMAC_TXVLAN_TRAN = 1 or C_TEMAC_TXVLAN_TAG = 1) and 
                                       C_TEMAC_TXVLAN_STRP = 1) generate
   begin

      CHECK_TRANS_TAG_TPID_HIT : process(checkTag1Tpid,LLTemac_Data_pipe1,
                                     tpid0_dly1,tpid1_dly1,tpid2_dly1,tpid3_dly1)
      begin

         if checkTag1Tpid = '1' then 
         --need to check second incomming VLAN frame not first (checkTag0Tpid)
            if LLTemac_Data_pipe1(0 to 15) = tpid0_dly1 or 
               LLTemac_Data_pipe1(0 to 15) = tpid1_dly1 or
               LLTemac_Data_pipe1(0 to 15) = tpid2_dly1 or 
               LLTemac_Data_pipe1(0 to 15) = tpid3_dly1 then
               tag1TpidHit <= '1';
            else
               tag1TpidHit <= '0';
            end if;
         else
            tag1TpidHit <= '0';
         end if;
      end process;
   end generate;


   ----------------------------------------------------------------------------
   -- Stage 1
   -- Compare delayed TPID value from LLink against the 4 TPID values stored in
   -- SW accessable registers -
   ----------------------------------------------------------------------------
   GEN_NO_TRANS_TAG_HIT : if (C_TEMAC_TXVLAN_TRAN = 0 and C_TEMAC_TXVLAN_TAG = 0) generate
   begin

      tag1TpidHit <= '0';
   end generate;


   ----------------------------------------------------------------------------
   -- Stage 2
   -- Set tag total hit only if tagging is enabled and the mode allows it
   --    If  tagMode_dly1 = "00" then do NOT tag any frames
   --    If  tagMode_dly1 = "01" then tag all frames even if it was not a
   --       VLAN HIT (tag1TpidHit = '0')
   --    If  tagMode_dly1 = "10" then add one tag to all VLAN Frames
   --       (tag1TpidHit = '1')
   --    If  tagMode_dly1 = "11" then add one tag to select VLAN frames
   --       based upon the bramDin tag bit being set
   --
   --       HOWEVER, since stripping is enabled, must decide which TAG to
   --       evaluate for  setting newTagTotalHit
   --          If a strip is occuring, then use the inner TAG
   --          If a strip is not going to occur, use the outer TAG
   ----------------------------------------------------------------------------
   GEN_TAG_HIT_WITH_STRIP : if C_TEMAC_TXVLAN_TAG = 1 and C_TEMAC_TXVLAN_STRP = 1 generate
   begin

      SET_TAG_HIT : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' or clrAllHits = '1' then
               newTagTotalHit <= '0';
            else
               case tagMode_dly1 is
                  when "11"   =>
                  --  Only tag select VLAN tagged frames
                     -- Strip is going to occur, so newTagTotalHit is set
                     -- by tpid hit from 2nd tag (tag1TpidHit)
                     if tag0TotalHit = '1' then
                        if tag1TpidHit = '1' then
                           newTagTotalHit <= bramDin(31);
                        else
                           newTagTotalHit <= newTagTotalHit;
                        end if;
                     else
                     -- Otherwise a strip is not occuring, so newTagTotalHit is
                     -- set by the tpid from the previous tag (tag0TpidHitReg)
                        if tag0TpidHitReg = '1' then
                           newTagTotalHit <= bramDinTag0Reg;
                        else
                           newTagTotalHit <= newTagTotalHit;
                        end if;
                     end if;

                  when "10"   =>
                  --  Only tag VLAN tagged frames
                     -- Strip is going to occur, so newTagTotalHit is set
                     -- by tpid hit from 2nd tag (tag1TpidHit)
                     if tag0TotalHit = '1' then  --strip will occur
                        if tag1TpidHit = '1' then  --2nd Tag hit
                           newTagTotalHit <= '1';
                        else
                           newTagTotalHit <= newTagTotalHit;
                        end if;
                     else
                     -- Otherwise a strip is not occuring, so newTagTotalHit is
                     -- set by the tpid from the previous tag (tag0TpidHitReg)
                        if tag0TpidHitReg = '1' then
                           newTagTotalHit <= '1';
                        else
                           newTagTotalHit <= newTagTotalHit;
                        end if;
                     end if;
                  when "01"   =>
                  --  Tag ALL frames
                     if checkTag1Tpid = '1' then
                        newTagTotalHit <= '1';
                     else
                        newTagTotalHit <= newTagTotalHit;
                     end if;
                  when others =>
                  --  Do not tag any frames
                     newTagTotalHit <= '0';
               end case;
            end if;
         end if;
      end process;

   end generate;


   ----------------------------------------------------------------------------
   -- Stage 2
   -- Set tag total hit only if tagging is enabled and the mode allows it
   --    If  tagMode_dly1 = "00" then do NOT tag any frames
   --    If  tagMode_dly1 = "01" then tag all frames even if it was not a
   --       VLAN HIT (tag1TpidHit = '0')
   --    If  tagMode_dly1 = "10" then add one tag to all VLAN Frames
   --       (tag1TpidHit = '1')
   --    If  tagMode_dly1 = "11" then add one tag to select VLAN frames
   --       based upon the bramDin tag bit being set
   --
   --    Always use the outer TAG when stripping is disabled by the parameter
   ----------------------------------------------------------------------------
   GEN_TAG_HIT_NO_STRIP : if C_TEMAC_TXVLAN_TAG = 1 and C_TEMAC_TXVLAN_STRP = 0 generate
   begin

      SET_TAG_HIT : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' or clrAllHits = '1' then
               newTagTotalHit <= '0';
            else
               case tagMode_dly1 is
                  when "11"   =>
                  --  Only tag select VLAN tagged frames
                     if tag1TpidHit = '1' then
                        newTagTotalHit <= bramDin(31);
                     else
                        newTagTotalHit <= newTagTotalHit;
                     end if;
                  when "10"   =>
                  --  Only tag VLAN tagged frames
                     if tag1TpidHit = '1' then
                        newTagTotalHit <= '1';
                     else
                        newTagTotalHit <= newTagTotalHit;
                     end if;
                  when "01"   =>             
                  --  Tag ALL frames
                     if checkTag1Tpid = '1' then
                        newTagTotalHit <= '1';
                     else
                        newTagTotalHit <= newTagTotalHit;
                     end if;                                          
                  when others =>
                  --  Do not tag any frames
                     newTagTotalHit <= '0';
               end case;
            end if;
         end if;
      end process;

   end generate;


   ----------------------------------------------------------------------------
   -- Force tag total hit LOW if tagging is NOT enabled
   ----------------------------------------------------------------------------
   GEN_NO_TAG_HIT : if C_TEMAC_TXVLAN_TAG = 0 generate
   begin

      newTagTotalHit <= '0';

   end generate;


   ----------------------------------------------------------------------------
   -- Set translation total hit if translation is enabled
   -- A translation will occure only if transEn is set and a TPID hit occurs
   -- on the first vlan tag when a strip does not occur or the 2nd vlan tag
   -- when a strip does occur.
   ----------------------------------------------------------------------------
   GEN_TRANS_HIT_WITH_STRIP : if C_TEMAC_TXVLAN_TRAN = 1  and C_TEMAC_TXVLAN_STRP = 1 generate
   begin

      SET_TRANS_HIT : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' or clrAllHits = '1' or transEn = '0' then
               transTotalHit <= '0';
            else
               if tag0TotalHit = '1' then
                  -- Strip is going to occur, so transTotalHit is set
                  -- by tpid hit from 2nd tag (tag1TpidHit)
                  if tag1TpidHit = '1' then
                     transTotalHit <= '1';
                  else
                     transTotalHit <= transTotalHit;
                  end if;
               else
                  -- Otherwise a strip is not occuring, so transTotalHit is
                  -- set by the tpid from the previous tag (tag0TpidHitReg)
                  if tag0TpidHitReg = '1' then
                     transTotalHit <= '1';
                  else
                     transTotalHit <= transTotalHit;
                  end if;
               end if;
            end if;
         end if;
      end process;

   end generate;
   

   ----------------------------------------------------------------------------
   -- Set translation total hit if translation is enabled
   -- A translation will occure only if transEn is set and a TPID hit occurs
   -- on the first vlan tag since stripping is not enabled.
   ----------------------------------------------------------------------------
   GEN_TRANS_HIT_NO_STRIP : if C_TEMAC_TXVLAN_TRAN = 1  and C_TEMAC_TXVLAN_STRP = 0 generate
   begin

      SET_TRANS_HIT : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' or clrAllHits = '1' or transEn = '0' then
               transTotalHit <= '0';
            else
               if tag1TpidHit = '1' then
                  transTotalHit <= '1';
               else
                  transTotalHit <= transTotalHit;
               end if;
            end if;
         end if;
      end process;

   end generate;


   ----------------------------------------------------------------------------
   -- Force translate total hit LOW if translation is NOT enabled
   ----------------------------------------------------------------------------
   GEN_NO_TRANS_HIT : if C_TEMAC_TXVLAN_TRAN = 0 generate
   begin

      transTotalHit <= '0';

   end generate;

   ----------------------------------------------------------------------------
   -- Set translation register if translation and stripping parameters are set
   --    It will always load the translation value from the first Bram Read,
   --    then update it with the 2nd Bram read if needed
   --       In either case the loaded data may/may not be used depending upon
   --       if a translation hit occurs
   ----------------------------------------------------------------------------
   GEN_TRANS_REG_WITH_STRIP : if C_TEMAC_TXVLAN_TRAN = 1 and C_TEMAC_TXVLAN_STRP = 1 generate
   begin

      LOAD_TRANS_REG : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' or clrAllHits = '1' then
               transReg <= (others => '0');
            else
               if checkTag0Tpid = '1' then
               -- Load the first tag into the trans reg
               -- -  This needs to be loaded because the strip may/may not occur at this point
               --    so load it to be safe then check if strip occurs on the next clock
               --    (the condition below)
                  transReg <= bramDin(18 to 29);
               elsif tag0TotalHit = '1' and checkTag1Tpid = '1' then
               -- Load the second tag into the trans reg
               -- -  This needs loaded because the first tag is stripped so the
               --    next tag (this one) will be translated
                  transReg <= bramDin(18 to 29);
               else
                  transReg <= transReg;
               end if;
            end if;
         end if;
      end process;
   end generate;


   ----------------------------------------------------------------------------
   -- Set translation register if translation aparameter is set
   --    The loaded data may/may not be used depending upon
   --    if a translation hit occurs
   ----------------------------------------------------------------------------
   GEN_TRANS_REG_NO_STRIP : if C_TEMAC_TXVLAN_TRAN = 1 and C_TEMAC_TXVLAN_STRP = 0 generate
   begin

      LOAD_TRANS_REG : process(LLTemac_Clk)
      begin

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' or clrAllHits = '1' then
               transReg <= (others => '0');
            else
               if checkTag0Tpid = '1' then
               -- Load the first tag into the trans reg
               -- -  since stripping is not enabled, this is the only tag it can be
                  transReg <= bramDin(18 to 29);
               else
                  transReg <= transReg;
               end if;
            end if;
         end if;
      end process;
   end generate;

   ----------------------------------------------------------------------------
   -- Translation is disabled
   ----------------------------------------------------------------------------
   GEN_NO_TRANS_REG : if C_TEMAC_TXVLAN_TRAN = 0 generate
   begin

      transReg <= (others => '0');
   end generate;

   ----------------------------------------------------------------------------
   -- Translation and Tagging are disabled
   ----------------------------------------------------------------------------
   GEN_NO_TT_HIT : if C_TEMAC_TXVLAN_TAG = 0 and C_TEMAC_TXVLAN_TRAN = 0 generate
   begin

      newTagTotalHit   <= '0';
      transTotalHit <= '0';
      transReg     <= (others => '0');
   end generate;

   ----------------------------------------------------------------------------
   -- END
   -- -  Strip, Tag, and Translation Hit Logic based upon parameter settings
   --    and register settings
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Each bit of the below vector controls a mux select depending upon the
   -- current VLAN transaction.  EOP_n from the pipeline stage is shifted 
   -- appropriately and assigned to LLTemac_EOP_n_clr.  LLTemac_EOP_n_clr
   -- can be set independant of SRC/DST throttling since the data when EOP_N 
   -- is LOW is not written to the FIFO
   ----------------------------------------------------------------------------
   SET_MUX_SELECTS : process(tag0TotalHit,newTagTotalHit,transTotalHit,LLTemac_EOP_n_pipe)
   variable mux_inputs : std_logic_vector(0 to 2) := "000";
   begin

      mux_inputs := tag0TotalHit & newTagTotalHit & transTotalHit;
      case mux_inputs is
         when "001"  => outputMuxCase_cmb <= 1;
                        LLTemac_EOP_n_clr <= LLTemac_EOP_n_pipe(8);
                                             --No Change
         when "010"  => outputMuxCase_cmb <= 2;
                        LLTemac_EOP_n_clr <= LLTemac_EOP_n_pipe(9);
                                             --Add 1 to indice - adding tag
         when "011"  => outputMuxCase_cmb <= 3;
                        LLTemac_EOP_n_clr <= LLTemac_EOP_n_pipe(9);
                                             --Add 1 to indice - adding tag
         when "100"  => outputMuxCase_cmb <= 4;
                        LLTemac_EOP_n_clr <= LLTemac_EOP_n_pipe(7);
                                             --Sub 1 from indice - stripping
         when "101"  => outputMuxCase_cmb <= 5;
                        LLTemac_EOP_n_clr <= LLTemac_EOP_n_pipe(7);
                                             --Sub 1 from indice - stripping
         when "110"  => outputMuxCase_cmb <= 6;
                        LLTemac_EOP_n_clr <= LLTemac_EOP_n_pipe(8);
                                             --No Change - stripping and tagging
         when "111"  => outputMuxCase_cmb <= 7;
                        LLTemac_EOP_n_clr <= LLTemac_EOP_n_pipe(8);
                                             --No Change - stripping and tagging
         when others => outputMuxCase_cmb <= 0;
                        LLTemac_EOP_n_clr <= LLTemac_EOP_n_pipe(8);
                                             --No Change
      end case;
   end process;

   ----------------------------------------------------------------------------
   -- Sample and hold the outputMuxSel_cmb signals at setMuxOutput until EOF_N
   -- delay
   ----------------------------------------------------------------------------
   REGISTER_OUTPUT_MUX : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or clrMuxOutput = '1' then
            outputMuxCase <= 0;
         elsif setMuxOutput = '1' then
            outputMuxCase <= outputMuxCase_cmb;
         else
            outputMuxCase <= outputMuxCase;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- Pipeline SOP_n required amount of times to reset mux at end of packet
   -- Each bit of the vector is one clock delay
   ----------------------------------------------------------------------------
   DELAY_SOP_N : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         ----------------------------------------------------------------------
         -- Prime the pipeline
         ----------------------------------------------------------------------
         if LLTemac_Rst = '1' then
            LLTemac_SOP_n_pipe(1) <= '1';
         elsif srcRdyPipeCe = '1'  or finishPipeCe = '1' then
            LLTemac_SOP_n_pipe(1) <= LLTemac_SOP_n_inc;
         else
            LLTemac_SOP_n_pipe(1) <= LLTemac_SOP_n_pipe(1);
         end if;

         ----------------------------------------------------------------------
         -- Pipe it through
         ----------------------------------------------------------------------
         for i in 1 to 7 loop
            if LLTemac_Rst = '1' then
               LLTemac_SOP_n_pipe(i+1) <= '1';
            elsif srcRdyPipeCe = '1'  or finishPipeCe = '1' then
               LLTemac_SOP_n_pipe(i+1) <= LLTemac_SOP_n_pipe(i);
            else
               if LLTemac_SOP_n_pipe(8) = '0' then
                  LLTemac_SOP_n_pipe(i+1) <= '1';  --clear all after (8) is low for 1 clock
               else
                  LLTemac_SOP_n_pipe(i+1) <= LLTemac_SOP_n_pipe(i+1);
               end if;
            end if;
         end loop;
      end if;

   end process;


   ----------------------------------------------------------------------------
   -- Pipeline EOP_n required amount of times to reset mux at end of packet
   -- Each bit of the vector is one clock delay
   ----------------------------------------------------------------------------
   DELAY_EOP_N : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         ----------------------------------------------------------------------
         -- Prime the pipeline
         ----------------------------------------------------------------------
         if LLTemac_Rst = '1' or LLTemac_EOP_n_clr = '0' then
            LLTemac_EOP_n_pipe(1) <= '1';
         elsif srcRdyPipeCe = '1'  or finishPipeCe = '1' then
            LLTemac_EOP_n_pipe(1) <= LLTemac_EOP_n_inc;
         else
            LLTemac_EOP_n_pipe(1) <= LLTemac_EOP_n_pipe(1);
         end if;

         ----------------------------------------------------------------------
         -- Pipe it through
         ----------------------------------------------------------------------
         for i in 1 to 8 loop
            if LLTemac_Rst = '1' or LLTemac_EOP_n_clr = '0' then
               LLTemac_EOP_n_pipe(i+1) <= '1';
            elsif srcRdyPipeCe = '1'  or finishPipeCe = '1' then
               LLTemac_EOP_n_pipe(i+1) <= LLTemac_EOP_n_pipe(i);
            else
               LLTemac_EOP_n_pipe(i+1) <= LLTemac_EOP_n_pipe(i+1);
            end if;
         end loop;
      end if;

   end process;


   ----------------------------------------------------------------------------
   -- Pipeline Source Ready required amount of times for timing
   -- Each bit of the vector is one clock delay
   ----------------------------------------------------------------------------
   DELAY_SOURCE_READY_N : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         ----------------------------------------------------------------------
         -- Prime the pipeline
         ----------------------------------------------------------------------
         if LLTemac_Rst = '1' then
            LLTemac_SRC_RDY_n_pipe <= '1';
         elsif finishPipeCe = '1' or LLTemac_EOP_n_clr = '0' then
            LLTemac_SRC_RDY_n_pipe <= '0';
         elsif srcRdyPipeCe = '1' and pipe_ce_DataVld(7) = '1' then
            LLTemac_SRC_RDY_n_pipe <= LLTemac_SRC_RDY_n_inc;
         else
            LLTemac_SRC_RDY_n_pipe <= '1';
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- Pipeline Destination Ready required amount of times for timing
   -- Each bit of the vector is one clock delay
   ----------------------------------------------------------------------------
   DELAY_DESTINATION_READY_N : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         ----------------------------------------------------------------------
         -- Prime the pipeline
         ----------------------------------------------------------------------
         if LLTemac_Rst = '1' then
            LLTemac_DST_RDY_n_pipe <= '1';
         elsif finishPipeCe = '1' or LLTemac_EOP_n_clr = '0' then
            LLTemac_DST_RDY_n_pipe <= '0';
         elsif srcRdyPipeCe = '1' and pipe_ce_DataVld(7) = '1' then
            LLTemac_DST_RDY_n_pipe <= LLTemac_DST_RDY_n_inc;
         else
            LLTemac_DST_RDY_n_pipe <= '1';
         end if;
      end if;
   end process;

   
   ----------------------------------------------------------------------------
   -- The remainder data is only valid when LLTemac_SOF_n_inc or 
   -- LLTemac_SOP_n_inc or LLTemac_EOP_n_inc or LLTemac_EOF_n_inc is LOW.  So 
   -- capture the data for output later in the pipeline stage.
   -- The design currently does not use header word 0, which is valid when 
   -- LLTemac_SOF_n_inc goes LOW, or the footer word which is valid when 
   -- LLTemac_EOF_n_inc goes LOW.  Therefore only capture the 
   -- remainder bits for when LLTemac_SOP_n_inc and LLTemac_EOP_n_inc are LOW.   
   ----------------------------------------------------------------------------
   
   ----------------------------------------------------------------------------
   -- Capture the remainder bits for SOP
   ----------------------------------------------------------------------------
   GET_REMAINDER_DATA_SOP : process(LLTemac_Clk)
   begin
   
      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' then
            LLTemac_Rem_sop <= (others => '0');
         elsif LLTemac_DST_RDY_n_inc = '0' and LLTemac_SRC_RDY_n_inc = '0' and
               LLTemac_SOP_n_inc = '0' then
            LLTemac_Rem_sop <= LLTemac_Rem_inc;
         else
            LLTemac_Rem_sop <= LLTemac_Rem_sop;
         end if; 
      end if;
   end process;
 

   ----------------------------------------------------------------------------
   -- Capture the remainder bits for EOP
   ----------------------------------------------------------------------------
   GET_REMAINDER_DATA_EOP : process(LLTemac_Clk)
   begin
   
      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' then
            LLTemac_Rem_eop <= (others => '0');
         elsif LLTemac_DST_RDY_n_inc = '0' and LLTemac_SRC_RDY_n_inc = '0' and
               LLTemac_EOP_n_inc = '0' then
            LLTemac_Rem_eop <= LLTemac_Rem_inc;
         else
            LLTemac_Rem_eop <= LLTemac_Rem_eop;
         end if;
      end if;
   end process;
               
     
   ----------------------------------------------------------------------------
   -- Pipeline Local Link temac datal required amount of times for timing and
   -- muxing.
   ----------------------------------------------------------------------------   
   DELAY_DATA_PRIME : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         ----------------------------------------------------------------------
         -- Prime the pipeline
         ----------------------------------------------------------------------
         if LLTemac_Rst = '1' then
            LLTemac_Data_pipe1 <= (others => '0');
            LLTemac_Data_pipe2 <= (others => '0');
            LLTemac_Data_pipe3 <= (others => '0');
            LLTemac_Data_pipe4 <= (others => '0');
            LLTemac_Data_pipe5 <= (others => '0');
            LLTemac_Data_pipe6 <= (others => '0');
            LLTemac_Data_pipe7 <= (others => '0');
            LLTemac_Data_pipe8 <= (others => '0');
         elsif srcRdyPipeCe = '1' or finishPipeCe = '1' then
            LLTemac_Data_pipe1 <= LLTemac_Data_inc;
            LLTemac_Data_pipe2 <= LLTemac_Data_pipe1;
            LLTemac_Data_pipe3 <= LLTemac_Data_pipe2;
            LLTemac_Data_pipe4 <= LLTemac_Data_pipe3;
            LLTemac_Data_pipe5 <= LLTemac_Data_pipe4;
            LLTemac_Data_pipe6 <= LLTemac_Data_pipe5;
            LLTemac_Data_pipe7 <= LLTemac_Data_pipe6;
            LLTemac_Data_pipe8 <= LLTemac_Data_pipe7;                       
         else
            LLTemac_Data_pipe1 <= LLTemac_Data_pipe1;
            LLTemac_Data_pipe2 <= LLTemac_Data_pipe2;
            LLTemac_Data_pipe3 <= LLTemac_Data_pipe3;
            LLTemac_Data_pipe4 <= LLTemac_Data_pipe4;
            LLTemac_Data_pipe5 <= LLTemac_Data_pipe5;
            LLTemac_Data_pipe6 <= LLTemac_Data_pipe6;
            LLTemac_Data_pipe7 <= LLTemac_Data_pipe7;
            LLTemac_Data_pipe8 <= LLTemac_Data_pipe8;
         end if;
      end if;
   end process;


   -- Stage 1 Chip Enable From SOP to EOF
   srcRdyPipeCe <= ((ll_temac_hdr and not LLTemac_SOP_n_inc) or not maskHeader)
                     --Pulse high at sof_n_inc
                     and not LLTemac_SRC_RDY_n_inc and LLTemac_EOF_n_inc and not txFIFO2IP_aFull;
                     --Continue HIGH if SRC, EOF, and FIFO is not full

   -- Stage 2 Chip Enable From EOF to end of pipeline stages
   finishPipeCe <= not txFIFO2IP_aFull and not write_complete;


   ----------------------------------------------------------------------------
   -- This signal is used to determine when the pipeline data first becomes 
   -- valid based upon the chip enables 
   ----------------------------------------------------------------------------
   PIPELINE_FILTER_ENABLE : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         ----------------------------------------------------------------------
         -- Prime the pipeline
         ----------------------------------------------------------------------
         if LLTemac_Rst = '1' or LLTemac_EOF_n = '0' then
            pipe_ce_DataVld(1) <= '0';
         elsif srcRdyPipeCe = '1' or finishPipeCe = '1' then
            pipe_ce_DataVld(1) <= '1';
         else
         --Throttle pipe when SRC/DST throttling
            pipe_ce_DataVld(1) <= pipe_ce_DataVld(1);  
         end if;

         ----------------------------------------------------------------------
         -- Pipe it through
         ----------------------------------------------------------------------
         for i in 1 to 7 loop
         if LLTemac_Rst = '1' or LLTemac_EOF_n = '0' then
               pipe_ce_DataVld(i+1) <= '0';
            elsif (srcRdyPipeCe = '1' or finishPipeCe = '1') then
               pipe_ce_DataVld(i+1) <= pipe_ce_DataVld(i);
            else
               pipe_ce_DataVld(i+1) <= pipe_ce_DataVld(i+1);
            end if;
         end loop;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- After EOP goes low, EOF can be driven low on the next clock for one clock
   -- because this data is not written to the fifo
   -----------------------------------------------------------------------------
   SET_EOF_N : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' then
            LLTemac_EOF_n <= '1';
         elsif LLTemac_EOP_n_clr = '0' and
               LLTemac_SRC_RDY_n_pipe = '0' and LLTemac_DST_RDY_n_pipe = '0' then
            LLTemac_EOF_n <= '0';
         else
            LLTemac_EOF_n <= '1';
         end if;
      end if;
   end process;

   ----------------------------------------------------------------------------
   -- In the case where force_dest_rdy_high_i is set and LLTemac_EOF_n goes
   -- low before force_dest_rdy_high_i is reset
   -- This can occur because after LLTemac_EOF_n goes low, no other data
   -- is written to the FIFO, so LLTemac_EOF_n is driven LOW one clock after
   -- LLTemac_EOF_n.
   ----------------------------------------------------------------------------
   FILTER_EOF : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' then
            LLTemac_EOF_n_filter <= '0';
         elsif LLTemac_EOF_n = '0' then
            LLTemac_EOF_n_filter <= '0';
         elsif LLTemac_EOP_n_inc = '0' and 
            LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0' then
            LLTemac_EOF_n_filter <= '1';
         else
            LLTemac_EOF_n_filter <= LLTemac_EOF_n_filter;
         end if;
      end if;
   end process;


   ---------------------------------------------------------------------------
   -- This signal is used to clear out the pipeline after LLTemac_EOP_n_inc
   -- This CE must ignore the incomming LLTemac_SRC_RDY_n_inc signal
   ---------------------------------------------------------------------------
   CHIP_ENABLE_IGNORE_SRC : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or LLTemac_EOP_n_clr = '0' then
            -- The last write to fifo was made while LLTemac_EOP_n_clr=0 so
            -- the fifo flag does not need to be checked.
            -- Set to get ready for the write dependant upon LLTemac_SRC_RDY_n_inc
            write_complete <= '1';
         elsif LLTemac_EOP_n_inc = '0' and LLTemac_SRC_RDY_n_inc = '0' and
            (txFIFO2IP_aFull = '0') then
            -- The last write dependant upon LLTemac_SRC_RDY_n_inc occured, so
            -- clear to allow writes that will clear the pipeline
            write_complete <= '0';
         else
            write_complete <= write_complete;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- Throttle DST RDY until the pipeline data has been passed through
   ----------------------------------------------------------------------------
   FORCE_DESTINATION_HIGH : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or (LLTemac_EOF_n = '0' and LLTemac_SRC_RDY_n_pipe = '0') then
            force_dest_rdy_high_i <= '0';
         elsif (LLTemac_EOF_n_inc = '0' and txFIFO2IP_aFull = '0' and LLTemac_EOF_n_filter = '1') then
            force_dest_rdy_high_i <= '1';
         else
            force_dest_rdy_high_i <= force_dest_rdy_high_i;
         end if;

      end if;
   end process;
   
  
   ----------------------------------------------------------------------------
   -- Mask Local Link header information so it is not written to the FIFO
   ----------------------------------------------------------------------------
   PIPELINE_DATA_CE1 : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1'  or LLTemac_EOP_n_clr = '0' then
            maskHeader <= '1';
         elsif (LLTemac_SOP_n_inc = '0' and
               (txFIFO2IP_aFull = '0')) then
            maskHeader <= '0';
         else
            maskHeader <= maskHeader;
         end if;

      end if;
   end process;


   ----------------------------------------------------------------------------
   -- Set Mux select and hold until clear.  This is used for the case when a
   -- strip and translation occurs and an earlier stage of the pipeline must
   -- be muxed in otherwise the wrong data will be translated
   ----------------------------------------------------------------------------
   HOLD_MOD_DELAY_3_MUX : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or clrAllHits = '1' then
             muxSelDlyMod3 <= '0';
         elsif setMuxSelDlyMod3 = '1' then
            muxSelDlyMod3 <= '1';
         else
            muxSelDlyMod3 <= muxSelDlyMod3;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- When muxSelDlyMod3 is set, and if strip and trans but not tag, then mux 
   -- in earlier pipeline stage so the correct TAG is translated.
   -- -  Once set, muxSel and muxSelDlyMod3 are set until EOP is received
   ----------------------------------------------------------------------------
   MOD_DELAY3_MUX : process(tag0TotalHit,newTagTotalHit,transTotalHit,
                            LLTemac_Data_pipe2,LLTemac_Data_pipe3,muxSelDlyMod3)
   variable muxSel : std_logic_vector(0 to 2) := "000";

   begin

   muxSel := tag0TotalHit & newTagTotalHit & transTotalHit;
      if muxSelDlyMod3 = '1' then
         case muxSel is
            when "101"  =>
               modDly3 <= LLTemac_Data_pipe2;
            when others =>
               modDly3 <= LLTemac_Data_pipe3;
         end case;
      else
         modDly3 <= LLTemac_Data_pipe3;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- Register the output of MOD_DELAY3_MUX for the next mux stage
   ----------------------------------------------------------------------------
   MOD_DELAY4_REGISTER : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' then
             LLTemac_Data_pipeMods4 <= (others => '0');
         elsif finishPipeCe = '1' then
            LLTemac_Data_pipeMods4 <= modDly3;
         elsif srcRdyPipeCe = '1' then
            LLTemac_Data_pipeMods4 <= modDly3;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- Mux in either the translated data or the new tag data if the xor of the
   -- mux selection bits is true; otherwise allow the delayed data to pass
   -- through
   -- -  muxNewTag & muxtrans will never be set at the same time
   ----------------------------------------------------------------------------
   MOD_DELAY4_MUX : process(muxNewTag,muxtrans,LLTemac_Data_pipe5,newTagData_dly1,transReg,
                            newTagTotalHit,holdModDly4MuxSel,LLTemac_Data_pipeMods4)
   variable muxSelModDly4 : std_logic_vector(0 to 1) := "00";

   begin

   muxSelModDly4 := muxNewTag & muxtrans;
      case muxSelModDly4 is
         when "01"   =>
            if newTagTotalHit = '0' then
               -- if tag did not occur, then mux in transReg here to save a clock
               modDly4 <= LLTemac_Data_pipeMods4(0 to 19) & transReg;
            else
               -- otherwise need to wait until next mux stage to do it
               if holdModDly4MuxSel = '1' then
               -- need to pipe through delayed version when both TAG and
               --    TRANS occur on the same packet otherwise original
               --    TAG will be overwritten with the new TAG
                  modDly4 <= LLTemac_Data_pipe5;
               else
                  modDly4 <= LLTemac_Data_pipeMods4;
               end if;
            end if;
         when "10"   => modDly4 <= newTagData_dly1;
         when others =>
            if holdModDly4MuxSel = '1' then
               modDly4 <= LLTemac_Data_pipe5;
            else
               modDly4 <= LLTemac_Data_pipeMods4;
            end if;
      end case;
   end process;
   
   
   ----------------------------------------------------------------------------
   -- The generate is used to generate a signal to allow for a one pipe delay 
   -- when translation and tagging are enabled and going to occur per the 
   -- *TotalHit signals
   ----------------------------------------------------------------------------
   GEN_HOLD_MOD_DELAY_4_MUX : if C_TEMAC_TXVLAN_TRAN = 1 and C_TEMAC_TXVLAN_TAG = 1 generate
   begin

      ----------------------------------------------------------------------------
      -- This signal is needed to route a one clock delayed version of the ll data
      -- through the rest of the pipeline when a strip and translation occures,
      -- but NOT a TAG.  Otherwise the original VLAN TAG data will be overwritten
      -- and the translated data will occur on the Type/Length data - which is
      -- wrong.  It cannot be set when all three VLAN functions occur or the data
      -- that is supposed to be stripped is not stripped and it is translated -
      -- this is also wrong.
      -- -  tag0TotalHit only set when stripping is is enabled 
      --    -  C_TEMAC_TXVLAN_STRP = '1' and strpMode_dly1 = "01" or "11"
      ----------------------------------------------------------------------------
      HOLD_MOD_DELAY_4_MUX : process(LLTemac_Clk)
      variable muxSel : std_logic_vector(0 to 2) := "000";

      begin
      muxSel := tag0TotalHit & newTagTotalHit & transTotalHit;

         if rising_edge(LLTemac_Clk) then
            if LLTemac_Rst = '1' or clrAllHits = '1' then
                holdModDly4MuxSel <= '0';
            elsif (srcRdyPipeCe = '1' or finishPipeCe = '1') and 
                   muxNewTag = '1' and transTotalHit = '1' then
               case muxSel is
                  when "011" =>
                  -- only needed when a tag and translation occurs but not a strip
                     holdModDly4MuxSel <= '1';
                  when others =>
                     holdModDly4MuxSel <= '0';
               end case;
            else
               holdModDly4MuxSel <= holdModDly4MuxSel;
            end if;
         end if;
      end process;

   end generate;
   
   
   ----------------------------------------------------------------------------
   -- holdModDly4MuxSel is not need in this case, so tie it LOW
   -----------------------------------------------------------------------------
   GEN_NO_HOLD_MOD_DELAY_4_MUX : if not(C_TEMAC_TXVLAN_TRAN = 1 and C_TEMAC_TXVLAN_TAG = 1) generate
   begin

      holdModDly4MuxSel <= '0';
   end generate;


   ----------------------------------------------------------------------------
   -- Register the output of MOD_DELAY4_MUX when the CE is set; otherwise hold
   -- the current value
   ----------------------------------------------------------------------------
   MOD_DELAY5_REGISTER : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' then
             LLTemac_Data_pipeMods5 <= (others => '0');
         elsif finishPipeCe = '1' then
            LLTemac_Data_pipeMods5 <= modDly4;
         elsif srcRdyPipeCe = '1' then
            LLTemac_Data_pipeMods5 <= modDly4;
         else
            LLTemac_Data_pipeMods5 <= LLTemac_Data_pipeMods5;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- Mux in either the translated data or the output of MOD_DELAY5_REGISTER
   ----------------------------------------------------------------------------
   MOD_DELAY5_MUX : process(muxtrans,LLTemac_Data_pipeMods5,transReg,newTagTotalHit)

   begin

      case muxtrans is
         when '1'    =>
            if newTagTotalHit = '1' then
               --  If tagging occured then mux in this transReg
               modDly5 <= LLTemac_Data_pipeMods5(0 to 19) & transReg;
            else
               --otherwise transReg was muxed in at previous mux stage
               modDly5 <= LLTemac_Data_pipeMods5;
            end if;
         when others => modDly5 <= LLTemac_Data_pipeMods5;
      end case;
   end process;


   ----------------------------------------------------------------------------
   -- Register the output of MOD_DELAY5_MUX when the CE is set; otherwise hold
   -- the current value
   ----------------------------------------------------------------------------
   MOD_DELAY6_REGISTER : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' then
             LLTemac_Data_pipeMods6 <= (others => '0');
         elsif finishPipeCe = '1' then
            LLTemac_Data_pipeMods6 <= modDly5;
         elsif srcRdyPipeCe = '1' then
            LLTemac_Data_pipeMods6 <= modDly5;
         else
            LLTemac_Data_pipeMods6 <= LLTemac_Data_pipeMods6;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- Once the mux selection bits are set (outputMuxCase) with setMuxOutput,
   -- they will stay set until the entire packet has been written to the FIFO.
   -- -  ie until after EOF has been received
   ----------------------------------------------------------------------------
   MOD_DELAY6_MUX : process(outputMuxCase,LLTemac_Data_pipe5,
                            LLTemac_Data_pipe6,LLTemac_Data_pipe7,
                            LLTemac_Data_pipeMods6)
   begin

      case outputMuxCase is
         when 4 | 5  => modDly6 <= LLTemac_Data_pipe5;
         when 1 | 6  => modDly6 <= LLTemac_Data_pipe6;
         when     2  => modDly6 <= LLTemac_Data_pipe7;
         when others => modDly6 <= LLTemac_Data_pipeMods6;
      end case;
   end process;


   ----------------------------------------------------------------------------
   -- Register the output of MOD_DELAY6_MUX when the CE is set; otherwise hold
   -- the current value
   ----------------------------------------------------------------------------
   MOD_DELAY7_REGISTER : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' then
             LLTemac_Data_pipeMods7 <= (others => '0');
         elsif finishPipeCe = '1' then
            LLTemac_Data_pipeMods7 <= modDly6;
         elsif srcRdyPipeCe = '1' then
            LLTemac_Data_pipeMods7 <= modDly6;
         else
            LLTemac_Data_pipeMods7 <= LLTemac_Data_pipeMods7;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- Once the mux selection bits are set (outputMuxCase) with setMuxOutput,
   -- they will stay set until the entire packet has been written to the FIFO.
   -- -  ie until after EOF has been received
   ----------------------------------------------------------------------------
   MOD_DELAY7_MUX : process(outputMuxCase,LLTemac_Data_pipe7,LLTemac_Data_pipe8,
                            LLTemac_Data_pipeMods7)
   begin

      case outputMuxCase is
         when 3      => modDly7 <= LLTemac_Data_pipe8;
         when 7      => modDly7 <= LLTemac_Data_pipe7;
         when others => modDly7 <= LLTemac_Data_pipeMods7;
      end case;
   end process;


   ----------------------------------------------------------------------------
   -- Register the output of MOD_DELAY7_MUX when the CE is set; otherwise hold
   -- the current value.  This is the data written to the FIFO.
   ----------------------------------------------------------------------------
   MOD_DELAY8_REGISTER : process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' then
             LLTemac_Data_pipeMods8 <= (others => '0');
         elsif finishPipeCe = '1' then
            LLTemac_Data_pipeMods8 <= modDly7;
         elsif srcRdyPipeCe = '1' then
            LLTemac_Data_pipeMods8 <= modDly7;
         else
            LLTemac_Data_pipeMods8 <= LLTemac_Data_pipeMods8;
         end if;
      end if;
   end process;



   ----------------------------------------------------------------------------
   -- This state machine controls the reading/evaluation of data read from 
   -- the BRAM and controls all of the muxing of the pipeline to perform 
   -- all of the transmit VLAN functions.  
   -- It assumes all three VLAN functions are enabled and
   -- branches accordingly based upon register mode settings for stripping and 
   -- tagging.  
   -- -  Stripping
   --    -  If strpMode_dly1 = 00 then no stripping occures
   --    -  If strpMode_dly1 = 01 then only strip if it is a VLAN tag
   --       ie if tag0TotalHit=1
   --    -  If strpMode_dly1 = 10 then do not strip anything
   --       this mode is reserved and has no function
   --    -  If strpMode_dly1 = 11 then strip select VLAN frames based upon:
   --       -  1. Must be a VLAN Hit (tag0TotalHit must be set) and
   --       -  2. bramDin Strip Enable bit must be set
   --
   -- -  Tagging
   --    -  If  tagMode_dly1 = "00" then do NOT tag any frames                
   --    -  If  tagMode_dly1 = "01" then tag all frames even if it was not a  
   --       VLAN HIT (tag1TpidHit = '0')                                     
   --    -  If  tagMode_dly1 = "10" then add one tag to all VLAN Frames       
   --       (tag1TpidHit = '1')                                              
   --    -  If  tagMode_dly1 = "11" then add one tag to select VLAN frames    
   --       based upon the bramDin tag bit being set                         
   -- 
   -- -  Translation
   --    -  If C_TEMAC_TXVLAN_TRAN is set and the current packet is a VLAN 
   --       packet (transTotalHit gets set HIGH), a translation will occur
   --
   -- The state machine transitions from state to state dependant upon
   -- lltemac_src_rdy_n_inc and lltemac_dst_rdy_n_inc both being LOW, or 
   -- if payLoadSizes1_14 is set.  Depending upon the branch taken for VLAN
   -- support, the state machine will stall without this signal for packet 
   -- sizes less than 15 (T/L = 0xF).
   ----------------------------------------------------------------------------
   VLAN_STRIP_SM_CMB: process (txVlanCs,
                               LLTemac_SOP_n_inc,
                               LLTemac_SRC_RDY_n_inc,LLTemac_DST_RDY_n_inc,
                               newTagTotalHit,transTotalHit,tag0TotalHit,
                               LLTemac_EOF_n,LLTemac_EOP_n_clr,
                               payLoadSizes1_14,flushPipeline
                              )
   begin
      setBramEn        <= '0';
      clrBramEn        <= '0';
      setCheckTag0Tpid <= '0';
      clrCheckTag0Tpid <= '0';
      setCheckTag1Tpid <= '0';
      clrCheckTag1Tpid <= '0';
      clrAllHits       <= '0';
      setMuxNewTag     <= '0';
      clrMuxNewTag     <= '0';
      setMuxTrans      <= '0';
      clrMuxTrans      <= '0';
      setMuxOutput     <= '0';
      clrMuxOutput     <= '0';

      setMuxSelDlyMod3 <= '0';

      case txVlanCs is
         when IDLE =>
            -- Start transition at SOP_n if the VLAN functions are enabled
            -- Otherwise remain in this state
            txVlanSmEncoding <= "0000";
            
            if LLTemac_SOP_n_inc = '0' and 
               LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0' then 
               txVlanNs <= RCVD_SOP;
            else
               txVlanNs <= IDLE;
            end if;
         when RCVD_SOP =>
            --Wait for SRC/DST to transition to next state to stay aligned to incoming Local link data
            txVlanSmEncoding <= "0001";
            if LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0' then
               txVlanNs <= SET_BRAM_ENABLE;
            else
               txVlanNs <= RCVD_SOP;
            end if;
         when SET_BRAM_ENABLE =>
            --Get ready for Bram Accesses
            txVlanSmEncoding <= "0010";
            if LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0' then
               setBramEn <= '1';
               txVlanNs <= TAG0_BRAM_ACCESS;
            else
               setBramEn <= '0';
               txVlanNs <= SET_BRAM_ENABLE;
            end if;
         when TAG0_BRAM_ACCESS =>
            txVlanSmEncoding <= "0011";
            if LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0' then
               setBramEn <= '1';
               setCheckTag0Tpid <= '1';
               txVlanNs <= TAG1_BRAM_ACCESS;
            else
               setBramEn <= '0';
               setCheckTag0Tpid <= '0';
               txVlanNs <= TAG0_BRAM_ACCESS;
            end if;
         when TAG1_BRAM_ACCESS =>
            txVlanSmEncoding <= "0100";
            clrCheckTag0Tpid <= '1';
            if (LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0') or
               payLoadSizes1_14 = '1' or flushPipeline = '1' then
               clrBramEn <= '1';
               setCheckTag1Tpid <= '1';
               txVlanNs <= WAIT_TPID_DECODE;
            else
               clrBramEn <= '0';
               setCheckTag1Tpid <= '0';
               txVlanNs <= TAG1_BRAM_ACCESS;
            end if;
         when WAIT_TPID_DECODE =>
            txVlanSmEncoding <= "0101";
            clrCheckTag1Tpid <= '1';
            if (LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0') or
               payLoadSizes1_14 = '1' or flushPipeline = '1' then
               setMuxSelDlyMod3 <= '1';
               txVlanNs <= STRIP_TAG_TRANS_BRANCH;
            else
               setMuxSelDlyMod3 <= '0';
               txVlanNs <= WAIT_TPID_DECODE;
            end if;
         when STRIP_TAG_TRANS_BRANCH =>
            txVlanSmEncoding <= "0110";
            if (LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0') or
               payLoadSizes1_14 = '1' or flushPipeline = '1' then
               if newTagTotalHit = '1' then
               -- perform tag based upon mode, and possibly TPID HIT and Enable Bit from BRAM
                  setMuxNewTag <= '1';
                  setMuxTrans <= '0';
                  txVlanNs <= MUX_NEW_TAG;
               elsif transTotalHit = '1' then
               -- not doing tag, so perform translation if TPID Hit
                  setMuxNewTag <= '0';
                  setMuxTrans <= '1';
                  txVlanNs <= MUX_TRANS;
               elsif tag0TotalHit = '1' then
               -- not doing tag or translation, so perform strip if TPID Hit and possibly
               --    Enable Bit from BRAM
                  setMuxNewTag <= '0';
                  setMuxTrans <= '0';
                  txVlanNs <= WAIT_STATE;
               else
               -- not doing tag, translation, or strip wait for EOF
                  setMuxNewTag <= '0';
                  setMuxTrans <= '0';
                  txVlanNs <= WAIT_EOP;
               end if;
            else
               setMuxNewTag <= '0';
               setMuxTrans <= '0';
               txVlanNs <= STRIP_TAG_TRANS_BRANCH;
            end if;
         when MUX_NEW_TAG =>
            txVlanSmEncoding <= "0111";
            if (LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0') or
               payLoadSizes1_14 = '1' or flushPipeline = '1' then
               clrMuxNewTag <= '1';
               if transTotalHit = '1' then
               -- Do translation
                  txVlanNs <= SET_MUX_TRANS;
               else
               -- not doing translation, so go to wait state
                  txVlanNs <= WAIT_STATE;
               end if;
            else
               txVlanNs <= MUX_NEW_TAG;
            end if;
         when SET_MUX_TRANS =>
            txVlanSmEncoding <= "1000";
            if (LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0') or
               payLoadSizes1_14 = '1' or flushPipeline = '1' then
            -- Do translation
               setMuxTrans <= '1';
               txVlanNs   <= MUX_TRANS;
            else
            -- wait for SRC and DST Ready signals
               setMuxTrans <= '0';
               txVlanNs <= SET_MUX_TRANS;
            end if;
         when MUX_TRANS =>
            txVlanSmEncoding <= "1001";
            if (LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0') or
               payLoadSizes1_14 = '1' or flushPipeline = '1' then
               clrMuxTrans <= '1';
               txVlanNs   <= WAIT_STATE;
            else
               clrMuxTrans <= '0';
               txVlanNs <= MUX_TRANS;
            end if;
         when WAIT_STATE =>
            txVlanSmEncoding <= "1010";
            if (LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0') or
               payLoadSizes1_14 = '1' or flushPipeline = '1' then
               txVlanNs   <= SET_OUTPUT_MUX;
            else
               txVlanNs <= WAIT_STATE;
            end if;
         when SET_OUTPUT_MUX =>
            txVlanSmEncoding <= "1011";
            if (LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0') or
               payLoadSizes1_14 = '1' or flushPipeline = '1' then
               setMuxOutput <= tag0TotalHit or newTagTotalHit or transTotalHit;
               txVlanNs   <= WAIT_EOP;
            else
               setMuxOutput <= '0';
               txVlanNs <= SET_OUTPUT_MUX;
            end if;
         when WAIT_EOP =>
            txVlanSmEncoding <= "1100";
            if LLTemac_DST_RDY_n_inc = '1' and 
               LLTemac_EOP_n_clr = '0' then
               txVlanNs   <= WAIT_EOF;
            else
               txVlanNs <= WAIT_EOP;
            end if;
         when WAIT_EOF =>
            txVlanSmEncoding <= "1101";
            if LLTemac_DST_RDY_n_inc = '1' and 
               LLTemac_EOF_n = '0' then
               clrMuxOutput <= '1';
               clrAllHits <= '1';
               txVlanNs   <= IDLE;
            else
               clrMuxOutput <= '0';
               clrAllHits <= '0';
               txVlanNs <= WAIT_EOF;
            end if;
         when others =>
            txVlanSmEncoding <= "1110";
            txVlanNs   <= IDLE;
      end case;
   end process;


  ----------------------------------------------------------------------------
  --  State machine sequencer
  ----------------------------------------------------------------------------
   TX_VLAN_SM_SEQUENCER : process (LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' then
            txVlanCs <= IDLE;
         else
            txVlanCs <= txVlanNs;
         end if;
      end if;
   end process;



   ----------------------------------------------------------------------------
   -- START
   -- -  Register State Machine Signals
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   --  Bram Enable Register
   ----------------------------------------------------------------------------
   BRAM_ENABLE_REGISTER : process (LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or clrBramEn = '1' then
            bramEn <= '0';
         elsif setBramEn = '1' then
            bramEn <= '1';
         else
            bramEn <= bramEn;
         end if;
      end if;
   end process;
   LlinkClkTxVlanBramEnA <= bramEn;


   ----------------------------------------------------------------------------
   --  Bram Address Register
   ----------------------------------------------------------------------------
   BRAM_ADDRESS_REGISTER : process (bramEn,LLTemac_Data_inc)
   begin

      if bramEn = '1' then
         bramAddr <= LLTemac_Data_inc(20 to 31);
      else
         bramAddr <= (others => '0');
      end if;
   end process;
   LlinkClkAddr <= bramAddr;


   ----------------------------------------------------------------------------
   --  Control signal indicating when to check the outter tag for a TPID hit
   ----------------------------------------------------------------------------
   CHECK_TAG0 : process (LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or clrCheckTag0Tpid = '1' then
            checkTag0Tpid <= '0';
         elsif setCheckTag0Tpid = '1' then
            checkTag0Tpid <= '1';
         else
            checkTag0Tpid <= checkTag0Tpid;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   --  Control signal indicating when to check the inner tag for a TPID hit
   ----------------------------------------------------------------------------
   CHECK_TAG1 : process (LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or clrCheckTag1Tpid = '1' then
            checkTag1Tpid <= '0';
         elsif setCheckTag1Tpid = '1' then
            checkTag1Tpid <= '1';
         else
            checkTag1Tpid <= checkTag1Tpid;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   --  Control signal indicating when to check the inner tag for a TPID hit
   ----------------------------------------------------------------------------
   MUX_TAG_DATA_SELECT : process (LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or clrMuxNewTag = '1' then
            muxNewTag <= '0';
         elsif setMuxNewTag = '1' then
            muxNewTag <= '1';
         else
            muxNewTag <= muxNewTag;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   --  Control signal indicating when to check the inner tag for a TPID hit
   ----------------------------------------------------------------------------
   MUX_TRANS_DATA_SELECT : process (LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or clrMuxTrans = '1' then
            muxTrans <= '0';
         elsif setMuxTrans = '1' then
            muxTrans <= '1';
         else
            muxTrans <= muxTrans;
         end if;
      end if;
   end process;


   ----------------------------------------------------------------------------
   -- END
   -- -  Register State Machine Signals
   ----------------------------------------------------------------------------
   
   
   ----------------------------------------------------------------------------
   -- START
   -- -  Additions payload size of 1 to 14
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   -- If pipe_ce_dataVld pipes 7 is not set when lltemac_eop_n_inc goes LOW
   -- the packet size is less than 29 bytes (wo VLAN).  The state machine needs this 
   -- signal to continue state transitions independant of LLTemac_SRC_RDY_n_inc
   -- and LLTemac_DST_Rdy_n_inc.  
   ----------------------------------------------------------------------------
   DETECT_PAYLOAD_SIZES_1_14 : process (LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or LLTemac_EOP_n_clr = '0' then
            payLoadSizes1_14 <= '0';
         elsif LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0' and 
               LLTemac_EOP_n_inc = '0' then         
            if pipe_ce_dataVld(7) = '0' then
               payLoadSizes1_14 <= '1';
            else
               payLoadSizes1_14 <= payLoadSizes1_14;
            end if;
         else
            payLoadSizes1_14 <= payLoadSizes1_14;
         end if;
      end if;
   end process;   
      
   
   ----------------------------------------------------------------------------
   -- Detect when the 2nd to last LLTemac_SRC_RDY_n_inc = '0' and 
   -- LLTemac_DST_RDY_n_inc = '0' and allow pipeline to be flushed only if 
   -- the state machine next stateis not the WAIT_EOP, or WAIT_EOF state,
   -- and the current state is not the WAIT_EOF state.
   ----------------------------------------------------------------------------
   PIPELINE_FLUSH: process(LLTemac_Clk)
   begin

      if rising_edge(LLTemac_Clk) then
         if LLTemac_Rst = '1' or LLTemac_EOP_n_clr = '0' then
            flushPipeline <= '0';
         elsif (LLTemac_SRC_RDY_n_inc = '0' and LLTemac_DST_RDY_n_inc = '0' and 
               LLTemac_EOP_n_inc = '0') and 
               (txVlanNs /= WAIT_EOP and txVlanNs /= WAIT_EOF and txVlanCs /= WAIT_EOF) then
            flushPipeline <= '1';
         else
            flushPipeline <= flushPipeline;
         end if;

      end if;
   end process;   
   
   ----------------------------------------------------------------------------
   -- END
   -- -  Additions payload size of 1 to 14
   ----------------------------------------------------------------------------
   

end implementation;
