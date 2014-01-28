------------------------------------------------------------------------------
-- $Id: v4_gt11_init_rx.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------
-- File       : v4_gt11_init_rx.vhd
-- Author     : Xilinx Inc.
------------------------------------------------------------------------
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
------------------------------------------------------------------------
-- Description: This file is based on a file provided by the RocketIO
-- Wizard v1.1 to implement the reset/initialisation state machines for
-- a GT11 as detailed in the Virtex-4 RocketIO Multi-Gigabit Transceiver
-- User Guide (UG076).

-- Specifically this file will generate GT11 resets as described in
-- figure 2-18 "Flow Chart ot Receiver Reset Sequence Where RX 
-- Buffer is Used" (UG076 v3.0 May 23, 2006)
--               
--               This is based on Coregen Wrappers from ISE J.38 (9.2i)
--               Wrapper version 4.5
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

--***********************************Entity Declaration*****************

entity v4_gt11_init_rx is
generic (
    C_SIMULATION  : integer := 0       -- Set to 1 for simulation
);
port
(
    clk           :  in  std_logic;
    usrclk2       :  in  std_logic;
    start_init    :  in  std_logic;
    lock          :  in  std_logic;
    usrclk_stable :  in  std_logic;
    pcs_error     :  in  std_logic;
    pma_reset     :  out std_logic;
    sync          :  out std_logic;
    pcs_reset     :  out std_logic;
    ready         :  out std_logic

);
end v4_gt11_init_rx;

architecture rtl of v4_gt11_init_rx is

--********************************Parameter Declarations****************
------------------------------------------------------------------------
-- Delays - these numbers are defined by the number of USRCLK needed in 
--          each state for each reset.  Refer to the User Guide on the 
--          block diagrams on the reset and the required delay.
------------------------------------------------------------------------
constant C_DELAY_PMA_RESET : unsigned(2 downto 0) := "101";      -- 5 
constant C_DELAY_SYNC      : unsigned(7 downto 0) := "01100111"; -- 103
constant C_DELAY_PCS_RESET : unsigned(2 downto 0) := "101";      -- 5
constant C_DELAY_WAIT_PCS  : unsigned(3 downto 0) := "1000";     -- 8
constant C_DELAY_WAIT_READY: unsigned(7 downto 0) := "01100111"; -- 103
constant C_PCS_ERROR_COUNT : unsigned(4 downto 0) := "10000";    -- 16


------------------------------------------------------------------------
-- GT11 Initialization FSM
------------------------------------------------------------------------
constant  C_RESET        : std_logic_vector(7 downto 0) := "00000001";
constant  C_PMA_RESET    : std_logic_vector(7 downto 0) := "00000010";
constant  C_WAIT_LOCK    : std_logic_vector(7 downto 0) := "00000100";
constant  C_SYNC         : std_logic_vector(7 downto 0) := "00001000";
constant  C_PCS_RESET    : std_logic_vector(7 downto 0) := "00010000";
constant  C_WAIT_PCS     : std_logic_vector(7 downto 0) := "00100000";
constant  C_ALMOST_READY : std_logic_vector(7 downto 0) := "01000000";
constant  C_READY        : std_logic_vector(7 downto 0) := "10000000";

--*******************************Register Declarations******************

signal reset_r                    : std_logic_vector(1 downto 0);
signal pcs_reset_r                : std_logic_vector(1 downto 0);
signal lock_r1                    : std_logic;
signal lock_r2                    : std_logic;
signal lock_r3                    : std_logic;
signal usrclk_stable_r1           : std_logic;
signal usrclk_stable_r2           : std_logic;
signal pcs_error_r1               : std_logic;
signal pcs_error_r2               : std_logic;
signal pma_reset_count_r          : unsigned(2 downto 0);
signal pcs_reset_count_r          : unsigned(2 downto 0);
signal wait_pcs_count_r           : unsigned(3 downto 0);
signal pcs_error_count_r          : unsigned(4 downto 0);
signal wait_ready_count_r         : unsigned(7 downto 0);
signal sync_count_r               : unsigned(7 downto 0);
signal init_state_r               : std_logic_vector(7 downto 0);
signal init_next_state_r          : std_logic_vector(7 downto 0);
signal sync_r                     : std_logic_vector(1 downto 0);
signal init_fsm_name              : std_logic_vector(40*7 downto 0);
signal init_fsm_wait_lock_check   : std_logic;

attribute ASYNC_REG                         : string;
attribute ASYNC_REG of reset_r              : signal is "TRUE";
attribute ASYNC_REG of pcs_reset_r          : signal is "TRUE";
attribute ASYNC_REG of sync_r               : signal is "TRUE";
attribute ASYNC_REG of lock_r1              : signal is "TRUE";
attribute ASYNC_REG of usrclk_stable_r1     : signal is "TRUE";
attribute ASYNC_REG of pcs_error_r1         : signal is "TRUE";


--*******************************Wire Declarations**********************

signal pma_reset_done_i         :  std_logic;

signal lock_pulse_i             :  std_logic;
signal stage_1_enable_i         :  std_logic;
signal stage_2_enable_i         :  std_logic;
signal stage_3_enable_i         :  std_logic;
signal lockupdate_ready_i       :  std_logic;
signal shift_register_1_enable_i:  std_logic;
signal shift_register_2_enable_i:  std_logic;
signal shift_register_3_enable_i:  std_logic;
signal shift_register_0_d_i     :  std_logic;
signal shift_register_1_d_i     :  std_logic;
signal shift_register_2_d_i     :  std_logic;
signal shift_register_3_d_i     :  std_logic;
signal shift_register_0_q_i     :  std_logic;
signal shift_register_1_q_i     :  std_logic;
signal shift_register_2_q_i     :  std_logic;
signal shift_register_3_q_i     :  std_logic;

signal sync_done_i              :  std_logic;
signal sync_async               :  std_logic;

signal pcs_reset_done_i         :  std_logic;
signal pcs_reset_async          :  std_logic;
signal wait_pcs_done_i          :  std_logic;
signal pcs_error_count_done_i   :  std_logic;
signal wait_ready_done_i        :  std_logic;
signal tied_to_ground_i         :  std_logic;
signal tied_to_vcc_i            :  std_logic;
signal not_lock_i               :  std_logic;

--**************************** Function Declaration ********************

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

--*********************************Main Body of Code********************

begin
------------------------------------------------------------------------
-- Static Assignments
------------------------------------------------------------------------
tied_to_ground_i <='0';
tied_to_vcc_i    <= '1';

------------------------------------------------------------------------
-- Synchronize Reset
------------------------------------------------------------------------
process (clk, start_init)
begin
  if (start_init = '1') then
    reset_r <= "11";
  elsif (rising_edge(clk)) then
    reset_r <= '0' & reset_r(1);
  end if;
end process;
        
------------------------------------------------------------------------
-- Synchronize lock
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if (reset_r(0) = '1') then
            lock_r1 <= '0';
            lock_r2 <= '0';
            lock_r3 <= '0';
        else
            lock_r1 <= lock;
            lock_r2 <= lock_r1;
            lock_r3 <= lock_r2;
        end if;
    end if;
end process;

------------------------------------------------------------------------
-- Synchronize usrclk_stable
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if (reset_r(0) = '1') then
            usrclk_stable_r1 <= '0';
            usrclk_stable_r2 <= '0';
        else
            usrclk_stable_r1 <= usrclk_stable;
            usrclk_stable_r2 <= usrclk_stable_r1;
        end if;
    end if;
end process;

------------------------------------------------------------------------
-- Synchronize PCS error
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if(reset_r(0) = '1') then
            pcs_error_r1 <= '0';
            pcs_error_r2 <= '0';
        else
            pcs_error_r1 <= pcs_error;
            pcs_error_r2 <= pcs_error_r1;
        end if;
    end if;
end process;
        
------------------------------------------------------------------------
-- ready, PMA and PCS reset signals
------------------------------------------------------------------------
pma_reset <= '1' when (init_state_r = C_PMA_RESET) else '0';
ready     <= '1' when (init_state_r = C_READY) else '0';

pcs_reset_async <= '1' when (init_state_r = C_PCS_RESET) else '0';

-- Resynchronise the PCS reset onto the USRCLK2 domain
process (usrclk2, pcs_reset_async)
begin
  if (pcs_reset_async = '1') then
    pcs_reset_r <= "11";
  elsif (rising_edge(usrclk2)) then
    pcs_reset_r <= '0' & pcs_reset_r(1);
  end if;
end process;

pcs_reset <= pcs_reset_r(0);


sync_async <= '1' when (init_state_r = C_SYNC) else '0';

-- Resynchronise the PCS SYNC onto the USRCLK2 domain
process (usrclk2, sync_async)
begin
  if (sync_async = '1') then
    sync_r <= "11";
  elsif (rising_edge(usrclk2)) then
    sync_r <= '0' & sync_r(1);
  end if;
end process;

sync <= sync_r(0);


------------------------------------------------------------------------
-- Counter for holding PMA reset for an amount of C_DELAY_PMA_RESET
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if(init_state_r /= C_PMA_RESET) then
            pma_reset_count_r <= C_DELAY_PMA_RESET;
        else
            pma_reset_count_r <= pma_reset_count_r - 1;
        end if;
    end if;
end process;

pma_reset_done_i <= '1' when (pma_reset_count_r = 1) else '0';

------------------------------------------------------------------------
-- Counter for the LOCKUPDATE cycles for RXLOCK
------------------------------------------------------------------------
    for_simulation: if (C_SIMULATION /= 0 ) generate
    begin
        lockupdate_ready_i <= tied_to_vcc_i;
    end generate for_simulation;

    for_hardware:  if (C_SIMULATION = 0 ) generate
    begin
        ----------------------------------------------------------------------
        -- Counter for the LOCKUPDATE cycles for RXLOCK:  This is built with
        -- SRL16s. Currently, we need to wait for 16 LOCKUPDATE cycles to
        -- qualify the RXLOCK signal.  Each LOCKUPDATE = 1024 REFCLK cycles.
        -- In this module, we assume 1 REFCLK = 1 USRCLK (please adjust the
        -- address of the fourth SRL16 stage as neccessary).  The whole four
        -- stages give 16,304 cycles of delay (16 * 16 * 16 * 4); note that
        -- the last stage has an extra FF at the end.
        ----------------------------------------------------------------------
        -- Create a pulse from RXLOCK to initialize SRL16's.
        lock_pulse_i <= lock_r2 and not lock_r3;

        -- SRL16 Stage Zero - First stage of shifting
        shift_register_0_d_i <= lock_r2 and (lock_pulse_i or stage_1_enable_i);

        shift_register_0 : SRL16E 
        port map
        (
            Q    =>  shift_register_0_q_i,
            A0   =>  tied_to_ground_i,
            A1   =>  tied_to_vcc_i,
            A2   =>  tied_to_vcc_i,
            A3   =>  tied_to_vcc_i,
            CE   =>  tied_to_vcc_i,
            CLK  =>  CLK,
            D    =>  shift_register_0_d_i
        );

        flop_stage_0 : FDE 
        port map
        (
            Q  =>  stage_1_enable_i,
            C  =>  CLK,
            CE =>  tied_to_vcc_i,
            D  =>  shift_register_0_q_i
        );

        -- SRL16 Stage One - Second stage of shifting
        shift_register_1_d_i <= lock_r2 and (lock_pulse_i or
                                (stage_1_enable_i and stage_2_enable_i));
        shift_register_1_enable_i <= not lock_r3 or stage_1_enable_i;

        shift_register_1 : SRL16E 
        port map
        (
            Q    =>  shift_register_1_q_i,
            A0   =>  tied_to_ground_i,
            A1   =>  tied_to_vcc_i,
            A2   =>  tied_to_vcc_i,
            A3   =>  tied_to_vcc_i,
            CE   =>  shift_register_1_enable_i,
            CLK  =>  CLK,
            D    =>  shift_register_1_d_i
        );

        flop_stage_1 : FDE 
        port map
        (
            Q  =>  stage_2_enable_i,
            C  =>  CLK,
            CE =>  shift_register_1_enable_i,
            D  =>  shift_register_1_q_i
        );

        -- SRL16 Stage Two - Third stage of shifting
        shift_register_2_d_i <= lock_r2 and (lock_pulse_i or
                                (stage_1_enable_i and stage_2_enable_i and
                                stage_3_enable_i));

        shift_register_2_enable_i <= not lock_r3 or
                                     (stage_1_enable_i and stage_2_enable_i);

        shift_register_2 : SRL16E 
        port map
        (
            Q    =>  shift_register_2_q_i,
            A0   =>  tied_to_ground_i,
            A1   =>  tied_to_vcc_i,
            A2   =>  tied_to_vcc_i,
            A3   =>  tied_to_vcc_i,
            CE   =>  shift_register_2_enable_i,
            CLK  =>  CLK,
            D    =>  shift_register_2_d_i
        );

        flop_stage_2 : FDE 
        port map
        (
            Q  =>  stage_3_enable_i,
            C  =>  CLK,
            CE =>  shift_register_2_enable_i,
            D  =>  shift_register_2_q_i
        );

        -- SRL16 Stage Three - Fourth stage of shifting
        -- LOCKUPDATE ready is redundant here in resetting the SRL16 since
        -- the flop is already reset by RXLOCK from the MGT
        shift_register_3_d_i <= lock_r2 and (lock_pulse_i or 
                                (stage_1_enable_i and stage_2_enable_i and
                        stage_3_enable_i and lockupdate_ready_i));
        
        shift_register_3_enable_i <= not lock_r3 or
                                  (stage_1_enable_i and stage_2_enable_i and
                                  stage_3_enable_i and not lockupdate_ready_i);
        
        shift_register_3 : SRL16E 
        port map
        (
            Q    =>  shift_register_3_q_i,
            A0   =>  tied_to_vcc_i,
            A1   =>  tied_to_vcc_i,
            A2   =>  tied_to_ground_i,
            A3   =>  tied_to_ground_i,
            CE   =>  shift_register_3_enable_i,
            CLK  =>  CLK,
            D    =>  shift_register_3_d_i
        );

        not_lock_i <= not lock_r2;

        flop_stage_3 : FDRE 
        port map
        (
            Q  =>  lockupdate_ready_i,
            C  =>  CLK,
            CE =>  shift_register_3_enable_i,
            D  =>  shift_register_3_q_i,
            R  =>  not_lock_i
        );
    end generate for_hardware;


------------------------------------------------------------------------------
-- Counter for holding SYNC for an amount of C_DELAY_SYNC
------------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if(init_state_r /= C_SYNC) then
            sync_count_r <= C_DELAY_SYNC;
        else
            sync_count_r <= sync_count_r - 1;
        end if;
    end if;
end process;
            
sync_done_i <= '1' when (sync_count_r = 1) else '0';


------------------------------------------------------------------------
-- Counter for holding PCS reset for an amount of C_DELAY_PCS_RESET
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if(init_state_r /= C_PCS_RESET) then
            pcs_reset_count_r <= C_DELAY_PCS_RESET;
        else
            pcs_reset_count_r <= pcs_reset_count_r - 1;
        end if;
    end if;
end process;
           
pcs_reset_done_i <= '1' when (pcs_reset_count_r = 1) else '0';

------------------------------------------------------------------------
-- Counter for waiting C_DELAY_WAIT_PCS after de-assertion of PCS reset
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if(init_state_r /= C_WAIT_PCS) then
            wait_pcs_count_r <= C_DELAY_WAIT_PCS;
        else
            wait_pcs_count_r <= wait_pcs_count_r - 1;
        end if;
    end if;
end process;
        
wait_pcs_done_i <= '1' when (wait_pcs_count_r = 1) else '0';

------------------------------------------------------------------------
-- Counter for PCS error
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if(init_state_r = C_PMA_RESET) then
            pcs_error_count_r <= C_PCS_ERROR_COUNT;
        elsif (((init_state_r = C_ALMOST_READY) or (init_state_r = C_READY)) and (pcs_error_r2 and lock_r3)='1') then
            pcs_error_count_r <= pcs_error_count_r - 1;
        end if;
    end if;
end process;
        
pcs_error_count_done_i <= '1' when (pcs_error_count_r = 1) else '0';

------------------------------------------------------------------------
-- Counter for the ready signal
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if((init_state_r /= C_ALMOST_READY) or (pcs_error_r2 = '1')) then
            wait_ready_count_r <= C_DELAY_WAIT_READY;
        elsif(pcs_error_r2='0') then
            wait_ready_count_r <= wait_ready_count_r - 1;
        end if;
    end if;
end process;

wait_ready_done_i <= '1' when (wait_ready_count_r = 1) else '0';


------------------------------------------------------------------------
-- GT11 Initialization FSM - This FSM is used to initialize the GT11 block
--   asserting the PMA and PCS reset in sequence.  It also takes into account
--   of any error that may happen during initialization.  The block uses
--   USRCLK as reference for the delay.  DO NOT use the output of the GT11
--   clocks for this reset module, as the output clocks may change when reset
--   is applied to the GT11.  Use a system clock, and make sure that the
--   wait time for each state equals the specified number of USRCLK cycles.
--
-- The following steps are applied:
--   1. C_RESET:  Upon system reset of this block, PMA reset will be asserted
--   2. C_PMA_RESET:  PMA reset is held for 3 USRCLK cycles
--   3. C_WAIT_LOCK:  Wait for LOCK.  After LOCK is asserted, wait for 16
--      LOCKUPDATE cycles and wait for the USRCLK of the GT11s to be stabled
--      before going to the next state to assert the PCS reset.  If LOCK gets
--      de-asserted, we reset the counter and wait for LOCK again.
--   4. C_SYNC:  Assert SYNG for 64 SYNC cycles.  If LOCK gets de-asserted, we
--      go back to Step 3.
--   5. C_PCS_RESET:  Assert PCS reset for 3 USRCLK cycles.  If LOCK gets
--      de-asserted, we go back to Step 3.
--   6. C_WAIT_PCS:  After de-assertion of PCS reset, wait 5 USRCLK cycles.
--      If LOCK gets de-asserted, we go back to Step 3.
--   7. C_ALMOST_READY:  Go to the Almost Ready state.  If LOCK gets
--      de-asserted, we go back to Step 3.  If there is a PCS error
--      (i.e. buffer error) detected while LOCK is high, we go back to Step 4.
--      If we cycle PCS reset for an N number of C_PCS_ERROR_COUNT, we go back
--      to Step 1 to do a PMA reset.
--   8. C_READY:  Go to the Ready state.  We reach this state after waiting
--      64 USRCLK cycles without any PCS errors.  We assert the READY signal
--      to denote that this block finishes initializing the GT11.  If there is
--      a PCS error during this state, we go back to Step 4.  If LOCK is lost,
--      we go back to Step 3.
------------------------------------------------------------------------------

process (clk)
begin 
  if (rising_edge(clk)) then
    if (reset_r(0) = '1') then
      init_state_r <= C_RESET;
    else
      init_state_r <= init_next_state_r;
    end if;
  end if;
end process;

init_fsm_wait_lock_check <= lock_r3 and usrclk_stable_r2 and lockupdate_ready_i;

process (reset_r(0), pma_reset_done_i, init_fsm_wait_lock_check, lock_r3,
         pcs_reset_done_i, wait_pcs_done_i, pcs_error_r2,wait_ready_done_i,
         pcs_error_count_done_i, sync_done_i)
  variable init_fsm_name : string(1 to 25);
begin
  case init_state_r is
    
    when C_RESET =>
      
      if (reset_r(0) = '1') then
        init_next_state_r <= C_RESET;
      else
        init_next_state_r <= C_PMA_RESET;
      end if;
      init_fsm_name := ExtendString("C_RESET", 25);

    when C_PMA_RESET =>

      if (pma_reset_done_i = '1') then
        init_next_state_r <= C_WAIT_LOCK;
      else
        init_next_state_r <= C_PMA_RESET;
      end if;
      init_fsm_name := ExtendString("C_PMA_RESET", 25);

    when C_WAIT_LOCK =>
      
      if(init_fsm_wait_lock_check = '1') then
        init_next_state_r <= C_SYNC;
      else
        init_next_state_r <= C_WAIT_LOCK;
      end if;
      init_fsm_name := ExtendString("C_WAIT_LOCK", 25);

    when C_SYNC =>
      if (lock_r3 = '1') then
        if (sync_done_i = '1') then
          init_next_state_r <= C_PCS_RESET;
        else
          init_next_state_r <= C_SYNC;
        end if;
      else
        init_next_state_r <= C_WAIT_LOCK;
      end if;
      init_fsm_name := ExtendString("C_SYNC", 25);

    when C_PCS_RESET =>
      if (lock_r3 = '1') then
        if (pcs_reset_done_i = '1') then
          init_next_state_r <= C_WAIT_PCS;
        else
          init_next_state_r <= C_PCS_RESET;
        end if;
      else
        init_next_state_r <= C_WAIT_LOCK;
      end if;
      init_fsm_name := ExtendString("C_PCS_RESET", 25);

    when C_WAIT_PCS =>
      if (lock_r3='1') then
        if (wait_pcs_done_i = '1') then
          init_next_state_r <= C_ALMOST_READY;
        else
          init_next_state_r <= C_WAIT_PCS;
        end if;
      else
        init_next_state_r <= C_WAIT_LOCK;
      end if;
      init_fsm_name := ExtendString("C_WAIT_PCS", 25);

    when C_ALMOST_READY =>
      if (lock_r3 = '0') then
        init_next_state_r <= C_WAIT_LOCK;
      elsif ((pcs_error_r2 ='1') and (pcs_error_count_done_i = '0')) then
        init_next_state_r <= C_SYNC;
      elsif ((pcs_error_r2 ='1') and (pcs_error_count_done_i = '1')) then
        init_next_state_r <= C_PMA_RESET;
      elsif (wait_ready_done_i = '1') then
        init_next_state_r <= C_READY;
      else
        init_next_state_r <= C_ALMOST_READY;
      end if;
      init_fsm_name := ExtendString("C_ALMOST_READY", 25);

    when C_READY =>
      if ((lock_r3 = '1') and (pcs_error_r2 = '0')) then
        init_next_state_r <= C_READY;
      elsif ((lock_r3 = '1') and (pcs_error_r2 = '1')) then
        init_next_state_r <= C_PCS_RESET;
      else
        init_next_state_r <= C_WAIT_LOCK;
      end if;
      init_fsm_name := ExtendString("C_READY", 25);

    when others =>
      init_next_state_r <= C_RESET;
      init_fsm_name := ExtendString("C_RESET", 25);

    end case;
end process;

end rtl;

