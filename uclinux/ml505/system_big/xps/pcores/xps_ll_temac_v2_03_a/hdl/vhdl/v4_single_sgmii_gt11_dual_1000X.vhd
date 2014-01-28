------------------------------------------------------------------------------
-- $Id: v4_single_sgmii_gt11_dual_1000X.vhd,v 1.1.4.39 2009/11/17 07:11:36 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : 1000BASE-X RocketIO wrapper
-- Project    : Virtex-4 FX Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v4_single_sgmii_gt11_dual_1000X.vhd
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
-- Description:  This is the VHDL instantiation of a Virtex-4 FX GT11
--               RocketIO tile for the Embedded Ethernet MAC.
--
--               This design also instantiates "rxclkcorcnt_shim" to
--               emulate the rxnotintable function and the clock
--               correction indication signalling of the Virtex-2 Pro
--               RocketIO tranceiver.

--               Two GT11's must be instantiated regardless of how many
--               GT11s are used in the MGT tile.
--               
--               This is based on Coregen Wrappers from ISE J.38 (9.2i)
--               Wrapper version 4.5
------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library UNISIM;
use UNISIM.Vcomponents.ALL;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

entity v4_single_sgmii_gt11_dual_1000X is
  generic (
           C_INCLUDE_IO               : integer          := 1
          );
   port (
          ENMCOMMAALIGN_0       : in    std_logic;
          ENPCOMMAALIGN_0       : in    std_logic;
          LOOPBACK_0            : in    std_logic_vector (1 downto 0);
          REFCLK1_0             : in    std_logic;
          REFCLK2_0             : in    std_logic;
          RXUSRCLK_0            : in    std_logic;
          RXUSRCLK2_0           : in    std_logic;
          RXRESET_0             : in    std_logic;
          RXPMARESET0           : in    std_logic;
          TXCHARDISPMODE_0      : in    std_logic;
          TXCHARDISPVAL_0       : in    std_logic;
          TXCHARISK_0           : in    std_logic;
          TXDATA_0              : in    std_logic_vector (7 downto 0);
          TXUSRCLK_0            : in    std_logic;
          TXUSRCLK2_0           : in    std_logic;
          TXRESET_0             : in    std_logic;
          DO_0                  : out   std_logic_vector (15 downto 0);
          DRDY_0                : out   std_logic;
          RXBUFERR_0            : out   std_logic;
          RXCHARISCOMMA_0       : out   std_logic;
          RXCHARISK_0           : out   std_logic;
          RXCLKCORCNT_0         : out   std_logic_vector (2 downto 0);
          RXCOMMADET_0          : out   std_logic;
          RXDATA_0              : out   std_logic_vector (7 downto 0);
          RXDISPERR_0           : out   std_logic;
          RXNOTINTABLE_0        : out   std_logic;
          RXREALIGN_0           : out   std_logic;
          RXRECCLK1_0           : out   std_logic;
          RXRUNDISP_0           : out   std_logic;
          RXSTATUS_0            : out   std_logic_vector (5 downto 0);
          TXBUFERR_0            : out   std_logic;
	  TX_PLLLOCK_0             : out   std_logic;
          RX_PLLLOCK_0             : out   std_logic;
          TXOUTCLK1_0           : out   std_logic;
          TXRUNDISP_0           : out   std_logic;
          RX_SIGNAL_DETECT_0    : in    std_logic;
          TX1N_0                : out   std_logic;
          TX1P_0                : out   std_logic;
          RX1N_0                : in    std_logic;
          RX1P_0                : in    std_logic;
          RXSYNC_0              : in    std_logic;

          TX1N_1_UNUSED         : out   std_logic;
          TX1P_1_UNUSED         : out   std_logic;
          RX1N_1_UNUSED         : in    std_logic;
          RX1P_1_UNUSED         : in    std_logic;


          PMARESET_TX0           : in  std_logic;
          DCLK                  : in  std_logic;
          DCM_LOCKED            : in  std_logic
          );
end v4_single_sgmii_gt11_dual_1000X;


architecture structural of v4_single_sgmii_gt11_dual_1000X is

  ----------------------------------------------------------------------
  -- Signal declarations for GT11
  ----------------------------------------------------------------------

   signal COMBUSOUT_1           : std_logic_vector (15 downto 0);
   signal COMBUSOUT_0           : std_logic_vector (15 downto 0);
   signal GND_BUS               : std_logic_vector (55 downto 0);

   signal TXLOCK_0              : std_logic;
   signal RXLOCK_0              : std_logic;
   signal RXNOTINTABLE_0_INT    : std_logic;
   signal RXSTATUS_0_INT        : std_logic_vector (5 downto 0);
   signal RXDATA_0_INT          : std_logic_vector (7 downto 0);
   signal RXCHARISK_0_INT       : std_logic;
   signal RXRUNDISP_0_INT       : std_logic;

   signal RXCHARISCOMMA_float0  : std_logic_vector (6 downto 0);
   signal RXCHARISK_float0      : std_logic_vector (6 downto 0);
   signal RXDATA_float0         : std_logic_vector (55 downto 0);
   signal RXDISPERR_float0      : std_logic_vector (6 downto 0);
   signal RXNOTINTABLE_float0   : std_logic_vector (6 downto 0);
   signal RXRUNDISP_float0      : std_logic_vector (6 downto 0);
   signal TXKERR_float0         : std_logic_vector (6 downto 0);
   signal TXRUNDISP_float0      : std_logic_vector (6 downto 0);



   ---------------------------------------------------------------------
   -- Signal Declarations for GT11 <=> Calibration block
   ---------------------------------------------------------------------

   signal CAL_BLOCK_RESET       : std_logic;

   -- GT11 connected to EMAC0
   signal gt_do_0               : std_logic_vector(15 downto 0);
   signal gt_di_0               : std_logic_vector(15 downto 0);
   signal gt_daddr_0            : std_logic_vector(7 downto 0);
   signal gt_den_0              : std_logic;
   signal gt_dwe_0              : std_logic;
   signal gt_drdy_0             : std_logic;

   signal gt_rxlock_0           : std_logic;
   signal gt_txpmareset_0       : std_logic;
   signal gt_txlock_0           : std_logic;
   signal gt_loopback_0         : std_logic_vector(1 downto 0);
   signal gt_txenc8b10buse_0    : std_logic;
   signal gt_txbypass8b10b_0    : std_logic_vector(7 downto 0);
   signal gt_txoutclk1_0        : std_logic;
   signal gt_rxrecclk2_0        : std_logic;

   -- GT11 connected to EMAC1
   signal gt_do_1               : std_logic_vector(15 downto 0);
   signal gt_di_1               : std_logic_vector(15 downto 0);
   signal gt_daddr_1            : std_logic_vector(7 downto 0);
   signal gt_den_1              : std_logic;
   signal gt_dwe_1              : std_logic;
   signal gt_drdy_1             : std_logic;

   signal gt_rxlock_1           : std_logic;
   signal gt_txpmareset_1       : std_logic;
   signal gt_txlock_1           : std_logic;
   signal gt_loopback_1         : std_logic_vector(1 downto 0);
   signal gt_txenc8b10buse_1    : std_logic;
   signal gt_txbypass8b10b_1    : std_logic_vector(7 downto 0);
   signal gt_txoutclk1_1        : std_logic;
   signal gt_rxrecclk2_1        : std_logic;



   ---------------------------------------------------------------------
   -- Signal Declarations for GT11 => FPGA fabric Rx Elastic Buffer
   ---------------------------------------------------------------------

   -- GT11 A
   signal rxrecclk10            : std_logic;
   signal rxrecclk1_bufr0       : std_logic;
   signal rxchariscomma_rec0    : std_logic_vector(1 downto 0);
   signal rxcharisk_rec0        : std_logic_vector(1 downto 0);       
   signal rxdisperr_rec0        : std_logic_vector(1 downto 0);       
   signal rxnotintable_rec0     : std_logic_vector(1 downto 0); 
   signal rxrundisp_rec0        : std_logic_vector(1 downto 0);    
   signal rxdata_rec0           : std_logic_vector(15 downto 0);
   signal rxclkcorcnt0          : std_logic_vector(2 downto 0);

begin


   GND_BUS(55 downto 0) <= (others => '0');


  ----------------------------------------------------------------------
  -- Wait for both PLL's to lock
  ----------------------------------------------------------------------

   TX_PLLLOCK_0        <=   gt_txlock_0;
   RX_PLLLOCK_0        <=   gt_rxlock_0;


  ----------------------------------------------------------------------
  -- Wire internal signals to outputs
  ----------------------------------------------------------------------

   RXNOTINTABLE_0  <=   RXNOTINTABLE_0_INT;
   RXSTATUS_0      <=   RXSTATUS_0_INT;


  ----------------------------------------------------------------------
  -- Instantiate the Virtex-4 FX GT11 <=> Virtex-II Pro MGT RocketIO
  -- shim for EMAC0
  ----------------------------------------------------------------------
   shim_A : entity xps_ll_temac_v2_03_a.v4_gt11_to_gt_rxclkcorcnt_shim(rtl)
   port map (
                rxusrclk2                    => TXUSRCLK2_0,
                rxstatus                     => RXSTATUS_0_INT,
                rxnotintable                 => RXNOTINTABLE_0_INT,
                rxd_in                       => RXDATA_0_INT,
                rxcharisk_in                 => RXCHARISK_0_INT,
                rxrundisp_in                 => RXRUNDISP_0_INT,
                rxclkcorcnt                  => RXCLKCORCNT_0,
                rxd_out                      => RXDATA_0,
                rxcharisk_out                => RXCHARISK_0,
                rxrundisp_out                => RXRUNDISP_0);


  ----------------------------------------------------------------------
  -- Instantiate the Virtex-4 FX GT11 A for EMAC0
  ----------------------------------------------------------------------

   GT11_1000X_A : GT11
   generic map( 
    
    ---------- RocketIO MGT 64B66B Block Sync State Machine Attributes --------- 

        SH_CNT_MAX                 =>      64,
        SH_INVALID_CNT_MAX         =>      16,
        
    ----------------------- RocketIO MGT Alignment Atrributes ------------------   

        ALIGN_COMMA_WORD           =>      2, 
        COMMA_10B_MASK             =>      x"07f",
        COMMA32                    =>      FALSE,
        DEC_MCOMMA_DETECT          =>      TRUE,
        DEC_PCOMMA_DETECT          =>      TRUE,
        DEC_VALID_COMMA_ONLY       =>      TRUE,
        MCOMMA_32B_VALUE           =>      x"00000283",
        MCOMMA_DETECT              =>      TRUE,
        PCOMMA_32B_VALUE           =>      x"0000017c",
        PCOMMA_DETECT              =>      TRUE,
        PCS_BIT_SLIP               =>      FALSE,        
        
    ---- RocketIO MGT Atrributes Common to Clk Correction & Channel Bonding ----   

        CCCB_ARBITRATOR_DISABLE    =>      FALSE,
        CLK_COR_8B10B_DE           =>      TRUE,        

    ------------------- RocketIO MGT Channel Bonding Atrributes ----------------   
    
        CHAN_BOND_LIMIT            =>      16,
        CHAN_BOND_MODE             =>      "NONE",
        CHAN_BOND_ONE_SHOT         =>      FALSE,
        CHAN_BOND_SEQ_1_1          =>      "00000000000",
        CHAN_BOND_SEQ_1_2          =>      "00000000000",
        CHAN_BOND_SEQ_1_3          =>      "00000000000",
        CHAN_BOND_SEQ_1_4          =>      "00000000000",
        CHAN_BOND_SEQ_1_MASK       =>      "1111",
        CHAN_BOND_SEQ_2_1          =>      "00000000000",
        CHAN_BOND_SEQ_2_2          =>      "00000000000",
        CHAN_BOND_SEQ_2_3          =>      "00000000000",
        CHAN_BOND_SEQ_2_4          =>      "00000000000",
        CHAN_BOND_SEQ_2_MASK       =>      "1111",
        CHAN_BOND_SEQ_2_USE        =>      FALSE,
        CHAN_BOND_SEQ_LEN          =>      1,
 
    ------------------ RocketIO MGT Clock Correction Atrributes ----------------   

        CLK_COR_MAX_LAT            =>      48,
        CLK_COR_MIN_LAT            =>      36,
        CLK_COR_SEQ_1_1            =>      "00110111100",
        CLK_COR_SEQ_1_2            =>      "00001010000",
        CLK_COR_SEQ_1_3            =>      "00000000000",
        CLK_COR_SEQ_1_4            =>      "00000000000",
        CLK_COR_SEQ_1_MASK         =>      "1100",
        CLK_COR_SEQ_2_1            =>      "00110111100",
        CLK_COR_SEQ_2_2            =>      "00010110101",
        CLK_COR_SEQ_2_3            =>      "00000000000",
        CLK_COR_SEQ_2_4            =>      "00000000000",
        CLK_COR_SEQ_2_MASK         =>      "1100",
        CLK_COR_SEQ_2_USE          =>      FALSE,
        CLK_COR_SEQ_DROP           =>      FALSE,
        CLK_COR_SEQ_LEN            =>      2,
        CLK_CORRECT_USE            =>      FALSE, 
        
    ---------------------- RocketIO MGT Clocking Atrributes --------------------      
                                        
        RX_CLOCK_DIVIDER           =>      "01",
        RXASYNCDIVIDE              =>      "01", 
        RXCLK0_FORCE_PMACLK        =>      FALSE,
        RXCLKMODE                  =>      "000011",
        RXOUTDIV2SEL               =>      4,
        RXPLLNDIVSEL               =>      10,
        RXPMACLKSEL                =>      "REFCLK1",
        RXRECCLK1_USE_SYNC         =>      FALSE,
        RXUSRDIVISOR               =>      1,
        TX_CLOCK_DIVIDER           =>      "10",
        TXABPMACLKSEL              =>      "REFCLK1",
        TXASYNCDIVIDE              =>      "00",
        TXCLK0_FORCE_PMACLK        =>      TRUE,
        TXCLKMODE                  =>      "0100",
        TXOUTCLK1_USE_SYNC         =>      FALSE,
        TXOUTDIV2SEL               =>      4,
        TXPHASESEL                 =>      FALSE, 
        TXPLLNDIVSEL               =>      10,

    -------------------------- RocketIO MGT CRC Atrributes ---------------------   

        RXCRCCLOCKDOUBLE           =>      FALSE,
        RXCRCENABLE                =>      FALSE,
        RXCRCINITVAL               =>      x"FFFFFFFF",
        RXCRCINVERTGEN             =>      FALSE,
        RXCRCSAMECLOCK             =>      TRUE,
        TXCRCCLOCKDOUBLE           =>      FALSE,
        TXCRCENABLE                =>      FALSE,
        TXCRCINITVAL               =>      x"FFFFFFFF",
        TXCRCINVERTGEN             =>      FALSE,
        TXCRCSAMECLOCK             =>      TRUE,
        
    --------------------- RocketIO MGT Data Path Atrributes --------------------   
    
        RXDATA_SEL                 =>      "00",
        TXDATA_SEL                 =>      "00",

    ---------------- RocketIO MGT Digital Receiver Attributes ------------------   

        DIGRX_FWDCLK               =>      "01",
        DIGRX_SYNC_MODE            =>      TRUE,
        ENABLE_DCDR                =>      FALSE,
        RXBY_32                    =>      FALSE,
        RXDIGRESET                 =>      FALSE,
        RXDIGRX                    =>      FALSE,
        SAMPLE_8X                  =>      FALSE,
                                        
    ----------------- Rocket IO MGT Miscellaneous Attributes ------------------     

        GT11_MODE                  =>      "A",
        OPPOSITE_SELECT            =>      FALSE,
        PMA_BIT_SLIP               =>      FALSE,
        REPEATER                   =>      FALSE,
        RX_BUFFER_USE              =>      FALSE,
        RXCDRLOS                   =>      "000000",
        RXDCCOUPLE                 =>      FALSE,
        RXFDCAL_CLOCK_DIVIDE       =>      "NONE",
        TX_BUFFER_USE              =>      TRUE,   
        TXFDCAL_CLOCK_DIVIDE       =>      "NONE",
        TXSLEWRATE                 =>      TRUE,

     ----------------- Rocket IO MGT Preemphasis and Equalization --------------
     
        RXAFEEQ                    =>       "000000000",
        RXEQ                       =>       x"4000000000000000",
        TXDAT_PRDRV_DAC            =>       "111",
        TXDAT_TAP_DAC              =>       "10110",
        TXHIGHSIGNALEN             =>       TRUE,
        TXPOST_PRDRV_DAC           =>       "111",
        TXPOST_TAP_DAC             =>       "00001",
        TXPOST_TAP_PD              =>       TRUE,
        TXPRE_PRDRV_DAC            =>       "111",
        TXPRE_TAP_DAC              =>       "00000",      
        TXPRE_TAP_PD               =>       TRUE,        
                                        
                                        
                                          
    ----------------------- Restricted RocketIO MGT Attributes -------------------  

    ---Note : THE FOLLOWING ATTRIBUTES ARE RESTRICTED. PLEASE DO NOT EDIT.

     ----------------------------- Restricted: Biasing -------------------------
     
        BANDGAPSEL                 =>       FALSE,
        BIASRESSEL                 =>       FALSE,    
        IREFBIASMODE               =>       "11",
        PMAIREFTRIM                =>       "0111",
        PMAVREFTRIM                =>       "0111",
        TXAREFBIASSEL              =>       TRUE, 
        TXTERMTRIM                 =>       "1100",
        VREFBIASMODE               =>       "11",

     ---------------- Restricted: Frequency Detector and Calibration -----------  
     
        CYCLE_LIMIT_SEL            =>       "00",
        FDET_HYS_CAL               =>       "010",
        FDET_HYS_SEL               =>       "100",
        FDET_LCK_CAL               =>       "101",
        FDET_LCK_SEL               =>       "001",
        LOOPCAL_WAIT               =>       "00",
        RXCYCLE_LIMIT_SEL          =>       "00",
        RXFDET_HYS_CAL             =>       "010",
        RXFDET_HYS_SEL             =>       "100",
        RXFDET_LCK_CAL             =>       "101",   
        RXFDET_LCK_SEL             =>       "001",
        RXLOOPCAL_WAIT             =>       "00",
        RXSLOWDOWN_CAL             =>       "00",
        SLOWDOWN_CAL               =>       "00",

     --------------------------- Restricted: PLL Settings ---------------------
     
        PMACLKENABLE               =>       TRUE,
        PMACOREPWRENABLE           =>       TRUE,
        PMAVBGCTRL                 =>       "00000",
        RXACTST                    =>       FALSE,          
        RXAFETST                   =>       FALSE,         
        RXCMADJ                    =>       "01",
        RXCPSEL                    =>       FALSE,
        RXCPTST                    =>       FALSE,
        RXCTRL1                    =>       x"200",
        RXFECONTROL1               =>       "00",  
        RXFECONTROL2               =>       "000",  
        RXFETUNE                   =>       "01", 
        RXLKADJ                    =>       "00000",
        RXLOOPFILT                 =>       "1111",
        RXPDDTST                   =>       TRUE,          
        RXRCPADJ                   =>       "010",   
        RXRIBADJ                   =>       "11",
        RXVCO_CTRL_ENABLE          =>       TRUE,
        RXVCODAC_INIT              =>       "0000000101",   
        TXCPSEL                    =>       FALSE,
        TXCTRL1                    =>       x"200",
        TXLOOPFILT                 =>       "1101",   
        VCO_CTRL_ENABLE            =>       TRUE,
        VCODAC_INIT                =>       "0000000101",
        
    --------------------------- Restricted: Powerdowns ------------------------  
    
        POWER_ENABLE               =>       TRUE,
        RXAFEPD                    =>       FALSE,
        RXAPD                      =>       FALSE,
        RXLKAPD                    =>       FALSE,
        RXPD                       =>       FALSE,
        RXRCPPD                    =>       FALSE,
        RXRPDPD                    =>       FALSE,
        RXRSDPD                    =>       FALSE,
        TXAPD                      =>       FALSE,
        TXDIGPD                    =>       FALSE,
        TXLVLSHFTPD                =>       FALSE,
        TXPD                       =>       FALSE
      )

      -- Connect to EMAC0 (SGMII)
       port map (
                CHBONDO                      => open,
                COMBUSIN(15 downto 0)        => COMBUSOUT_1(15 downto 0),
                DRDY                         => gt_drdy_0,
                RXBUFERR                     => open,
                RXCALFAIL                    => open,
                RXCHARISCOMMA(7 downto 2)    => RXCHARISCOMMA_float0(6 downto 1),
                RXCHARISCOMMA(1 downto 0)    => rxchariscomma_rec0,
                RXCHARISK(7 downto 2)        => RXCHARISK_float0(6 downto 1),
                RXCHARISK(1 downto 0)        => rxcharisk_rec0,
                RXCOMMADET                   => RXCOMMADET_0,
                RXCRCOUT                     => open,
                RXCYCLELIMIT                 => open,
                RXDATA(63 downto 16)         => RXDATA_float0(55 downto 8),
                RXDATA(15 downto 0)          => rxdata_rec0,
                RXDISPERR(7 downto 2)        => RXDISPERR_float0(6 downto 1),
                RXDISPERR(1 downto 0)        => rxdisperr_rec0,
                RXLOCK                       => gt_rxlock_0,
                RXLOSSOFSYNC                 => open,
                RXMCLK                       => open,
                RXNOTINTABLE(7 downto 2)     => RXNOTINTABLE_float0(6 downto 1),
                RXNOTINTABLE(1 downto 0)     => rxnotintable_rec0,
                RXPCSHCLKOUT                 => open,
                RXREALIGN                    => RXREALIGN_0,
                RXRECCLK1                    => rxrecclk10,
                RXRECCLK2                    => gt_rxrecclk2_0,
                RXRUNDISP(7 downto 2)        => RXRUNDISP_float0(6 downto 1),
                RXRUNDISP(1 downto 0)        => rxrundisp_rec0,
                RXSIGDET                     => open,
                RXSTATUS                     => open,
                TXBUFERR                     => TXBUFERR_0,
                TXCALFAIL                    => open,
                TXCRCOUT                     => open,
                TXCYCLELIMIT                 => open,
                TXKERR                       => open,
                TXLOCK                       => gt_txlock_0,
                TXOUTCLK1                    => gt_txoutclk1_0,
                TXOUTCLK2                    => open,
                TXPCSHCLKOUT                 => open,
                TXRUNDISP(7 downto 1)        => TXRUNDISP_float0(6 downto 0),
                TXRUNDISP(0)                 => TXRUNDISP_0,
                TX1N                         => TX1N_0,
                TX1P                         => TX1P_0,

                CHBONDI                      => (others => '0'),
                COMBUSOUT(15 downto 0)       => COMBUSOUT_0(15 downto 0),
                DADDR(7 downto 0)            => gt_daddr_0,
                DCLK                         => DCLK,
                DEN                          => gt_den_0,
                DI(15 downto 0)              => gt_do_0,
                DWE                          => gt_dwe_0,
                ENCHANSYNC                   => '0',
                ENMCOMMAALIGN                => ENMCOMMAALIGN_0,
                ENPCOMMAALIGN                => ENPCOMMAALIGN_0,
                GREFCLK                      => '0',
                LOOPBACK(1 downto 0)         => gt_loopback_0,
                POWERDOWN                    => '0',
                REFCLK1                      => REFCLK1_0,
                REFCLK2                      => REFCLK2_0,
                RXBLOCKSYNC64B66BUSE         => '0',
                RXCLKSTABLE                  => '1',
                RXCOMMADETUSE                => '1',
                RXCRCCLK                     => TXUSRCLK2_0,
                RXCRCDATAVALID               => '0',
                RXCRCDATAWIDTH               => "000",
                RXCRCIN                      => X"0000000000000000",
                RXCRCINIT                    => '0',
                RXCRCINTCLK                  => TXUSRCLK2_0,
                RXCRCPD                      => '1',
                RXCRCRESET                   => '0',
                RXDATAWIDTH                  => "01",
                RXDEC8B10BUSE                => '1',
                RXDEC64B66BUSE               => '0',
                RXDESCRAM64B66BUSE           => '0',
                RXIGNOREBTF                  => '0',
                RXINTDATAWIDTH               => "11",
                RXPMARESET                   => RXPMARESET0,
                RXPOLARITY                   => '0',
                RXRESET                      => RXRESET_0,
                RXSLIDE                      => '0',
                RXSYNC                       => RXSYNC_0,
                RXUSRCLK                     => '0',            -- Internal clock dividers are in use
                RXUSRCLK2                    => rxrecclk1_bufr0,
                RX1N                         => RX1N_0,
                RX1P                         => RX1P_0,
                TXBYPASS8B10B                => gt_txbypass8b10b_0,
                TXCHARDISPMODE(7 downto 1)   => "0000000",
                TXCHARDISPMODE(0)            => TXCHARDISPMODE_0,
                TXCHARDISPVAL(7 downto 1)    => "0000000",
                TXCHARDISPVAL(0)             => TXCHARDISPVAL_0,
                TXCHARISK(7 downto 1)        => "0000000",
                TXCHARISK(0)                 => TXCHARISK_0,
                TXCLKSTABLE                  => '1',
                TXCRCCLK                     => TXUSRCLK2_0,
                TXCRCDATAVALID               => '0',
                TXCRCDATAWIDTH               => "000",
                TXCRCIN                      => X"0000000000000000",
                TXCRCINIT                    => '0',
                TXCRCINTCLK                  => TXUSRCLK2_0,
                TXCRCPD                      => '1',
                TXCRCRESET                   => '0',
                TXDATA(63 downto 8)          => GND_BUS(55 downto 0),
                TXDATA(7 downto 0)           => TXDATA_0 (7 downto 0),
                TXDATAWIDTH                  => "00",
                TXENC8B10BUSE                => gt_txenc8b10buse_0,
                TXENC64B66BUSE               => '0',
                TXENOOB                      => '0',
                TXGEARBOX64B66BUSE           => '0',
                TXINHIBIT                    => '0',
                TXINTDATAWIDTH               => "11",
                TXPMARESET                   => PMARESET_TX0,
                TXPOLARITY                   => '0',
                TXRESET                      => TXRESET_0,
                TXSCRAM64B66BUSE             => '0',
                TXSYNC                       => '0',
                TXUSRCLK                     => TXUSRCLK_0,
                TXUSRCLK2                    => TXUSRCLK2_0,
                DO                           => gt_di_0
      );

      TXOUTCLK1_0 <= gt_txoutclk1_0;



      ---------------------------------------------------------------------
      -- Component Instantiation for the version 1.4.1 Calibration Block
      -- Applied to the GT11 A connected to EMAC0
      ---------------------------------------------------------------------

      CAL_BLOCK_RESET <= not DCM_LOCKED;

cal_block_A : entity xps_ll_temac_v2_03_a.v4_cal_block_v1_4_1(rtl)
        generic map (
          C_MGT_ID            => 0,                     -- 0 = MGTA | 1 = MGTB
          C_TXPOST_TAP_PD     => "TRUE",                -- "TRUE" or "FALSE"
          C_RXDIGRX           => "FALSE"                 -- "TRUE" or "FALSE"
        )
        port map (
          -- User DRP Interface (destination/slave interface)
          USER_DO             => open,                  -- O [15:0]
          USER_DI             => X"0000",               -- I [15:0]
          USER_DADDR          => X"00",                 -- I [7:0]
          USER_DEN            => '0',                   -- I
          USER_DWE            => '0',                   -- I
          USER_DRDY           => open,                  -- O

          -- MGT DRP Interface (source/master interface)
          GT_DO               => gt_do_0,               -- O [15:0]
          GT_DI               => gt_di_0,               -- I [15:0]
          GT_DADDR            => gt_daddr_0,            -- O [7:0]
          GT_DEN              => gt_den_0,              -- O
          GT_DWE              => gt_dwe_0,              -- O
          GT_DRDY             => gt_drdy_0,             -- I

          -- Clock and Reset
          DCLK                => DCLK,                  -- I
          RESET               => CAL_BLOCK_RESET,       -- I

          -- Calibration Block Active and Disable Signals (legacy)
          ACTIVE              => open,                  -- O

          -- User side MGT Pass through Signals
          USER_LOOPBACK       =>  LOOPBACK_0,           -- I [1:0]
          USER_TXENC8B10BUSE  =>  '1',                  -- I
          USER_TXBYPASS8B10B  =>  X"00",                -- I [7:0]

          -- GT side MGT Pass through Signals
          GT_LOOPBACK         => gt_loopback_0,         -- O [1:0]
          GT_TXENC8B10BUSE    => gt_txenc8b10buse_0,    -- O
          GT_TXBYPASS8B10B    => gt_txbypass8b10b_0,    -- O [7:0]

          -- Signal Detect Ports
          TX_SIGNAL_DETECT    => '1',                   -- I
          RX_SIGNAL_DETECT    => RX_SIGNAL_DETECT_0     -- I

        );



      ------------------------------------------------------------------
      -- Instantiation of the FPGA Fabric Receiver Elastic Buffer
      -- connected to RocketIO A        
      ------------------------------------------------------------------


      -- Place the Rx recovered clock on a Regional Clock Buffer
      bufr_rxrecclk10 : BUFR
      generic map (
         BUFR_DIVIDE => "BYPASS"
      )
      port map (
         I           => rxrecclk10, 
         CE          => '1', 
         CLR         => '0', 
         O           => rxrecclk1_bufr0
      );

      RXRECCLK1_0 <= rxrecclk1_bufr0;

      clock_correction_A : entity xps_ll_temac_v2_03_a.v4_rx_elastic_buffer(structural)
      port map ( 

         -- Signals received from the RocketIO on RXRECCLK.

         rxrecclk                     => rxrecclk1_bufr0,
         reset                        => RXRESET_0,
         rxchariscomma_rec            => rxchariscomma_rec0,
         rxcharisk_rec                => rxcharisk_rec0,         
         rxdisperr_rec                => rxdisperr_rec0,         
         rxnotintable_rec             => rxnotintable_rec0, 
         rxrundisp_rec                => rxrundisp_rec0,      
         rxdata_rec                   => rxdata_rec0,       

         -- Signals reclocked onto RXUSRCLK2.

         rxusrclk2                    => RXUSRCLK2_0,
         rxreset                      => RXRESET_0,
         rxchariscomma_usr            => RXCHARISCOMMA_0,
         rxcharisk_usr                => RXCHARISK_0_INT,
         rxdisperr_usr                => RXDISPERR_0,
         rxnotintable_usr             => RXNOTINTABLE_0_INT,
         rxrundisp_usr                => RXRUNDISP_0_INT,
         rxclkcorcnt_usr              => rxclkcorcnt0,
         rxbuferr                     => RXBUFERR_0,
         rxdata_usr                   => RXDATA_0_INT
      );



      -- Assign clock correction information to RXSTATUS
      RXSTATUS_0_INT(5) <= '0';
      RXSTATUS_0_INT(4) <= '1' when (rxclkcorcnt0 /= "000") else '0';
      RXSTATUS_0_INT(3) <= '0';
      RXSTATUS_0_INT(2) <= '0';
      RXSTATUS_0_INT(1) <= '0';
      RXSTATUS_0_INT(0) <= '1' when (rxclkcorcnt0 = "100") else '0';



  ----------------------------------------------------------------------
  -- Instantiate the Virtex-4 FX GT11 B for EMAC1
  ----------------------------------------------------------------------


   GT11_1000X_B : GT11
   generic map( 
    
    ---------- RocketIO MGT 64B66B Block Sync State Machine Attributes --------- 

        SH_CNT_MAX                 =>      64,
        SH_INVALID_CNT_MAX         =>      16,
        
    ----------------------- RocketIO MGT Alignment Atrributes ------------------   

        ALIGN_COMMA_WORD           =>      1,
        COMMA_10B_MASK             =>      x"07f",
        COMMA32                    =>      FALSE,
        DEC_MCOMMA_DETECT          =>      TRUE,
        DEC_PCOMMA_DETECT          =>      TRUE,
        DEC_VALID_COMMA_ONLY       =>      TRUE,
        MCOMMA_32B_VALUE           =>      x"00000283",
        MCOMMA_DETECT              =>      TRUE,
        PCOMMA_32B_VALUE           =>      x"0000017c",
        PCOMMA_DETECT              =>      TRUE,
        PCS_BIT_SLIP               =>      FALSE,        
        
    ---- RocketIO MGT Atrributes Common to Clk Correction & Channel Bonding ----   

        CCCB_ARBITRATOR_DISABLE    =>      FALSE,
        CLK_COR_8B10B_DE           =>      TRUE,        

    ------------------- RocketIO MGT Channel Bonding Atrributes ----------------   
    
        CHAN_BOND_LIMIT            =>      16,
        CHAN_BOND_MODE             =>      "NONE",
        CHAN_BOND_ONE_SHOT         =>      FALSE,
        CHAN_BOND_SEQ_1_1          =>      "00000000000",
        CHAN_BOND_SEQ_1_2          =>      "00000000000",
        CHAN_BOND_SEQ_1_3          =>      "00000000000",
        CHAN_BOND_SEQ_1_4          =>      "00000000000",
        CHAN_BOND_SEQ_1_MASK       =>      "1111",
        CHAN_BOND_SEQ_2_1          =>      "00000000000",
        CHAN_BOND_SEQ_2_2          =>      "00000000000",
        CHAN_BOND_SEQ_2_3          =>      "00000000000",
        CHAN_BOND_SEQ_2_4          =>      "00000000000",
        CHAN_BOND_SEQ_2_MASK       =>      "1111",
        CHAN_BOND_SEQ_2_USE        =>      FALSE,
        CHAN_BOND_SEQ_LEN          =>      1,
 
    ------------------ RocketIO MGT Clock Correction Atrributes ----------------   

        CLK_COR_MAX_LAT            =>      48,
        CLK_COR_MIN_LAT            =>      36,
        CLK_COR_SEQ_1_1            =>      "00110111100",
        CLK_COR_SEQ_1_2            =>      "00001010000",
        CLK_COR_SEQ_1_3            =>      "00000000000",
        CLK_COR_SEQ_1_4            =>      "00000000000",
        CLK_COR_SEQ_1_MASK         =>      "1100",
        CLK_COR_SEQ_2_1            =>      "00110111100",
        CLK_COR_SEQ_2_2            =>      "00010110101",
        CLK_COR_SEQ_2_3            =>      "00000000000",
        CLK_COR_SEQ_2_4            =>      "00000000000",
        CLK_COR_SEQ_2_MASK         =>      "1100",
        CLK_COR_SEQ_2_USE          =>      FALSE,
        CLK_COR_SEQ_DROP           =>      FALSE,
        CLK_COR_SEQ_LEN            =>      2,
        CLK_CORRECT_USE            =>      TRUE,
        
    ---------------------- RocketIO MGT Clocking Atrributes --------------------      
                                        
        RX_CLOCK_DIVIDER           =>      "10",
        RXASYNCDIVIDE              =>      "00",
        RXCLK0_FORCE_PMACLK        =>      TRUE,
        RXCLKMODE                  =>      "000011",
        RXOUTDIV2SEL               =>      4,
        RXPLLNDIVSEL               =>      10,
        RXPMACLKSEL                =>      "REFCLK1",
        RXRECCLK1_USE_SYNC         =>      FALSE,
        RXUSRDIVISOR               =>      1,
        TX_CLOCK_DIVIDER           =>      "10",
        TXABPMACLKSEL              =>      "REFCLK1",
        TXASYNCDIVIDE              =>      "00",
        TXCLK0_FORCE_PMACLK        =>      TRUE,
        TXCLKMODE                  =>      "0100",
        TXOUTCLK1_USE_SYNC         =>      FALSE,
        TXOUTDIV2SEL               =>      4,
        TXPHASESEL                 =>      FALSE, 
        TXPLLNDIVSEL               =>      10,

    -------------------------- RocketIO MGT CRC Atrributes ---------------------   

        RXCRCCLOCKDOUBLE           =>      FALSE,
        RXCRCENABLE                =>      FALSE,
        RXCRCINITVAL               =>      x"FFFFFFFF",
        RXCRCINVERTGEN             =>      FALSE,
        RXCRCSAMECLOCK             =>      TRUE,
        TXCRCCLOCKDOUBLE           =>      FALSE,
        TXCRCENABLE                =>      FALSE,
        TXCRCINITVAL               =>      x"FFFFFFFF",
        TXCRCINVERTGEN             =>      FALSE,
        TXCRCSAMECLOCK             =>      TRUE,
        
    --------------------- RocketIO MGT Data Path Atrributes --------------------   
    
        RXDATA_SEL                 =>      "00",
        TXDATA_SEL                 =>      "00",

    ---------------- RocketIO MGT Digital Receiver Attributes ------------------   

        DIGRX_FWDCLK               =>      "10",
        DIGRX_SYNC_MODE            =>      FALSE,
        ENABLE_DCDR                =>      FALSE,
        RXBY_32                    =>      FALSE,
        RXDIGRESET                 =>      FALSE,
        RXDIGRX                    =>      FALSE,
        SAMPLE_8X                  =>      FALSE,
                                        
    ----------------- Rocket IO MGT Miscellaneous Attributes ------------------     

        GT11_MODE                  =>      "B",
        OPPOSITE_SELECT            =>      FALSE,
        PMA_BIT_SLIP               =>      FALSE,
        REPEATER                   =>      FALSE,
        RX_BUFFER_USE              =>      TRUE,
        RXCDRLOS                   =>      "000000",
        RXDCCOUPLE                 =>      FALSE,
        RXFDCAL_CLOCK_DIVIDE       =>      "NONE",
        TX_BUFFER_USE              =>      TRUE,   
        TXFDCAL_CLOCK_DIVIDE       =>      "NONE",
        TXSLEWRATE                 =>      TRUE,

     ----------------- Rocket IO MGT Preemphasis and Equalization --------------
     
        RXAFEEQ                    =>       "000000000",
        RXEQ                       =>       x"4000000000000000",
        TXDAT_PRDRV_DAC            =>       "111",
        TXDAT_TAP_DAC              =>       "10110",
        TXHIGHSIGNALEN             =>       TRUE,
        TXPOST_PRDRV_DAC           =>       "111",
        TXPOST_TAP_DAC             =>       "00001",
        TXPOST_TAP_PD              =>       TRUE,
        TXPRE_PRDRV_DAC            =>       "111",
        TXPRE_TAP_DAC              =>       "00000",      
        TXPRE_TAP_PD               =>       TRUE,        
                                        
                                        
                                          
    ----------------------- Restricted RocketIO MGT Attributes -------------------  

    ---Note : THE FOLLOWING ATTRIBUTES ARE RESTRICTED. PLEASE DO NOT EDIT.

     ----------------------------- Restricted: Biasing -------------------------
     
        BANDGAPSEL                 =>       FALSE,
        BIASRESSEL                 =>       FALSE,    
        IREFBIASMODE               =>       "11",
        PMAIREFTRIM                =>       "0111",
        PMAVREFTRIM                =>       "0111",
        TXAREFBIASSEL              =>       TRUE, 
        TXTERMTRIM                 =>       "1100",
        VREFBIASMODE               =>       "11",

     ---------------- Restricted: Frequency Detector and Calibration -----------  
     
        CYCLE_LIMIT_SEL            =>       "00",
        FDET_HYS_CAL               =>       "010",
        FDET_HYS_SEL               =>       "100",
        FDET_LCK_CAL               =>       "101",
        FDET_LCK_SEL               =>       "001",
        LOOPCAL_WAIT               =>       "00",
        RXCYCLE_LIMIT_SEL          =>       "00",
        RXFDET_HYS_CAL             =>       "010",
        RXFDET_HYS_SEL             =>       "100",
        RXFDET_LCK_CAL             =>       "101",   
        RXFDET_LCK_SEL             =>       "001",
        RXLOOPCAL_WAIT             =>       "00",
        RXSLOWDOWN_CAL             =>       "00",
        SLOWDOWN_CAL               =>       "00",

     --------------------------- Restricted: PLL Settings ---------------------
     
        PMACLKENABLE               =>       TRUE,
        PMACOREPWRENABLE           =>       TRUE,
        PMAVBGCTRL                 =>       "00000",
        RXACTST                    =>       FALSE,          
        RXAFETST                   =>       FALSE,         
        RXCMADJ                    =>       "01",
        RXCPSEL                    =>       FALSE,
        RXCPTST                    =>       FALSE,
        RXCTRL1                    =>       x"200",
        RXFECONTROL1               =>       "00",  
        RXFECONTROL2               =>       "000",  
        RXFETUNE                   =>       "01", 
        RXLKADJ                    =>       "00000",
        RXLOOPFILT                 =>       "1111",
        RXPDDTST                   =>       TRUE,          
        RXRCPADJ                   =>       "010",   
        RXRIBADJ                   =>       "11",
        RXVCO_CTRL_ENABLE          =>       TRUE,
        RXVCODAC_INIT              =>       "0000000101",   
        TXCPSEL                    =>       FALSE,
        TXCTRL1                    =>       x"200",
        TXLOOPFILT                 =>       "1101",   
        VCO_CTRL_ENABLE            =>       TRUE,
        VCODAC_INIT                =>       "0000000101",
        
    --------------------------- Restricted: Powerdowns ------------------------  
    
        POWER_ENABLE               =>       TRUE,
        RXAFEPD                    =>       FALSE,
        RXAPD                      =>       FALSE,
        RXLKAPD                    =>       FALSE,
        RXPD                       =>       FALSE,
        RXRCPPD                    =>       FALSE,
        RXRPDPD                    =>       FALSE,
        RXRSDPD                    =>       FALSE,
        TXAPD                      =>       FALSE,
        TXDIGPD                    =>       FALSE,
        TXLVLSHFTPD                =>       FALSE,
        TXPD                       =>       FALSE
      )

      -- unused
       port map (
                CHBONDO                      => open,
                COMBUSIN(15 downto 0)        => COMBUSOUT_0(15 downto 0),
                DRDY                         => gt_drdy_1,
                RXBUFERR                     => open,
                RXCALFAIL                    => open,
                RXCHARISCOMMA                => open,
                RXCHARISK                    => open,
                RXCOMMADET                   => open,
                RXCRCOUT                     => open,
                RXCYCLELIMIT                 => open,
                RXDATA                       => open,
                RXDISPERR                    => open,
                RXLOCK                       => gt_rxlock_1,
                RXLOSSOFSYNC                 => open,
                RXMCLK                       => open,
                RXNOTINTABLE                 => open,
                RXPCSHCLKOUT                 => open,
                RXREALIGN                    => open,
                RXRECCLK1                    => open,
                RXRECCLK2                    => gt_rxrecclk2_1,
                RXRUNDISP                    => open,
                RXSIGDET                     => open,
                RXSTATUS                     => open,
                TXBUFERR                     => open,
                TXCALFAIL                    => open,
                TXCRCOUT                     => open,
                TXCYCLELIMIT                 => open,
                TXKERR                       => open,
                TXLOCK                       => gt_txlock_1,
                TXOUTCLK1                    => gt_txoutclk1_1,
                TXOUTCLK2                    => open,
                TXPCSHCLKOUT                 => open,
                TXRUNDISP                    => open,
                TX1N                         => TX1N_1_UNUSED,
                TX1P                         => TX1P_1_UNUSED,

                CHBONDI                      => (others => '0'),
                COMBUSOUT(15 downto 0)       => COMBUSOUT_1(15 downto 0),
                DADDR(7 downto 0)            => gt_daddr_1,
                DCLK                         => DCLK,
                DEN                          => gt_den_1,
                DI(15 downto 0)              => gt_do_1,
                DWE                          => gt_dwe_1,
                ENCHANSYNC                   => '0',
                ENMCOMMAALIGN                => '0',
                ENPCOMMAALIGN                => '0',
                GREFCLK                      => '0',
                LOOPBACK(1 downto 0)         => gt_loopback_1,
                POWERDOWN                    => '1',
                REFCLK1                      => REFCLK1_0,
                REFCLK2                      => REFCLK2_0,
                RXBLOCKSYNC64B66BUSE         => '0',
                RXCLKSTABLE                  => '1',
                RXCOMMADETUSE                => '1',
                RXCRCCLK                     => '0',
                RXCRCDATAVALID               => '0',
                RXCRCDATAWIDTH               => "000",
                RXCRCIN                      => X"0000000000000000",
                RXCRCINIT                    => '0',
                RXCRCINTCLK                  => '0',
                RXCRCPD                      => '1',
                RXCRCRESET                   => '0',
                RXDATAWIDTH                  => "00",
                RXDEC8B10BUSE                => '1',
                RXDEC64B66BUSE               => '0',
                RXDESCRAM64B66BUSE           => '0',
                RXIGNOREBTF                  => '0',
                RXINTDATAWIDTH               => "11",
                RXPMARESET                   => RXPMARESET0,
                RXPOLARITY                   => '0',
                RXRESET                      => '0',
                RXSLIDE                      => '0',
                RXSYNC                       => '0',
                RXUSRCLK                     => '0',
                RXUSRCLK2                    => '0',
                RX1N                         => RX1N_1_UNUSED,
                RX1P                         => RX1P_1_UNUSED,
                TXBYPASS8B10B                => gt_txbypass8b10b_1,
                TXCHARDISPMODE               => "00000000",
                TXCHARDISPVAL                => "00000000",
                TXCHARISK                    => "00000000",
                TXCLKSTABLE                  => '1',
                TXCRCCLK                     => '0',
                TXCRCDATAVALID               => '0',
                TXCRCDATAWIDTH               => "000",
                TXCRCIN                      => X"0000000000000000",
                TXCRCINIT                    => '0',
                TXCRCINTCLK                  => '0',
                TXCRCPD                      => '1',
                TXCRCRESET                   => '0',
                TXDATA                       => X"0000000000000000",
                TXDATAWIDTH                  => "00",
                TXENC8B10BUSE                => gt_txenc8b10buse_1,
                TXENC64B66BUSE               => '0',
                TXENOOB                      => '0',
                TXGEARBOX64B66BUSE           => '0',
                TXINHIBIT                    => '1',
                TXINTDATAWIDTH               => "11",
                TXPMARESET                   => PMARESET_TX0,
                TXPOLARITY                   => '0',
                TXRESET                      => '0',
                TXSCRAM64B66BUSE             => '0',
                TXSYNC                       => '0',
                TXUSRCLK                     => '0',
                TXUSRCLK2                    => '0',
                DO                           => gt_di_1
      );



      ---------------------------------------------------------------------
      -- Component Instantiation for the version 1.4.1 Calibration Block
      -- Applied to the GT11 B connected to EMAC1 (unused)
      ---------------------------------------------------------------------

      cal_block_B : entity xps_ll_temac_v2_03_a.v4_cal_block_v1_4_1(rtl)
  generic map (
    C_MGT_ID            => 1,  										-- 0 = MGTA | 1 = MGTB
    C_TXPOST_TAP_PD     => "TRUE",  							-- "TRUE" or "FALSE"
    C_RXDIGRX           => "TRUE"   							-- "TRUE" or "FALSE"
  )
  port map (
    -- User DRP Interface (destination/slave interface)
    USER_DO             => open,    							-- O [15:0]
    USER_DI             => X"0000", 							-- I [15:0]
    USER_DADDR          => X"00",   							-- I [7:0]
    USER_DEN            => '0',     							-- I
    USER_DWE            => '0',     							-- I
    USER_DRDY           => open,    							-- O

    -- MGT DRP Interface (source/master interface)
    GT_DO               => gt_do_1,     					-- O [15:0]
    GT_DI               => gt_di_1,     					-- I [15:0]
    GT_DADDR            => gt_daddr_1,  					-- O [7:0]
    GT_DEN              => gt_den_1,    					-- O
    GT_DWE              => gt_dwe_1,    					-- O
    GT_DRDY             => gt_drdy_1,   					-- I

    -- Clock and Reset
    DCLK                => DCLK, 									-- I
    RESET               => CAL_BLOCK_RESET, 			-- I

    -- Calibration Block Active and Disable Signals (legacy)
    ACTIVE              => open, 									-- O

    -- User side MGT Pass through Signals
    USER_LOOPBACK       =>  "00", 		      			-- I [1:0]
    USER_TXENC8B10BUSE  =>  '1',        					-- I
    USER_TXBYPASS8B10B  =>  X"00",      					-- I [7:0]

    -- GT side MGT Pass through Signals
    GT_LOOPBACK         => gt_loopback_1,      		-- O [1:0]
    GT_TXENC8B10BUSE    => gt_txenc8b10buse_1, 		-- O
    GT_TXBYPASS8B10B    => gt_txbypass8b10b_1, 		-- O [7:0]

    -- Signal Detect Ports
    TX_SIGNAL_DETECT    => '0', 									-- I
    RX_SIGNAL_DETECT    => '0'  		              -- I

  );

 end structural;
