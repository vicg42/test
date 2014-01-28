------------------------------------------------------------------------------
-- $Id: v6_sgmii_rocketio_wrapper.vhd,v 1.1.4.40 2010/06/16 14:27:03 mwelter Exp $
------------------------------------------------------------------------------
-- File       : v6_sgmii_rocketio_wrapper.vhd
-- Author     : Xilinx
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version : 1.3
--  \   \         Application : Virtex-6 FPGA RocketIO GTX Transceiver Wizard
--  /   /         Filename : rocketio_wrapper.vhd
-- /___/   /\     Timestamp :
-- \   \  /  \
--  \___\/\___\
--
--
-- Module ROCKETIO_WRAPPER (a GTX Wrapper)
-- Generated by Xilinx Virtex-6 FPGA RocketIO GTX Transceiver Wizard
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
--               This is based on Coregen Wrappers from ISE L (11.3i)
--               Wrapper version 1.3
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

--***************************** Entity Declaration ****************************

entity v6_sgmii_rocketio_wrapper is
generic
(
    -- Simulation attributes
    WRAPPER_SIM_GTXRESET_SPEEDUP    : integer   := 0 -- Set to 1 to speed up sim reset
);
port
(

    --_________________________________________________________________________
    --_________________________________________________________________________
    --GTX0  (X0Y8)

    ------------------------ Loopback and Powerdown Ports ----------------------
    GTX0_LOOPBACK_IN                        : in   std_logic_vector(2 downto 0);
    GTX0_RXPOWERDOWN_IN                     : in   std_logic_vector(1 downto 0);
    GTX0_TXPOWERDOWN_IN                     : in   std_logic_vector(1 downto 0);
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GTX0_RXCHARISCOMMA_OUT                  : out  std_logic_vector(1 downto 0);
    GTX0_RXCHARISK_OUT                      : out  std_logic_vector(1 downto 0);
    GTX0_RXDISPERR_OUT                      : out  std_logic_vector(1 downto 0);
    GTX0_RXNOTINTABLE_OUT                   : out  std_logic_vector(1 downto 0);
    GTX0_RXRUNDISP_OUT                      : out  std_logic_vector(1 downto 0);
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GTX0_RXCLKCORCNT_OUT                    : out  std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GTX0_RXENMCOMMAALIGN_IN                 : in   std_logic;
    GTX0_RXENPCOMMAALIGN_IN                 : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    GTX0_RXDATA_OUT                         : out  std_logic_vector(15 downto 0);
    GTX0_RXRECCLK_OUT                       : out  std_logic;
    GTX0_RXRESET_IN                         : in   std_logic;
    GTX0_RXUSRCLK2_IN                       : in   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GTX0_RXELECIDLE_OUT                     : out  std_logic;
    GTX0_RXN_IN                             : in   std_logic;
    GTX0_RXP_IN                             : in   std_logic;
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GTX0_RXBUFRESET_IN                      : in   std_logic;
    GTX0_RXBUFSTATUS_OUT                    : out  std_logic_vector(2 downto 0);
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GTX0_GTXRXRESET_IN                      : in   std_logic;
    GTX0_MGTREFCLKRX_IN                     : in   std_logic;
    GTX0_PLLRXRESET_IN                      : in   std_logic;
    GTX0_RXPLLLKDET_OUT                     : out  std_logic;
    GTX0_RXRESETDONE_OUT                    : out  std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GTX0_TXCHARDISPMODE_IN                  : in   std_logic;
    GTX0_TXCHARDISPVAL_IN                   : in   std_logic;
    GTX0_TXCHARISK_IN                       : in   std_logic;
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GTX0_TXDATA_IN                          : in   std_logic_vector(7 downto 0);
    GTX0_TXOUTCLK_OUT                       : out  std_logic;
    GTX0_TXRESET_IN                         : in   std_logic;
    GTX0_TXUSRCLK2_IN                       : in   std_logic;
    ---------------- Transmit Ports - TX Driver and OOB signaling --------------
    GTX0_TXN_OUT                            : out  std_logic;
    GTX0_TXP_OUT                            : out  std_logic;
    ----------- Transmit Ports - TX Elastic Buffer and Phase Alignment ---------
    GTX0_TXBUFSTATUS_OUT                    : out  std_logic_vector(1 downto 0);
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GTX0_GTXTXRESET_IN                      : in   std_logic;
    GTX0_TXRESETDONE_OUT                    : out  std_logic


);
end v6_sgmii_rocketio_wrapper;

architecture RTL of v6_sgmii_rocketio_wrapper is

--***************************** Signal Declarations *****************************

    -- ground and tied_to_vcc_i signals
    signal  tied_to_ground_i                :   std_logic;
    signal  tied_to_ground_vec_i            :   std_logic_vector(63 downto 0);
    signal  tied_to_vcc_i                   :   std_logic;

    signal  gtx0_share_rxpll_i           :   std_logic_vector(1 downto 0);
    signal  gtx0_mgtrefclkrx_i           :   std_logic_vector(1 downto 0);

--********************************* Main Body of Code**************************

begin

    tied_to_ground_i                    <= '0';
    tied_to_ground_vec_i(63 downto 0)   <= (others => '0');
    tied_to_vcc_i                       <= '1';

    gtx0_mgtrefclkrx_i <= (tied_to_ground_i & GTX0_MGTREFCLKRX_IN);


    --------------------------- GTX Instances  -------------------------------


    --_________________________________________________________________________
    --_________________________________________________________________________
    --GTX0  (X0Y8)

    gtx0_rocketio_wrapper_i : entity xps_ll_temac_v2_03_a.v6_sgmii_rocketio_wrapper_gtx(RTL)
    generic map
    (
        -- Simulation attributes
        GTX_SIM_GTXRESET_SPEEDUP    => WRAPPER_SIM_GTXRESET_SPEEDUP,

        -- Share RX PLL parameter
        GTX_TX_CLK_SOURCE           => "RXPLL",
        -- Save power parameter
        GTX_POWER_SAVE              => "0000110100"
    )
    port map
    (
        ------------------------ Loopback and Powerdown Ports ----------------------
        LOOPBACK_IN                     =>      GTX0_LOOPBACK_IN,
        RXPOWERDOWN_IN                  =>      GTX0_RXPOWERDOWN_IN,
        TXPOWERDOWN_IN                  =>      GTX0_TXPOWERDOWN_IN,
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        RXCHARISCOMMA_OUT               =>      GTX0_RXCHARISCOMMA_OUT,
        RXCHARISK_OUT                   =>      GTX0_RXCHARISK_OUT,
        RXDISPERR_OUT                   =>      GTX0_RXDISPERR_OUT,
        RXNOTINTABLE_OUT                =>      GTX0_RXNOTINTABLE_OUT,
        RXRUNDISP_OUT                   =>      GTX0_RXRUNDISP_OUT,
        ------------------- Receive Ports - Clock Correction Ports -----------------
        RXCLKCORCNT_OUT                 =>      GTX0_RXCLKCORCNT_OUT,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        RXENMCOMMAALIGN_IN              =>      GTX0_RXENMCOMMAALIGN_IN,
        RXENPCOMMAALIGN_IN              =>      GTX0_RXENPCOMMAALIGN_IN,
        ------------------- Receive Ports - RX Data Path interface -----------------
        RXDATA_OUT                      =>      GTX0_RXDATA_OUT,
        RXRECCLK_OUT                    =>      GTX0_RXRECCLK_OUT,
        RXRESET_IN                      =>      GTX0_RXRESET_IN,
        RXUSRCLK2_IN                    =>      GTX0_RXUSRCLK2_IN,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        RXELECIDLE_OUT                  =>      GTX0_RXELECIDLE_OUT,
        RXN_IN                          =>      GTX0_RXN_IN,
        RXP_IN                          =>      GTX0_RXP_IN,
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        RXBUFRESET_IN                   =>      GTX0_RXBUFRESET_IN,
        RXBUFSTATUS_OUT                 =>      GTX0_RXBUFSTATUS_OUT,
        ------------------------ Receive Ports - RX PLL Ports ----------------------
        GTXRXRESET_IN                   =>      GTX0_GTXRXRESET_IN,
        MGTREFCLKRX_IN                  =>      gtx0_mgtrefclkrx_i,
        PLLRXRESET_IN                   =>      GTX0_PLLRXRESET_IN,
        RXPLLLKDET_OUT                  =>      GTX0_RXPLLLKDET_OUT,
        RXRESETDONE_OUT                 =>      GTX0_RXRESETDONE_OUT,
        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TXCHARDISPMODE_IN               =>      GTX0_TXCHARDISPMODE_IN,
        TXCHARDISPVAL_IN                =>      GTX0_TXCHARDISPVAL_IN,
        TXCHARISK_IN                    =>      GTX0_TXCHARISK_IN,
        ------------------ Transmit Ports - TX Data Path interface -----------------
        TXDATA_IN                       =>      GTX0_TXDATA_IN,
        TXOUTCLK_OUT                    =>      GTX0_TXOUTCLK_OUT,
        TXRESET_IN                      =>      GTX0_TXRESET_IN,
        TXUSRCLK2_IN                    =>      GTX0_TXUSRCLK2_IN,
        ---------------- Transmit Ports - TX Driver and OOB signaling --------------
        TXN_OUT                         =>      GTX0_TXN_OUT,
        TXP_OUT                         =>      GTX0_TXP_OUT,
        ----------- Transmit Ports - TX Elastic Buffer and Phase Alignment ---------
        TXBUFSTATUS_OUT                 =>      GTX0_TXBUFSTATUS_OUT,
        ----------------------- Transmit Ports - TX PLL Ports ----------------------
        GTXTXRESET_IN                   =>      GTX0_GTXTXRESET_IN,
        MGTREFCLKTX_IN                  =>      gtx0_mgtrefclkrx_i,
        PLLTXRESET_IN                   =>      tied_to_ground_i,
        TXPLLLKDET_OUT                  =>      open,
        TXRESETDONE_OUT                 =>      GTX0_TXRESETDONE_OUT

    );


end RTL;
