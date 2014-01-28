-------------------------------------------------------------------------------
-- xps_sysace.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ***************************************************************************
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
-- Copyright 2001, 2002, 2004, 2005, 2006, 2008, 2009 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
-- ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        xps_sysace.vhd
-- Version:         v1.01a
-- Description:     This is the top-level design file for the SystemACE 
--                  Controller.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  xps_sysace.vhd
--                      -- plbv46_slave_single.vhd
--                      -- sysace.vhd
--                          --mem_state_machine.vhd
--                          -- sync_2_clock.vhd
--
-------------------------------------------------------------------------------
-- Author:          VKN
-- History:     
-- ~~~~~~~~~~~~~~
--   VKN                11/06/06
-- ^^^^^^^^^^^^^^
--  First version of xps_sysace. Based on OPB SYSACE 1.00c
-- ~~~~~~~~~~~~~~
--------------------------------------------------------------------------------
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
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
--------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_arith.conv_std_logic_vector;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;

-- vcomponents package of the unisim library is used for different component 
-- declaration
library unisim;
use unisim.vcomponents.all;

-- Libraries used for different functions and component declaration
library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;
use proc_common_v3_00_a.ipif_pkg.all;
use proc_common_v3_00_a.family.all;
use proc_common_v3_00_a.all;

-- Library used for sysace_common instantiation
library sysace_common_v1_01_a;
use sysace_common_v1_01_a.sysace;

-- Library used for the plb_slave_single instantiation
library plbv46_slave_single_v1_01_a; 
use plbv46_slave_single_v1_01_a.plbv46_slave_single;

-- Library unsigned is used for overloading of "=" which allows integer to
-- be compared to std_logic_vector
use ieee.std_logic_unsigned.all;
--
-------------------------------------------------------------------------------
--                     Defination of Generics :                              --
-------------------------------------------------------------------------------
-- C_BASEADDR            -- XPS GPIO Base Address
-- C_HIGHADDR            -- XPS GPIO High Address
-- C_MEM_WDITH           -- Data Access mode for Sysace registers
-- C_SPLB_AWIDTH         -- Width of the PLB address bus
-- C_SPLB_DWIDTH         -- width of the PLB data bus
-- C_SPLB_P2P            -- Selects point to point or shared topology
-- C_SPLB_MID_WIDTH      -- PLB Master ID bus width
-- C_SPLB_NUM_MASTERS    -- Number of PLB masters 
-- C_SPLB_NATIVE_DWIDTH  -- Slave bus data width
-- C_SPLB_SUPPORT_BURSTS -- Burst/no burst support
-- C_FAMILY              -- XILINX FPGA family
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--                  Defination of Ports                                      --
-------------------------------------------------------------------------------
    
--   PLB Slave Signals 
--      PLB_ABus                -- PLB address bus          
--      PLB_UABus               -- PLB upper address bus
--      PLB_PAValid             -- PLB primary address valid
--      PLB_SAValid             -- PLB secondary address valid
--      PLB_rdPrim              -- PLB secondary to primary read request
--      PLB_wrPrim              -- PLB secondary to primary write request
--      PLB_masterID            -- PLB current master identifier
--      PLB_abort               -- PLB abort request
--      PLB_busLock             -- PLB bus lock
--      PLB_RNW                 -- PLB read not write
--      PLB_BE                  -- PLB byte enable
--      PLB_MSize               -- PLB data bus width indicator
--      PLB_size                -- PLB transfer size
--      PLB_type                -- PLB transfer type
--      PLB_lockErr             -- PLB lock error
--      PLB_wrDBus              -- PLB write data bus
--      PLB_wrBurst             -- PLB burst write transfer
--      PLB_rdBurst             -- PLB burst read transfer
--      PLB_wrPendReq           -- PLB pending bus write request
--      PLB_rdPendReq           -- PLB pending bus read request
--      PLB_wrPendPri           -- PLB pending bus write request priority
--      PLB_rdPendPri           -- PLB pending bus read request priority
--      PLB_reqPri              -- PLB current request 
--      PLB_TAttribute          -- PLB transfer attribute
--   Slave Responce Signal
--      Sl_addrAck              -- Slave address ack
--      Sl_SSize                -- Slave data bus size
--      Sl_wait                 -- Slave wait indicator
--      Sl_rearbitrate          -- Slave rearbitrate
--      Sl_wrDAck               -- Slave write data ack
--      Sl_wrComp               -- Slave write complete
--      Sl_wrBTerm              -- Slave terminate write burst transfer
--      Sl_rdDBus               -- Slave read data bus
--      Sl_rdWdAddr             -- Slave read word address
--      Sl_rdDAck               -- Slave read data ack
--      Sl_rdComp               -- Slave read complete
--      Sl_rdBTerm              -- Slave terminate read burst transfer
--      Sl_MBusy                -- Slave busy
--      Sl_MWrErr               -- Slave write error
--      Sl_MRdErr               -- Slave read error
--      Sl_MIRQ                 -- Master interrput 
--
--   Memory signals
--      SysACE_MPA              -- SYSACE address inputs
--      SysACE_CLK              -- SYSACE clock
--      SysACE_MPIRQ            -- SYSACE interrupt
--      SysACE_MPD_I            -- SYSACE input data bus
--      SysACE_MPD_O            -- SYSACE output data bus
--      SysACE_MPD_T            -- SYSACE data output enable
--      SysACE_CEN              -- SYSACE chip select
--      SysACE_OEN              -- SYSACE output enable
--      SysACE_WEN              -- SYSACE write enable
--      SysACE_IRQ              -- SYSACE interrupt
--
--   System Signals
--      SPLB_Clk                -- System clock
--      SPLB_Rst                -- System Reset (active high)
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------

entity xps_sysace is
  generic 
  (
     -- Generics to be set by user---------------------------------------------
     C_BASEADDR                      : std_logic_vector         := X"FFFFFFFF";
     C_HIGHADDR                      : std_logic_vector         := X"00000000";
     C_MEM_WIDTH                     : integer range 8 to 16    := 16;
     -- Generics set for PLBV46------------------------------------------------
     C_SPLB_AWIDTH                   : integer range 32 to 36   := 32;
     C_SPLB_DWIDTH                   : integer range 32 to 128  := 32;
     C_SPLB_P2P                      : integer range 0 to 1     := 0;
     C_SPLB_MID_WIDTH                : integer range 1 to 4     := 1;
     C_SPLB_NUM_MASTERS              : integer range 1 to 16    := 1;
     C_SPLB_NATIVE_DWIDTH            : integer range 32 to 128  := 32;    
     C_SPLB_SUPPORT_BURSTS           : integer range 0 to 1     := 0;    
     C_FAMILY                        : string                   := "virtex5"
  );
  port
  (
     -- System signals --------------------------------------------------------
     SPLB_Clk             : in  std_logic;
     SPLB_Rst             : in  std_logic;
     -- Bus Slave signals -----------------------------------------------------
     PLB_ABus             : in  std_logic_vector(0 to 31);
     PLB_UABus            : in  std_logic_vector(0 to 31);
     PLB_PAValid          : in  std_logic;
     PLB_SAValid          : in  std_logic;
     PLB_rdPrim           : in  std_logic;
     PLB_wrPrim           : in  std_logic;
     PLB_masterID         : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
     PLB_abort            : in  std_logic;
     PLB_busLock          : in  std_logic;
     PLB_RNW              : in  std_logic;
     PLB_BE               : in  std_logic_vector(0 to (C_SPLB_DWIDTH/8)-1);
     PLB_MSize            : in  std_logic_vector(0 to 1);
     PLB_size             : in  std_logic_vector(0 to 3);
     PLB_type             : in  std_logic_vector(0 to 2);
     PLB_lockErr          : in  std_logic;
     PLB_wrDBus           : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);
     PLB_wrBurst          : in  std_logic;
     PLB_rdBurst          : in  std_logic;   
     PLB_wrPendReq        : in  std_logic; 
     PLB_rdPendReq        : in  std_logic; 
     PLB_wrPendPri        : in  std_logic_vector(0 to 1); 
     PLB_rdPendPri        : in  std_logic_vector(0 to 1); 
     PLB_reqPri           : in  std_logic_vector(0 to 1);
     PLB_TAttribute       : in  std_logic_vector(0 to 15); 
     
     -- Slave Response Signals-------------------------------------------------
     Sl_addrAck           : out std_logic;
     Sl_SSize             : out std_logic_vector(0 to 1);
     Sl_wait              : out std_logic;
     Sl_rearbitrate       : out std_logic;
     Sl_wrDAck            : out std_logic;
     Sl_wrComp            : out std_logic;
     Sl_wrBTerm           : out std_logic;
     Sl_rdDBus            : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
     Sl_rdWdAddr          : out std_logic_vector(0 to 3);
     Sl_rdDAck            : out std_logic;
     Sl_rdComp            : out std_logic;
     Sl_rdBTerm           : out std_logic;
     Sl_MBusy             : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
     Sl_MWrErr            : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
     Sl_MRdErr            : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
     Sl_MIRQ              : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);

     -- User SystemACE Port----------------------------------------------------
     SysACE_CLK           : in  std_logic;
     SysACE_MPIRQ         : in  std_logic;
     SysACE_MPD_I         : in  std_logic_vector(C_MEM_WIDTH-1 downto 0);
     SysACE_MPD_O         : out std_logic_vector(C_MEM_WIDTH-1 downto 0);
     SysACE_MPD_T         : out std_logic_vector(C_MEM_WIDTH-1 downto 0);
     SysACE_MPA           : out std_logic_vector(6 downto 0);
     SysACE_CEN           : out std_logic;
     SysACE_OEN           : out std_logic;
     SysACE_WEN           : out std_logic;
     SysACE_IRQ           : out std_logic

  );

  --fan-out attributes for XST-------------------------------------------------
  attribute MAX_FANOUT                          : string;
  attribute MAX_FANOUT   of SPLB_Clk            : signal is "10000";
  attribute MAX_FANOUT   of SPLB_Rst            : signal is "10000";
                
  -- PSFUtil MPD attributes----------------------------------------------------
  attribute IP_GROUP                            : string;
  attribute IP_GROUP of xps_sysace              : entity is "LOGICORE";
                  
  attribute MIN_SIZE                            : string;
  attribute MIN_SIZE of C_BASEADDR              : constant is "0x80";
                
  attribute SIGIS                               : string;
  attribute SIGIS of SPLB_Clk                   : signal is "Clk";
  attribute SIGIS of SPLB_Rst                   : signal is "Rst";
  attribute SIGIS of SysACE_IRQ                 : signal is "INTR_LEVEL_HIGH";
  
  attribute ASSIGNMENT                          : string;
  attribute ASSIGNMENT of C_BASEADDR            : constant is "REQUIRE";
  attribute ASSIGNMENT of C_HIGHADDR            : constant is "REQUIRE";
  attribute ASSIGNMENT of C_SPLB_DWIDTH         : constant is "CONSTANT";
  attribute ASSIGNMENT of C_SPLB_NATIVE_DWIDTH  : constant is "CONSTANT";
  attribute ASSIGNMENT of C_SPLB_AWIDTH         : constant is "CONSTANT";
  
  attribute XRANGE                              : string;
  attribute XRANGE of C_MEM_WIDTH               : constant is "(8,16)";

      
end entity xps_sysace;


-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of xps_sysace is

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
constant MEM_AWIDTH           : integer := 7;  -- change this if SysAce changes
constant IPIF_AWIDTH          : integer := C_SPLB_AWIDTH;
constant IPIF_DWIDTH          : integer := 32;
--constant IPIF_DWIDTH          : integer := C_SPLB_NATIVE_DWIDTH;
constant SYSACE_ID            : integer := 120;
constant ZEROES               : std_logic_vector := X"00000000";
constant ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE :=
       (
        ZEROES & C_BASEADDR, -- SYSACE Base Address := X"2000_0000"
        ZEROES & C_HIGHADDR  -- SYSACE High Address := X"2FFF_FFFF"
       );
constant ARD_NUM_CE_ARRAY     : INTEGER_ARRAY_TYPE :=
       (
         0 => 1    -- SYSACE CE number
       );

-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------
-- IPIC Used Signals
signal ip2bus_rdack     : std_logic;
signal ip2bus_wrack     : std_logic;
signal ip2bus_errack    : std_logic;
signal ip2bus_data_ipif : std_logic_vector(0 to IPIF_DWIDTH - 1);
signal ip2bus_data_i    : std_logic_vector(0 to IPIF_DWIDTH - 1);
signal bus2IP_Addr      : std_logic_vector(0 to IPIF_AWIDTH - 1);
signal bus2IP_Data      : std_logic_vector(0 to IPIF_DWIDTH - 1);
signal bus2IP_Data_i    : std_logic_vector(0 to IPIF_DWIDTH - 1);
signal bus2IP_RNW       : std_logic;
signal bus2IP_RdCE      : std_logic_vector(0 to
				           calc_num_ce(ARD_NUM_CE_ARRAY)-1);
signal bus2IP_WrCE      : std_logic_vector(0 to 
				           calc_num_ce(ARD_NUM_CE_ARRAY)-1);
signal bus2IP_BE        : std_logic_vector(0 to (IPIF_DWIDTH / 8) - 1);
signal bus2IP_Clk       : std_logic;
signal bus2IP_Reset     : std_logic;
signal bus2IP_CS        : std_logic_vector(0 to 
                                          ((ARD_ADDR_RANGE_ARRAY'LENGTH)/2)-1);
signal sysace_cen_i     : std_logic;
signal sysace_oen_i     : std_logic;
signal sysace_wen_i     : std_logic;
signal sysace_mpa_i     : std_logic_vector(6 downto 0);
signal mpa              : std_logic_vector(0 to 6);
signal mpd_i            : std_logic_vector(0 to C_MEM_WIDTH -1);
signal sysace_mpd_o_i   : std_logic_vector(C_MEM_WIDTH-1 downto 0);
signal mpd_o            : std_logic_vector(0 to C_MEM_WIDTH -1);
signal sysace_mpd_t_i   : std_logic_vector(C_MEM_WIDTH-1 downto 0);
signal mpd_t            : std_logic_vector(0 to C_MEM_WIDTH -1);


-------------------------------------------------------------------------------

begin -- architecture IMP

-------------------------------------------------------------------------------
-- Change the the Bus2IP/IP2Bus_Data little Endian to SysACE_MPD Big Endian
-------------------------------------------------------------------------------
sysace_mpd_o_i(7)   <= mpd_o(0);
sysace_mpd_o_i(6)   <= mpd_o(1);
sysace_mpd_o_i(5)   <= mpd_o(2);
sysace_mpd_o_i(4)   <= mpd_o(3);
sysace_mpd_o_i(3)   <= mpd_o(4);
sysace_mpd_o_i(2)   <= mpd_o(5);
sysace_mpd_o_i(1)   <= mpd_o(6);
sysace_mpd_o_i(0)   <= mpd_o(7);

sysace_mpd_t_i(7)   <= mpd_t(0);
sysace_mpd_t_i(6)   <= mpd_t(1);
sysace_mpd_t_i(5)   <= mpd_t(2);
sysace_mpd_t_i(4)   <= mpd_t(3);
sysace_mpd_t_i(3)   <= mpd_t(4);
sysace_mpd_t_i(2)   <= mpd_t(5);
sysace_mpd_t_i(1)   <= mpd_t(6);
sysace_mpd_t_i(0)   <= mpd_t(7);

mpd_i(0)            <= SYSACE_MPD_I(7);
mpd_i(1)            <= SYSACE_MPD_I(6);
mpd_i(2)            <= SYSACE_MPD_I(5);
mpd_i(3)            <= SYSACE_MPD_I(4);
mpd_i(4)            <= SYSACE_MPD_I(3);
mpd_i(5)            <= SYSACE_MPD_I(2);
mpd_i(6)            <= SYSACE_MPD_I(1);
mpd_i(7)            <= SYSACE_MPD_I(0);

-------------------------------------------------------------------------------
-- Change the the higher order bytes of Bus2IP/IP2Bus_Data little Endian to 
-- SysACE_MPD Big Endian, incase the bus width=16
-------------------------------------------------------------------------------
MEMWIDTH_16_GEN: if C_MEM_WIDTH = 16 generate
   sysace_mpd_o_i(15)  <= mpd_o(8);
   sysace_mpd_o_i(14)  <= mpd_o(9);
   sysace_mpd_o_i(13)  <= mpd_o(10);
   sysace_mpd_o_i(12)  <= mpd_o(11);
   sysace_mpd_o_i(11)  <= mpd_o(12);
   sysace_mpd_o_i(10)  <= mpd_o(13);
   sysace_mpd_o_i(9)   <= mpd_o(14);
   sysace_mpd_o_i(8)   <= mpd_o(15);
   
   sysace_mpd_t_i(15)  <= mpd_t(8);
   sysace_mpd_t_i(14)  <= mpd_t(9);
   sysace_mpd_t_i(13)  <= mpd_t(10);
   sysace_mpd_t_i(12)  <= mpd_t(11);
   sysace_mpd_t_i(11)  <= mpd_t(12);
   sysace_mpd_t_i(10)  <= mpd_t(13);
   sysace_mpd_t_i(9)   <= mpd_t(14);
   sysace_mpd_t_i(8)   <= mpd_t(15);
   
   mpd_i(8)            <= SYSACE_MPD_I(15);
   mpd_i(9)            <= SYSACE_MPD_I(14);
   mpd_i(10)           <= SYSACE_MPD_I(13);
   mpd_i(11)           <= SYSACE_MPD_I(12);
   mpd_i(12)           <= SYSACE_MPD_I(11);
   mpd_i(13)           <= SYSACE_MPD_I(10);
   mpd_i(14)           <= SYSACE_MPD_I(9) ;
   mpd_i(15)           <= SYSACE_MPD_I(8) ;
  
end generate MEMWIDTH_16_GEN;

SYSACE_MPD_O          <=  sysace_mpd_o_i ;
SYSACE_MPD_T          <=  sysace_mpd_t_i ;

-------------------------------------------------------------------------------
-- Change the the Bus2IP_Addr little Endian to SysACE_MPA Big Endian
-------------------------------------------------------------------------------
sysace_mpa_i(6) <=  mpa(0);
sysace_mpa_i(5) <=  mpa(1);
sysace_mpa_i(4) <=  mpa(2);
sysace_mpa_i(3) <=  mpa(3);
sysace_mpa_i(2) <=  mpa(4);
sysace_mpa_i(1) <=  mpa(5);
sysace_mpa_i(0) <=  mpa(6);
SYSACE_MPA      <=  sysace_mpa_i;


SYSACE_CEN      <=  sysace_cen_i;
SYSACE_OEN      <=  sysace_oen_i;
SYSACE_WEN      <=  sysace_wen_i;
SYSACE_IRQ      <=  SysACE_MPIRQ;


-------------------------------------------------------------------------------
-- Component Instantiations
-------------------------------------------------------------------------------

PLBV46_I : entity plbv46_slave_single_v1_01_a.plbv46_slave_single
  generic map
  (
     C_ARD_ADDR_RANGE_ARRAY => ARD_ADDR_RANGE_ARRAY,
     C_ARD_NUM_CE_ARRAY     => ARD_NUM_CE_ARRAY,
     C_SPLB_P2P             => C_SPLB_P2P,
     C_SPLB_MID_WIDTH       => C_SPLB_MID_WIDTH,
     C_SPLB_NUM_MASTERS     => C_SPLB_NUM_MASTERS,
     C_SPLB_AWIDTH          => C_SPLB_AWIDTH,
     C_SPLB_DWIDTH          => C_SPLB_DWIDTH,   
     C_SIPIF_DWIDTH         => C_SPLB_NATIVE_DWIDTH,
     C_FAMILY               => C_FAMILY
  )
  port map
  (
     -- System signals --------------------------------------------------------
     SPLB_Clk          => SPLB_Clk,
     SPLB_Rst          => SPLB_Rst,
     -- Bus Slave signals -----------------------------------------------------
     PLB_ABus          => PLB_ABus,      
     PLB_UABus         => PLB_UABus,     
     PLB_PAValid       => PLB_PAValid, 
     PLB_SAValid       => PLB_SAValid,
     PLB_rdPrim        => PLB_rdPrim, 
     PLB_wrPrim        => PLB_wrPrim,
     PLB_masterID      => PLB_masterID, 
     PLB_abort         => PLB_abort,
     PLB_busLock       => PLB_busLock, 
     PLB_RNW           => PLB_RNW,
     PLB_BE            => PLB_BE, 
     PLB_MSize         => PLB_MSize,
     PLB_size          => PLB_size, 
     PLB_type          => PLB_type,
     PLB_lockErr       => PLB_lockErr, 
     PLB_wrDBus        => PLB_wrDBus,
     PLB_wrBurst       => PLB_wrBurst, 
     PLB_rdBurst       => PLB_rdBurst,
     PLB_wrPendReq     => PLB_wrPendReq, 
     PLB_rdPendReq     => PLB_rdPendReq,
     PLB_wrPendPri     => PLB_wrPendPri, 
     PLB_rdPendPri     => PLB_rdPendPri,
     PLB_reqPri        => PLB_reqPri, 
     PLB_TAttribute    => PLB_TAttribute,
     -- Slave Response Signals ------------------------------------------------
     Sl_addrAck        => Sl_addrAck,   
     Sl_SSize          => Sl_SSize,  
     Sl_wait           => Sl_wait,
     Sl_rearbitrate    => Sl_rearbitrate,
     Sl_wrDAck         => Sl_wrDAck, 
     Sl_wrComp         => Sl_wrComp,
     Sl_wrBTerm        => Sl_wrBTerm,
     Sl_rdDBus         => Sl_rdDBus,
     Sl_rdWdAddr       => Sl_rdWdAddr,
     Sl_rdDAck         => Sl_rdDAck,
     Sl_rdComp         => Sl_rdComp, 
     Sl_rdBTerm        => Sl_rdBTerm,
     Sl_MBusy          => Sl_MBusy,
     Sl_MWrErr         => Sl_MWrErr,
     Sl_MRdErr         => Sl_MRdErr, 
     Sl_MIRQ           => Sl_MIRQ,
     -- IP Interconnect (IPIC) port signals -----------------------------------
     Bus2IP_Clk        => Bus2IP_Clk,   
     Bus2IP_Reset      => Bus2IP_Reset, 
     IP2Bus_Data       => ip2bus_data_ipif,         
     IP2Bus_WrAck      => ip2bus_wrack,
     IP2Bus_RdAck      => ip2bus_rdack,
     IP2Bus_Error      => ip2bus_errack,
     Bus2IP_Addr       => bus2ip_addr,   
     Bus2IP_Data       => bus2ip_data_i,
     Bus2IP_RNW        => bus2ip_rnw,      
     Bus2IP_BE         => bus2ip_be,    
     Bus2IP_CS         => bus2ip_cs,
     Bus2IP_RdCE       => bus2ip_rdce, 
     Bus2IP_WrCE       => bus2ip_wrce    
  );

-------------------------------------------------------------------------------
-- BYTE STEERING has to be done here, since the plbv46_slave_single does not 
-- do anymore byte steering and the sysace_common is designed taking byte
-- steering into consideration.
-------------------------------------------------------------------------------

ip2bus_data_ipif(0 to C_MEM_WIDTH -1)   
                <= ip2bus_data_i(0 to C_MEM_WIDTH -1) 
                         when Bus2IP_BE(0)='1' or Bus2IP_BE(0 to 1)="11" else
                         (others => '0');
ip2bus_data_ipif(C_MEM_WIDTH to 2*C_MEM_WIDTH -1)
                <= ip2bus_data_i(0 to C_MEM_WIDTH -1)
                         when Bus2IP_BE(1)='1' or Bus2IP_BE(2 to 3) = "11" else
                         (others => '0');

                          
MEM_WIDTH_8_GEN: if C_MEM_WIDTH = 8 generate
   ip2bus_data_ipif(2*C_MEM_WIDTH to 3*C_MEM_WIDTH -1)
                   <= ip2bus_data_i(0 to C_MEM_WIDTH -1)
                             when Bus2IP_BE(2)='1' else
                             (others => '0');
   ip2bus_data_ipif(3*C_MEM_WIDTH to 4*C_MEM_WIDTH -1)
                   <= ip2bus_data_i(0 to C_MEM_WIDTH -1)
                             when Bus2IP_BE(3)='1' else
                             (others => '0');
   Bus2IP_Data(0 to C_MEM_WIDTH -1)                   
                   <= bus2IP_Data_i(0 to C_MEM_WIDTH -1)
                           when Bus2IP_BE(0)='1' or Bus2IP_BE(0 to 1)="11" else
                      bus2IP_Data_i(C_MEM_WIDTH to 2*C_MEM_WIDTH -1)
                           when Bus2IP_BE(1)='1' or Bus2IP_BE(2 to 3)="11" else
                      bus2IP_Data_i(2*C_MEM_WIDTH to 3*C_MEM_WIDTH -1) 
                           when Bus2IP_BE(2)='1' else 
                      bus2IP_Data_i(3*C_MEM_WIDTH to 4*C_MEM_WIDTH -1) 
                           when Bus2IP_BE(3)='1' else
                      (others => '0');
   Bus2IP_Data(C_MEM_WIDTH to 4*C_MEM_WIDTH-1) <= (others => '0');
    
end generate MEM_WIDTH_8_GEN;                          
                          
MEM_WIDTH_16_GEN: if C_MEM_WIDTH = 16 generate

   Bus2IP_Data(0 to C_MEM_WIDTH -1)                   
                   <= bus2IP_Data_i(0 to C_MEM_WIDTH -1)
                            when Bus2IP_BE(0)='1' or Bus2IP_BE(0 to 1)="11"
                                                  or Bus2IP_BE(1)='1' else
                      bus2IP_Data_i(C_MEM_WIDTH to 2*C_MEM_WIDTH -1)
                            when Bus2IP_BE(2)='1' or Bus2IP_BE(2 to 3)="11"
                                                  or Bus2IP_BE(3)='1' else
                      (others => '0');
   Bus2IP_Data(C_MEM_WIDTH to 2*C_MEM_WIDTH-1) <= (others => '0');
    
end generate MEM_WIDTH_16_GEN;
                          
-------------------------------------------------------------------------------
-- SYSACE controller
-------------------------------------------------------------------------------

I_SYSACE_CONTROLLER : entity sysace_common_v1_01_a.sysace
  generic map
  (
     C_BASEADDR           =>  C_BASEADDR,
     C_HIGHADDR           =>  C_HIGHADDR,
     C_IPIF_DWIDTH        =>  C_SPLB_NATIVE_DWIDTH,
     C_IPIF_AWIDTH        =>  C_SPLB_AWIDTH,
     C_MEM_DWIDTH         =>  C_MEM_WIDTH,
     C_MEM_AWIDTH         =>  MEM_AWIDTH
  )
  port map 
  (
     Bus2IP_Reset         =>  Bus2IP_Reset,
     Bus2IP_Clk           =>  Bus2IP_Clk,
     Bus2IP_Addr          =>  Bus2IP_Addr,
     Bus2IP_BE            =>  Bus2IP_BE,
     Bus2IP_Data          =>  Bus2IP_Data,
     Bus2IP_RNW           =>  Bus2IP_RNW,
     Bus2IP_CS            =>  Bus2IP_CS(0),
     Bus2IP_RdCE          =>  Bus2IP_RdCE(0),
     Bus2IP_WrCE          =>  Bus2IP_WrCE(0),
    
     IP2Bus_Data          => ip2bus_data_i,
     IP2Bus_errAck        => ip2bus_errack,
     IP2Bus_retry         => open,
     IP2Bus_toutSup       => open,
     IP2Bus_RdAck         => ip2bus_rdack,
     IP2Bus_WrAck         => ip2bus_wrack,
                         
     SysACE_MPA           => mpa,    
     SysACE_CLK           => SysACE_CLK,    
     SysACE_MPD_I         => mpd_i,   
     SysACE_MPD_O         => mpd_o,   
     SysACE_MPD_T         => mpd_t,   
     SysACE_CEN           => sysace_cen_i,    
     SysACE_OEN           => sysace_oen_i,    
     SysACE_WEN           => sysace_wen_i    
  );

end implementation;

