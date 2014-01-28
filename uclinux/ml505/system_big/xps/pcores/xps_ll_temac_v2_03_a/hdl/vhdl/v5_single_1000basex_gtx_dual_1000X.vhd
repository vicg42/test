------------------------------------------------------------------------------
-- $Id: v5_single_1000basex_gtx_dual_1000X.vhd,v 1.1.4.39 2009/11/17 07:11:37 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : 1000BASE-X RocketIO wrapper
-- Project    : Virtex-5 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v5_single_1000basex_gtx_dual_1000X.vhd
-- Author     : Xilinx
-------------------------------------------------------------------------------
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
-- Description:  This is the VHDL instantiation of a Virtex-5 GTX    
--               RocketIO tile for the Embedded Ethernet MAC.
--
--               Two GTX's must be instantiated regardless of how many  
--               GTXs are used in the MGT tile. 
--               This is based on Coregen Wrappers from ISE L (11.1i)
--               Wrapper version 1.6
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library UNISIM;
use UNISIM.Vcomponents.ALL;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

entity v5_single_1000basex_gtx_dual_1000X is
  generic (
           C_INCLUDE_IO               : integer          := 1
          );
   port (
          RESETDONE_0           : out   std_logic;
          ENMCOMMAALIGN_0       : in    std_logic; 
          ENPCOMMAALIGN_0       : in    std_logic; 
          LOOPBACK_0            : in    std_logic;
          POWERDOWN_0           : in    std_logic;
          RXUSRCLK_0            : in    std_logic;
          RXUSRCLK2_0           : in    std_logic;
          RXRESET_0             : in    std_logic;          
          TXCHARDISPMODE_0      : in    std_logic; 
          TXCHARDISPVAL_0       : in    std_logic; 
          TXCHARISK_0           : in    std_logic; 
          TXDATA_0              : in    std_logic_vector (7 downto 0); 
          TXUSRCLK_0            : in    std_logic; 
          TXUSRCLK2_0           : in    std_logic; 
          TXRESET_0             : in    std_logic; 
          RXCHARISCOMMA_0       : out   std_logic; 
          RXCHARISK_0           : out   std_logic;
          RXCLKCORCNT_0         : out   std_logic_vector (2 downto 0);           
          RXDATA_0              : out   std_logic_vector (7 downto 0); 
          RXDISPERR_0           : out   std_logic; 
          RXNOTINTABLE_0        : out   std_logic;
          RXRUNDISP_0           : out   std_logic; 
          RXBUFERR_0            : out   std_logic;
          TXBUFERR_0            : out   std_logic; 
          PLLLKDET_0            : out   std_logic; 
          TXOUTCLK_0            : out   std_logic; 
          RXELECIDLE_0    	: out   std_logic;
          TX1N_0                : out   std_logic; 
          TX1P_0                : out   std_logic;
          RX1N_0                : in    std_logic; 
          RX1P_0                : in    std_logic;

          TX1N_1_UNUSED         : out   std_logic;
          TX1P_1_UNUSED         : out   std_logic;
          RX1N_1_UNUSED         : in    std_logic;
          RX1P_1_UNUSED         : in    std_logic;


          CLK_DS                : in    std_logic;
          REFCLKOUT             : out   std_logic;
          GTRESET               : in    std_logic;
          PMARESET              : in    std_logic;
          DCM_LOCKED            : in    std_logic
          );
end v5_single_1000basex_gtx_dual_1000X;


architecture structural of v5_single_1000basex_gtx_dual_1000X is

  ----------------------------------------------------------------------
  -- Signal declarations for GTX
  ----------------------------------------------------------------------

   signal GND_BUS               : std_logic_vector (55 downto 0);
   signal PLLLOCK               : std_logic;

            
   signal RXNOTINTABLE_0_INT    : std_logic;   
   signal RXDATA_0_INT          : std_logic_vector (7 downto 0);
   signal RXCHARISK_0_INT       : std_logic;   
   signal RXDISPERR_0_INT       : std_logic;
   signal RXRUNDISP_0_INT       : std_logic;
         
   signal RXBUFSTATUS_float0    : std_logic_vector(1 downto 0);
   signal TXBUFSTATUS_float0    : std_logic;

   signal gt_txoutclk1_0        : std_logic;
   signal resetdone0_i_del      : std_logic;

   signal rxelecidle0_i         : std_logic;
   signal resetdone0_i          : std_logic;


   attribute ASYNC_REG                        : string;

begin

   GND_BUS(55 downto 0) <= (others => '0');

   ----------------------------------------------------------------------
   -- Wait for both PLL's to lock   
   ----------------------------------------------------------------------

   
   PLLLKDET_0        <=   PLLLOCK;


   ----------------------------------------------------------------------
   -- Wire internal signals to outputs   
   ----------------------------------------------------------------------

   RXNOTINTABLE_0  <=   RXNOTINTABLE_0_INT;
   RXDISPERR_0     <=   RXDISPERR_0_INT;
   TXOUTCLK_0      <=   gt_txoutclk1_0;

   RESETDONE_0          <= resetdone0_i;
   RXELECIDLE_0         <= rxelecidle0_i;

  
 

   ----------------------------------------------------------------------
   -- Instantiate the Virtex-5 GTX
   -- EMAC0 connects to GTX 0 and EMAC1 connects to GTX 1
   ----------------------------------------------------------------------

   -- Direct from the RocketIO Wizard output
   GTX_1000X : entity xps_ll_temac_v2_03_a.v5_1000basex_rocketio_wrapper_gtx(RTL)
    generic map (
        WRAPPER_SIM_GTXRESET_SPEEDUP           => 1,
        WRAPPER_SIM_PLL_PERDIV2                => x"0c8"
    )    
    port map (
        ------------------- Shared Ports - Tile and PLL Ports --------------------
        TILE0_CLKIN_IN                 => CLK_DS,
        TILE0_GTXRESET_IN              => GTRESET,
        TILE0_PLLLKDET_OUT             => PLLLOCK,
        TILE0_REFCLKOUT_OUT            => REFCLKOUT,
        ---------------------- Loopback and Powerdown Ports ----------------------
	TILE0_LOOPBACK0_IN(2 downto 1) => "00",
        TILE0_LOOPBACK0_IN(0)          => LOOPBACK_0,
        TILE0_RXPOWERDOWN0_IN(0)       => POWERDOWN_0,
        TILE0_RXPOWERDOWN0_IN(1)       => POWERDOWN_0,
        TILE0_TXPOWERDOWN0_IN(0)       => POWERDOWN_0,
        TILE0_TXPOWERDOWN0_IN(1)       => POWERDOWN_0,
        --------------------- Receive Ports - 8b10b Decoder ----------------------
        TILE0_RXCHARISCOMMA0_OUT       => RXCHARISCOMMA_0,
        TILE0_RXCHARISK0_OUT           => RXCHARISK_0_INT,
        TILE0_RXDISPERR0_OUT           => RXDISPERR_0_INT,
        TILE0_RXNOTINTABLE0_OUT        => RXNOTINTABLE_0_INT,
        TILE0_RXRUNDISP0_OUT           => RXRUNDISP_0_INT,
        ----------------- Receive Ports - Clock Correction Ports -----------------
        TILE0_RXCLKCORCNT0_OUT         => RXCLKCORCNT_0,
        ------------- Receive Ports - Comma Detection and Alignment --------------
        TILE0_RXENMCOMMAALIGN0_IN      => ENMCOMMAALIGN_0,
        TILE0_RXENPCOMMAALIGN0_IN      => ENPCOMMAALIGN_0,
        ----------------- Receive Ports - RX Data Path interface -----------------
        TILE0_RXDATA0_OUT              => RXDATA_0_INT,
        TILE0_RXRECCLK0_OUT            => open,
        TILE0_RXRESET0_IN              => RXRESET_0,
        TILE0_RXUSRCLK0_IN             => RXUSRCLK_0,
        TILE0_RXUSRCLK20_IN            => RXUSRCLK2_0,
        ------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        TILE0_RXBUFSTATUS0_OUT(2)      => RXBUFERR_0,
        TILE0_RXBUFSTATUS0_OUT(1 downto 0) => RXBUFSTATUS_float0,
        TILE0_RXBUFRESET0_IN           => RXRESET_0,
        ----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        TILE0_RXELECIDLE0_OUT          => rxelecidle0_i,
        TILE0_RXN0_IN                  => RX1N_0,
        TILE0_RXP0_IN                  => RX1P_0,       
        ------------- ResetDone Ports --------------------------------------------
        TILE0_RESETDONE0_OUT           => resetdone0_i,
        -------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        TILE0_TXCHARDISPMODE0_IN       => TXCHARDISPMODE_0,
        TILE0_TXCHARDISPVAL0_IN        => TXCHARDISPVAL_0,
        TILE0_TXCHARISK0_IN            => TXCHARISK_0,
        ----------- Transmit Ports - TX Buffering and Phase Alignment ------------
        TILE0_TXBUFSTATUS0_OUT(1)      => TXBUFERR_0, 
        TILE0_TXBUFSTATUS0_OUT(0)      => TXBUFSTATUS_float0,
        ---------------- Transmit Ports - TX Data Path interface -----------------
        TILE0_TXDATA0_IN               => TXDATA_0,
        TILE0_TXOUTCLK0_OUT            => gt_txoutclk1_0,
        TILE0_TXRESET0_IN              => TXRESET_0,
        TILE0_TXUSRCLK0_IN             => TXUSRCLK_0,
        TILE0_TXUSRCLK20_IN            => TXUSRCLK2_0,
        ------------- Transmit Ports - TX Driver and OOB signalling --------------
        TILE0_TXN0_OUT                 => TX1N_0,
        TILE0_TXP0_OUT                 => TX1P_0,
        TILE0_LOOPBACK1_IN             => "000",
        TILE0_RXPOWERDOWN1_IN          => "00",
        TILE0_TXPOWERDOWN1_IN          => "00",
        TILE0_RXCHARISCOMMA1_OUT       => open,
        TILE0_RXCHARISK1_OUT           => open,
        TILE0_RXDISPERR1_OUT           => open,
        TILE0_RXNOTINTABLE1_OUT        => open,
        TILE0_RXRUNDISP1_OUT           => open,
        TILE0_RXCLKCORCNT1_OUT         => open,
        TILE0_RXENMCOMMAALIGN1_IN      => '0',
        TILE0_RXENPCOMMAALIGN1_IN      => '0',
        TILE0_RXDATA1_OUT              => open,
        TILE0_RXRECCLK1_OUT            => open,
        TILE0_RXRESET1_IN              => '0',
        TILE0_RXUSRCLK1_IN             => '0',
        TILE0_RXUSRCLK21_IN            => '0',
        TILE0_RXBUFRESET1_IN           => '0',
        TILE0_RXBUFSTATUS1_OUT         => open,
        TILE0_RXELECIDLE1_OUT          => open,
        TILE0_RXN1_IN                  => RX1N_1_UNUSED,
        TILE0_RXP1_IN                  => RX1P_1_UNUSED,       
        TILE0_RESETDONE1_OUT           => open,
        TILE0_TXCHARDISPMODE1_IN       => '0',
        TILE0_TXCHARDISPVAL1_IN        => '0',
        TILE0_TXCHARISK1_IN            => '0',
        TILE0_TXBUFSTATUS1_OUT         => open,
        TILE0_TXDATA1_IN               => "00000000",
        TILE0_TXOUTCLK1_OUT            => open,
        TILE0_TXRESET1_IN              => '0',
        TILE0_TXUSRCLK1_IN             => '0',
        TILE0_TXUSRCLK21_IN            => '0',
        TILE0_TXN1_OUT                 => TX1N_1_UNUSED,
        TILE0_TXP1_OUT                 => TX1P_1_UNUSED	
   );

                       
   -------------------------------------------------------------------------------
   -- EMAC0 to GTX logic shim
   -------------------------------------------------------------------------------

   -- When the RXNOTINTABLE condition is detected, the Virtex5 RocketIO
   -- GTX outputs the raw 10B code in a bit swapped order to that of the
   -- Virtex-II Pro RocketIO.
   gen_rxdata0 : process (RXNOTINTABLE_0_INT, RXDISPERR_0_INT, RXCHARISK_0_INT, RXDATA_0_INT,
                         RXRUNDISP_0_INT)
   begin
      if RXNOTINTABLE_0_INT = '1' then
         RXDATA_0(0) <= RXDISPERR_0_INT;
         RXDATA_0(1) <= RXCHARISK_0_INT;
         RXDATA_0(2) <= RXDATA_0_INT(7);
         RXDATA_0(3) <= RXDATA_0_INT(6);
         RXDATA_0(4) <= RXDATA_0_INT(5);
         RXDATA_0(5) <= RXDATA_0_INT(4);
         RXDATA_0(6) <= RXDATA_0_INT(3);
         RXDATA_0(7) <= RXDATA_0_INT(2);
         RXRUNDISP_0 <= RXDATA_0_INT(1);
         RXCHARISK_0 <= RXDATA_0_INT(0);

      else
         RXDATA_0    <= RXDATA_0_INT;
         RXRUNDISP_0 <= RXRUNDISP_0_INT;
         RXCHARISK_0 <= RXCHARISK_0_INT;

      end if;
   end process gen_rxdata0;




end structural;
