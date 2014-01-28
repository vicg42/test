------------------------------------------------------------------------------
-- $Id: rx_cl_if.vhd,v 1.1.4.39 2009/11/17 07:11:34 tomaik Exp $
------------------------------------------------------------------------------
-- rx_cl_if.vhd            
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
-- Filename:        rx_cl_if.vhd
-- Version:         v3.00a
-- Description:     receive client interface to TEMAC block
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
use ieee.std_logic_arith.all;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.numeric_std.all;    

library unisim;
use unisim.vcomponents.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.coregen_comp_defs.all;
use proc_common_v3_00_a.all;
use proc_common_v3_00_a.proc_common_pkg.log2;

-- synopsys translate_off
library XilinxCoreLib;
-- synopsys translate_on

------------------------------------------------------------------------------
-- Port Declaration
------------------------------------------------------------------------------

entity rx_cl_if is
  generic (
    C_FAMILY             : string    := "virtex5";  
    C_TEMAC_TYPE         : integer   :=    0;  
      -- 0 - Virtex 5 hard TEMAC (FX, LXT, SXT devices)                
      -- 1 - Virtex 4 hard TEMAC (FX)               
      -- 2 - Soft TEMAC         
    C_TEMAC_RXFIFO       : integer   := 4096; 
    C_TEMAC_MCAST_EXTEND : integer   := 0;
    C_MEM_DEPTH          : integer   := 9 
  );

  port    (
    LLTemac_Clk           : in  std_logic;
    RxClClk_Rst           : in  std_logic;
    Rx_Cl_Clk             : in  std_logic;
    RxClClkEn             : in  std_logic;
    RxClClkFrameDropInt   : out std_logic;
    RxClClkFrameRejtInt   : out std_logic;
    RxClClkFrameAcptInt   : out std_logic;
    RxClClkMemFullInt     : out std_logic;
    PlbRegCrBrdCastRej    : in  std_logic;
    PlbRegCrMulCastRej    : in  std_logic;
    EmacClientRxBadFrame  : in  std_logic;
    EmacClientRxd         : in  std_logic_vector(7 downto 0);
    EmacClientRxdVld      : in  std_logic;
    EmacClientRxFrameDrop : in  std_logic;
    EmacClientRxGoodFrame : in  std_logic;
    EmacClientRxStatsVld  : in  std_logic;
    EmacClientRxStats     : in  std_logic_vector(6 downto 0);
    SoftEmacClientRxStats : in  std_logic_vector(27 downto 0);
    LlinkClkNewFncEnbl    : in  std_logic;
    LlinkClkEMultiFltrEnbl: in  std_logic;
    UawLRegData           : in  std_logic_vector(0 to 31);
    UawURegData           : in  std_logic_vector(16 to 31);
    RxClClkMcastAddr      : out std_logic_vector(0 to 14);
    RxClClkMcastEn        : out std_logic;
    RxClClkMcastRdData    : in  std_logic_vector(0 to 0);
    RxLLinkClkDPMemWrData : in  std_logic_vector(35 downto 0);
    RxLLinkClkDPMemRdData : out std_logic_vector(35 downto 0);
    RxLLinkClkDPMemWrEn   : in  std_logic_vector(0 downto 0);
    RxLLinkClkDPMemAddr   : in  std_logic_vector(C_MEM_DEPTH downto 0);
    RxLlClkLastProcessedGray : in std_logic_vector(C_MEM_DEPTH downto 0)
);
end rx_cl_if;

------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
--
------------------------------------------------------------------------------

architecture simulation of rx_cl_if is

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

type RXCLWRSM_TYPE is (
                     PWR_UP_INIT_LAST_PROC,
                     PWR_UP_INIT_NEXT_AVAIL,
                     WAIT_FOR_STRT_OF_FRAME,
                     RCVING_A_FRAME,
                     END_OF_FRAME_CHECK_GOOD_BAD,
                     WRITE_FRAME_LENGTH,
                     UPDATE_NEXT_AVAIL,
                     WRITE_NEXT_AVAIL
                    );

--------------------------------------------------------------------------
-- Signal Declarations
--------------------------------------------------------------------------

signal rxClClkLastProcessedGray_d1   : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkLastProcessedGray_d2   : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkLastProcessedBinary    : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkLastProcessedBinary_d1 : std_logic_vector(C_MEM_DEPTH downto 0);

signal rxClWrSm_Cs              : RXCLWRSM_TYPE;
signal rxClWrSm_Ns              : RXCLWRSM_TYPE;

signal rxClClkRxBadFrame_d1  : std_logic;
signal rxClClkRxBadFrame_d2  : std_logic;
signal rxClClkRxdVld_d1      : std_logic;
signal rxClClkRxdVld_d2      : std_logic;
signal rxClClkRxdVld_d3      : std_logic;
signal rxClClkRxdVld_d4      : std_logic;
signal rxClClkRxGoodFrame_d1 : std_logic;
signal rxClClkRxGoodFrame_d2 : std_logic;
signal rxClClkRxStatsVld_d1  : std_logic;
signal rxClClkRxStatsVld_d2  : std_logic;
signal rxClClkRxStatsVld_d3  : std_logic;
signal rxClClkRxStatsVld_d4  : std_logic;

signal rxClClkStartOfStats      : std_logic;
signal rxClClkStartOfFrame      : std_logic;
signal rxClClkEndOfStats        : std_logic;
signal rxClClkEndOfFrame        : std_logic;
signal rxClClkEndOfStats_d1     : std_logic;
signal rxClClkRxDataPacked	: std_logic_vector(35 downto 0);
signal rxClClkRxDataPackState	: std_logic_vector(1 downto 0);
signal rxClClkWriteRxDataPacked : std_logic;
signal rxClClkDPMemWrData       : std_logic_vector(35 downto 0);
signal rxClClkDPMemRdData       : std_logic_vector(35 downto 0);
signal rxClClkDPMemWrEn         : std_logic_vector(0 downto 0);
signal rxClClkDPMemAddr         : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkWrAddrCntr        : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkWrAddrCntrEn      : std_logic;
signal rxClClkWrAddrCntrLd      : std_logic;
signal rxClClkRdLastProcessed   : std_logic;
signal rxClClkRdLastProcessedAddrEn : std_logic;
signal rxClClkNextAvailable     : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkNextAvailable_d   : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkLastProcessed     : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkLastProcessedSubOne  : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkLastProcessedSubTwo  : std_logic_vector(C_MEM_DEPTH downto 0);
signal rxClClkMemFullBeforeStart: std_logic;
signal rxClClkMemFullBeforeStart_d1: std_logic;
signal rxClClkMemFullDuringWr   : std_logic;
signal rxClClkStatistics        : std_logic_vector(26 downto 0);
signal rxClClkMulticast         : std_logic;
signal rxClClkIPMulticast       : std_logic;
signal rxClClkBroadcast         : std_logic;
signal rxClClkFrameLengthBytes  : std_logic_vector(13 downto 0);
signal rxClClkFrameLengthBytesTrue  : std_logic_vector(15 downto 0);
signal rxClClkWriteRxFrameLength: std_logic;
signal rxClClkRegCrBrdCastRej   : std_logic;
signal rxClClkRegCrMulCastRej   : std_logic;
signal rxClClkRegCrBrdCastRej_d1: std_logic;
signal rxClClkRegCrMulCastRej_d1: std_logic;
signal rxClClkFrameReject       : std_logic;
signal rxClClkFrameAccept       : std_logic;
signal rxClClkMemFull           : std_logic;

signal fullMask                 : std_logic_vector(C_MEM_DEPTH downto 0);
signal fullMaskMinusOne         : std_logic_vector(C_MEM_DEPTH downto 0);
signal fullMaskMinusTwo         : std_logic_vector(C_MEM_DEPTH downto 0);
signal emptyMask                : std_logic_vector(C_MEM_DEPTH downto 0);
signal zeroMask                 : std_logic_vector(C_MEM_DEPTH downto 0);
signal oneMask                  : std_logic_vector(C_MEM_DEPTH downto 0);
signal twoMask                  : std_logic_vector(C_MEM_DEPTH downto 0);
signal zeroExtendMask36         : std_logic_vector(35 downto C_MEM_DEPTH+1);

signal emacClientRxFrameDrop_i  : std_logic;

signal emacClientRxd_d1         : std_logic_vector(7 downto 0);
signal emacClientRxdVld_d1      : std_logic;

signal emacClientRxd_d2         : std_logic_vector(7 downto 0);
signal emacClientRxdVld_d2      : std_logic;

signal extendedMulticastReject  : std_logic;

signal rxClClkMcastEn_i        : std_logic;
signal rxClClkMcastAddr_i      : std_logic_vector(0 to 14);
signal rxClClkMcastAddr_i_d    : std_logic_vector(0 to 14);

signal rxWrStateEnc            : std_logic_vector(0 to 2);
signal promiscuousFrameRecvd   : std_logic;

begin
        
  -------------------------------------------------------------------------
  -- Generate variable width address masks for checking memory pointers
  -------------------------------------------------------------------------
  GENMASK1: for I in C_MEM_DEPTH downto 0 generate
    fullMask(I) <= '1';
    emptyMask(I) <= '0';
  end generate;
  
  zeroMask         <= emptyMask;
  oneMask          <= emptyMask + 1;
  twoMask          <= emptyMask + 2;
  fullMaskMinusOne <= fullMask - 1;
  fullMaskMinusTwo <= fullMask - 2;
        
  -------------------------------------------------------------------------
  -- Synchronize gray encoded last processed pointer from LocalLink clock 
  -- domain to the receive client clock domain. reset to one at power-up
  -- skipping zero which is where the next avail pointer is
  -------------------------------------------------------------------------
  RX_CL_CLK_SYNC_LAST_PROC_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClClkLastProcessedGray_d1  <= oneMask;
        rxClClkLastProcessedGray_d2  <= oneMask;
      else
        rxClClkLastProcessedGray_d1  <= RxLlClkLastProcessedGray;
        rxClClkLastProcessedGray_d2  <= rxClClkLastProcessedGray_d1;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- Convert gray encoded last processed pointer back to binary encoded
  -------------------------------------------------------------------------
  rxClClkLastProcessedBinary <= gray_to_bin(rxClClkLastProcessedGray_d2);

  -------------------------------------------------------------------------
  -- Register binary encoded last processed pointer from local link 
  -- interface
  -------------------------------------------------------------------------
  RX_CL_CLK_REG_LAST_PROC_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClClkLastProcessedBinary_d1  <= oneMask;
      else
        rxClClkLastProcessedBinary_d1  <= rxClClkLastProcessedBinary;
      end if;
    end if;
  end process;

  COUNT_RX_BYTES_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClClkFrameLengthBytesTrue <= (others => '0');
      else
        if (RxClClkEn = '1') then             
          if ((rxClClkRxdVld_d1 = '0')and (EmacClientRxdVld = '1')) then             
            rxClClkFrameLengthBytesTrue <= (others => '0');
          elsif (rxClClkRxdVld_d1 = '1')then
            rxClClkFrameLengthBytesTrue <= rxClClkFrameLengthBytesTrue + 1;
          end if;
        end if;
      end if;
    end if;
  end process;
    
  PIPE_RX_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        emacClientRxd_d1     <= (others => '0');
        emacClientRxdVld_d1  <= '0';
        emacClientRxd_d2     <= (others => '0');
        emacClientRxdVld_d2  <= '0';
      else
        if (RxClClkEn = '1') then             
          emacClientRxd_d1     <= EmacClientRxd;
          emacClientRxdVld_d1  <= EmacClientRxdVld;
          emacClientRxd_d2     <= emacClientRxd_d1;
          emacClientRxdVld_d2  <= emacClientRxdVld_d1;
        end if;
      end if;
    end if;
  end process;

  DETECT_IP_MULTICAST_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClClkIPMulticast  <= '0';
      else
        if (RxClClkEn = '1') then             
          if (EmacClientRxd = X"5e" and emacClientRxd_d1 = X"00" and emacClientRxd_d2 = X"01" and EmacClientRxdVld = '1'and emacClientRxdVld_d1 = '1'and emacClientRxdVld_d2 = '1') then             
            rxClClkIPMulticast  <= '1';
          elsif (rxClClkEndOfStats = '1') then
            rxClClkIPMulticast  <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  GENMASK2: for I in 35 downto C_MEM_DEPTH+1 generate
    zeroExtendMask36(I) <= '0';
  end generate;
    
  rxClClkDPMemWrEn(0) <= rxClClkWriteRxDataPacked when rxClWrSm_Cs = RCVING_A_FRAME else
                    '1'                      when rxClWrSm_Cs = PWR_UP_INIT_NEXT_AVAIL else
                    '1'                      when rxClWrSm_Cs = WRITE_NEXT_AVAIL else
                    '1'                      when rxClClkWriteRxFrameLength = '1' else
                    '0';
  
  rxClClkDPMemWrData(35 downto 0) <= zeroExtendMask36 & rxClClkNextAvailable_d                       when rxClWrSm_Cs = PWR_UP_INIT_NEXT_AVAIL else
                                zeroExtendMask36 & rxClClkNextAvailable_d                       when rxClWrSm_Cs = WRITE_NEXT_AVAIL else
                                "0000" & rxClClkMulticast & rxClClkIPMulticast & rxClClkBroadcast & "0000000000000" & rxClClkFrameLengthBytesTrue(15 downto 0) when rxClClkWriteRxFrameLength = '1' else
                                --"0000" & rxClClkMulticast & rxClClkIPMulticast & rxClClkBroadcast & "000000000000000" & rxClClkFrameLengthBytes(13 downto 0) when rxClClkWriteRxFrameLength = '1' else
                                rxClClkRxDataPacked(35)&rxClClkRxDataPacked(26)&rxClClkRxDataPacked(17)&rxClClkRxDataPacked(8)&
                                rxClClkRxDataPacked(34 downto 27)&rxClClkRxDataPacked(25 downto 18)&rxClClkRxDataPacked(16 downto 9)&
                                rxClClkRxDataPacked(7 downto 0);
                                   
  rxClClkDPMemAddr(C_MEM_DEPTH downto 0) <= 
                                       zeroMask  when rxClWrSm_Cs = PWR_UP_INIT_NEXT_AVAIL else
                                       zeroMask  when rxClWrSm_Cs = WRITE_NEXT_AVAIL else
                                       rxClClkWrAddrCntr;
  
  HARD_TEMAC_STATISTICS : if (C_TEMAC_TYPE = 0 or C_TEMAC_TYPE = 1 or C_TEMAC_TYPE = 3) generate
  begin

    DETECT_FRAMEDROP_PROCESS: process (Rx_Cl_Clk)
    begin
      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          emacClientRxFrameDrop_i <= '0';
          promiscuousFrameRecvd   <= '0';
        else
          if (RxClClkEn = '1') then             
            if (rxClClkEndOfFrame = '1'and EmacClientRxFrameDrop = '1') then -- frame that normally would have been dropped was not due to promiscuous mode
              promiscuousFrameRecvd  <= '1';
            elsif (rxClClkEndOfFrame = '1'and EmacClientRxFrameDrop = '0') then -- frame received that matches address filtering
              promiscuousFrameRecvd  <= '0';
            elsif (rxClClkEndOfStats_d1 = '1') then -- used to clear out after each frame
              promiscuousFrameRecvd  <= '0';
            end if;
            if (rxClClkEndOfStats = '1'and EmacClientRxFrameDrop = '1' and promiscuousFrameRecvd  <= '0' and C_TEMAC_MCAST_EXTEND = 0) then             
              emacClientRxFrameDrop_i <= '1';
            elsif (rxClClkEndOfStats_d1 = '1') then
              emacClientRxFrameDrop_i  <= '0';
            end if;            
          end if;
        end if;
      end if;
    end process;
    
    --emacClientRxFrameDrop_i <= (EmacClientRxStatsVld and EmacClientRxFrameDrop and (not rxClClkRxdVld_d4)) when (C_TEMAC_MCAST_EXTEND = 0) else -- if RxdVld is 1 then we're in promiscuous mode so not really a frame drop
    --                            '0';
    
    RX_CL_CLK_STATS_DEMUX_PROCESS: process (Rx_Cl_Clk)
    begin
      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          rxClClkStatistics(6 downto 0)       <= (others => '0');
          rxClClkMulticast                    <= '0';        
          rxClClkBroadcast                    <= '0';   
          rxClClkFrameLengthBytes(1 downto 0) <= (others => '0');
        else
          if (RxClClkEn = '1') then        
            if (EmacClientRxStatsVld = '1' and rxClClkRxStatsVld_d1 = '0') then
              rxClClkStatistics(6 downto 0)       <= EmacClientRxStats;
              rxClClkMulticast                    <= EmacClientRxStats(4);        
              rxClClkBroadcast                    <= EmacClientRxStats(3);   
              rxClClkFrameLengthBytes(1 downto 0) <= EmacClientRxStats(6 downto 5);
            end if;
          end if;
        end if;
      end if;

      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          rxClClkStatistics(13 downto 7)      <= (others => '0');
          rxClClkFrameLengthBytes(8 downto 2) <= (others => '0');
        else
          if (RxClClkEn = '1') then             
            if (rxClClkRxStatsVld_d1 = '1' and rxClClkRxStatsVld_d2 = '0') then
              rxClClkStatistics(13 downto 7)      <= EmacClientRxStats;
              rxClClkFrameLengthBytes(8 downto 2) <= EmacClientRxStats;
            end if;
          end if;
        end if;
      end if;

      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          rxClClkStatistics(20 downto 14)      <= (others => '0');
          rxClClkFrameLengthBytes(13 downto 9) <= (others => '0');
        else
          if (RxClClkEn = '1') then             
            if (rxClClkRxStatsVld_d2 = '1' and rxClClkRxStatsVld_d3 = '0') then
              rxClClkStatistics(20 downto 14)      <= EmacClientRxStats;
              rxClClkFrameLengthBytes(13 downto 9) <= EmacClientRxStats(4 downto 0);
            end if;
          end if;
        end if;
      end if;

      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          rxClClkStatistics(26 downto 21)  <= (others => '0');
        else
          if (RxClClkEn = '1') then             
            if (rxClClkRxStatsVld_d3 = '1' and rxClClkRxStatsVld_d4 = '0') then
              rxClClkStatistics(26 downto 21) <= EmacClientRxStats(5 downto 0);
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate HARD_TEMAC_STATISTICS;
  
  SOFT_TEMAC_STATISTICS : if C_TEMAC_TYPE = 2 generate
  BEGIN
    
    emacClientRxFrameDrop_i <= (EmacClientRxStatsVld and not (SoftEmacClientRxStats(27))) when (C_TEMAC_MCAST_EXTEND = 0) else
                                '0';
    
    RX_CL_CLK_STATS_DEMUX_PROCESS: process (Rx_Cl_Clk)
    begin
      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          rxClClkMulticast                     <= '0';        
          rxClClkBroadcast                     <= '0';   
          rxClClkFrameLengthBytes(13 downto 0) <= (others => '0');
          rxClClkStatistics(26 downto 0)       <= (others => '0');
        else
          if (RxClClkEn = '1') then        
            if (EmacClientRxStatsVld = '1' and rxClClkRxStatsVld_d1 = '0') then
              rxClClkStatistics(26 downto 0)       <= SoftEmacClientRxStats(26 downto 0);
              rxClClkMulticast                     <= SoftEmacClientRxStats(4);        
              rxClClkBroadcast                     <= SoftEmacClientRxStats(3);   
              rxClClkFrameLengthBytes(13 downto 0) <= SoftEmacClientRxStats(18 downto 5);
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate SOFT_TEMAC_STATISTICS;
    
  -------------------------------------------------------------------------
  -- Initialize the dual port address for the RX Client Clk side to 
  -- the next available pointer (2) at power-up. make sure we wrap around
  -- to one when we reach the last location in memory
  -------------------------------------------------------------------------
  RX_CL_CLK_WR_ADDR_CNTR_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClClkWrAddrCntr  <= rxClClkNextAvailable_d;
      elsif (rxClClkWrAddrCntrLd = '1') then
        rxClClkWrAddrCntr  <= rxClClkNextAvailable_d;
      else
        if (RxClClkEn = '1') then             
          if ((rxClClkWriteRxDataPacked = '1' or rxClClkWriteRxFrameLength = '1') and rxClClkWrAddrCntrEn = '1' and not(rxClClkWrAddrCntr = fullMask)) then
            rxClClkWrAddrCntr  <= rxClClkWrAddrCntr + 1;
          elsif ((rxClClkWriteRxDataPacked = '1' or rxClClkWriteRxFrameLength = '1') and rxClClkWrAddrCntrEn = '1' and rxClClkWrAddrCntr = fullMask) then
            rxClClkWrAddrCntr  <= oneMask;
          end if;
        end if;
      end if;
    end if;
  end process;
        
  INTERRUPT_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
       RxClClkFrameDropInt <= '0';
       RxClClkFrameRejtInt <= '0';
       RxClClkFrameAcptInt <= '0';
       RxClClkMemFullInt   <= '0';
      else
        if (RxClClkEn = '1') then             
          RxClClkFrameDropInt <= emacClientRxFrameDrop_i;
          RxClClkFrameRejtInt <= rxClClkFrameReject;
          RxClClkFrameAcptInt <= rxClClkFrameAccept;
          RxClClkMemFullInt   <= rxClClkMemFull;
        end if;
      end if;
    end if;
  end process;
       
  PIPE_EMACCLIENT_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClClkRxBadFrame_d1     <= '0';
        rxClClkRxBadFrame_d2     <= '0';
        rxClClkRxdVld_d1         <= '0';
        rxClClkRxdVld_d2         <= '0';
        rxClClkRxdVld_d3         <= '0';
        rxClClkRxdVld_d4         <= '0';
        rxClClkRxGoodFrame_d1    <= '0';
        rxClClkRxGoodFrame_d2    <= '0';
        rxClClkRxStatsVld_d1     <= '0';
        rxClClkRxStatsVld_d2     <= '0';
        rxClClkRxStatsVld_d3     <= '0';
        rxClClkRxStatsVld_d4     <= '0';
        rxClClkStartOfFrame      <= '0';
        rxClClkEndOfFrame        <= '0';
        rxClClkEndOfStats_d1     <= '0';
        rxClClkStartOfStats      <= '0';
        rxClClkEndOfStats        <= '0';
        rxClClkRegCrBrdCastRej   <= '0';
        rxClClkRegCrMulCastRej   <= '0';
        rxClClkRegCrBrdCastRej_d1<= '0';
        rxClClkRegCrMulCastRej_d1<= '0';
      else
        if (RxClClkEn = '1') then             
          rxClClkRxBadFrame_d1     <= EmacClientRxBadFrame;
          rxClClkRxBadFrame_d2     <= rxClClkRxBadFrame_d1;
          rxClClkRxdVld_d1         <= EmacClientRxdVld;
          rxClClkRxdVld_d2         <= rxClClkRxdVld_d1;
          rxClClkRxdVld_d3         <= rxClClkRxdVld_d2;
          rxClClkRxdVld_d4         <= rxClClkRxdVld_d3;
          rxClClkRxGoodFrame_d1    <= EmacClientRxGoodFrame;
          rxClClkRxGoodFrame_d2    <= rxClClkRxGoodFrame_d1;
          rxClClkRxStatsVld_d1     <= EmacClientRxStatsVld;
          rxClClkRxStatsVld_d2     <= rxClClkRxStatsVld_d1;
          rxClClkRxStatsVld_d3     <= rxClClkRxStatsVld_d2;
          rxClClkRxStatsVld_d4     <= rxClClkRxStatsVld_d3;
          rxClClkStartOfFrame      <= EmacClientRxdVld and not(rxClClkRxdVld_d1);
          rxClClkEndOfFrame        <= not(EmacClientRxdVld) and rxClClkRxdVld_d1;
          rxClClkEndOfStats_d1     <= rxClClkEndOfStats;
          rxClClkStartOfStats      <= EmacClientRxStatsVld and not(rxClClkRxStatsVld_d1);
          rxClClkEndOfStats        <= not(EmacClientRxStatsVld) and rxClClkRxStatsVld_d1;
          rxClClkRegCrBrdCastRej   <= PlbRegCrBrdCastRej;
          rxClClkRegCrMulCastRej   <= PlbRegCrMulCastRej;
          rxClClkRegCrBrdCastRej_d1<= rxClClkRegCrBrdCastRej;
          rxClClkRegCrMulCastRej_d1<= rxClClkRegCrMulCastRej;
        end if;
      end if;
    end if;
  end process;
   
  RX_DATA_PACK_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClClkRxDataPacked      <= (others => '0');
        rxClClkRxDataPackState   <= (others => '0');
        rxClClkWriteRxDataPacked <= '0';
      else
        if (RxClClkEn = '1') then             
          if (EmacClientRxdVld = '1') then
            if (rxClClkRxDataPackState = "11") then
              rxClClkRxDataPackState   <= "00";
              rxClClkWriteRxDataPacked <= '1';
            else
              rxClClkRxDataPackState   <= rxClClkRxDataPackState + 1;
              rxClClkWriteRxDataPacked <= '0';
            end if;
            if (rxClClkRxDataPackState = "00") then
              rxClClkRxDataPacked(8 downto 0) <= EmacClientRxdVld & EmacClientRxd;
            elsif (rxClClkRxDataPackState = "01") then
              rxClClkRxDataPacked(17 downto 0) <= rxClClkRxDataPacked(8 downto 0) & EmacClientRxdVld & EmacClientRxd;
            elsif (rxClClkRxDataPackState = "10") then
              rxClClkRxDataPacked(26 downto 0) <= rxClClkRxDataPacked(17 downto 0) & EmacClientRxdVld & EmacClientRxd;
            elsif (rxClClkRxDataPackState = "11") then
              rxClClkRxDataPacked(35 downto 0) <= rxClClkRxDataPacked(26 downto 0) & EmacClientRxdVld & EmacClientRxd;
            end if;
          elsif (EmacClientRxdVld = '0' and rxClClkRxdVld_d1='1') then
            if (rxClClkRxDataPackState = "01") then
              rxClClkRxDataPacked(35 downto 0) <= rxClClkRxDataPacked(8 downto 0) & "000000000000000000000000000";          
              rxClClkWriteRxDataPacked         <= '1';
            elsif (rxClClkRxDataPackState = "10") then
              rxClClkRxDataPacked(35 downto 0) <= rxClClkRxDataPacked(17 downto 0) & "000000000000000000";          
              rxClClkWriteRxDataPacked         <= '1';
            elsif (rxClClkRxDataPackState = "11") then
              rxClClkRxDataPacked(35 downto 0) <= rxClClkRxDataPacked(26 downto 0) & "000000000";          
              rxClClkWriteRxDataPacked         <= '1';
            else
              rxClClkWriteRxDataPacked <= '0';
            end if;        
          else
            rxClClkWriteRxDataPacked <= '0';
            rxClClkRxDataPackState   <= "00";
            rxClClkRxDataPacked      <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;
 
 I_RX_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
   generic map(
      c_family                 => C_FAMILY,
      c_xdevicefamily          => C_FAMILY, 

      -- Memory Specific Configurations
      c_mem_type               => 2,
         -- This wrapper only supports the True Dual Port RAM
         -- 0: Single Port RAM
         -- 1: Simple Dual Port RAM
         -- 2: True Dual Port RAM
         -- 3: Single Port Rom
         -- 4: Dual Port RAM
      c_algorithm              => 1,
         -- 0: Selectable Primative
         -- 1: Minimum Area
      c_prim_type              => 1,
         -- 0: ( 1-bit wide)
         -- 1: ( 2-bit wide)
         -- 2: ( 4-bit wide)
         -- 3: ( 9-bit wide)
         -- 4: (18-bit wide)
         -- 5: (36-bit wide)
         -- 6: (72-bit wide, single port only)
      c_byte_size              => 9,   -- 8 or 9

      -- Simulation Behavior Options
      c_sim_collision_check    => "NONE",
         -- "None"
         -- "Generate_X"
         -- "All"
         -- "Warnings_only"
      c_common_clk             => 0,   -- 0, 1
      c_disable_warn_bhv_coll  => 0,   -- 0, 1
      c_disable_warn_bhv_range => 0,   -- 0, 1

      -- Initialization Configuration Options
      c_load_init_file         => 0,
      c_init_file_name         => "no_coe_file_loaded",
      c_use_default_data       => 0,   -- 0, 1
      c_default_data           => "0", -- "..."

      -- Port A Specific Configurations
      c_has_mem_output_regs_a  => 0,   -- 0, 1
      c_has_mux_output_regs_a  => 0,   -- 0, 1
      c_write_width_a          => 36,  -- 1 to 1152
      c_read_width_a           => 36,  -- 1 to 1152
      c_write_depth_a          => (C_TEMAC_RXFIFO/4),  -- 2 to 9011200
      c_read_depth_a           => (C_TEMAC_RXFIFO/4),  -- 2 to 9011200
      c_addra_width            => (log2(C_TEMAC_RXFIFO/4)),   -- 1 to 24
      c_write_mode_a           => "NO_CHANGE",
         -- "Write_First"
         -- "Read_first"
         -- "No_Change"
      c_has_ena                => 1,   -- 0, 1
      c_has_regcea             => 0,   -- 0, 1
      c_has_ssra               => 0,   -- 0, 1
      c_sinita_val             => "0", --"..."
      c_use_byte_wea           => 0,   -- 0, 1
      c_wea_width              => 1,   -- 1 to 128

      -- Port B Specific Configurations
      c_has_mem_output_regs_b  => 0,   -- 0, 1
      c_has_mux_output_regs_b  => 0,   -- 0, 1
      c_write_width_b          => 36,  -- 1 to 1152
      c_read_width_b           => 36,  -- 1 to 1152
      c_write_depth_b          => (C_TEMAC_RXFIFO/4),  -- 2 to 9011200
      c_read_depth_b           => (C_TEMAC_RXFIFO/4),   -- 2 to 9011200
      c_addrb_width            => (log2(C_TEMAC_RXFIFO/4)),   -- 1 to 24
      c_write_mode_b           => "NO_CHANGE",
         -- "Write_First"
         -- "Read_first"
         -- "No_Change"
      c_has_enb                => 0,   -- 0, 1
      c_has_regceb             => 0,   -- 0, 1
      c_has_ssrb               => 0,   -- 0, 1
      c_sinitb_val             => "0", -- "..."
      c_use_byte_web           => 0,   -- 0, 1
      c_web_width              => 1,   -- 1 to 128

      -- Other Miscellaneous Configurations
      c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
         -- The number of pipeline stages within the MUX
         --    for both Port A and Port B
      c_use_ecc                => 0,
         -- See DS512 for the limited core option selections for ECC support
      c_use_ramb16bwer_rst_bhv => 0    --0, 1
      )
   port map
      (
      clka    => Rx_Cl_Clk,      --: in  std_logic;
      ssra    => '0',            --: in  std_logic := '0';
      dina    => rxClClkDPMemWrData,  --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
      addra   => rxClClkDPMemAddr,    --: in  std_logic_vector(c_addra_width-1   downto 0);
      ena     => RxClClkEn,      --: in  std_logic := '1';
      regcea  => '0',            --: in  std_logic := '1';
      wea     => rxClClkDPMemWrEn,    --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
      douta   => rxClClkDPMemRdData,  --: out std_logic_vector(c_read_width_a-1  downto 0);


      clkb    => LLTemac_Clk,    --: in  std_logic := '0';
      ssrb    => '0',            --: in  std_logic := '0';
      dinb    => RxLLinkClkDPMemWrData,  --: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
      addrb   => RxLLinkClkDPMemAddr,    --: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
      enb     => '1',            --: in  std_logic := '1';
      regceb  => '0',            --: in  std_logic := '1';
      web     => RxLLinkClkDPMemWrEn,    --: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
      doutb   => RxLLinkClkDPMemRdData,  --: out std_logic_vector(c_read_width_b-1  downto 0);

      dbiterr => open,           --: out std_logic;
         -- Double bit error that that cannot be auto corrected by ECC
      sbiterr => open            --: out std_logic
         -- Single Bit Error that has been auto corrected on the output bus
      );
     
    
  -------------------------------------------------------------------------
  -- Initialize the last processed pointer to onw at power-up and provide
  -- as last processed minus 2 pointer (skipping 0 which is the next avail
  -- pointer location)
  -------------------------------------------------------------------------
  RX_CL_CLK_RD_PTR_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClClkLastProcessed  <= oneMask;
        rxClClkLastProcessedSubOne <= fullMask;
        rxClClkLastProcessedSubTwo <= fullMaskMinusOne;
      else
        if (RxClClkEn = '1') then             
          rxClClkLastProcessed  <= rxClClkLastProcessedBinary_d1;
          if (rxClClkLastProcessedBinary_d1 = oneMask) then
            rxClClkLastProcessedSubOne <= fullMask;
            rxClClkLastProcessedSubTwo <= fullMaskMinusOne;
          elsif (rxClClkLastProcessedBinary_d1 = zeroMask) then
            rxClClkLastProcessedSubOne <= fullMaskMinusOne;
            rxClClkLastProcessedSubTwo <= fullMaskMinusTwo;
          elsif (rxClClkLastProcessedBinary_d1 = twoMask) then
            rxClClkLastProcessedSubOne <= oneMask;
            rxClClkLastProcessedSubTwo <= fullMask;
          else
            rxClClkLastProcessedSubOne <= rxClClkLastProcessedBinary_d1 - 1;
            rxClClkLastProcessedSubTwo <= rxClClkLastProcessedBinary_d1 - 2;
          end if;
        end if;
      end if;
    end if;
  end process;
  
  -------------------------------------------------------------------------
  -- check for a full memory before we start receiving a new frame.
  -------------------------------------------------------------------------
  RX_CL_CLK_CHK_PTRS_AT_START_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClClkMemFullBeforeStart  <= '0';
        rxClClkMemFullBeforeStart_d1  <= '0';
      else
        if (RxClClkEn = '1') then             
          rxClClkMemFullBeforeStart_d1  <= rxClClkMemFullBeforeStart;
          if (rxClClkRdLastProcessed = '1' and rxClClkLastProcessedSubOne = oneMask and rxClClkNextAvailable_d = (fullMask)) then
            rxClClkMemFullBeforeStart  <= '1';
          elsif (rxClClkRdLastProcessed = '1' and ((rxClClkNextAvailable = rxClClkLastProcessedSubTwo) or (rxClClkNextAvailable = rxClClkLastProcessedSubOne))) then
            rxClClkMemFullBeforeStart  <= '1';
          elsif (rxClClkRdLastProcessed = '1') then
            rxClClkMemFullBeforeStart  <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- check for a full memory while receiving a frame.
  -------------------------------------------------------------------------
  RX_CL_CLK_CHK_PTRS_DURING_WR_PROCESS: process (Rx_Cl_Clk)
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClClkMemFullDuringWr  <= '0';
      else
        if (RxClClkEn = '1') then             
          if (rxClClkWrAddrCntrEn = '1' and rxClClkLastProcessedSubOne = oneMask and rxClClkWrAddrCntr = (fullMask)) then
            rxClClkMemFullDuringWr  <= '1';
          elsif (rxClClkWrAddrCntrEn = '1' and ((rxClClkWrAddrCntr = rxClClkLastProcessedSubTwo) or (rxClClkWrAddrCntr = rxClClkLastProcessedSubOne))) then
            rxClClkMemFullDuringWr  <= '1';
          elsif (rxClWrSm_Cs = WAIT_FOR_STRT_OF_FRAME) then
          --elsif (rxClClkWrAddrCntrEn = '1') then
            rxClClkMemFullDuringWr  <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- Rx Client Write State Machine
  -- RXCLWRSM_REGS_PROCESS: registered process of the state machine
  -- RXCLWRSM_CMB_PROCESS:  combinatorial next-state logic
  --------------------------------------------------------------------------
  
  RXCLWRSM_REGS_PROCESS: process (Rx_Cl_Clk )
  begin
    if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
      if (RxClClk_Rst = '1') then
        rxClWrSm_Cs     <= PWR_UP_INIT_LAST_PROC;
        rxClClkNextAvailable_d <= rxClClkNextAvailable;
      else
        if (RxClClkEn = '1') then             
          rxClWrSm_Cs <= rxClWrSm_Ns;
          rxClClkNextAvailable_d <= rxClClkNextAvailable;
        end if;
      end if;
    end if;
  end process;
  
  RXCLWRSM_CMB_PROCESS: process (
                               RxClWrSm_Cs,
                               rxClClkStartOfFrame,
                               rxClClkMemFullBeforeStart_d1,
                               rxClClkMemFullDuringWr,
                               rxClClkRxGoodFrame_d2,
                               rxClClkRxBadFrame_d2,
                               rxClClkWriteRxDataPacked,
                               rxClClkNextAvailable_d,
                               rxClClkEndOfFrame,
                               rxClClkWrAddrCntr,
                               rxClClkRxDataPackState,
                               extendedMulticastReject,
                               rxClClkBroadcast,
                               rxClClkRegCrBrdCastRej_d1,
                               rxClClkMulticast,
                               rxClClkRegCrMulCastRej_d1
                              )
  begin

    rxClClkWrAddrCntrEn       <= '0';
    rxClClkRdLastProcessed    <= '0';
    rxClClkRdLastProcessedAddrEn <= '0';
    rxClClkNextAvailable      <= rxClClkNextAvailable_d;
    rxClClkWrAddrCntrLd       <= '0';
    rxClClkWriteRxFrameLength <= '0';
    rxClClkFrameReject        <= '0';
    rxClClkFrameAccept        <= '0';
    rxClClkMemFull            <= '0';
      
    case rxClWrSm_Cs is

      when PWR_UP_INIT_LAST_PROC =>
        rxWrStateEnc <= "000";
        rxClClkNextAvailable <= std_logic_vector(to_unsigned(2, C_MEM_DEPTH+1)); --mw needs to scale "0000000010" 
        rxClWrSm_Ns <= PWR_UP_INIT_NEXT_AVAIL;

      when PWR_UP_INIT_NEXT_AVAIL =>
        rxWrStateEnc <= "001";
        rxClClkNextAvailable <= std_logic_vector(to_unsigned(2, C_MEM_DEPTH+1)); --mw needs to scale "0000000010";
        rxClWrSm_Ns <= WAIT_FOR_STRT_OF_FRAME;

      when WAIT_FOR_STRT_OF_FRAME =>
        rxWrStateEnc <= "010";
        rxClClkRdLastProcessed <= '1';
        rxClClkRdLastProcessedAddrEn <= '1';
        rxClClkWrAddrCntrLd    <= '1';
        if (rxClClkStartOfFrame = '1' and rxClClkMemFullBeforeStart_d1 = '0') then
          rxClWrSm_Ns <= RCVING_A_FRAME;
        else
          if (rxClClkStartOfFrame = '1' and rxClClkMemFullBeforeStart_d1 = '1') then
            rxClClkMemFull <= '1';
          end if;
          rxClWrSm_Ns    <= WAIT_FOR_STRT_OF_FRAME;
        end if;
          
      when RCVING_A_FRAME =>
        rxWrStateEnc <= "011";
        rxClClkWrAddrCntrEn <= '1';
        if (rxClClkMemFullDuringWr = '1') then
          rxClClkMemFull <= '1';
          rxClWrSm_Ns    <= WAIT_FOR_STRT_OF_FRAME;
        elsif (rxClClkEndOfFrame = '1') then
          rxClWrSm_Ns <= END_OF_FRAME_CHECK_GOOD_BAD;
        else
          rxClWrSm_Ns <= RCVING_A_FRAME;
          if (rxClClkRxDataPackState = "10" or rxClClkRxDataPackState = "11") then 
            rxClClkRdLastProcessedAddrEn <= '1';
          end if;
          if (rxClClkRxDataPackState = "11") then 
            rxClClkRdLastProcessed <= '1';
          end if;
        end if;

      when END_OF_FRAME_CHECK_GOOD_BAD =>
        rxWrStateEnc <= "100";
        if (rxClClkRxGoodFrame_d2 = '1') then
          if ((rxClClkBroadcast = '1' and rxClClkRegCrBrdCastRej_d1 = '1') or 
              (rxClClkMulticast = '1' and rxClClkRegCrMulCastRej_d1 = '1') or
              (extendedMulticastReject = '1'))then
            rxClWrSm_Ns <= WAIT_FOR_STRT_OF_FRAME;
            rxClClkFrameReject <= '1';
          else          
            rxClWrSm_Ns <= WRITE_FRAME_LENGTH;
          end if;
        elsif (rxClClkRxBadFrame_d2 = '1') then
          rxClWrSm_Ns <= WAIT_FOR_STRT_OF_FRAME;
          rxClClkFrameReject <= '1';
        else
          rxClWrSm_Ns <= END_OF_FRAME_CHECK_GOOD_BAD;
        end if;

      when WRITE_FRAME_LENGTH =>
        rxWrStateEnc <= "101";
--        rxClClkWriteRxFrameLength  <= '1';
        rxClClkWrAddrCntrEn <= '1';
        if (rxClClkMemFullDuringWr = '1') then
          rxClClkMemFull <= '1';
          rxClWrSm_Ns <= WAIT_FOR_STRT_OF_FRAME;
        else
          rxClClkWriteRxFrameLength  <= '1'; -- don't actually write this value if the memory is full!
          rxClWrSm_Ns <= UPDATE_NEXT_AVAIL;
        end if;

      when UPDATE_NEXT_AVAIL =>
        rxWrStateEnc <= "110";
        rxClClkNextAvailable <= rxClClkWrAddrCntr;
        rxClWrSm_Ns          <= WRITE_NEXT_AVAIL;

      when WRITE_NEXT_AVAIL =>
        rxWrStateEnc <= "111";
        rxClWrSm_Ns        <= WAIT_FOR_STRT_OF_FRAME;
        rxClClkFrameAccept <= '1';

      when others   => 
        rxClWrSm_Ns <= PWR_UP_INIT_LAST_PROC;
    end case;
  end process;                    

  EXTENDED_MULTICAST: if(C_TEMAC_MCAST_EXTEND = 1) generate

    type EMCFLTRSM_TYPE is (
      WAIT_FRAME_START,
      GET_SECOND_BYTE,
      GET_THIRD_BYTE,
      GET_FORTH_BYTE,
      GET_FIFTH_BYTE,
      READ_TABLE_ENTRY,
      GET_UNI_ADDRESS,
      CHECK_UNI_ADDRESS,
      GET_BRDCAST_ADDRESS,
      CHECK_BRDCAST_ADDRESS,
      ACCEPT_AND_WAIT_TILL_END,
      REJECT_AND_WAIT_TILL_END
    );

    signal eMcFltrSM_Cs           : EMCFLTRSM_TYPE;
    signal eMcFltrSM_Ns           : EMCFLTRSM_TYPE;
    signal rxClClkStartOfFrame_d1 : std_logic;
    signal rxClClkStartOfFrame_d2 : std_logic;
    signal rxClClkStartOfFrame_d3 : std_logic;
    signal rxClClkStartOfFrame_d4 : std_logic;
    signal rxClClkStartOfFrame_d5 : std_logic;
    signal rxClClkStartOfFrame_d6 : std_logic;
    signal rxClClkStartOfFrame_d7 : std_logic;
    signal tempDestAddr           : std_logic_vector(0 to 47);
    signal unicastMatch           : std_logic;
    signal broadcastMatch         : std_logic;

    signal mcastStateEnc          : std_logic_vector(0 to 3);
    
  begin

  RxClClkMcastEn   <= rxClClkMcastEn_i;
  RxClClkMcastAddr <= rxClClkMcastAddr_i;

    COMPARE_UNICAST_ADDR_PROCESS: process (Rx_Cl_Clk)
    begin
      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          unicastMatch <= '0';
        else
          if (tempDestAddr(0 to 7) = UawLRegData(24 to 31) and 
              tempDestAddr(8 to 15) = UawLRegData(16 to 23) and
              tempDestAddr(16 to 23) = UawLRegData(8 to 15) and
              tempDestAddr(24 to 31) = UawLRegData(0 to 7) and
              tempDestAddr(32 to 39) = UawURegData(24 to 31) and
              tempDestAddr(40 to 47) = UawURegData(16 to 23))then
            unicastMatch <= '1';
          else
            unicastMatch <= '0';
          end if;
        end if;
      end if;
    end process;

    COMPARE_BROADCAST_ADDR_PROCESS: process (Rx_Cl_Clk)
    begin
      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          broadcastMatch <= '0';
        else
          if (tempDestAddr=x"ffffffffffff") then
            broadcastMatch <= '1';
          else
            broadcastMatch <= '0';
          end if;
        end if;
      end if;
    end process;
       
    PIPE_STARTOFFRAME_PROCESS: process (Rx_Cl_Clk)
    begin
      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          rxClClkStartOfFrame_d1    <= '0';
          rxClClkStartOfFrame_d2    <= '0';
          rxClClkStartOfFrame_d3    <= '0';
          rxClClkStartOfFrame_d4    <= '0';
          rxClClkStartOfFrame_d5    <= '0';
          rxClClkStartOfFrame_d6    <= '0';
          rxClClkStartOfFrame_d7    <= '0';
        else
          if (RxClClkEn = '1') then             
            rxClClkStartOfFrame_d1    <= rxClClkStartOfFrame;
            rxClClkStartOfFrame_d2    <= rxClClkStartOfFrame_d1;
            rxClClkStartOfFrame_d3    <= rxClClkStartOfFrame_d2;
            rxClClkStartOfFrame_d4    <= rxClClkStartOfFrame_d3;
            rxClClkStartOfFrame_d5    <= rxClClkStartOfFrame_d4;
            rxClClkStartOfFrame_d6    <= rxClClkStartOfFrame_d5;
            rxClClkStartOfFrame_d7    <= rxClClkStartOfFrame_d6;
          end if;
        end if;
      end if;
    end process;
       
    CAPTURE_TEMPDESTADDR_PROCESS: process (Rx_Cl_Clk)
    begin
      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          tempDestAddr    <= (others => '0');
        else
          if (RxClClkEn = '1') then             
            if (rxClClkStartOfFrame = '1') then             
              tempDestAddr(0 to 7)   <= EmacClientRxd_d1(7 downto 0);
              tempDestAddr(8 to 47)  <= (others => '0');
            elsif (rxClClkStartOfFrame_d1 = '1') then 
              tempDestAddr(0 to 7)   <= tempDestAddr(0 to 7);
              tempDestAddr(8 to 15)  <= EmacClientRxd_d1(7 downto 0);
              tempDestAddr(16 to 47) <= (others => '0');
            elsif (rxClClkStartOfFrame_d2 = '1') then 
              tempDestAddr(0 to 15)  <= tempDestAddr(0 to 15);
              tempDestAddr(16 to 23) <= EmacClientRxd_d1(7 downto 0);
              tempDestAddr(24 to 47) <= (others => '0');
            elsif (rxClClkStartOfFrame_d3 = '1') then 
              tempDestAddr(0 to 23)  <= tempDestAddr(0 to 23);
              tempDestAddr(24 to 31) <= EmacClientRxd_d1(7 downto 0);
              tempDestAddr(32 to 47) <= (others => '0');
            elsif (rxClClkStartOfFrame_d4 = '1') then 
              tempDestAddr(0 to 31)  <= tempDestAddr(0 to 31);
              tempDestAddr(32 to 39) <= EmacClientRxd_d1(7 downto 0);
              tempDestAddr(40 to 47) <= (others => '0');
            elsif (rxClClkStartOfFrame_d5 = '1') then 
              tempDestAddr(0 to 39)  <= tempDestAddr(0 to 39);
              tempDestAddr(40 to 47) <= EmacClientRxd_d1(7 downto 0);
            else 
              tempDestAddr(0 to 47)  <= tempDestAddr(0 to 47);
            end if;
          end if;
        end if;
      end if;
    end process;

    EMCFLTRSM_REGS_PROCESS: process (Rx_Cl_Clk )
    begin
      if (Rx_Cl_Clk'event and Rx_Cl_Clk = '1') then
        if (RxClClk_Rst = '1') then
          eMcFltrSM_Cs     <= WAIT_FRAME_START;
          rxClClkMcastAddr_i_d <= (others => '0');
        else
          if (RxClClkEn = '1') then             
            eMcFltrSM_Cs <= eMcFltrSM_Ns;
            rxClClkMcastAddr_i_d <= rxClClkMcastAddr_i;
          end if;
        end if;
      end if;
    end process;
  
    EMCFLTRSM_CMB_PROCESS: process (
       eMcFltrSM_Cs,
       rxClClkStartOfFrame,
       rxClClkEndOfFrame,
       LlinkClkNewFncEnbl,
       LlinkClkEMultiFltrEnbl,
       rxClClkEndOfStats,
       emacClientRxd_d1,
       RxClClkMcastRdData,
       tempDestAddr,
       UawLRegData,
       UawURegData,
       rxClClkStartOfFrame_d7,
       unicastMatch,
       rxClClkMcastAddr_i_d,
       rxClClkMcastAddr_i,
       broadcastMatch,
       rxClWrSm_Cs       
     )
    begin

      extendedMulticastReject   <= '0';
      rxClClkMcastAddr_i        <= (others => '0');
      rxClClkMcastEn_i          <= '0';
      rxClClkMcastAddr_i        <= rxClClkMcastAddr_i_d;
      
      case eMcFltrSM_Cs is

        when WAIT_FRAME_START =>
          mcastStateEnc <= "0000";
          rxClClkMcastAddr_i <= (others => '0');
          if (LlinkClkNewFncEnbl = '1' and LlinkClkEMultiFltrEnbl = '1') then
            if (rxClClkStartOfFrame = '1')then
              if (emacClientRxd_d1=X"01")then
                eMcFltrSM_Ns <= GET_SECOND_BYTE; -- looks like IP generated multicast so far
              elsif (emacClientRxd_d1(0)='0')then
                eMcFltrSM_Ns <= GET_UNI_ADDRESS; -- it's a unicast address that we need to compare
              elsif (emacClientRxd_d1=X"FF")then
                eMcFltrSM_Ns <= GET_BRDCAST_ADDRESS; -- looks like broadcast so far
              else          
                eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END; -- must be multicast but non-IP generated
                extendedMulticastReject <= '1';            
              end if;
            else
              eMcFltrSM_Ns <= WAIT_FRAME_START; -- a new frame hasn't started yet
            end if;
          else
            eMcFltrSM_Ns <= WAIT_FRAME_START; -- extended multicast filtering not enabled
          end if;

        when GET_SECOND_BYTE =>
          mcastStateEnc <= "0001";
          if (emacClientRxd_d1=X"00")then
            eMcFltrSM_Ns <= GET_THIRD_BYTE; -- still looks like IP generated multicast so far
          else
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END; -- must be multicast but non-IP generated
            extendedMulticastReject <= '1';            
          end if;

        when GET_THIRD_BYTE =>
          mcastStateEnc <= "0010";
          if (emacClientRxd_d1=X"5e")then
            eMcFltrSM_Ns <= GET_FORTH_BYTE; -- it is an IP generated multicast so let get the rest and look it up
          else
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END; -- must be multicast but non-IP generated
            extendedMulticastReject <= '1';            
          end if;

        when GET_FORTH_BYTE =>
          mcastStateEnc <= "0011";
          rxClClkMcastAddr_i(0 to 6) <= emacClientRxd_d1(6 downto 0);
          eMcFltrSM_Ns <= GET_FIFTH_BYTE;

        when GET_FIFTH_BYTE =>
          mcastStateEnc <= "0100";
          rxClClkMcastAddr_i(7 to 14) <= emacClientRxd_d1(7 downto 0);
          rxClClkMcastEn_i            <= '1';
          eMcFltrSM_Ns <= READ_TABLE_ENTRY;

        when READ_TABLE_ENTRY =>
          mcastStateEnc <= "0101";
          rxClClkMcastEn_i            <= '1';
          if (RxClClkMcastRdData(0)='0')then
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END;
            extendedMulticastReject  <= '1';
          else
            eMcFltrSM_Ns <= ACCEPT_AND_WAIT_TILL_END;
          end if;

        when GET_UNI_ADDRESS =>
          mcastStateEnc <= "0110";
          if (rxClClkStartOfFrame_d7='1')then
            eMcFltrSM_Ns <= CHECK_UNI_ADDRESS;
          else
            eMcFltrSM_Ns <= GET_UNI_ADDRESS;
          end if;

        when GET_BRDCAST_ADDRESS =>
          mcastStateEnc <= "0111";
          if (rxClClkStartOfFrame_d7='1')then
            eMcFltrSM_Ns <= CHECK_BRDCAST_ADDRESS;
          else
            eMcFltrSM_Ns <= GET_BRDCAST_ADDRESS;
          end if;

        when CHECK_BRDCAST_ADDRESS =>
          mcastStateEnc <= "1000";
          if (broadcastMatch='1')then
            eMcFltrSM_Ns <= ACCEPT_AND_WAIT_TILL_END;
          else
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END;
            extendedMulticastReject  <= '1';
          end if;

        when CHECK_UNI_ADDRESS =>
          mcastStateEnc <= "1001";
          if (unicastMatch = '1')then
            eMcFltrSM_Ns <= ACCEPT_AND_WAIT_TILL_END;
          else
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END;
            extendedMulticastReject  <= '1';
          end if;

        when REJECT_AND_WAIT_TILL_END =>
          mcastStateEnc <= "1010";
          extendedMulticastReject  <= '1';
--          if (rxClClkEndOfStats = '1' )then
          if (rxClWrSm_Cs = WAIT_FOR_STRT_OF_FRAME)then
            eMcFltrSM_Ns <= WAIT_FRAME_START;
          else          
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END;
          end if;

        when ACCEPT_AND_WAIT_TILL_END =>
          mcastStateEnc <= "1011";
          extendedMulticastReject  <= '0';
          if (rxClClkEndOfStats = '1' )then
            eMcFltrSM_Ns <= WAIT_FRAME_START;
          else          
            eMcFltrSM_Ns <= ACCEPT_AND_WAIT_TILL_END;
          end if;

        when others   => 
          eMcFltrSM_Ns <= WAIT_FRAME_START;
      end case;
    end process;                    


  end generate EXTENDED_MULTICAST;

  NO_EXTENDED_MULTICAST: if(C_TEMAC_MCAST_EXTEND = 0) generate
  begin
    extendedMulticastReject <= '0';
  end generate NO_EXTENDED_MULTICAST;
          
end simulation;
