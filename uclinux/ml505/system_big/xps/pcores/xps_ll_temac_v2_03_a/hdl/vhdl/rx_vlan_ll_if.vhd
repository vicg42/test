------------------------------------------------------------------------------
-- $Id: rx_vlan_ll_if.vhd,v 1.1.4.41 2010/03/23 19:25:23 shurt Exp $
------------------------------------------------------------------------------
-- rx_vlan_ll_if.vhd
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
-- Filename:        rx_vlan_ll_if.vhd
-- Version:         v1.00a
-- Description:     Receive interface between the receive and status fifos and
--                  LL.  Data is formatted into the local link prototcol
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
--  DRP      2006.05.17      -- First version
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

------------------------------------------------------------------------------
-- Libraries used;
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.numeric_std.all;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.coregen_comp_defs.all;
use proc_common_v3_00_a.family_support.all;

-- synopsys translate_off
library XilinxCoreLib;
-- synopsys translate_on

library unisim;
use unisim.vcomponents.all;

------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
--
------------------------------------------------------------------------------

entity rx_vlan_ll_if is
  generic (
    C_FAMILY              : string   := "virtex5";  
    C_TEMAC_TYPE          : integer  :=    0;  
      -- 0 - Virtex 5 hard TEMAC (FX, LXT, SXT devices)                
      -- 1 - Virtex 4 hard TEMAC (FX)               
      -- 2 - Soft TEMAC         
    C_TEMAC_RXCSUM        : integer  :=    0;
    C_TEMAC_RXFIFO        : integer  := 4096; 
    C_TEMAC_RXVLAN_TRAN   : integer  := 0;
    C_TEMAC_RXVLAN_TAG    : integer  := 0;
    C_TEMAC_RXVLAN_STRP   : integer  := 0;
    C_MEM_DEPTH           : integer  := 9; 
    C_TEMAC_RXVLAN_WIDTH  : integer  := 1
  );
  port (
    LLTemac_Clk        : in  std_logic;
    LLTemac_Rst        : in  std_logic;          
    TemacLL_SOF_n      : out std_logic;
    TemacLL_SOP_n      : out std_logic;
    TemacLL_Data       : out std_logic_vector(0 to 31);
    TemacLL_REM        : out std_logic_vector(0 to 3);
    TemacLL_EOP_n      : out std_logic;
    TemacLL_EOF_n      : out std_logic;
    TemacLL_SRC_RDY_n  : out std_logic;
    TemacLL_DST_RDY_n  : in  std_logic;
    RxLLinkClkDPMemWrData : out std_logic_vector(35 downto 0);
    RxLLinkClkDPMemRdData : in  std_logic_vector(35 downto 0);
    RxLLinkClkDPMemWrEn   : out std_logic_vector(0 downto 0);
    RxLLinkClkDPMemAddr   : out std_logic_vector(C_MEM_DEPTH downto 0);
    LlinkClkNewFncEnbl : in  std_logic;
    LlinkClkRxVStrpMode : in  std_logic_vector(0 to 1);
    LlinkClkRxVTagMode  : in  std_logic_vector(0 to 1);
    RtagRegData        : in  std_logic_vector(0 to 31);
    Tpid0RegData       : in  std_logic_vector(0 to 31);
    Tpid1RegData       : in  std_logic_vector(0 to 31);
    LlinkClkVlanAddr   : out std_logic_vector(0 to 11);
    LlinkClkVlanRdData : in  std_logic_vector(18 to 31);
    LlinkClkRxVlanBramEnA : out std_logic;
    RxLLinkRdMemPtrErr : out std_logic;
    RxLlClkLastProcessedGray : out std_logic_vector(C_MEM_DEPTH downto 0)
  );
end rx_vlan_ll_if;

------------------------------------------------------------------------------
-- Architecture
------------------------------------------------------------------------------

architecture beh of rx_vlan_ll_if is

---------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------

-- Convert a binary value into a gray code
function bin_to_gray (
   bin : std_logic_vector)
   return std_logic_vector is

   variable gray : std_logic_vector(bin'range);
   
begin

   for i in bin'range loop
      if i = bin'left then
         gray(i) := bin(i);
      else
         gray(i) := bin(i+1) xor bin(i);
      end if;
   end loop;  -- i

   return gray;

end bin_to_gray;



-- Convert a gray code value into binary
function gray_to_bin (
   gray : std_logic_vector)
   return std_logic_vector is

   variable binary : std_logic_vector(gray'range);
   
begin

   for i in gray'high downto gray'low loop
      if i = gray'high then
         binary(i) := gray(i);
      else
         binary(i) := binary(i+1) xor gray(i);
      end if;
   end loop;  -- i

   return binary;
   
end gray_to_bin;

------------------------------------------------------------------------------
--  Constant Declarations
------------------------------------------------------------------------------


--------------------------------------------------------------------------
-- Type Declarations
--------------------------------------------------------------------------

type RXLLRDSM_TYPE is (
                     PWR_UP_INIT_LAST_PROC,
                     PWR_UP_WAIT_INIT_DONE,
                     READ_NEXT_AVAIL_PTR,
                     READ_NEXT_AVAIL_PTR2,
                     READ_NEXT_AVAIL_PTR3,
                     WAIT_FOR_FRAME_AVAIL,
                     WAIT_FOR_FIFO_EMPTY,
                     WAIT_FOR_FIFO_EMPTY2,
                     READ_WORD_1,
                     PAUSE_1,
                     READ_WORD_2,
                     READ_WORD_3,
                     READ_WORD_4,
                     READ_WORD_5,
                     CHECK_TPID_1,
                     CHECK_TPID_2,
                     GET_BRAM_WD4,
                     GET_BRAM_WD5,
                     SOF,

                     SEND_WD1,
                     SEND_WD2,
                     SEND_WD3,
                     SEND_WD4,
                     SEND_WD5,
                     SEND_WD4TRANS,
                     SEND_WD5TRANS,
                     SEND_TAG,
                     
                     RD_FRAME_FROM_MEM,
                     ALMOST_FULL_WAIT1,
                     ALMOST_FULL_WAIT2,
                     ALMOST_FULL_WAIT3,
                     ALMOST_FULL_WAIT4,
                     SPECIAL_EOP,
                     EOP,
                     FOOT_0,
                     FOOT_1,
                     FOOT_2,
                     FOOT_3,
                     FOOT_4,
                     FOOT_5,
                     FOOT_6,
                     EOF,
                     WRITE_LAST_PROC
                    );

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

signal rxLlRdSm_Cs              : RXLLRDSM_TYPE;
signal rxLlRdSm_Ns              : RXLLRDSM_TYPE;

signal rxLlClkNextAvailable     : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxLlClkLastProcessed_d   : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxLlClkLastProcessed     : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxLlClkRdAddrCntr        : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxLlClkRdAddrCntrLd      : std_logic;
signal rxLlClkRdNextAvailable   : std_logic;
signal rxLlClkFrameLengthBytes  : std_logic_vector(13 downto 0);
signal rxLlClkMemEmptyDuringRd  : std_logic;
signal rxLlClkRdFrameLengthDetct     : std_logic;
signal rxLlClkMemNotEmptyBeforeStart : std_logic;

signal footWord3                : std_logic_vector(16 to 31);
signal footWord4                : std_logic_vector(0 to 31);
signal footWord5                : std_logic_vector(0 to 31);
signal footWord6                : std_logic_vector(0 to 15);
signal footWord7                : std_logic_vector(0 to 31);

signal wd4TPIDMatch             : std_logic;
signal wd4TPID0Match            : std_logic;
signal wd4TPID1Match            : std_logic;
signal wd4TPID2Match            : std_logic;
signal wd4TPID3Match            : std_logic;
signal wd5TPIDMatch             : std_logic;
signal wd5TPID0Match            : std_logic;
signal wd5TPID1Match            : std_logic;
signal wd5TPID2Match            : std_logic;
signal wd5TPID3Match            : std_logic;
signal wd4VID                   : std_logic_vector(0 to 11);
signal wd5VID                   : std_logic_vector(0 to 11);
signal wd4BRAM                  : std_logic_vector(0 to 13);
signal wd5BRAM                  : std_logic_vector(0 to 13);

signal rdWord1                  : std_logic_vector(0 to 35);
signal rdWord2                  : std_logic_vector(0 to 35);
signal rdWord3                  : std_logic_vector(0 to 35);
signal rdWord4                  : std_logic_vector(0 to 35);
signal rdWord5                  : std_logic_vector(0 to 35);
signal rdWord1WrEn              : std_logic;
signal rdWord2WrEn              : std_logic;
signal rdWord3WrEn              : std_logic;
signal rdWord4WrEn              : std_logic;
signal rdWord5WrEn              : std_logic;

signal transEnabled             : std_logic;
signal tagEnabled               : std_logic;
signal strpEnabled              : std_logic;
signal rxLlClkRdFrameLengthDetctPulse : std_logic;
signal rxLlClkRdFrameLengthDetct_d1: std_logic;

signal rxLlClkLastProcessed_d2     : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxLlClkLastProcessed_d_gray : std_logic_vector(C_MEM_DEPTH downto 0);

signal incByteCntBy4            : std_logic;
signal decByteCntBy4            : std_logic;
signal incByteCntBy4_d          : std_logic;
signal decByteCntBy4_d          : std_logic;

signal veryShortFrame           : std_logic; -- 1 or 2 bytes in data field (4 words in memory when stripping turned on)
signal shortFrame               : std_logic; -- 3, 4, 5, or 6 bytes in data field (5 words in memory when stripping turned on)

signal incrementRdAddrCntr      : std_logic;
signal decrementRdAddrCntr      : std_logic;

signal preRegFifoRemDataIn : std_logic_vector(0 to 3);     
signal fifoDataIn    : std_logic_vector(0 to 39);     
signal fifoDataIn_i  : std_logic_vector(0 to 39);     
signal fifoWrEn      : std_logic;       
signal fifoRdEn      : std_logic;       
signal fifoRdEnMod      : std_logic;       
signal fifoDataOut   : std_logic_vector(0 to 39);    
signal fifoFull      : std_logic;      
signal fifoEmpty     : std_logic;      
signal preRegFifoSOFIn     : std_logic;
signal preRegFifoSOPIn     : std_logic;
signal preRegFifoEOPIn     : std_logic;
signal preRegFifoEOFIn     : std_logic;
signal preRegFifoWrEn      : std_logic;       
signal preRegFifoDataIn    : std_logic_vector(0 to 39);     
signal rxLLinkClkDPMemRdData_d1 : std_logic_vector(35 downto 0);
signal fifoAlmostFull      : std_logic;
signal fifoDataCount            : std_logic_vector(0 to 5);

signal grayCodeUpdateEnable : std_logic;
signal rxLlClkLastProcessed_d2_clean : std_logic_vector(C_MEM_DEPTH downto 0);
signal fullMask                 : std_logic_vector(C_MEM_DEPTH downto 0);
signal emptyMask                : std_logic_vector(C_MEM_DEPTH downto 0);
signal zeroMask                 : std_logic_vector(C_MEM_DEPTH downto 0);
signal oneMask                  : std_logic_vector(C_MEM_DEPTH downto 0);
signal twoMask                  : std_logic_vector(C_MEM_DEPTH downto 0);
signal threeMask                : std_logic_vector(C_MEM_DEPTH downto 0);

signal localLinkTransInProg     : std_logic;

begin
        
  -------------------------------------------------------------------------
  -- Generate variable width address masks for checking memory pointers
  -------------------------------------------------------------------------
  GENMASK1: for I in C_MEM_DEPTH downto 0 generate
    fullMask(I) <= '1';
    emptyMask(I) <= '0';
  end generate;
  
  zeroMask  <= emptyMask;
  oneMask   <= emptyMask + 1;
  twoMask   <= emptyMask + 2;
  threeMask <= emptyMask + 3;

  RX_LL_CLK_DETECT_SMALL_FRAMES_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        veryShortFrame  <= '0';
        shortFrame      <= '0';
      else
        if (rxLlClkRdFrameLengthDetctPulse = '1' and (rxLlRdSm_Cs = READ_WORD_5)) then
          veryShortFrame  <= '1';
        elsif (rxLlClkRdFrameLengthDetctPulse = '1' and (rxLlRdSm_Cs = CHECK_TPID_1)) then
          shortFrame      <= '1';
        elsif (rxLlRdSm_Cs = WAIT_FOR_FRAME_AVAIL) then
          veryShortFrame  <= '0';
          shortFrame      <= '0';
        end if;
      end if;
    end if;
  end process;


-------------------------------------------------------------------------------
-- This processes ensures that the grey code is clean
-------------------------------------------------------------------------------
process(LLTemac_Clk)
  begin
    if(rising_edge(LLTemac_Clk)) then
      if(LLTemac_Rst='1') then
        rxLlClkLastProcessed_d2_clean <= (others => '0');
      else
        if(conv_integer(rxLlClkLastProcessed_d2)>0) then
          if(rxLlClkLastProcessed_d2_clean<rxLlClkLastProcessed_d2) then
            rxLlClkLastProcessed_d2_clean<=rxLlClkLastProcessed_d2_clean+'1';
          elsif(rxLlClkLastProcessed_d2_clean>rxLlClkLastProcessed_d2) then
            rxLlClkLastProcessed_d2_clean<=rxLlClkLastProcessed_d2_clean+'1';
          end if;
        end if;
      end if;
    end if;
end process;

  -------------------------------------------------------------------------
  -- Subtract one from last processed while processing packet to mask 1
  -- count overshoot and back-up at end of read from memory
  -------------------------------------------------------------------------
  
  grayCodeUpdateEnable <= '1' when rxLlRdSm_Cs = RD_FRAME_FROM_MEM or rxLlRdSm_Cs = READ_NEXT_AVAIL_PTR else
                          '0';

  RX_LL_CLK_LAST_PROC_REG_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rxLlClkLastProcessed_d2  <= oneMask;
      elsif (grayCodeUpdateEnable = '1') then
        if (not (rxLlClkLastProcessed_d = oneMask)) then
          rxLlClkLastProcessed_d2 <= rxLlClkLastProcessed_d - 1;
        else
          rxLlClkLastProcessed_d2 <= fullMask;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- Convert binary encoded last processed pointer to gray encoded to send
  -- to receive client interface
  -------------------------------------------------------------------------
  rxLlClkLastProcessed_d_gray <= bin_to_gray(rxLlClkLastProcessed_d2_clean);
    
  -------------------------------------------------------------------------
  -- Register gray encoded last processed pointer to send to receive client 
  -- interface. reset to zero at power-up
  -------------------------------------------------------------------------
  RX_LL_CLK_LAST_PROC_GRAY_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        RxLlClkLastProcessedGray  <= (others => '0');
      else 
        RxLlClkLastProcessedGray <= rxLlClkLastProcessed_d_gray;
      end if;
    end if;
  end process;


  transEnabled <= '1' when LlinkClkNewFncEnbl = '1' and C_TEMAC_RXVLAN_TRAN = 1 and ((strpEnabled = '0' and wd4TPIDMatch = '1') or (strpEnabled = '1' and wd5TPIDMatch = '1')) else
                  '0';

  strpEnabled  <= '1' when LlinkClkNewFncEnbl = '1' and C_TEMAC_RXVLAN_STRP = 1 and ((LlinkClkRxVStrpMode = "01" and wd4TPIDMatch = '1') or (LlinkClkRxVStrpMode = "11" and wd4TPIDMatch = '1' and wd4BRAM(12) = '1')) else
                  '0';

  tagEnabled   <= '1' when LlinkClkNewFncEnbl = '1' and C_TEMAC_RXVLAN_TAG  = 1 and ((LlinkClkRxVTagMode = "01") or (LlinkClkRxVTagMode = "10" and ((strpEnabled = '1' and wd5TPIDMatch = '1') or (strpEnabled = '0' and wd4TPIDMatch = '1'))) or (LlinkClkRxVTagMode = "11" and ((strpEnabled = '1' and wd5TPIDMatch = '1' and wd5BRAM(13) = '1') or (strpEnabled = '0' and wd4TPIDMatch = '1' and wd4BRAM(13) = '1')))) else
                  '0';

  WORD_1_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rdWord1       <= (others => '0');
      else
        if (rdWord1WrEn = '1') then
          rdWord1       <= RxLLinkClkDPMemRdData;
        end if;
      end if;
    end if;
  end process;

  WORD_2_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rdWord2       <= (others => '0');
      else
        if (rdWord2WrEn = '1') then
          rdWord2       <= RxLLinkClkDPMemRdData;
        end if;
      end if;
    end if;
  end process;

  WORD_3_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rdWord3       <= (others => '0');
      else
        if (rdWord3WrEn = '1') then
          rdWord3       <= RxLLinkClkDPMemRdData;
        end if;
      end if;
    end if;
  end process;

  WORD_4_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rdWord4       <= (others => '0');
      else
        if (RxLlRdSm_Cs = READ_NEXT_AVAIL_PTR) then
          rdWord4       <= (others => '0');
        elsif (rdWord4WrEn = '1') then
          rdWord4       <= RxLLinkClkDPMemRdData;
        end if;
      end if;
    end if;
  end process;

  WORD_5_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rdWord5       <= (others => '0');
      else
        if (RxLlRdSm_Cs = READ_NEXT_AVAIL_PTR) then
          rdWord5       <= (others => '0');
        elsif (rdWord5WrEn = '1') then
          rdWord5       <= RxLLinkClkDPMemRdData;
        end if;
      end if;
    end if;
  end process;

  ADDRESS_MEMORY_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        LlinkClkVlanAddr       <= (others => '0');
        LlinkClkRxVlanBramEnA  <= '0';
        wd4BRAM                <= (others => '0');
        wd5BRAM                <= (others => '0');
      else
        if (rxLlRdSm_Cs = READ_WORD_5 and wd4TPIDMatch = '1' and LlinkClkNewFncEnbl = '1') then
          LlinkClkVlanAddr       <= wd4VID;
          LlinkClkRxVlanBramEnA  <= '1';
        elsif (rxLlRdSm_Cs = CHECK_TPID_1 and wd4TPIDMatch = '1' and LlinkClkNewFncEnbl = '1') then
          LlinkClkVlanAddr       <= wd5VID;
          LlinkClkRxVlanBramEnA  <= '1';
        elsif (rxLlRdSm_Cs = CHECK_TPID_2 and wd4TPIDMatch = '1' and LlinkClkNewFncEnbl = '1') then
          LlinkClkVlanAddr       <= (others => '0');
          LlinkClkRxVlanBramEnA  <= '0';
          wd4BRAM                <= LlinkClkVlanRdData;
        elsif (rxLlRdSm_Cs = GET_BRAM_WD4 and wd4TPIDMatch = '1' and LlinkClkNewFncEnbl = '1') then
          LlinkClkVlanAddr       <= (others => '0');
          LlinkClkRxVlanBramEnA  <= '0';
          wd5BRAM                <= LlinkClkVlanRdData;
        else
          LlinkClkVlanAddr       <= (others => '0');
          LlinkClkRxVlanBramEnA  <= '0';        
        end if;
      end if;
    end if;
  end process;
  
  wd4TPIDMatch <= wd4TPID0Match or wd4TPID1Match or wd4TPID2Match or wd4TPID3Match;
  wd5TPIDMatch <= wd5TPID0Match or wd5TPID1Match or wd5TPID2Match or wd5TPID3Match;
  
  TPID_MATCH_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        wd4TPID0Match <= '0';
        wd4TPID1Match <= '0';
        wd4TPID2Match <= '0';
        wd4TPID3Match <= '0';
        wd5TPID0Match <= '0';
        wd5TPID1Match <= '0';
        wd5TPID2Match <= '0';
        wd5TPID3Match <= '0';
        wd4VID        <= (others => '0');
        wd5VID        <= (others => '0');
      else
        if (rxLlRdSm_Cs = READ_WORD_4) then
          if (RxLLinkClkDPMemRdData(31 downto 16)  = Tpid0RegData(16 to 31)) then
            wd4TPID0Match <= '1';
          else
            wd4TPID0Match <= '0';            
          end if;
          if (RxLLinkClkDPMemRdData(31 downto 16)  = Tpid0RegData(0 to 15)) then
            wd4TPID1Match <= '1';
          else
            wd4TPID1Match <= '0';            
          end if;
          if (RxLLinkClkDPMemRdData(31 downto 16)  = Tpid1RegData(16 to 31)) then
            wd4TPID2Match <= '1';
          else
            wd4TPID2Match <= '0';            
          end if;
          if (RxLLinkClkDPMemRdData(31 downto 16)  = Tpid1RegData(0 to 15)) then
            wd4TPID3Match <= '1';
          else
            wd4TPID3Match <= '0';            
          end if;
          wd4VID          <= RxLLinkClkDPMemRdData(11 downto 0);
        end if;
        if (rxLlRdSm_Cs = READ_WORD_5) then
          if (RxLLinkClkDPMemRdData(31 downto 16)  = Tpid0RegData(16 to 31)) then
            wd5TPID0Match <= '1';
          else
            wd5TPID0Match <= '0';            
          end if;
          if (RxLLinkClkDPMemRdData(31 downto 16)  = Tpid0RegData(0 to 15)) then
            wd5TPID1Match <= '1';
          else
            wd5TPID1Match <= '0';            
          end if;
          if (RxLLinkClkDPMemRdData(31 downto 16)  = Tpid1RegData(16 to 31)) then
            wd5TPID2Match <= '1';
          else
            wd5TPID2Match <= '0';            
          end if;
          if (RxLLinkClkDPMemRdData(31 downto 16)  = Tpid1RegData(0 to 15)) then
            wd5TPID3Match <= '1';
          else
            wd5TPID3Match <= '0';            
          end if;
          wd5VID          <= RxLLinkClkDPMemRdData(11 downto 0);
        end if;
      end if;
    end if;
  end process;
   
  RX_LL_CLK_CAPTURE_FOOTER_WORDS_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        footWord3 <= (others => '0');
        footWord4 <= (others => '0');
        footWord5 <= (others => '0');
        footWord6 <= (others => '0');
        footWord7 <= (others => '0');
      else
        if (rxLlRdSm_Cs = READ_WORD_2) then
          footWord4(24 to 31)  <= rdWord1(4 to 11);
          footWord4(16 to 23)  <= rdWord1(12 to 19);
          footWord4(8 to 15)   <= rdWord1(20 to 27);
          footWord4(0 to 7)    <= rdWord1(28 to 35);
        end if;
        if (rxLlRdSm_Cs = READ_WORD_3) then
          footWord3(24 to 31) <= rdWord2(4 to 11);
          footWord3(16 to 23) <= rdWord2(12 to 19);
        end if;
        if (rxLlRdSm_Cs = READ_WORD_5) then
          footWord6(0 to 15) <= rdWord4(4 to 19);
          footWord7(0 to 15) <= rdWord4(20 to 35);
        end if;
        if (rxLlRdSm_Cs = EOP or rxLlRdSm_Cs = SPECIAL_EOP) and (veryShortFrame = '0')  then
            footWord5(31)      <= rxLLinkClkDPMemRdData_d1(31);
            footWord5(30)      <= rxLLinkClkDPMemRdData_d1(30);
            footWord5(29)      <= rxLLinkClkDPMemRdData_d1(29);
            footWord5(0 to 14) <= rxLLinkClkDPMemRdData_d1(25 downto 11);
        elsif (rxLlRdSm_Cs = CHECK_TPID_1) and (veryShortFrame = '1')  then
            footWord5(31)      <= rxLLinkClkDPMemRdData_d1(31);
            footWord5(30)      <= rxLLinkClkDPMemRdData_d1(30);
            footWord5(29)      <= rxLLinkClkDPMemRdData_d1(29);
            footWord5(0 to 14) <= rxLLinkClkDPMemRdData_d1(25 downto 11);
        end if;
        if (rxLlRdSm_Cs = FOOT_2) then
          footWord7(18 to 31) <= rxLlClkFrameLengthBytes;
        end if;
      end if;
    end if;
  end process;

  LOCALLINK_IN_PROG_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        localLinkTransInProg  <= '0';
      else
        if (fifoDataOut(0) = '0' and fifoEmpty = '0') then -- SOF is low
          localLinkTransInProg <= '1';
        elsif (fifoDataOut(3) = '0' and fifoEmpty = '0' and TemacLL_DST_RDY_n = '0') then -- EOF is low
          localLinkTransInProg <= '0';
        end if;
      end if;
    end if;
  end process;                        

  fifoRdEn <= not(TemacLL_DST_RDY_n);
  fifoRdEnMod <= fifoRdEn or LLTemac_Rst;

  TemacLL_SOF_n <= fifoDataOut(0) when (fifoEmpty = '0') else
                   '1';
  TemacLL_SOP_n <= fifoDataOut(1) when (fifoEmpty = '0' and localLinkTransInProg = '1') else
                   '1';
  TemacLL_EOP_n <= fifoDataOut(2) when (fifoEmpty = '0' and localLinkTransInProg = '1') else
                   '1';
  TemacLL_EOF_n <= fifoDataOut(3) when (fifoEmpty = '0' and localLinkTransInProg = '1') else
                   '1';
  TemacLL_REM   <= fifoDataOut(4 to 7) when (fifoEmpty = '0' and localLinkTransInProg = '1') else
                   "0000";

  TemacLL_Data        <= fifoDataOut(8 to 39);
  TemacLL_SRC_RDY_n   <= fifoEmpty;
       
  RxLLinkClkDPMemAddr(C_MEM_DEPTH downto 0) <= zeroMask   when rxLlClkRdNextAvailable = '1'  else -- 0 is BRAM address of next avail frame to be processed ptr
                                               rxLlClkRdAddrCntr;
  RxLLinkClkDPMemWrEn(0) <= '0';
  RxLLinkClkDPMemWrData(35 downto 0) <= (others => '0');
 
  RX_LL_CLK_CAPTURE_MEM_PTR_COLLISION_ERR_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        RxLLinkRdMemPtrErr  <= '0';
      elsif (rxLlClkLastProcessed_d = rxLlClkNextAvailable) then
        RxLLinkRdMemPtrErr  <= '1';
      end if;
    end if;
  end process;

  RX_LL_CLK_CAPTURE_FRAME_LENGTH_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rxLlClkFrameLengthBytes  <= (others => '0');
      else
        if ((rxLlClkRdFrameLengthDetctPulse = '1' and rxLlRdSm_Cs = RD_FRAME_FROM_MEM) or
            (rxLlClkRdFrameLengthDetctPulse = '1' and rxLlRdSm_Cs = READ_WORD_5) or
            (rxLlClkRdFrameLengthDetctPulse = '1' and rxLlRdSm_Cs = CHECK_TPID_1)) then
          rxLlClkFrameLengthBytes  <= RxLLinkClkDPMemRdData(13 downto 0);
        elsif (incByteCntBy4_d = '1'and rxLlRdSm_Cs = FOOT_0) then
          rxLlClkFrameLengthBytes <= rxLlClkFrameLengthBytes + 4;
        elsif (decByteCntBy4_d = '1'and rxLlRdSm_Cs = FOOT_0) then
          rxLlClkFrameLengthBytes <= rxLlClkFrameLengthBytes - 4;                  
        end if;
      end if;
    end if;
  end process;

  RX_LL_CLK_RD_PTR_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rxLlClkNextAvailable  <= twoMask;
      else 
        if (rxLlClkRdNextAvailable = '1') then
          rxLlClkNextAvailable  <= RxLLinkClkDPMemRdData(C_MEM_DEPTH downto 0);
        end if;
      end if;
    end if;
  end process;

  incrementRdAddrCntr <= '1' when (((rxLlRdSm_Cs = RD_FRAME_FROM_MEM) and (fifoAlmostFull = '0')) or 
                                     rxLlRdSm_Cs = ALMOST_FULL_WAIT3 or 
                                     rxLlRdSm_Cs = ALMOST_FULL_WAIT4 or
                                     rxLlRdSm_Cs = SEND_WD5TRANS or 
                                     rxLlRdSm_Cs = SEND_WD5 or 
                                     rxLlRdSm_Cs = READ_WORD_1 or 
                                     rxLlRdSm_Cs = PAUSE_1  or 
                                     rxLlRdSm_Cs = READ_WORD_2 or 
                                     rxLlRdSm_Cs = READ_WORD_3 or 
                                     rxLlRdSm_Cs = READ_WORD_4) else
                         '0';

  decrementRdAddrCntr <= '1' when ((rxLlRdSm_Cs = EOP) or 
                                   (rxLlRdSm_Cs = FOOT_0) or
                                   (rxLlRdSm_Cs = ALMOST_FULL_WAIT1)
                                   ) else
                         '0';

  RX_LL_CLK_RD_ADDR_CNTR_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rxLlClkRdAddrCntr    <= twoMask;
      elsif (rxLlClkRdAddrCntrLd = '1') then
        if (not(rxLlClkLastProcessed_d = fullMask)) then
          rxLlClkRdAddrCntr  <= rxLlClkLastProcessed_d+1;
        else
          rxLlClkRdAddrCntr  <= oneMask;
        end if;
      else
        if (incrementRdAddrCntr = '1') then
          if (not(rxLlClkRdAddrCntr = fullMask)) then
            rxLlClkRdAddrCntr  <= rxLlClkRdAddrCntr + 1;
          elsif (rxLlClkRdAddrCntr = fullMask) then
            rxLlClkRdAddrCntr  <= oneMask;
          end if;
        elsif (decrementRdAddrCntr = '1') then
          if (not(rxLlClkRdAddrCntr = oneMask)) then
            rxLlClkRdAddrCntr  <= rxLlClkRdAddrCntr - 1;
          elsif (rxLlClkRdAddrCntr = oneMask) then
            rxLlClkRdAddrCntr  <= fullMask;
          end if;
        end if;
      end if;
    end if;
  end process;
   
  RX_LL_CLK_CHK_PTRS_AT_START_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rxLlClkMemNotEmptyBeforeStart  <= '0';
      else
        if (rxLlRdSm_Cs = WAIT_FOR_FRAME_AVAIL) then
          if (rxLlClkNextAvailable = oneMask and rxLlClkLastProcessed_d = fullMask) then
            rxLlClkMemNotEmptyBeforeStart  <= '0';
          elsif (rxLlClkLastProcessed_d = (rxLlClkNextAvailable - 1)) then
            rxLlClkMemNotEmptyBeforeStart  <= '0';
          else
            rxLlClkMemNotEmptyBeforeStart  <= '1';
          end if;
        else
          rxLlClkMemNotEmptyBeforeStart  <= '0';
        end if;
      end if;
    end if;
  end process;

  RX_LL_CLK_CHK_PTRS_DURING_RD_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rxLlClkMemEmptyDuringRd  <= '0';
      else
        if (rxLlRdSm_Cs = RD_FRAME_FROM_MEM or 
            rxLlRdSm_Cs = READ_WORD_1 or 
            rxLlRdSm_Cs = PAUSE_1 or 
            rxLlRdSm_Cs = READ_WORD_2 or 
            rxLlRdSm_Cs = READ_WORD_3 or 
            rxLlRdSm_Cs = READ_WORD_4 or 
            rxLlRdSm_Cs = READ_WORD_5) then
          if (rxLlClkNextAvailable = oneMask and rxLlClkRdAddrCntr = fullMask) then
            rxLlClkMemEmptyDuringRd  <= '1';
          elsif ((rxLlRdSm_Cs = RD_FRAME_FROM_MEM or 
                  rxLlRdSm_Cs = READ_WORD_1 or 
                  rxLlRdSm_Cs = PAUSE_1  or 
                  rxLlRdSm_Cs = READ_WORD_2 or 
                  rxLlRdSm_Cs = READ_WORD_3 or 
                  rxLlRdSm_Cs = READ_WORD_4 or 
                  rxLlRdSm_Cs = READ_WORD_5) and 
                  rxLlClkRdAddrCntr = (rxLlClkNextAvailable - 1)) then
            rxLlClkMemEmptyDuringRd  <= '1';
          else
            rxLlClkMemEmptyDuringRd  <= '0';
          end if;
        else
          rxLlClkMemEmptyDuringRd  <= '0';
        end if;
      end if;
    end if;
  end process;
  
  ----------------------------------------------------------------------------
  -- Rx LocalLink Read State Machine
  -- RXLLRDSM_REGS_PROCESS: registered process of the state machine
  -- RXLLRDSM_CMB_PROCESS:  combinatorial next-state logic
  ----------------------------------------------------------------------------
   
  RXLLRDSM_REGS_PROCESS: process (LLTemac_Clk )
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        RxLlRdSm_Cs            <= PWR_UP_INIT_LAST_PROC;
        rxLlClkLastProcessed_d <= rxLlClkLastProcessed;
        decByteCntBy4_d        <= '0';
        incByteCntBy4_d        <= '0';
      else
        RxLlRdSm_Cs            <= RxLlRdSm_Ns;
        rxLlClkLastProcessed_d <= rxLlClkLastProcessed;
        decByteCntBy4_d        <= decByteCntBy4;
        incByteCntBy4_d        <= incByteCntBy4;
      end if;
    end if;
  end process;
  
  RXLLRDSM_CMB_PROCESS: process (
                                RxLlRdSm_Cs,
                                rxLlClkLastProcessed_d,
                                decByteCntBy4_d,
                                incByteCntBy4_d,
                                TemacLL_DST_RDY_n,
                                rxLlClkMemNotEmptyBeforeStart,
                                rxLlClkMemEmptyDuringRd,
                                rxLlClkRdFrameLengthDetct,
                                rxLlClkNextAvailable,
                                oneMask,
                                twoMask,
                                rxLlClkRdAddrCntr,
                                fifoEmpty,
                                fifoAlmostFull,
                                strpEnabled,
                                transEnabled,
                                tagEnabled,
                                veryShortFrame
                               )
  begin

    rxLlClkLastProcessed   <= rxLlClkLastProcessed_d;
    decByteCntBy4          <= decByteCntBy4_d;
    incByteCntBy4          <= incByteCntBy4_d;
    rxLlClkRdNextAvailable <= '0';
    rxLlClkRdAddrCntrLd    <= '0';
    rdWord1WrEn            <= '0';
    rdWord2WrEn            <= '0';
    rdWord3WrEn            <= '0';
    rdWord4WrEn            <= '0';
    rdWord5WrEn            <= '0';
    
    case RxLlRdSm_Cs is
      
      when PWR_UP_INIT_LAST_PROC =>
        rxLlClkLastProcessed <= oneMask;
        decByteCntBy4          <= '0';
        incByteCntBy4          <= '0';
        rxLlClkRdNextAvailable <= '1';
        rxLlClkRdAddrCntrLd    <= '1';
        RxLlRdSm_Ns <= PWR_UP_WAIT_INIT_DONE;
      
      when PWR_UP_WAIT_INIT_DONE =>
        rxLlClkLastProcessed <= oneMask;
        decByteCntBy4          <= '0';
        incByteCntBy4          <= '0';
        rxLlClkRdNextAvailable <= '1';
        rxLlClkRdAddrCntrLd    <= '1';
        if (rxLlClkNextAvailable = twoMask) then
          RxLlRdSm_Ns <= WAIT_FOR_FRAME_AVAIL;
        else
          RxLlRdSm_Ns <= PWR_UP_WAIT_INIT_DONE;
        end if;

      when READ_NEXT_AVAIL_PTR =>
        decByteCntBy4          <= '0';
        incByteCntBy4          <= '0';
        rxLlClkRdNextAvailable <= '1';
        rxLlClkRdAddrCntrLd    <= '1';
        RxLlRdSm_Ns <= READ_NEXT_AVAIL_PTR2;

      when READ_NEXT_AVAIL_PTR2 =>
        decByteCntBy4          <= '0';
        incByteCntBy4          <= '0';
        rxLlClkRdNextAvailable <= '1';
        rxLlClkRdAddrCntrLd    <= '1';
        RxLlRdSm_Ns <= READ_NEXT_AVAIL_PTR3;

      when READ_NEXT_AVAIL_PTR3 =>
        rxLlClkRdNextAvailable <= '1';
        rxLlClkRdAddrCntrLd    <= '1';
        RxLlRdSm_Ns <= WAIT_FOR_FRAME_AVAIL;

      when WAIT_FOR_FRAME_AVAIL =>
        rxLlClkRdNextAvailable <= '1';
        rxLlClkRdAddrCntrLd    <= '1';
        if (rxLlClkMemNotEmptyBeforeStart = '1') then
          RxLlRdSm_Ns <= PAUSE_1;
        else
          RxLlRdSm_Ns <= WAIT_FOR_FRAME_AVAIL;
        end if;

      when PAUSE_1 =>
        RxLlRdSm_Ns <= READ_WORD_1;
                
      when READ_WORD_1 =>
        rdWord1WrEn <= '1';
        RxLlRdSm_Ns <= READ_WORD_2;

      when READ_WORD_2 =>
        rdWord2WrEn <= '1';
        RxLlRdSm_Ns <= READ_WORD_3;

      when READ_WORD_3 =>
        rdWord3WrEn <= '1';
        RxLlRdSm_Ns <= READ_WORD_4;

      when READ_WORD_4 =>
        rdWord4WrEn <= '1';
        if (rxLlClkRdFrameLengthDetct = '1') then
          RxLlRdSm_Ns <= CHECK_TPID_1;
        else
          RxLlRdSm_Ns <= READ_WORD_5;
        end if;

      when READ_WORD_5 =>
        rdWord5WrEn <= '1';
        RxLlRdSm_Ns <= CHECK_TPID_1;

      when CHECK_TPID_1 =>
        RxLlRdSm_Ns <= CHECK_TPID_2;

      when CHECK_TPID_2 =>
        RxLlRdSm_Ns <= GET_BRAM_WD4;

      when GET_BRAM_WD4 =>
        RxLlRdSm_Ns <= GET_BRAM_WD5;

      when GET_BRAM_WD5 =>
        RxLlRdSm_Ns <= WAIT_FOR_FIFO_EMPTY;

      when WAIT_FOR_FIFO_EMPTY =>
        if (fifoEmpty = '1') then
          RxLlRdSm_Ns <= SOF;
        else
          RxLlRdSm_Ns <= WAIT_FOR_FIFO_EMPTY;
        end if;

      when SOF =>
          RxLlRdSm_Ns <= SEND_WD1;

      when SEND_WD1 =>
          RxLlRdSm_Ns <= SEND_WD2;

      when SEND_WD2 =>
          RxLlRdSm_Ns <= SEND_WD3;

      when SEND_WD3 =>
          if(strpEnabled = '0' and transEnabled = '0' and tagEnabled = '0') then
            RxLlRdSm_Ns <= SEND_WD4;        
          elsif(strpEnabled = '0' and transEnabled = '0' and tagEnabled = '1') then
            RxLlRdSm_Ns <= SEND_TAG;
            incByteCntBy4 <= '1';
          elsif(strpEnabled = '0' and transEnabled = '1' and tagEnabled = '0') then
            RxLlRdSm_Ns <= SEND_WD4TRANS;
          elsif(strpEnabled = '0' and transEnabled = '1' and tagEnabled = '1') then
            RxLlRdSm_Ns <= SEND_TAG;
            incByteCntBy4 <= '1';
          elsif(strpEnabled = '1' and transEnabled = '0' and tagEnabled = '0') then
            RxLlRdSm_Ns <= SEND_WD5;
            decByteCntBy4 <= '1';
          elsif(strpEnabled = '1' and transEnabled = '0' and tagEnabled = '1') then
            RxLlRdSm_Ns <= SEND_TAG;
          elsif(strpEnabled = '1' and transEnabled = '1' and tagEnabled = '0') then
            RxLlRdSm_Ns <= SEND_WD5TRANS;
            decByteCntBy4 <= '1';
          elsif(strpEnabled = '1' and transEnabled = '1' and tagEnabled = '1') then
            RxLlRdSm_Ns <= SEND_TAG;
          else
            RxLlRdSm_Ns <= PWR_UP_INIT_LAST_PROC;
          end if;

      when SEND_WD4 =>
          if (veryShortFrame = '1') then
            RxLlRdSm_Ns <= SPECIAL_EOP;
          else
            RxLlRdSm_Ns <= SEND_WD5;        
          end if;

      when SEND_WD4TRANS =>
          RxLlRdSm_Ns <= SEND_WD5;        

      when SEND_WD5 =>
          if (ShortFrame = '1') then
            RxLlRdSm_Ns <= SPECIAL_EOP;
          else
            RxLlRdSm_Ns <= RD_FRAME_FROM_MEM;        
          end if;

      when SEND_WD5TRANS =>
            RxLlRdSm_Ns <= RD_FRAME_FROM_MEM;        

      when SEND_TAG =>
          if(strpEnabled = '0' and transEnabled = '0' and tagEnabled = '1') then
            RxLlRdSm_Ns <= SEND_WD4;
          elsif(strpEnabled = '0' and transEnabled = '1' and tagEnabled = '1') then
            RxLlRdSm_Ns <= SEND_WD4TRANS;
          elsif(strpEnabled = '1' and transEnabled = '0' and tagEnabled = '1') then
            RxLlRdSm_Ns <= SEND_WD5;
          elsif(strpEnabled = '1' and transEnabled = '1' and tagEnabled = '1') then
            RxLlRdSm_Ns <= SEND_WD5TRANS;
          else
            RxLlRdSm_Ns <= PWR_UP_INIT_LAST_PROC;
          end if;

      when RD_FRAME_FROM_MEM =>
        rxLlClkLastProcessed <= rxLlClkRdAddrCntr;
        if (rxLlClkRdFrameLengthDetct = '1' and fifoEmpty = '0'and fifoAlmostFull = '0') then
          RxLlRdSm_Ns <= EOP;
        elsif (rxLlClkRdFrameLengthDetct = '1' and fifoEmpty = '0'and fifoAlmostFull = '1') then
          RxLlRdSm_Ns <= SPECIAL_EOP;
        elsif (fifoAlmostFull = '1') then
          RxLlRdSm_Ns <= ALMOST_FULL_WAIT1;
        else
          RxLlRdSm_Ns <= RD_FRAME_FROM_MEM;
        end if;

      when ALMOST_FULL_WAIT1 =>
        RxLlRdSm_Ns <= ALMOST_FULL_WAIT2;

      when ALMOST_FULL_WAIT2 =>
        if (fifoAlmostFull = '0') then
          RxLlRdSm_Ns <= ALMOST_FULL_WAIT3;
        else
          RxLlRdSm_Ns <= ALMOST_FULL_WAIT2;
        end if;

      when ALMOST_FULL_WAIT3 =>
        RxLlRdSm_Ns <= ALMOST_FULL_WAIT4;

      when ALMOST_FULL_WAIT4 =>
        RxLlRdSm_Ns <= RD_FRAME_FROM_MEM;

      when SPECIAL_EOP =>
          RxLlRdSm_Ns <= FOOT_0;

      when EOP =>
          RxLlRdSm_Ns <= FOOT_0;

      when FOOT_0 =>
          RxLlRdSm_Ns <= FOOT_1;

      when FOOT_1 =>
          RxLlRdSm_Ns <= FOOT_2;

      when FOOT_2 =>
          RxLlRdSm_Ns <= FOOT_3;

      when FOOT_3 =>
          RxLlRdSm_Ns <= FOOT_4;

      when FOOT_4 =>
          RxLlRdSm_Ns <= FOOT_5;

      when FOOT_5 =>
          RxLlRdSm_Ns <= FOOT_6;

      when FOOT_6 =>
          RxLlRdSm_Ns <= EOF;

      when EOF =>
        rxLlClkLastProcessed <= rxLlClkRdAddrCntr;
        RxLlRdSm_Ns <= WRITE_LAST_PROC;

      when WRITE_LAST_PROC =>
        RxLlRdSm_Ns <= WAIT_FOR_FIFO_EMPTY2;

      when WAIT_FOR_FIFO_EMPTY2 =>
        if (fifoEmpty = '1') then
          RxLlRdSm_Ns <= READ_NEXT_AVAIL_PTR;
        else
          RxLlRdSm_Ns <= WAIT_FOR_FIFO_EMPTY2;
        end if;

      when others   => 
        RxLlRdSm_Ns <= PWR_UP_INIT_LAST_PROC;
    end case;
  end process;                    

  NOT_V6_OR_S6: if((equalIgnoringCase(C_FAMILY, "virtex6")= FALSE) and (equalIgnoringCase(C_FAMILY, "spartan6")= FALSE)) generate
  begin
    ELASTIC_FIFO : fifo_generator_v4_3 
      generic map(
    C_COMMON_CLOCK                =>  1,                                           
    C_COUNT_TYPE                  =>  0,                                           
    C_DATA_COUNT_WIDTH            =>  6,
    C_DEFAULT_VALUE               =>  "BlankString",
    C_DIN_WIDTH                   =>  40,                          
    C_DOUT_RST_VAL                =>  "0",                                         
    C_DOUT_WIDTH                  =>  40,                           
    C_ENABLE_RLOCS                =>  0,                     -- not supported      
    C_FAMILY                      =>  C_FAMILY,                                    
    C_HAS_ALMOST_EMPTY            =>  0,                                           
    C_HAS_ALMOST_FULL             =>  1,                                           
    C_HAS_BACKUP                  =>  0,                                           
    C_HAS_DATA_COUNT              =>  1,                                
    C_HAS_MEMINIT_FILE            =>  0,                                           
    C_HAS_OVERFLOW                =>  0,                                
    C_HAS_RD_DATA_COUNT           =>  0,              -- not used for sync FIFO    
    C_HAS_RD_RST                  =>  0,              -- not used for sync FIFO    
    C_HAS_RST                     =>  0,              -- not used for sync FIFO    
    C_HAS_SRST                    =>  1,                                           
    C_HAS_UNDERFLOW               =>  0,                                
    C_HAS_VALID                   =>  0,                                
    C_HAS_WR_ACK                  =>  0,                                
    C_HAS_WR_DATA_COUNT           =>  0,              -- not used for sync FIFO    
    C_HAS_WR_RST                  =>  0,              -- not used for sync FIFO    
    C_IMPLEMENTATION_TYPE         =>  0,                                 
    C_INIT_WR_PNTR_VAL            =>  0,                                           
    C_MEMORY_TYPE                 =>  2,                                 
    C_MIF_FILE_NAME               =>  "BlankString",                               
    C_OPTIMIZATION_MODE           =>  0,                                           
    C_OVERFLOW_LOW                =>  0,                                
    C_PRELOAD_REGS                =>  1,     -- 1 = first word fall through                                      
    C_PRELOAD_LATENCY             =>  0,  -- 0 = first word fall through                                          
    C_PRIM_FIFO_TYPE              =>  "512x36", -- only used for V5 Hard FIFO      
    C_PROG_EMPTY_THRESH_ASSERT_VAL=>  4,                                           
    C_PROG_EMPTY_THRESH_NEGATE_VAL=>  5,                                           
    C_PROG_EMPTY_TYPE             =>  0,                                           
    C_PROG_FULL_THRESH_ASSERT_VAL =>  29,                 
    C_PROG_FULL_THRESH_NEGATE_VAL =>  28,                 
    C_PROG_FULL_TYPE              =>  1,                                           
    C_RD_DATA_COUNT_WIDTH         =>  6,                          
    C_RD_DEPTH                    =>  32,                                   
    C_RD_FREQ                     =>  1,                                           
    C_RD_PNTR_WIDTH               =>  5,                          
    C_UNDERFLOW_LOW               =>  0,                                
    C_USE_DOUT_RST                =>  1,                                           
    C_USE_EMBEDDED_REG            =>  0,                                           
    C_USE_FIFO16_FLAGS            =>  0,                                           
    C_USE_FWFT_DATA_COUNT         =>  1,                                           
    C_VALID_LOW                   =>  0,                                
    C_WR_ACK_LOW                  =>  0,                                
    C_WR_DATA_COUNT_WIDTH         =>  6,                          
    C_WR_DEPTH                    =>  32,                                   
    C_WR_FREQ                     =>  1,                                           
    C_WR_PNTR_WIDTH               =>  5,                          
    C_WR_RESPONSE_LATENCY         =>  1,                                           
    C_USE_ECC                     =>  0,                                           
    C_FULL_FLAGS_RST_VAL          =>  1,                                           
    C_HAS_INT_CLK                 =>  0,                                            
    C_MSGON_VAL                   =>  1
    )
  port map(
    CLK                       =>  LLTemac_Clk,           
    DIN                       =>  fifoDataIn,            
    RD_EN                     =>  fifoRdEnMod,              
    SRST                      =>  LLTemac_Rst,           
    WR_EN                     =>  fifoWrEn,              
    ALMOST_FULL               =>  open,  
    DATA_COUNT                =>  fifoDataCount,             
    DOUT                      =>  fifoDataOut,           
    EMPTY                     =>  fifoEmpty,             
    FULL                      =>  fifoFull,         
    PROG_FULL                 =>  open              
    );
  end generate NOT_V6_OR_S6;

  YES_V6_OR_S6: if((equalIgnoringCase(C_FAMILY, "virtex6")= TRUE) or (equalIgnoringCase(C_FAMILY, "spartan6")= TRUE)) generate
  begin
    ELASTIC_FIFO : fifo_generator_v6_1
      generic map(
    C_COMMON_CLOCK                =>  1,                                           
    C_COUNT_TYPE                  =>  0,                                           
    C_DATA_COUNT_WIDTH            =>  6,
    C_DEFAULT_VALUE               =>  "BlankString",
    C_DIN_WIDTH                   =>  40,                          
    C_DOUT_RST_VAL                =>  "0",                                         
    C_DOUT_WIDTH                  =>  40,                           
    C_ENABLE_RLOCS                =>  0,                     -- not supported      
    C_FAMILY                      =>  C_FAMILY,                                    
    C_HAS_ALMOST_EMPTY            =>  0,                                           
    C_HAS_ALMOST_FULL             =>  1,                                           
    C_HAS_BACKUP                  =>  0,                                           
    C_HAS_DATA_COUNT              =>  1,                                
    C_HAS_MEMINIT_FILE            =>  0,                                           
    C_HAS_OVERFLOW                =>  0,                                
    C_HAS_RD_DATA_COUNT           =>  0,              -- not used for sync FIFO    
    C_HAS_RD_RST                  =>  0,              -- not used for sync FIFO    
    C_HAS_RST                     =>  0,              -- not used for sync FIFO    
    C_HAS_SRST                    =>  1,                                           
    C_HAS_UNDERFLOW               =>  0,                                
    C_HAS_VALID                   =>  0,                                
    C_HAS_WR_ACK                  =>  0,                                
    C_HAS_WR_DATA_COUNT           =>  0,              -- not used for sync FIFO    
    C_HAS_WR_RST                  =>  0,              -- not used for sync FIFO    
    C_IMPLEMENTATION_TYPE         =>  0,                                 
    C_INIT_WR_PNTR_VAL            =>  0,                                           
    C_MEMORY_TYPE                 =>  2,                                 
    C_MIF_FILE_NAME               =>  "BlankString",                               
    C_OPTIMIZATION_MODE           =>  0,                                           
    C_OVERFLOW_LOW                =>  0,                                
    C_PRELOAD_REGS                =>  1,     -- 1 = first word fall through                                      
    C_PRELOAD_LATENCY             =>  0,  -- 0 = first word fall through                                          
    C_PRIM_FIFO_TYPE              =>  "512x36", -- only used for V5 Hard FIFO      
    C_PROG_EMPTY_THRESH_ASSERT_VAL=>  4,                                           
    C_PROG_EMPTY_THRESH_NEGATE_VAL=>  5,                                           
    C_PROG_EMPTY_TYPE             =>  0,                                           
    C_PROG_FULL_THRESH_ASSERT_VAL =>  29,                 
    C_PROG_FULL_THRESH_NEGATE_VAL =>  28,                 
    C_PROG_FULL_TYPE              =>  1,                                           
    C_RD_DATA_COUNT_WIDTH         =>  6,                          
    C_RD_DEPTH                    =>  32,                                   
    C_RD_FREQ                     =>  1,                                           
    C_RD_PNTR_WIDTH               =>  5,                          
    C_UNDERFLOW_LOW               =>  0,                                
    C_USE_DOUT_RST                =>  1,                                           
    C_USE_EMBEDDED_REG            =>  0,                                           
    C_USE_FIFO16_FLAGS            =>  0,                                           
    C_USE_FWFT_DATA_COUNT         =>  1,                                           
    C_VALID_LOW                   =>  0,                                
    C_WR_ACK_LOW                  =>  0,                                
    C_WR_DATA_COUNT_WIDTH         =>  6,                          
    C_WR_DEPTH                    =>  32,                                   
    C_WR_FREQ                     =>  1,                                           
    C_WR_PNTR_WIDTH               =>  5,                          
    C_WR_RESPONSE_LATENCY         =>  1,                                           
    C_USE_ECC                     =>  0,                                           
    C_FULL_FLAGS_RST_VAL          =>  1,                                           
    C_HAS_INT_CLK                 =>  0,                                            
    C_MSGON_VAL                   =>  1
    )
  port map(
    CLK                       =>  LLTemac_Clk,            
    DIN                       =>  fifoDataIn,             
    RD_EN                     =>  fifoRdEnMod,               
    SRST                      =>  LLTemac_Rst,            
    WR_EN                     =>  fifoWrEn,               
    ALMOST_FULL               =>  open, 
    DATA_COUNT                =>  fifoDataCount,               
    DOUT                      =>  fifoDataOut,            
    EMPTY                     =>  fifoEmpty,              
    FULL                      =>  fifoFull,          
    PROG_FULL                 =>  open               
    );
  end generate YES_V6_OR_S6;

process(fifoDataCount, fifoEmpty)
  begin
    fifoAlmostFull  <= '0';
    if(conv_integer(fifoDataCount)>21 and fifoEmpty='0') then
      fifoAlmostFull <= '1';
    end if;
end process;
     
--  ELASTIC_FIFO : entity proc_common_v3_00_a.sync_fifo_fg
--    generic map (
--      C_FAMILY             => C_FAMILY, 
--      C_DCOUNT_WIDTH       => 6,        
--      C_ENABLE_RLOCS       => 0,        
--      C_HAS_DCOUNT         => 1,        
--      C_HAS_RD_ACK         => 0,        
--      C_HAS_RD_ERR         => 0,        
--      C_HAS_WR_ACK         => 0,        
--      C_HAS_WR_ERR         => 0,        
--      C_MEMORY_TYPE        => 2,        
--      C_PORTS_DIFFER       => 0,        
--      C_RD_ACK_LOW         => 0,        
--      C_HAS_ALMOST_FULL    => 0,        
--      C_READ_DATA_WIDTH    => 40,       
--      C_READ_DEPTH         => 32,       
--      C_RD_ERR_LOW         => 0,        
--      C_WR_ACK_LOW         => 0,        
--      C_WR_ERR_LOW         => 0,        
--      C_PRELOAD_REGS       => 1,        
--      C_PRELOAD_LATENCY    => 0,        
--      C_WRITE_DATA_WIDTH   => 40,       
--      C_WRITE_DEPTH        => 32        
--      )
--    port map (
--      Clk          => LLTemac_Clk,      
--      Sinit        => LLTemac_Rst,      
--      Din          => fifoDataIn,       
--      Wr_en        => fifoWrEn,         
--      Rd_en        => FifoRdEn,         
--      Dout         => fifoDataOut,      
--      Full         => fifoFull,         
--      Empty        => fifoEmpty,        
--      Rd_ack       => open,             
--      Wr_ack       => open,             
--      Rd_err       => open,             
--      Wr_err       => open,             
--      Data_count   => fifoDataCount     
--      );

    
  preRegFifoSOFIn <= '0' when rxLlRdSm_Cs = SOF else 
                     '1';

  preRegFifoSOPIn <= '0' when rxLlRdSm_Cs = SEND_WD1 else 
                     '1';

  preRegFifoEOPIn <= '0' when (rxLlClkRdFrameLengthDetct = '1') and (rxLlRdSm_Cs = RD_FRAME_FROM_MEM or
                                                               rxLlRdSm_Cs = ALMOST_FULL_WAIT1 or
                                                               (rxLlRdSm_Cs = SEND_WD5 and shortFrame = '1') or
                                                               (rxLlRdSm_Cs = SEND_WD4 and veryShortFrame = '1')) else 
                     '1';

  preRegFifoEOFIn <= '0' when rxLlRdSm_Cs = FOOT_6 else 
                     '1';

  preRegFifoRemDataIn <= not(rdWord4(0)) & 
                         not(rdWord4(1)) & 
                         not(rdWord4(2)) & 
                         not(rdWord4(3))                   when (rxLlRdSm_Cs = SEND_WD4) and 
                                                                (veryShortFrame = '1')                 else -- word 4 is last data
                         
                         not(rdWord5(0)) & 
                         not(rdWord5(1)) & 
                         not(rdWord5(2)) & 
                         not(rdWord5(3))                   when (rxLlRdSm_Cs = SEND_WD5) and 
                                                                (shortFrame = '1')                     else -- word 5 is last data
                         
                         not(RxLLinkClkDPMemRdData(35)) & 
                         not(RxLLinkClkDPMemRdData(34)) & 
                         not(RxLLinkClkDPMemRdData(33)) & 
                         not(RxLLinkClkDPMemRdData(32))    when (rxLlRdSm_Cs = ALMOST_FULL_WAIT1) or 
                                                                (rxLlRdSm_Cs = RD_FRAME_FROM_MEM)     else -- data field
                                                                
                         "0000";                                                                            -- idle, footer field, or first 5 words
                    
  preRegFifoWrEn <= '1'  when (rxLlRdSm_Cs = SOF or 
                               rxLlRdSm_Cs = RD_FRAME_FROM_MEM or
                               rxLlRdSm_Cs = SEND_WD1 or 
                               rxLlRdSm_Cs = SEND_WD2 or 
                               rxLlRdSm_Cs = SEND_WD3 or 
                               rxLlRdSm_Cs = SEND_WD4 or 
                               rxLlRdSm_Cs = SEND_WD5 or 
                               rxLlRdSm_Cs = SEND_WD4TRANS or
                               rxLlRdSm_Cs = SEND_WD5TRANS or
                               rxLlRdSm_Cs = SEND_TAG	   or
                               rxLlRdSm_Cs = FOOT_0 or
                               rxLlRdSm_Cs = FOOT_1 or
                               rxLlRdSm_Cs = FOOT_2 or
                               rxLlRdSm_Cs = FOOT_3 or
                               rxLlRdSm_Cs = FOOT_4 or
                               rxLlRdSm_Cs = FOOT_5 or
                               rxLlRdSm_Cs = FOOT_6 or
                               (rxLlRdSm_Cs = SPECIAL_EOP and (veryShortFrame = '1' or shortFrame = '1'))) else
                    '0';
                       
  preRegFifoDataIn(0 to 3) <= preRegFifoSOFIn & preRegFifoSOPIn & preRegFifoEOPIn & preRegFifoEOFIn;
  
  preRegFifoDataIn(4 to 7) <= preRegFifoRemDataIn;
  
  preRegFifoDataIn(8 to 39) <= (others => '0')            when rxLlRdSm_Cs = SOF or
                                                               rxLlRdSm_Cs = EOP or 
                                                               rxLlRdSm_Cs = SPECIAL_EOP or
                                                               rxLlRdSm_Cs = FOOT_0 or
                                                               rxLlRdSm_Cs = FOOT_1          else

                               "0000000000000000" & 
                               footWord3                  when rxLlRdSm_Cs = FOOT_2          else

                               footWord4                  when rxLlRdSm_Cs = FOOT_3          else
                               footWord5                  when rxLlRdSm_Cs = FOOT_4          else

                               footWord6 & 
                               "0000000000000000"         when rxLlRdSm_Cs = FOOT_5          else
                               
                               footWord7                  when rxLlRdSm_Cs = FOOT_6          else                              
                               rdWord1(4 to 35)           when rxLlRdSm_Cs = SEND_WD1        else
                               rdWord2(4 to 35)           when rxLlRdSm_Cs = SEND_WD2        else
                               rdWord3(4 to 35)           when rxLlRdSm_Cs = SEND_WD3        else
                               RtagRegData                when rxLlRdSm_Cs = SEND_TAG        else
                               
                               rdWord4(4 to 23) & 
                               wd4BRAM(0 to 11)           when rxLlRdSm_Cs = SEND_WD4TRANS   else
                               
                               rdWord4(4 to 35)           when rxLlRdSm_Cs = SEND_WD4        else
                               
                               rdWord5(4 to 23) &
                               wd5BRAM(0 to 11)           when rxLlRdSm_Cs = SEND_WD5TRANS   else
                               
                               rdWord5(4 to 35)           when rxLlRdSm_Cs = SEND_WD5        else
                               RxLLinkClkDPMemRdData(31 downto 0);


  rxLlClkRdFrameLengthDetct <= '1'  when RxLLinkClkDPMemRdData(35 downto 32) = "0000" else
                               '0';

  FRAMELENGTHDETECTPULSEGENERATE_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rxLlClkRdFrameLengthDetct_d1 <= '0';
      else
        rxLlClkRdFrameLengthDetct_d1 <= rxLlClkRdFrameLengthDetct;
      end if;
    end if;
  end process;
   
  rxLlClkRdFrameLengthDetctPulse <= rxLlClkRdFrameLengthDetct and not(rxLlClkRdFrameLengthDetct_d1);

  
  fifoDataIn <= "1101" & fifoDataIn_i(4 to 7) & rxLLinkClkDPMemRdData_d1(31 downto 0)  when  (rxLlClkRdFrameLengthDetct = '1' and (rxLlRdSm_Cs = RD_FRAME_FROM_MEM or
                                                                                                                           rxLlRdSm_Cs = ALMOST_FULL_WAIT1)) else
                "1101" & fifoDataIn_i(4 to 39)                                         when (rxLlRdSm_Cs = SPECIAL_EOP and (veryShortFrame = '1' or shortFrame = '1')) else
                fifoDataIn_i;

  FIFO_PRE_REG_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        fifoDataIn_i  <= (others => '0');
        fifoWrEn    <= '0';
      elsif (preRegFifoWrEn = '1') then 
        if (rxLlClkRdFrameLengthDetct = '1' and (rxLlRdSm_Cs = RD_FRAME_FROM_MEM)) then
          fifoDataIn_i  <= "1111" & "0000" & "00000000000000000000000000000000";
        else
          fifoDataIn_i  <= preRegFifoDataIn;
        end if;
        fifoWrEn    <= preRegFifoWrEn;
      else
        fifoWrEn    <= preRegFifoWrEn;
      end if;
    end if;
  end process;

  PIPE_DPMEM_RD_DATA_PROCESS: process (LLTemac_Clk)
  begin
    if (LLTemac_Clk'event and LLTemac_Clk = '1') then
      if (LLTemac_Rst = '1') then
        rxLLinkClkDPMemRdData_d1  <= (others => '0');
      else
        rxLLinkClkDPMemRdData_d1  <= RxLLinkClkDPMemRdData;
      end if;
    end if;
  end process;

end beh;
