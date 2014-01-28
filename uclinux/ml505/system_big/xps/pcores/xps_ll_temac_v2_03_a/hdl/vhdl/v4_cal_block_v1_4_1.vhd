------------------------------------------------------------------------------
-- $Id: v4_cal_block_v1_4_1.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- MGT Calibration Block v1.4.1
------------------------------------------------------------------------------
-- $Revision: 1.1.4.39 $
-- $Date: 2009/11/17 07:11:35 $
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
-- Filename:          v4_cal_block_v1_4_1.vhd
-- Description:       DRP Calibration Block v1.4.1
--               
--               This is based on Coregen Wrappers from ISE J.38 (9.2i)
--               Wrapper version 4.5
------------------------------------------------------------------------
--
-- VHDL-standard:     VHDL '93
------------------------------------------------------------------------------
-- Authors:   Xilinx
-- History:
--  ML        01/27/2006      - Initial Code based on v1.4.1 Verilog version
--
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity v4_cal_block_v1_4_1 is
  generic (
    C_MGT_ID          : integer := 0;       -- 0 = MGTA | 1 = MGTB
    C_TXPOST_TAP_PD   : string  := "TRUE";  -- Default POST TAP PD
    C_RXDIGRX         : string  := "FALSE"  -- Default RXDIGRX
  );

  port (
    -- User DRP Interface (destination/slave interface)
    USER_DO             : out std_logic_vector(16-1 downto 0);
    USER_DI             : in  std_logic_vector(16-1 downto 0);
    USER_DADDR          : in  std_logic_vector(8-1 downto 0);
    USER_DEN            : in  std_logic;
    USER_DWE            : in  std_logic;
    USER_DRDY           : out std_logic;

    -- MGT DRP Interface (source/master interface)
    GT_DO               : out std_logic_vector(16-1 downto 0);
    GT_DI               : in  std_logic_vector(16-1 downto 0);
    GT_DADDR            : out std_logic_vector(8-1 downto 0);
    GT_DEN              : out std_logic;
    GT_DWE              : out std_logic;
    GT_DRDY             : in  std_logic;

    -- DRP Clock and Reset
    DCLK                : in  std_logic;
    RESET               : in  std_logic;

    -- Calibration Block Active and Disable Signals (legacy)
    ACTIVE              : out std_logic;

    -- User side MGT Pass through Signals
    USER_LOOPBACK       : in  std_logic_vector(1 downto 0);
    USER_TXENC8B10BUSE  : in  std_logic;
    USER_TXBYPASS8B10B  : in  std_logic_vector(7 downto 0);

    -- GT side MGT Pass through Signals
    GT_LOOPBACK         : out std_logic_vector(1 downto 0);
    GT_TXENC8B10BUSE    : out std_logic;
    GT_TXBYPASS8B10B    : out std_logic_vector(7 downto 0);

    -- Signal Detect Ports
    TX_SIGNAL_DETECT    : in  std_logic;
    RX_SIGNAL_DETECT    : in  std_logic

);

  attribute use_sync_reset : string;
  attribute use_sync_reset of v4_cal_block_v1_4_1: entity is "yes";

  attribute use_sync_set : string;
  attribute use_sync_set of v4_cal_block_v1_4_1: entity is "yes";

  attribute use_clock_enable : string;
  attribute use_clock_enable of v4_cal_block_v1_4_1: entity is "yes";

  attribute use_dsp48 : string;
  attribute use_dsp48 of v4_cal_block_v1_4_1: entity is "no";

end v4_cal_block_v1_4_1;

architecture rtl of v4_cal_block_v1_4_1 is


  ----------------------------------------------------------------------------
  -- Function Declaration
  ----------------------------------------------------------------------------
  function ExtendString (string_in : string;
                         string_len : integer)
          return string is

    variable string_out : string(1 to string_len)
                          := (others => ' ');

  begin
    if string_in'length > string_len then
      string_out := string_in(1 to string_len);
    else
      string_out(1 to string_in'length) := string_in;
    end if;
    return  string_out;
  end ExtendString;

  function StringToBool (S : string) return boolean is
  begin
    if (ExtendString(S,5) = "TRUE ") then
      return true;
    elsif (ExtendString(S,5) = "FALSE") then
      return false;
    else
      return false;
    end if;
  end function StringToBool;

  ----------------------------------------------------------------------------
  -- Constants
  ----------------------------------------------------------------------------
  constant C_DRP_DWIDTH : integer := 16;
  constant C_DRP_AWIDTH : integer := 8;

  ----------------------------------------------------------------------------
  -- Signals
  ----------------------------------------------------------------------------
  signal reset_r                  : std_logic_vector(1 downto 0);

  signal user_di_r                : std_logic_vector(C_DRP_DWIDTH-1 downto 0)
                                    := (others => '0');
  signal user_daddr_r             : std_logic_vector(C_DRP_AWIDTH-3 downto 0);
  signal user_den_r               : std_logic;
  signal user_req                 : std_logic;
  signal user_dwe_r               : std_logic;

  signal user_drdy_i              : std_logic;

  signal gt_drdy_r                : std_logic := '0';
  signal gt_do_r                  : std_logic_vector(C_DRP_DWIDTH-1 downto 0)
                                    := (others => '0');

  signal rxdigrx_cache            : std_logic;
  signal txpost_tap_pd_cache      : std_logic;

  signal gt_do_r_sel              : std_logic_vector(2 downto 0);
  signal gt_daddr_sel             : std_logic_vector(2 downto 0);

  signal c_rx_digrx_addr          : std_logic_vector(C_DRP_AWIDTH-1 downto 0);
  signal c_tx_pt_addr             : std_logic_vector(C_DRP_AWIDTH-1 downto 0);
  signal c_txpost_tap_pd_bin      : std_logic;
  signal c_rxdigrx_bin            : std_logic;

  signal user_sel                 : std_logic;
  signal sd_sel                   : std_logic;
  signal sd_req                   : std_logic := '0';
  signal sd_read                  : std_logic := '0';
  signal sd_write                 : std_logic := '0';
  signal sd_drp_done              : std_logic := '0';
  signal sd_wr_wreg               : std_logic_vector(C_DRP_DWIDTH-1 downto 0)
                                    := (others => '0');
  signal sd_addr_r                : std_logic_vector(C_DRP_AWIDTH-3 downto 0);

  signal drp_rd                   : std_logic;
  signal drp_wr                   : std_logic;

  signal cb_state                 : std_logic_vector(3 downto 0);
  signal cb_next_state            : std_logic_vector(3 downto 0);

  signal drp_state                : std_logic_vector(4 downto 0);
  signal drp_next_state           : std_logic_vector(4 downto 0);

  signal sd_state                 : std_logic_vector(13 downto 0);
  signal sd_next_state            : std_logic_vector(13 downto 0);


  ----------------------------------------------------------------------------
  -- Arbitration FSM
  ----------------------------------------------------------------------------
  constant C_RESET        : std_logic_vector(3 downto 0) := "0001";
  constant C_IDLE         : std_logic_vector(3 downto 0) := "0010";
  constant C_SD_DRP_OP    : std_logic_vector(3 downto 0) := "0100";
  constant C_USER_DRP_OP  : std_logic_vector(3 downto 0) := "1000";


  ----------------------------------------------------------------------------
  -- DRP FSM
  ----------------------------------------------------------------------------
  constant C_DRP_IDLE       : std_logic_vector(4 downto 0) := "00001";
  constant C_DRP_READ       : std_logic_vector(4 downto 0) := "00010";
  constant C_DRP_WRITE      : std_logic_vector(4 downto 0) := "00100";
  constant C_DRP_WAIT       : std_logic_vector(4 downto 0) := "01000";
  constant C_DRP_COMPLETE   : std_logic_vector(4 downto 0) := "10000";


  ----------------------------------------------------------------------------
  -- Signal Detect Indicator FSM
  ----------------------------------------------------------------------------
  constant C_SD_IDLE               : std_logic_vector(13 downto 0)
                                     := "00000000000001";
  constant C_SD_RD_PT_ON           : std_logic_vector(13 downto 0)
                                     := "00000000000010";
  constant C_SD_MD_PT_ON           : std_logic_vector(13 downto 0)
                                     := "00000000000100";
  constant C_SD_WR_PT_ON           : std_logic_vector(13 downto 0)
                                     := "00000000001000";
  constant C_SD_RD_RXDIGRX_ON      : std_logic_vector(13 downto 0)
                                     := "00000000010000";
  constant C_SD_MD_RXDIGRX_ON      : std_logic_vector(13 downto 0)
                                     := "00000000100000";
  constant C_SD_WR_RXDIGRX_ON      : std_logic_vector(13 downto 0)
                                     := "00000001000000";
  constant C_SD_WAIT               : std_logic_vector(13 downto 0)
                                     := "00000010000000";
  constant C_SD_RD_RXDIGRX_RESTORE : std_logic_vector(13 downto 0)
                                     := "00000100000000";
  constant C_SD_MD_RXDIGRX_RESTORE : std_logic_vector(13 downto 0)
                                     := "00001000000000";
  constant C_SD_WR_RXDIGRX_RESTORE : std_logic_vector(13 downto 0)
                                     := "00010000000000";
  constant C_SD_RD_PT_OFF          : std_logic_vector(13 downto 0)
                                     := "00100000000000";
  constant C_SD_MD_PT_OFF          : std_logic_vector(13 downto 0)
                                     := "01000000000000";
  constant C_SD_WR_PT_OFF          : std_logic_vector(13 downto 0)
                                     := "10000000000000";


  ----------------------------------------------------------------------------
  -- Make Addresses for MGTA or MGTB at compile time
  ----------------------------------------------------------------------------
  constant C_MGTA_RX_DIGRX_ADDR    : std_logic_vector(7 downto 0)
                                     := "01111101";   --7Dh
  constant C_MGTA_TX_PT_ADDR       : std_logic_vector(7 downto 0)
                                     := "01001100";   --4Ch

  constant C_MGTB_RX_DIGRX_ADDR    : std_logic_vector(7 downto 0)
                                     := "01011001";   --59h
  constant C_MGTB_TX_PT_ADDR       : std_logic_vector(7 downto 0)
                                     := "01001110";   --4Eh


begin
  use_mgt_b : if (C_MGT_ID /= 0) generate
  begin
    c_rx_digrx_addr <= C_MGTB_RX_DIGRX_ADDR;
    c_tx_pt_addr    <= C_MGTB_TX_PT_ADDR;
  end generate use_mgt_b;

  use_mgt_a : if (C_MGT_ID = 0) generate
  begin
    c_rx_digrx_addr <= C_MGTA_RX_DIGRX_ADDR;
    c_tx_pt_addr    <= C_MGTA_TX_PT_ADDR;
  end generate use_mgt_a;


  ----------------------------------------------------------------------------
  -- Convert C_TXPOST_TAP_PD from ASCII text "TRUE"/"FALSE" to binary value
  ----------------------------------------------------------------------------
  use_txpost_tap_pd_true : if (StringToBool(C_TXPOST_TAP_PD)=true) generate
  begin
    c_txpost_tap_pd_bin <= '1';
  end generate;

  use_txpost_tap_pd_false : if (StringToBool(C_TXPOST_TAP_PD)=false) generate
  begin
    c_txpost_tap_pd_bin <= '0';
  end generate;


  ----------------------------------------------------------------------------
  -- Convert C_RXDIGRX from ASCII text "TRUE"/"FALSE" to binary value
  ----------------------------------------------------------------------------
  use_rxdigrx_true : if (StringToBool(C_RXDIGRX)=true) generate
  begin
    c_rxdigrx_bin <= '1';
  end generate;

  use_rxdigrx_false : if (StringToBool(C_RXDIGRX)=false) generate
  begin
    c_rxdigrx_bin <= '0';
  end generate;


  ----------------------------------------------------------------------------
  -- Sync Reset
  ----------------------------------------------------------------------------
  process (DCLK, RESET)
  begin
    if (RESET = '1') then
      reset_r <= "11";
    elsif (rising_edge(DCLK)) then
      reset_r <= '0' & reset_r(1);
    end if;
  end process;


  ----------------------------------------------------------------------------
  -- User DRP Transaction Capture Input Registers
  ----------------------------------------------------------------------------
  -- User Data Input
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if (USER_DEN = '1') then
        user_di_r <= USER_DI;
      end if;
    end if;
  end process;

  -- User DRP Address
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if (USER_DEN = '1') then
        user_daddr_r <= USER_DADDR(C_DRP_AWIDTH-3 downto 0);
      end if;
    end if;
  end process;

  -- User Data Write Enable
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if (reset_r(0) = '1') then
        user_dwe_r <= '0';
      elsif (USER_DEN = '1') then
        user_dwe_r <= USER_DWE;
      end if;
    end if;
  end process;

  -- Register the user_den_r when the user is granted access from the
  -- Arbitration FSM
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if ( (reset_r(0) = '1') or
           (cb_state = C_USER_DRP_OP) or
           ((USER_DADDR(7) = '1') or (USER_DADDR(6) = '0')) ) then
        user_den_r <= '0';
      elsif (user_den_r = '0') then
        user_den_r <= USER_DEN;
      end if;
    end if;
  end process;

  -- Generate the user request (user_req) signal when the user is not
  -- accessing the same DRP addresses as the Calibration Block or when the
  -- Calibration  Block is in idle, reset, or wait states.
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if ((reset_r(0) = '1')  or (cb_state = C_USER_DRP_OP)) then

        user_req <= '0';

      elsif (
        (not(user_daddr_r(5 downto 0)=c_rx_digrx_addr(5 downto 0))) and
        (not(user_daddr_r(5 downto 0)=c_tx_pt_addr(5 downto 0)))
        ) then

        user_req <= user_den_r;

      elsif ( (sd_state = C_SD_IDLE) or (sd_state = C_SD_WAIT) ) then

        user_req <= user_den_r;

      end if;
    end if;
  end process;

  -- User Data Output
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if ((cb_state = C_USER_DRP_OP) and (GT_DRDY = '1')) then
          USER_DO <= GT_DI;
        end if;
    end if;
  end process;

  -- User Data Ready
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if ((reset_r(0) = '1') or (user_drdy_i = '1')) then
        user_drdy_i <= '0' ;
      elsif (cb_state = C_USER_DRP_OP) then
        user_drdy_i <= GT_DRDY;
      end if;
    end if;
  end process;

  USER_DRDY <= user_drdy_i;

  -- Active signal to indicate a Calibration Block operation
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if (cb_state = C_RESET) then
        ACTIVE <= '0';
      else
        if ( (not (cb_state = C_IDLE)) and
             (not (cb_state = C_USER_DRP_OP)) ) then
           ACTIVE <= '1';
        else
           ACTIVE <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Storing the value of RXDIGRX.  The value is written from the
  -- default parameter upon reset or when the user writes to DRP register in
  -- those bits location.
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if (reset_r(0) = '1') then
        rxdigrx_cache <= c_rxdigrx_bin;
      elsif ( (drp_state = C_DRP_WRITE) and
              (cb_state = C_USER_DRP_OP) and
              (user_daddr_r(5 downto 0) = c_rx_digrx_addr(5 downto 0)) ) then
        rxdigrx_cache <= user_di_r(1);
      end if;
    end if;
  end process;

  -- Storing the value of TXPOST_TAP_PD.  The value is written from the
  -- default parameter upon reset or when the user writes to DRP register in
  -- those bits location.
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if (reset_r(0) = '1') then
        txpost_tap_pd_cache <= c_txpost_tap_pd_bin;
      elsif ( (drp_state = C_DRP_WRITE) and
              (cb_state = C_USER_DRP_OP) and
              (user_daddr_r(5 downto 0) = c_tx_pt_addr(5 downto 0)) ) then
        txpost_tap_pd_cache <= user_di_r(12);
      end if;
    end if;
  end process;


  ----------------------------------------------------------------------------
  -- GT DRP Interface
  ----------------------------------------------------------------------------
  -- GT Data Output: the data output is generated either from a Signal Detect
  -- FSM operation or a user access.
  gt_do_r_sel <= sd_sel & '0' & user_sel;

  process (DCLK)
  begin
    if (rising_edge(DCLK)) then

      if (gt_do_r_sel(2) = '1') then
          gt_do_r <= sd_wr_wreg;
      elsif (gt_do_r_sel = "001") then
          gt_do_r <= user_di_r;
      else
          null;
      end if;

    end if;
  end process;

  GT_DO <= gt_do_r;

  -- GT DRP Address: the DRP address is generated either from a Signal Detect
  -- FSM operation, or a user access.  DRP address ranges from 0x40 to 0x7F.
  gt_daddr_sel <= sd_sel & '0' & user_sel;

  process (DCLK)
  begin
    if (rising_edge(DCLK)) then

        if (gt_daddr_sel(2) = '1') then
          GT_DADDR(5 downto 0) <= sd_addr_r(5 downto 0);
        elsif (gt_daddr_sel = "001") then
          GT_DADDR(5 downto 0) <= user_daddr_r(5 downto 0);
        else
          null;
        end if;

      GT_DADDR(7 downto 6) <= "01";

    end if;
  end process;

  -- GT Data Enable: the data enable is generated whenever there is a DRP
  -- Read or a DRP Write
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if (reset_r(0) = '1') then
        GT_DEN <= '0';
      else
        if ( (drp_state = C_DRP_IDLE) and
             ((drp_wr = '1') or (drp_rd = '1')) ) then
           GT_DEN <= '1';
        else
           GT_DEN <= '0';
        end if;
      end if;
    end if;
  end process;

  -- GT Data Write Enable
  GT_DWE <= '1' when (drp_state = C_DRP_WRITE) else '0';

  -- GT Data Ready
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      gt_drdy_r <= GT_DRDY;
    end if;
  end process;


  ----------------------------------------------------------------------------
  -- Calibration Block Internal Logic:  The different select signals are
  -- generated for a user DRP operations as well as internal Calibration Block
  -- accesses.
  ----------------------------------------------------------------------------
  sd_sel   <= '1' when (cb_state = C_SD_DRP_OP) else '0';
  user_sel <= '1' when (cb_state = C_USER_DRP_OP) else '0';


  ----------------------------------------------------------------------------
  -- Calibration Block (CB) FSM
  ----------------------------------------------------------------------------
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
       if (reset_r(0) = '1') then
          cb_state <= C_RESET;
       else
          cb_state <= cb_next_state;
       end if;
    end if;
  end process;

  process (cb_state, sd_req, user_req, gt_drdy_r)
    variable cb_fsm_name : string(1 to 25);
  begin
    case cb_state is

      when C_RESET =>

        cb_next_state <= C_IDLE;
        cb_fsm_name := ExtendString("C_RESET", 25);

      when C_IDLE =>

        if (sd_req = '1') then
          cb_next_state <= C_SD_DRP_OP;
        elsif (user_req = '1') then
          cb_next_state <= C_USER_DRP_OP;
        else
          cb_next_state <= C_IDLE;
        end if;

        cb_fsm_name :=  ExtendString("C_IDLE", 25);

      when C_SD_DRP_OP =>

        if (gt_drdy_r = '1') then
          cb_next_state <= C_IDLE;
        else
          cb_next_state <= C_SD_DRP_OP;
        end if;

        cb_fsm_name :=  ExtendString("C_SD_DRP_OP", 25);

      when C_USER_DRP_OP =>

        if (gt_drdy_r = '1') then
          cb_next_state <= C_IDLE;
        else
          cb_next_state <= C_USER_DRP_OP;
        end if;

        cb_fsm_name :=  ExtendString("C_USER_DRP_OP", 25);

      when others =>

        cb_next_state <= C_IDLE;
        cb_fsm_name :=  ExtendString("default", 25);

    end case;
  end process;

  ----------------------------------------------------------------------------
  -- Signal Detect Block Internal Logic
  ----------------------------------------------------------------------------
  -- Signal Detect Request for DRP operation
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if ((sd_state = C_SD_IDLE) or (sd_drp_done='1')) then
        sd_req <= '0' ;
      else
        sd_req <= sd_read or sd_write;
      end if;
    end if;
  end process;

  -- Indicates Signal Detect DRP Read
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if ((sd_state = C_SD_IDLE) or (sd_drp_done='1')) then
        sd_read <= '0';
      else
        if ( (sd_state = C_SD_RD_PT_ON) or
             (sd_state = C_SD_RD_RXDIGRX_ON) or
             (sd_state = C_SD_RD_RXDIGRX_RESTORE) or
             (sd_state = C_SD_RD_PT_OFF) ) then
          sd_read <= '1';
        else
          sd_read <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Indicates Signal Detect DRP Write
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if ((sd_state = C_SD_IDLE) or (sd_drp_done='1')) then
        sd_write <= '0' ;
      else
        if ( (sd_state = C_SD_WR_PT_ON) or
             (sd_state = C_SD_WR_RXDIGRX_ON) or
             (sd_state = C_SD_WR_RXDIGRX_RESTORE) or
             (sd_state = C_SD_WR_PT_OFF) ) then
          sd_write <=  '1';
        else
          sd_write <= '0' ;
        end if;
      end if;
    end if;
  end process;

  -- Signal Detect DRP Write Working Register
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if ((cb_state = C_SD_DRP_OP) and (sd_read='1') and (GT_DRDY='1')) then
        sd_wr_wreg <= GT_DI;
      else
        case sd_state is

          when C_SD_MD_PT_ON =>
            sd_wr_wreg <= sd_wr_wreg(15 downto 13) & '0' &
                          sd_wr_wreg(11 downto 0);
          when C_SD_MD_RXDIGRX_ON =>
            sd_wr_wreg <= sd_wr_wreg(15 downto 2) & '1' & sd_wr_wreg(0);
          when C_SD_MD_RXDIGRX_RESTORE =>
            sd_wr_wreg <= sd_wr_wreg(15 downto 2) & rxdigrx_cache &
                          sd_wr_wreg(0);
          when C_SD_MD_PT_OFF =>
            sd_wr_wreg <= sd_wr_wreg(15 downto 13) & txpost_tap_pd_cache &
                          sd_wr_wreg(11 downto 0);
          when others =>
            null;
        end case;
      end if;
    end if;
  end process;

  -- Generate DRP Addresses for Signal Detect
  process (sd_state)
  begin
    case sd_state is
      when C_SD_RD_PT_ON =>
        sd_addr_r(5 downto 0) <= c_tx_pt_addr(5 downto 0);
      when C_SD_WR_PT_ON =>
        sd_addr_r(5 downto 0) <= c_tx_pt_addr(5 downto 0);
      when C_SD_RD_PT_OFF =>
        sd_addr_r(5 downto 0) <= c_tx_pt_addr(5 downto 0);
      when C_SD_WR_PT_OFF =>
        sd_addr_r(5 downto 0) <= c_tx_pt_addr(5 downto 0);
      when C_SD_RD_RXDIGRX_ON =>
        sd_addr_r(5 downto 0) <= c_rx_digrx_addr(5 downto 0);
      when C_SD_WR_RXDIGRX_ON =>
        sd_addr_r(5 downto 0) <= c_rx_digrx_addr(5 downto 0);
      when C_SD_RD_RXDIGRX_RESTORE =>
        sd_addr_r(5 downto 0) <= c_rx_digrx_addr(5 downto 0);
      when C_SD_WR_RXDIGRX_RESTORE =>
        sd_addr_r(5 downto 0) <= c_rx_digrx_addr(5 downto 0);
      when others =>
        sd_addr_r(5 downto 0) <= c_tx_pt_addr(5 downto 0);
    end case;
  end process;

  -- Assert when Signal Detect DRP Operation is Complete
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if ((GT_DRDY  = '1') and (cb_state = C_SD_DRP_OP)) then
        sd_drp_done <= '1';
      else
        sd_drp_done <= '0';
      end if;
    end if;
  end process;

  -- GT_LOOPBACK, GT_TXENC8B10BUSE and GT_TXBYPASS8B10B
  --  Switch the GT11 to serial loopback mode and enable 8B10B when the Signal
  --  Detect is Low.
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if (reset_r(0) = '1') then
        GT_LOOPBACK <= "00";
      elsif (RX_SIGNAL_DETECT = '0') then
        GT_LOOPBACK <= "11";
      else
        GT_LOOPBACK <= USER_LOOPBACK;
      end if;
    end if;
  end process;

  GT_TXBYPASS8B10B <= USER_TXBYPASS8B10B when (TX_SIGNAL_DETECT = '1') else
                      "00000000";

  GT_TXENC8B10BUSE <= USER_TXENC8B10BUSE when (TX_SIGNAL_DETECT = '1') else
                      '1';

  ----------------------------------------------------------------------------
  -- Signal Detect Block FSM:  The SD FSM is triggered when RX_SIGNAL_DETECT
  -- goes Low
  ----------------------------------------------------------------------------
  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if (reset_r(0) = '1') then
        sd_state <= C_SD_IDLE;
      else
        sd_state <= sd_next_state;
      end if;
    end if;
  end process;

  process (sd_state, RX_SIGNAL_DETECT,sd_drp_done)
    variable sd_fsm_name : string(1 to 25);
  begin
    case sd_state is

      when C_SD_IDLE =>

        if (RX_SIGNAL_DETECT = '0') then
          sd_next_state <= C_SD_RD_PT_ON;
        else
          sd_next_state <= C_SD_IDLE;
        end if;

        sd_fsm_name := ExtendString("C_SD_IDLE", 25);

      when C_SD_RD_PT_ON =>

        if (sd_drp_done = '1') then
          sd_next_state <= C_SD_MD_PT_ON;
        else
          sd_next_state <= C_SD_RD_PT_ON;
        end if;

        sd_fsm_name := ExtendString("C_SD_RD_PT_ON", 25);

      when C_SD_MD_PT_ON =>

        sd_next_state <= C_SD_WR_PT_ON;
        sd_fsm_name := ExtendString("C_SD_MD_PT_ON", 25);

      when C_SD_WR_PT_ON =>

        if (sd_drp_done = '1') then
          sd_next_state <= C_SD_RD_RXDIGRX_ON;
        else
          sd_next_state <= C_SD_WR_PT_ON;
        end if;

        sd_fsm_name := ExtendString("C_SD_WR_PT_ON", 25);

      when C_SD_RD_RXDIGRX_ON =>

        if (sd_drp_done = '1') then
          sd_next_state <= C_SD_MD_RXDIGRX_ON;
        else
          sd_next_state <= C_SD_RD_RXDIGRX_ON;
        end if;

        sd_fsm_name := ExtendString("C_SD_RD_RXDIGRX_ON", 25);

      when C_SD_MD_RXDIGRX_ON =>

        sd_next_state <= C_SD_WR_RXDIGRX_ON;
        sd_fsm_name := ExtendString("C_SD_MD_RXDIGRX_ON", 25);

      when C_SD_WR_RXDIGRX_ON =>

        if (sd_drp_done = '1') then
          sd_next_state <= C_SD_WAIT;
        else
          sd_next_state <= C_SD_WR_RXDIGRX_ON;
        end if;

        sd_fsm_name := ExtendString("C_SD_WR_RXDIGRX_ON", 25);

      when C_SD_WAIT =>

        if (RX_SIGNAL_DETECT = '1') then
          sd_next_state <= C_SD_RD_RXDIGRX_RESTORE;
        else
          sd_next_state <= C_SD_WAIT;
        end if;

        sd_fsm_name := ExtendString("C_SD_WAIT", 25);

       when C_SD_RD_RXDIGRX_RESTORE =>

         if (sd_drp_done = '1') then
           sd_next_state <= C_SD_MD_RXDIGRX_RESTORE;
         else
           sd_next_state <= C_SD_RD_RXDIGRX_RESTORE;
         end if;

         sd_fsm_name := ExtendString("C_SD_RD_RXDIGRX_RESTORE", 25);

       when C_SD_MD_RXDIGRX_RESTORE =>

         sd_next_state <= C_SD_WR_RXDIGRX_RESTORE;
         sd_fsm_name := ExtendString("C_SD_MD_RXDIGRX_RESTORE", 25);

       when C_SD_WR_RXDIGRX_RESTORE =>

         if (sd_drp_done = '1') then
           sd_next_state <= C_SD_RD_PT_OFF;
         else
           sd_next_state <= C_SD_WR_RXDIGRX_RESTORE;
         end if;

         sd_fsm_name := ExtendString("C_SD_WR_RXDIGRX_RESTORE", 25);

      when C_SD_RD_PT_OFF =>

        if (sd_drp_done = '1') then
          sd_next_state <= C_SD_MD_PT_OFF;
        else
          sd_next_state <= C_SD_RD_PT_OFF;
        end if;

        sd_fsm_name := ExtendString("C_SD_RD_PT_OFF", 25);

      when C_SD_MD_PT_OFF =>

        sd_next_state <= C_SD_WR_PT_OFF;
        sd_fsm_name := ExtendString("C_SD_MD_PT_OFF", 25);

      when C_SD_WR_PT_OFF =>

        if (sd_drp_done = '1') then
          sd_next_state <= C_SD_IDLE;
        else
          sd_next_state <= C_SD_WR_PT_OFF;
        end if;

        sd_fsm_name := ExtendString("C_SD_WR_PT_OFF", 25);

       when others =>

         sd_next_state <= C_SD_IDLE;
         sd_fsm_name := ExtendString("default", 25);

        end case;
  end process;


  ----------------------------------------------------------------------------
  -- DRP Read/Write FSM
  ----------------------------------------------------------------------------
  -- Generate a read signal for the DRP
  drp_rd <= '1' when  ( ((cb_state = C_SD_DRP_OP) and (sd_read = '1')) or
                        ((cb_state = C_USER_DRP_OP) and (user_dwe_r = '0')) )
            else '0';

  -- Generate a write signal for the DRP
  drp_wr <= '1' when  ( ((cb_state = C_SD_DRP_OP) and (sd_write = '1')) or
                        ((cb_state = C_USER_DRP_OP) and (user_dwe_r = '1')) )
            else '0';


  process (DCLK)
  begin
    if (rising_edge(DCLK)) then
      if (reset_r(0) = '1') then
        drp_state <= C_DRP_IDLE;
      else
        drp_state <= drp_next_state;
      end if;
    end if;
  end process;

  process (drp_state, drp_rd, drp_wr, gt_drdy_r)
    variable drp_fsm_name: string(1 to 25);
  begin
    case drp_state is
      when C_DRP_IDLE =>

        if (drp_wr = '1') then
          drp_next_state <= C_DRP_WRITE;
        else
          if (drp_rd = '1') then
            drp_next_state <= C_DRP_READ;
          else
            drp_next_state <= C_DRP_IDLE;
          end if;
        end if;

        drp_fsm_name := ExtendString("C_DRP_IDLE", 25);

      when C_DRP_READ =>

        drp_next_state <= C_DRP_WAIT;
        drp_fsm_name := ExtendString("C_DRP_READ", 25);

      when C_DRP_WRITE =>

        drp_next_state <= C_DRP_WAIT;
        drp_fsm_name := ExtendString("C_DRP_WRITE", 25);

      when C_DRP_WAIT =>

        if (gt_drdy_r = '1') then
          drp_next_state <= C_DRP_COMPLETE;
        else
          drp_next_state <= C_DRP_WAIT;
        end if;

        drp_fsm_name := ExtendString("C_DRP_WAIT", 25);

      when C_DRP_COMPLETE =>

        drp_next_state <= C_DRP_IDLE;
        drp_fsm_name := ExtendString("C_DRP_COMPLETE", 25);

      when others =>
        drp_next_state <= C_DRP_IDLE;
        drp_fsm_name := ExtendString("default", 25);

    end case;
  end process;

end rtl;
