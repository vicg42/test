------------------------------------------------------------------------------
-- $Id: v6_1000basex.vhd,v 1.1.4.39 2009/11/17 07:11:38 tomaik Exp $
-------------------------------------------------------------------------------
-- Title      : Virtex-6 Ethernet MAC Wrapper
-------------------------------------------------------------------------------
-- File       : v6_1000basex.vhd
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
--------------------------------------------------------------------------------
-- Description:  This wrapper file instantiates the full Virtex-6 Ethernet 
--               Tri-Mode Ethernet MAC (EMAC) primitive, where:
--
--               * all unused input ports on the primitive are tied to the
--                 appropriate logic level;
--
--               * all unused output ports on the primitive are left
--                 unconnected;
--
--               * the attributes are set based on the options selected
--                 from CORE Generator;
--
--               * only used ports are connected to the ports of this
--                 wrapper file.
--
--               This simplified wrapper should therefore be used as the
--               instantiation template for the EMAC primitive in customer
--               designs.
--
--               This is based on Coregen Wrappers from ISE L (11.3i)
--               Wrapper version 1.3
--------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
-- The entity declaration for the Virtex-6 Embedded Ethernet MAC wrapper.
--------------------------------------------------------------------------------

entity v6_1000basex is
  generic (
           C_INCLUDE_IO                : integer          := 1;
           C_EMAC_DCRBASEADDR          : bit_vector       := "0000000000";
           C_TEMAC_PHYADDR             : std_logic_vector(4 downto 0) := "00010"
          );
    port(

        -- Client Receiver Interface
        EMACCLIENTRXCLIENTCLKOUT      : out std_logic;
        CLIENTEMACRXCLIENTCLKIN       : in  std_logic;
        EMACCLIENTRXD                 : out std_logic_vector(7 downto 0);
        EMACCLIENTRXDVLD              : out std_logic;
        EMACCLIENTRXDVLDMSW           : out std_logic;
        EMACCLIENTRXGOODFRAME         : out std_logic;
        EMACCLIENTRXBADFRAME          : out std_logic;
        EMACCLIENTRXFRAMEDROP         : out std_logic;
        EMACCLIENTRXSTATS             : out std_logic_vector(6 downto 0);
        EMACCLIENTRXSTATSVLD          : out std_logic;
        EMACCLIENTRXSTATSBYTEVLD      : out std_logic;

        -- Client Transmitter Interface
        EMACCLIENTTXCLIENTCLKOUT      : out std_logic;
        CLIENTEMACTXCLIENTCLKIN       : in  std_logic;
        CLIENTEMACTXD                 : in  std_logic_vector(7 downto 0);
        CLIENTEMACTXDVLD              : in  std_logic;
        CLIENTEMACTXDVLDMSW           : in  std_logic;
        EMACCLIENTTXACK               : out std_logic;
        CLIENTEMACTXFIRSTBYTE         : in  std_logic;
        CLIENTEMACTXUNDERRUN          : in  std_logic;
        EMACCLIENTTXCOLLISION         : out std_logic;
        EMACCLIENTTXRETRANSMIT        : out std_logic;
        CLIENTEMACTXIFGDELAY          : in  std_logic_vector(7 downto 0);
        EMACCLIENTTXSTATS             : out std_logic;
        EMACCLIENTTXSTATSVLD          : out std_logic;
        EMACCLIENTTXSTATSBYTEVLD      : out std_logic;

        -- MAC Control Interface
        CLIENTEMACPAUSEREQ            : in  std_logic;
        CLIENTEMACPAUSEVAL            : in  std_logic_vector(15 downto 0);

        -- Clock Signals
        GTX_CLK                       : in  std_logic;
        PHYEMACTXGMIIMIICLKIN         : in  std_logic;
        EMACPHYTXGMIIMIICLKOUT        : out std_logic;

        -- 1000BASE-X PCS/PMA Interface
        RXDATA                        : in  std_logic_vector(7 downto 0);
        TXDATA                        : out std_logic_vector(7 downto 0);
        MMCM_LOCKED                   : in  std_logic;
        AN_INTERRUPT                  : out std_logic;
        SIGNAL_DETECT                 : in  std_logic;
        PHYAD                         : in  std_logic_vector(4 downto 0);
        ENCOMMAALIGN                  : out std_logic;
        LOOPBACKMSB                   : out std_logic;
        MGTRXRESET                    : out std_logic;
        MGTTXRESET                    : out std_logic;
        POWERDOWN                     : out std_logic;
        SYNCACQSTATUS                 : out std_logic;
        RXCLKCORCNT                   : in  std_logic_vector(2 downto 0);
        RXBUFSTATUS                   : in  std_logic;
        RXCHARISCOMMA                 : in  std_logic;
        RXCHARISK                     : in  std_logic;
        RXDISPERR                     : in  std_logic;
        RXNOTINTABLE                  : in  std_logic;
        RXREALIGN                     : in  std_logic;
        RXRUNDISP                     : in  std_logic;
        TXBUFERR                      : in  std_logic;
        TXCHARDISPMODE                : out std_logic;
        TXCHARDISPVAL                 : out std_logic;
        TXCHARISK                     : out std_logic;

        -- MDIO Interface
        MDC                           : out std_logic;
        MDIO_I                        : in  std_logic;
        MDIO_O                        : out std_logic;
        MDIO_T                        : out std_logic;

        -- DCR Interface
        HOSTCLK                       : in  std_logic;
        DCREMACCLK                    : in  std_logic;
        DCREMACABUS                   : in  std_logic_vector(0 to 9);
        DCREMACREAD                   : in  std_logic;
        DCREMACWRITE                  : in  std_logic;
        DCREMACDBUS                   : in  std_logic_vector(0 to 31);
        EMACDCRACK                    : out std_logic;
        EMACDCRDBUS                   : out std_logic_vector(0 to 31);
        DCREMACENABLE                 : in  std_logic;
        DCRHOSTDONEIR                 : out std_logic;

        -- Asynchronous Reset
        RESET                         : in  std_logic
    );

end v6_1000basex;


architecture WRAPPER of v6_1000basex is

    ----------------------------------------------------------------------------
    -- Attribute declarations
    ----------------------------------------------------------------------------
    -- Configure the PCS/PMA logic
    -- PCS/PMA reset is not asserted
    constant EMAC_PHYRESET : boolean := FALSE;
    -- PCS/PMA Auto-Negotiation is enabled
    constant EMAC_PHYINITAUTONEG_ENABLE : boolean := TRUE;
    -- PCS/PMA isolate is not enabled
    constant EMAC_PHYISOLATE : boolean := FALSE;
    -- PCS/PMA is not held in powerdown mode
    constant EMAC_PHYPOWERDOWN : boolean := FALSE;
    -- PCS/PMA loopback is not enabled
    constant EMAC_PHYLOOPBACKMSB : boolean := FALSE;
    -- GT loopback is not enabled
    constant EMAC_GTLOOPBACK : boolean := FALSE;
    -- Do not allow transmission without having established a valid link
    constant EMAC_UNIDIRECTION_ENABLE : boolean := FALSE;
    constant EMAC_LINKTIMERVAL : bit_vector := x"13D";
    -- Do not ignore the MDIO broadcast address
    constant EMAC_MDIO_IGNORE_PHYADZERO : boolean := FALSE;

    -- Configure the EMAC operating mode
    -- MDIO is enabled
    constant EMAC_MDIO_ENABLE : boolean := TRUE;
    -- Speed is defaulted to 1000 Mb/s
    constant EMAC_SPEED_LSB : boolean := FALSE;
    constant EMAC_SPEED_MSB : boolean := TRUE;
    -- Clock Enable advanced clocking is not in use
    constant EMAC_USECLKEN : boolean := FALSE;
    -- Byte PHY advanced clocking is not supported. Do not modify.
    constant EMAC_BYTEPHY : boolean := FALSE;
    -- RGMII physical interface is not in use
    constant EMAC_RGMII_ENABLE : boolean := FALSE;
    -- SGMII physical interface is not in use
    constant EMAC_SGMII_ENABLE : boolean := FALSE;
    -- 1000BASE-X PCS/PMA physical interface is in use
    constant EMAC_1000BASEX_ENABLE : boolean := TRUE;
    -- The host interface is enabled
    constant EMAC_HOST_ENABLE : boolean := TRUE;
    -- The Tx-side 8-bit client data interface is used
    constant EMAC_TX16BITCLIENT_ENABLE : boolean := FALSE;
    -- The Rx-side 8-bit client data interface is used
    constant EMAC_RX16BITCLIENT_ENABLE : boolean := FALSE;
    -- The address filter is enabled
    constant EMAC_ADDRFILTER_ENABLE : boolean := TRUE;

    -- EMAC configuration defaults
    -- Rx Length/Type checking enabled
    constant EMAC_LTCHECK_DISABLE : boolean := FALSE;
    -- Rx control frame length checking is enabled
    constant EMAC_CTRLLENCHECK_DISABLE : boolean := FALSE;
    -- Rx flow control is enabled
    constant EMAC_RXFLOWCTRL_ENABLE : boolean := TRUE;
    -- Tx flow control is enabled
    constant EMAC_TXFLOWCTRL_ENABLE : boolean := TRUE;
    -- Transmitter is not held in reset
    constant EMAC_TXRESET : boolean := FALSE;
    -- Transmitter Jumbo frames are enabled
    constant EMAC_TXJUMBOFRAME_ENABLE : boolean := TRUE;
    -- Transmitter in-band FCS is not enabled
    constant EMAC_TXINBANDFCS_ENABLE : boolean := FALSE;
    -- Transmitter is enabled
    constant EMAC_TX_ENABLE : boolean := TRUE;
    -- Transmitter VLAN frames are enabled
    constant EMAC_TXVLAN_ENABLE : boolean := TRUE;
    -- Transmitter full-duplex mode is enabled
    constant EMAC_TXHALFDUPLEX : boolean := FALSE;
    -- Transmitter IFG Adjust is enabled
    constant EMAC_TXIFGADJUST_ENABLE : boolean := TRUE;
    -- Receiver is not held in reset
    constant EMAC_RXRESET : boolean := FALSE;
    -- Receiver Jumbo frames are enabled
    constant EMAC_RXJUMBOFRAME_ENABLE : boolean := TRUE;
    -- Receiver in-band FCS is enabled
    constant EMAC_RXINBANDFCS_ENABLE : boolean := TRUE;
    -- Receiver is enabled
    constant EMAC_RX_ENABLE : boolean := TRUE;
    -- Receiver VLAN frames are enabled
    constant EMAC_RXVLAN_ENABLE : boolean := TRUE;
    -- Receiver full-duplex mode is enabled
    constant EMAC_RXHALFDUPLEX : boolean := FALSE;

    -- Configure the EMAC addressing
    -- Set the PAUSE address default
    constant EMAC_PAUSEADDR : bit_vector := x"FFEEDDCCBBAA";
    -- Set the unicast address
    constant EMAC_UNICASTADDR : bit_vector := x"FFEEDDCCBBAA";
    -- Set the DCR base address
--    constant EMAC_DCRBASEADDR : bit_vector := X"00";


    ----------------------------------------------------------------------------
    -- Signal declarations
    ----------------------------------------------------------------------------

    signal gnd_v48_i                    : std_logic_vector(47 downto 0);

    signal client_rx_data_i             : std_logic_vector(15 downto 0);
    signal client_tx_data_i             : std_logic_vector(15 downto 0);
    signal client_tx_data_valid_i       : std_logic;
    signal client_tx_data_valid_msb_i   : std_logic;

    signal rxbufstatus_i                : std_logic_vector(1 downto 0);

    ----------------------------------------------------------------------------
    -- Main body of code
    ----------------------------------------------------------------------------

begin

    gnd_v48_i <= "000000000000000000000000000000000000000000000000";
    rxbufstatus_i <= RXBUFSTATUS & '0';

    -- Use the 8-bit client data interface
    EMACCLIENTRXD <= client_rx_data_i(7 downto 0);
    client_tx_data_i <= "00000000" & CLIENTEMACTXD after 4 ns;
    client_tx_data_valid_i <= CLIENTEMACTXDVLD after 4 ns;
    client_tx_data_valid_msb_i <= '0';

    -- Instantiate the Virtex-6 Embedded Tri-Mode Ethernet MAC
    v6_emac : TEMAC_SINGLE
    generic map (
  EMAC_1000BASEX_ENABLE      => EMAC_1000BASEX_ENABLE,
  EMAC_ADDRFILTER_ENABLE     => EMAC_ADDRFILTER_ENABLE,
  EMAC_BYTEPHY               => EMAC_BYTEPHY,
  EMAC_DCRBASEADDR           => C_EMAC_DCRBASEADDR(9 downto 2),
  EMAC_GTLOOPBACK            => EMAC_GTLOOPBACK,
  EMAC_HOST_ENABLE           => EMAC_HOST_ENABLE,
  EMAC_LINKTIMERVAL          => EMAC_LINKTIMERVAL(3 to 11),
  EMAC_LTCHECK_DISABLE       => EMAC_LTCHECK_DISABLE,
  EMAC_MDIO_ENABLE           => EMAC_MDIO_ENABLE,
  EMAC_PAUSEADDR             => EMAC_PAUSEADDR,
  EMAC_PHYINITAUTONEG_ENABLE => EMAC_PHYINITAUTONEG_ENABLE,
  EMAC_PHYISOLATE            => EMAC_PHYISOLATE,
  EMAC_PHYLOOPBACKMSB        => EMAC_PHYLOOPBACKMSB,
  EMAC_PHYPOWERDOWN          => EMAC_PHYPOWERDOWN,
  EMAC_PHYRESET              => EMAC_PHYRESET,
  EMAC_RGMII_ENABLE          => EMAC_RGMII_ENABLE,
  EMAC_RX16BITCLIENT_ENABLE  => EMAC_RX16BITCLIENT_ENABLE,
  EMAC_RXFLOWCTRL_ENABLE     => EMAC_RXFLOWCTRL_ENABLE,
  EMAC_RXHALFDUPLEX          => EMAC_RXHALFDUPLEX,
  EMAC_RXINBANDFCS_ENABLE    => EMAC_RXINBANDFCS_ENABLE,
  EMAC_RXJUMBOFRAME_ENABLE   => EMAC_RXJUMBOFRAME_ENABLE,
  EMAC_RXRESET               => EMAC_RXRESET,
  EMAC_RXVLAN_ENABLE         => EMAC_RXVLAN_ENABLE,
  EMAC_RX_ENABLE             => EMAC_RX_ENABLE,
  EMAC_SGMII_ENABLE          => EMAC_SGMII_ENABLE,
  EMAC_SPEED_LSB             => EMAC_SPEED_LSB,
  EMAC_SPEED_MSB             => EMAC_SPEED_MSB,
  EMAC_TX16BITCLIENT_ENABLE  => EMAC_TX16BITCLIENT_ENABLE,
  EMAC_TXFLOWCTRL_ENABLE     => EMAC_TXFLOWCTRL_ENABLE,
  EMAC_TXHALFDUPLEX          => EMAC_TXHALFDUPLEX,
  EMAC_TXIFGADJUST_ENABLE    => EMAC_TXIFGADJUST_ENABLE,
  EMAC_TXINBANDFCS_ENABLE    => EMAC_TXINBANDFCS_ENABLE,
  EMAC_TXJUMBOFRAME_ENABLE   => EMAC_TXJUMBOFRAME_ENABLE,
  EMAC_TXRESET               => EMAC_TXRESET,
  EMAC_TXVLAN_ENABLE         => EMAC_TXVLAN_ENABLE,
  EMAC_TX_ENABLE             => EMAC_TX_ENABLE,
  EMAC_UNICASTADDR           => EMAC_UNICASTADDR,
  EMAC_UNIDIRECTION_ENABLE   => EMAC_UNIDIRECTION_ENABLE,
  EMAC_USECLKEN              => EMAC_USECLKEN,
  EMAC_MDIO_IGNORE_PHYADZERO => EMAC_MDIO_IGNORE_PHYADZERO,
  EMAC_CTRLLENCHECK_DISABLE  => EMAC_CTRLLENCHECK_DISABLE
    )
    port map (
        RESET                    => RESET,

        EMACCLIENTRXCLIENTCLKOUT => EMACCLIENTRXCLIENTCLKOUT,
        CLIENTEMACRXCLIENTCLKIN  => CLIENTEMACRXCLIENTCLKIN,
        EMACCLIENTRXD            => client_rx_data_i,
        EMACCLIENTRXDVLD         => EMACCLIENTRXDVLD,
        EMACCLIENTRXDVLDMSW      => EMACCLIENTRXDVLDMSW,
        EMACCLIENTRXGOODFRAME    => EMACCLIENTRXGOODFRAME,
        EMACCLIENTRXBADFRAME     => EMACCLIENTRXBADFRAME,
        EMACCLIENTRXFRAMEDROP    => EMACCLIENTRXFRAMEDROP,
        EMACCLIENTRXSTATS        => EMACCLIENTRXSTATS,
        EMACCLIENTRXSTATSVLD     => EMACCLIENTRXSTATSVLD,
        EMACCLIENTRXSTATSBYTEVLD => EMACCLIENTRXSTATSBYTEVLD,

        EMACCLIENTTXCLIENTCLKOUT => EMACCLIENTTXCLIENTCLKOUT,
        CLIENTEMACTXCLIENTCLKIN  => CLIENTEMACTXCLIENTCLKIN,
        CLIENTEMACTXD            => client_tx_data_i,
        CLIENTEMACTXDVLD         => client_tx_data_valid_i,
        CLIENTEMACTXDVLDMSW      => client_tx_data_valid_msb_i,
        EMACCLIENTTXACK          => EMACCLIENTTXACK,
        CLIENTEMACTXFIRSTBYTE    => CLIENTEMACTXFIRSTBYTE,
        CLIENTEMACTXUNDERRUN     => CLIENTEMACTXUNDERRUN,
        EMACCLIENTTXCOLLISION    => EMACCLIENTTXCOLLISION,
        EMACCLIENTTXRETRANSMIT   => EMACCLIENTTXRETRANSMIT,
        CLIENTEMACTXIFGDELAY     => CLIENTEMACTXIFGDELAY,
        EMACCLIENTTXSTATS        => EMACCLIENTTXSTATS,
        EMACCLIENTTXSTATSVLD     => EMACCLIENTTXSTATSVLD,
        EMACCLIENTTXSTATSBYTEVLD => EMACCLIENTTXSTATSBYTEVLD,

        CLIENTEMACPAUSEREQ       => CLIENTEMACPAUSEREQ,
        CLIENTEMACPAUSEVAL       => CLIENTEMACPAUSEVAL,

        PHYEMACGTXCLK            => GTX_CLK,
        PHYEMACTXGMIIMIICLKIN    => PHYEMACTXGMIIMIICLKIN,
        EMACPHYTXGMIIMIICLKOUT   => EMACPHYTXGMIIMIICLKOUT,

        PHYEMACRXCLK             => '0',
        PHYEMACMIITXCLK          => '0',
        PHYEMACRXD               => RXDATA,
        PHYEMACRXDV              => RXREALIGN,
        PHYEMACRXER              => '0',
        EMACPHYTXCLK             => open,
        EMACPHYTXD               => TXDATA,
        EMACPHYTXEN              => open,
        EMACPHYTXER              => open,
        PHYEMACCOL               => '0',
        PHYEMACCRS               => '0',
        CLIENTEMACDCMLOCKED      => MMCM_LOCKED,
        EMACCLIENTANINTERRUPT    => AN_INTERRUPT,
        PHYEMACSIGNALDET         => SIGNAL_DETECT,
        PHYEMACPHYAD             => C_TEMAC_PHYADDR(4 downto 0),
        EMACPHYENCOMMAALIGN      => ENCOMMAALIGN,
        EMACPHYLOOPBACKMSB       => LOOPBACKMSB,
        EMACPHYMGTRXRESET        => MGTRXRESET,
        EMACPHYMGTTXRESET        => MGTTXRESET,
        EMACPHYPOWERDOWN         => POWERDOWN,
        EMACPHYSYNCACQSTATUS     => SYNCACQSTATUS,
        PHYEMACRXCLKCORCNT       => RXCLKCORCNT,
        PHYEMACRXBUFSTATUS       => rxbufstatus_i,
        PHYEMACRXCHARISCOMMA     => RXCHARISCOMMA,
        PHYEMACRXCHARISK         => RXCHARISK,
        PHYEMACRXDISPERR         => RXDISPERR,
        PHYEMACRXNOTINTABLE      => RXNOTINTABLE,
        PHYEMACRXRUNDISP         => RXRUNDISP,
        PHYEMACTXBUFERR          => TXBUFERR,
        EMACPHYTXCHARDISPMODE    => TXCHARDISPMODE,
        EMACPHYTXCHARDISPVAL     => TXCHARDISPVAL,
        EMACPHYTXCHARISK         => TXCHARISK,

        EMACPHYMCLKOUT           => MDC,
        PHYEMACMCLKIN            => '0',
        PHYEMACMDIN              => MDIO_I,
        EMACPHYMDOUT             => MDIO_O,
        EMACPHYMDTRI             => MDIO_T,

        EMACSPEEDIS10100         => open,
        HOSTCLK                  => HOSTCLK,
        HOSTOPCODE               => gnd_v48_i(1 downto 0),
        HOSTREQ                  => '0',
        HOSTMIIMSEL              => '0',
        HOSTADDR                 => gnd_v48_i(9 downto 0),
        HOSTWRDATA               => gnd_v48_i(31 downto 0),
        HOSTMIIMRDY              => open,
        HOSTRDDATA               => open,

        DCREMACCLK               => DCREMACCLK,
        DCREMACABUS              => DCREMACABUS,
        DCREMACREAD              => DCREMACREAD,
        DCREMACWRITE             => DCREMACWRITE,
        DCREMACDBUS              => DCREMACDBUS,
        EMACDCRACK               => EMACDCRACK,
        EMACDCRDBUS              => EMACDCRDBUS,
        DCREMACENABLE            => DCREMACENABLE,
        DCRHOSTDONEIR            => DCRHOSTDONEIR
    );


end WRAPPER;
