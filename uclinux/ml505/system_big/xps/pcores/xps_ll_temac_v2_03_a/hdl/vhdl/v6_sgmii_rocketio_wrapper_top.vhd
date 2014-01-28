-------------------------------------------------------------------------------
-- $Id: v6_sgmii_rocketio_wrapper_top.vhd,v 1.1.4.39 2009/11/17 07:11:38 tomaik Exp $
------------------------------------------------------------------------------
-- File       : v6_sgmii_rocketio_wrapper_top.vhd
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
--               This is based on Coregen Wrappers from ISE L (11.3i)
--               Wrapper version 1.3
--
------------------------------------------------------------------------
-- Description:  This is the top-level RocketIO GTX wrapper. It
--               instantiates the lower-level wrappers produced by
--               the Virtex-6 FPGA RocketIO GTX Wrapper Wizard.
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library UNISIM;
use UNISIM.Vcomponents.ALL;

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

entity v6_sgmii_rocketio_wrapper_top is
   port (
      RESETDONE           : out   std_logic;
      ENMCOMMAALIGN       : in    std_logic;
      ENPCOMMAALIGN       : in    std_logic;
      LOOPBACK            : in    std_logic;
      POWERDOWN           : in    std_logic;
      RXUSRCLK2           : in    std_logic;
      RXRESET             : in    std_logic;
      TXCHARDISPMODE      : in    std_logic;
      TXCHARDISPVAL       : in    std_logic;
      TXCHARISK           : in    std_logic;
      TXDATA              : in    std_logic_vector (7 downto 0);
      TXUSRCLK2           : in    std_logic;
      TXRESET             : in    std_logic;
      RXCHARISCOMMA       : out   std_logic;
      RXCHARISK           : out   std_logic;
      RXCLKCORCNT         : out   std_logic_vector (2 downto 0);
      RXDATA              : out   std_logic_vector (7 downto 0);
      RXDISPERR           : out   std_logic;
      RXNOTINTABLE        : out   std_logic;
      RXRUNDISP           : out   std_logic;
      RXBUFERR            : out   std_logic;
      TXBUFERR            : out   std_logic;
      PLLLKDET            : out   std_logic;
      TXOUTCLK            : out   std_logic;
      RXELECIDLE          : out   std_logic;
      TXN                 : out   std_logic;
      TXP                 : out   std_logic;
      RXN                 : in    std_logic;
      RXP                 : in    std_logic;
      CLK_DS              : in    std_logic;
      PMARESET            : in    std_logic
   );
end v6_sgmii_rocketio_wrapper_top;


architecture RTL of v6_sgmii_rocketio_wrapper_top is


  ----------------------------------------------------------------------
  -- Signal declarations for GTX
  ----------------------------------------------------------------------

   signal GND_BUS           : std_logic_vector (55 downto 0);

   signal RXBUFSTATUS_float : std_logic_vector(1 downto 0);
   signal TXBUFSTATUS_float : std_logic;

   signal RXRECCLK          : std_logic;
   signal RXRECCLK_BUFR     : std_logic;
   signal RXCHARISCOMMA_REC : std_logic_vector(1 downto 0);
   signal RXNOTINTABLE_REC  : std_logic_vector(1 downto 0);
   signal RXCHARISK_REC     : std_logic_vector(1 downto 0);
   signal RXDISPERR_REC     : std_logic_vector(1 downto 0);
   signal RXRUNDISP_REC     : std_logic_vector(1 downto 0);
   signal RXDATA_REC        : std_logic_vector(15 downto 0);

   signal RXRESET_REG       : std_logic;
   signal RXRESET_REC       : std_logic;
   signal RXBUFRESET_REG    : std_logic;
   signal RXBUFRESET_REC    : std_logic;
   signal RXRESET_USR_REG   : std_logic;
   signal RXRESET_USR       : std_logic;
   signal ENPCOMMAALIGN_REG : std_logic;
   signal ENPCOMMAALIGN_REC : std_logic;
   signal ENMCOMMAALIGN_REG : std_logic;
   signal ENMCOMMAALIGN_REC : std_logic;
   signal RXBUFERR_REC      : std_logic;
   signal RXBUFERR_INT      : std_logic;

   attribute KEEP                           : boolean;
   attribute KEEP of RXRECCLK               : signal is TRUE;
   attribute ASYNC_REG                      : string;
   attribute ASYNC_REG of RXRESET_REG       : signal is "TRUE";
   attribute ASYNC_REG of RXRESET_REC       : signal is "TRUE";
   attribute ASYNC_REG of RXBUFRESET_REG    : signal is "TRUE";
   attribute ASYNC_REG of RXBUFRESET_REC    : signal is "TRUE";
   attribute ASYNC_REG of RXRESET_USR_REG   : signal is "TRUE";
   attribute ASYNC_REG of RXRESET_USR       : signal is "TRUE";
   attribute ASYNC_REG of ENPCOMMAALIGN_REG : signal is "TRUE";
   attribute ASYNC_REG of ENPCOMMAALIGN_REC : signal is "TRUE";
   attribute ASYNC_REG of ENMCOMMAALIGN_REG : signal is "TRUE";
   attribute ASYNC_REG of ENMCOMMAALIGN_REC : signal is "TRUE";

   signal rxbuf_reset_i : std_logic;
   signal clk_ds_i      : std_logic;
   signal pma_reset_i   : std_logic;
   signal reset_r       : std_logic_vector(3 downto 0);

   attribute ASYNC_REG of reset_r : signal is "TRUE";

   signal resetdone_tx_i : std_logic;
   signal resetdone_tx_r : std_logic;
   signal resetdone_rx_i : std_logic;
   signal resetdone_rx_r : std_logic;
   signal resetdone_i    : std_logic;

begin

   GND_BUS(55 downto 0) <= (others => '0');

   --------------------------------------------------------------------
   -- RocketIO PMA reset circuitry
   --------------------------------------------------------------------

   -- Locally buffer the output of the IBUFDS_GTXE1 for reset logic
   bufr_clk_ds : BUFR port map (
     I   => CLK_DS,
     O   => clk_ds_i,
     CE  => '1',
     CLR => '0'
   );

   process(PMARESET, clk_ds_i)
   begin
     if (PMARESET = '1') then
       reset_r <= "1111";
     elsif clk_ds_i'event and clk_ds_i = '1' then
       reset_r <= reset_r(2 downto 0) & PMARESET;
     end if;
   end process;

   pma_reset_i <= reset_r(3);

   ----------------------------------------------------------------------
   -- Instantiate the Virtex-6 GTX
   ----------------------------------------------------------------------

   -- Direct from the RocketIO Wizard output
    rocketio_wrapper_inst : entity xps_ll_temac_v2_03_a.v6_sgmii_rocketio_wrapper(RTL)
    generic map (
        WRAPPER_SIM_GTXRESET_SPEEDUP     => 1
    )
    port map (
        ---------------------- Loopback and Powerdown Ports ----------------------
        GTX0_LOOPBACK_IN(2 downto 1)     => "00",
        GTX0_LOOPBACK_IN(0)              => LOOPBACK,
        GTX0_RXPOWERDOWN_IN(0)           => POWERDOWN,
        GTX0_RXPOWERDOWN_IN(1)           => POWERDOWN,
        GTX0_TXPOWERDOWN_IN(0)           => POWERDOWN,
        GTX0_TXPOWERDOWN_IN(1)           => POWERDOWN,
        --------------------- Receive Ports - 8b10b Decoder ----------------------
        GTX0_RXCHARISCOMMA_OUT           => RXCHARISCOMMA_REC,
        GTX0_RXCHARISK_OUT               => RXCHARISK_REC,
        GTX0_RXDISPERR_OUT               => RXDISPERR_REC,
        GTX0_RXNOTINTABLE_OUT            => RXNOTINTABLE_REC,
        GTX0_RXRUNDISP_OUT               => RXRUNDISP_REC,
        ----------------- Receive Ports - Clock Correction Ports -----------------
        GTX0_RXCLKCORCNT_OUT             => open,
        ------------- Receive Ports - Comma Detection and Alignment --------------
        GTX0_RXENMCOMMAALIGN_IN          => ENMCOMMAALIGN_REC,
        GTX0_RXENPCOMMAALIGN_IN          => ENPCOMMAALIGN_REC,
        ----------------- Receive Ports - RX Data Path interface -----------------
        GTX0_RXDATA_OUT                  => RXDATA_REC,
        GTX0_RXRECCLK_OUT                => RXRECCLK,
        GTX0_RXRESET_IN                  => RXRESET_REC,
        GTX0_RXUSRCLK2_IN                => RXRECCLK_BUFR,
        ------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        GTX0_RXBUFRESET_IN               => RXRESET_REC,
        GTX0_RXBUFSTATUS_OUT(2)          => RXBUFERR_REC,
        GTX0_RXBUFSTATUS_OUT(1 downto 0) => RXBUFSTATUS_float,
        ----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        GTX0_RXELECIDLE_OUT              => RXELECIDLE,
        GTX0_RXN_IN                      => RXN,
        GTX0_RXP_IN                      => RXP,
        -------------------- Receive Ports - RX PLL Ports ------------------------
        GTX0_GTXRXRESET_IN               => pma_reset_i,
        GTX0_MGTREFCLKRX_IN              => CLK_DS,
        GTX0_PLLRXRESET_IN               => pma_reset_i,
        GTX0_RXPLLLKDET_OUT              => PLLLKDET,
        GTX0_RXRESETDONE_OUT             => resetdone_rx_i,
        -------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        GTX0_TXCHARDISPMODE_IN           => TXCHARDISPMODE,
        GTX0_TXCHARDISPVAL_IN            => TXCHARDISPVAL,
        GTX0_TXCHARISK_IN                => TXCHARISK,
        ---------------- Transmit Ports - TX Data Path interface -----------------
        GTX0_TXDATA_IN                   => TXDATA,
        GTX0_TXOUTCLK_OUT                => TXOUTCLK,
        GTX0_TXRESET_IN                  => TXRESET,
        GTX0_TXUSRCLK2_IN                => TXUSRCLK2,
        ------------- Transmit Ports - TX Driver and OOB signalling --------------
        GTX0_TXN_OUT                     => TXN,
        GTX0_TXP_OUT                     => TXP,
        ----------- Transmit Ports - TX Buffering and Phase Alignment ------------
        GTX0_TXBUFSTATUS_OUT(1)          => TXBUFERR,
        GTX0_TXBUFSTATUS_OUT(0)          => TXBUFSTATUS_float,
        -------------------- Transmit Ports - TX PLL Ports -----------------------
        GTX0_GTXTXRESET_IN               => pma_reset_i,
        GTX0_TXRESETDONE_OUT             => resetdone_tx_i
   );

   -- Register the Tx and Rx resetdone signals, and AND them to provide a
   -- single RESETDONE output
   process(TXUSRCLK2, TXRESET)
   begin
      if (TXRESET = '1') then
         resetdone_tx_r <= '0';
      elsif TXUSRCLK2'event and TXUSRCLK2 = '1' then
         resetdone_tx_r <= resetdone_tx_i;
      end if;
   end process;

   process(RXUSRCLK2, RXRESET)
   begin
      if (RXRESET = '1') then
         resetdone_rx_r <= '0';
      elsif RXUSRCLK2'event and RXUSRCLK2 = '1' then
         resetdone_rx_r <= resetdone_rx_i;
      end if;
   end process;

   resetdone_i <= resetdone_tx_r and resetdone_rx_r;
   RESETDONE   <= resetdone_i;

   -- Route RXRECLK through a regional clock buffer
   rxrecclkbufr : BUFR port map (
     I   => RXRECCLK,
     O   => RXRECCLK_BUFR,
     CE  => '1',
     CLR => '0'
   );

   -- Instantiate the RX elastic buffer. This performs clock
   -- correction on the incoming data to cope with differences
   -- between the user clock and the clock recovered from the data.
   rx_elastic_buffer_inst : entity xps_ll_temac_v2_03_a.v6_rx_elastic_buffer(structural)
    port map (
     -- Signals from the GTX on RXRECCLK
     rxrecclk          => RXRECCLK_BUFR,
     rxrecreset        => RXBUFRESET_REC,
     rxchariscomma_rec => RXCHARISCOMMA_REC,
     rxcharisk_rec     => RXCHARISK_REC,
     rxdisperr_rec     => RXDISPERR_REC,
     rxnotintable_rec  => RXNOTINTABLE_REC,
     rxrundisp_rec     => RXRUNDISP_REC,
     rxdata_rec        => RXDATA_REC,

     -- Signals reclocked onto USRCLK2
     rxusrclk2         => RXUSRCLK2,
     rxreset           => RXRESET_USR,
     rxchariscomma_usr => RXCHARISCOMMA,
     rxcharisk_usr     => RXCHARISK,
     rxdisperr_usr     => RXDISPERR,
     rxnotintable_usr  => RXNOTINTABLE,
     rxrundisp_usr     => RXRUNDISP,
     rxclkcorcnt_usr   => RXCLKCORCNT,
     rxbuferr          => RXBUFERR_INT,
     rxdata_usr        => RXDATA
   );

  RXBUFERR <= RXBUFERR_INT or RXBUFERR_REC;

  -- Resynchronise the PMARESET onto the RXRECCLK domain
  rxrstreclock : process(RXRECCLK_BUFR, PMARESET)
  begin
    if PMARESET = '1' then
        RXRESET_REG  <= '1';
        RXRESET_REC  <= '1';
    elsif RXRECCLK_BUFR'event and RXRECCLK_BUFR = '1' then
        RXRESET_REG  <= '0';
        RXRESET_REC  <= RXRESET_REG;
    end if;
  end process rxrstreclock;

  -- Generate a reset to the rx_elastic_buffer in the RXRECCLK domain
  rxbuf_reset_i <= PMARESET or (not resetdone_i);
  rxrstreclockbuf : process(RXRECCLK_BUFR, rxbuf_reset_i)
  begin
    if rxbuf_reset_i = '1' then
        RXBUFRESET_REG  <= '1';
        RXBUFRESET_REC  <= '1';
    elsif RXRECCLK_BUFR'event and RXRECCLK_BUFR = '1' then
        RXBUFRESET_REG  <= '0';
        RXBUFRESET_REC  <= RXBUFRESET_REG;
    end if;
  end process rxrstreclockbuf;

  -- Resynchronise the RXRESET onto the RXUSRCLK2 domain
  rxrstusrreclock : process(RXUSRCLK2, RXRESET)
  begin
    if RXRESET = '1' then
        RXRESET_USR_REG  <= '1';
        RXRESET_USR      <= '1';
    elsif RXUSRCLK2'event and RXUSRCLK2 = '1' then
        RXRESET_USR_REG  <= '0';
        RXRESET_USR      <= RXRESET_USR_REG;
    end if;
  end process rxrstusrreclock;

  -- Re-align signals from the USRCLK domain into the RXRECCLK domain
  rxrecclkreclock : process (RXRECCLK_BUFR, RXRESET_REC)
  begin
    if RXRESET_REC = '1' then
      ENPCOMMAALIGN_REG <= '0';
      ENPCOMMAALIGN_REC <= '0';
      ENMCOMMAALIGN_REG <= '0';
      ENMCOMMAALIGN_REC <= '0';
    elsif RXRECCLK_BUFR'event and RXRECCLK_BUFR = '1' then
      ENPCOMMAALIGN_REG <= ENPCOMMAALIGN;
      ENPCOMMAALIGN_REC <= ENPCOMMAALIGN_REG;
      ENMCOMMAALIGN_REG <= ENMCOMMAALIGN;
      ENMCOMMAALIGN_REC <= ENMCOMMAALIGN_REG;
    end if;
  end process rxrecclkreclock;

end RTL;
