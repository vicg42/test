-------------------------------------------------------------------------------
-- xps_ipif_ssp1.vhd - entity/architecture pair
-------------------------------------------------------------------------------
--  ***************************************************************************
--  ** DISCLAIMER OF LIABILITY                                               **
--  **                                                                       **
--  **  This file contains proprietary and confidential information of       **
--  **  Xilinx, Inc. ("Xilinx"), that is distributed under a license         **
--  **  from Xilinx, and may be used, copied and/or disclosed only           **
--  **  pursuant to the terms of a valid license agreement with Xilinx.      **
--  **                                                                       **
--  **  XILINX is PROVIDING THIS DESIGN, CODE, OR INFORMATION                **
--  **  ("MATERIALS") "AS is" WITHOUT WARRANTY OF ANY KIND, EITHER           **
--  **  EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                  **
--  **  LIMITATION, ANY WARRANTY WITH RESPECT to NONINFRINGEMENT,            **
--  **  MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx        **
--  **  does not warrant that functions included in the Materials will       **
--  **  meet the requirements of Licensee, or that the operation of the      **
--  **  Materials will be uninterrupted or error-free, or that defects       **
--  **  in the Materials will be corrected. Furthermore, Xilinx does         **
--  **  not warrant or make any representations regarding use, or the        **
--  **  results of the use, of the Materials in terms of correctness,        **
--  **  accuracy, reliability or otherwise.                                  **
--  **                                                                       **
--  **  Xilinx products are not designed or intended to be fail-safe,        **
--  **  or for use in any application requiring fail-safe performance,       **
--  **  such as life-support or safety devices or systems, Class III         **
--  **  medical devices, nuclear facilities, applications related to         **
--  **  the deployment of airbags, or any other applications that could      **
--  **  lead to death, personal injury or severe property or                 **
--  **  environmental damage (individually and collectively, "critical       **
--  **  applications"). Customer assumes the sole risk and liability         **
--  **  of any use of Xilinx products in critical applications,              **
--  **  subject only to applicable laws and regulations governing            **
--  **  limitations on product liability.                                    **
--  **                                                                       **
--  **  Copyright 2007, 2008, 2009 Xilinx, Inc.                              **
--  **  All rights reserved.                                                 **
--  **                                                                       **
--  **  This disclaimer and copyright notice must be retained as part        **
--  **  of this file at all times.                                           **
--  ***************************************************************************
-------------------------------------------------------------------------------
-- Filename:        xps_ipif_ssp1.vhd
-- Version:         v2.03.a                        
--
-- Description:     XPS IPIF Slave Services Package 1
-- Purpose:         This block provides the following services:
--                      + wraps the plbv46_slave_single BUS to IPIC block and
--                      sets up its address decoding.
--                      + Provides the Software Reset register
--                      + Provides interrupt servicing
--                      + IPIC multiplexing service between the external IIC
--                      register block IP2Bus data path and the internal
--                      Interrupt controller's IP2Bus data path.
--
-------------------------------------------------------------------------------
-- Structure:
--
--           xps_iic.vhd
--              -- iic.vhd
--                  -- xps_ipif_ssp1.vhd
--                      -- plbv46_slave_single.vhd
--                      -- interrupt_control.vhd
--                      -- soft_reset.vhd
--                  -- reg_interface.vhd
--                  -- filter.vhd
--                      -- debounce.vhd
--                  -- iic_control.vhd
--                      -- upcnt_n.vhd
--                      -- shift8.vhd
--                  -- dynamic_master.vhd
--                  -- iic_pkg.vhd
--
-------------------------------------------------------------------------------
-- Author:      Prabhakar M
--
-- History:
--
--          07/09/04
-- ^^^^^^
--      Initial version.
-- ~~~~~~
-- TRD      12/12/2006
-- ^^^^^^
--      Updated to XPS (plbv46) port attachment using the plbv46_slave_single
--      IPIF. It also directly instantiates an equivalent register for software
--      reset which was present in the old OPB ipif but was unavailable in the
--      new one. Interrupt servicing previously handled by the OPB ipif is now
--      handled in a seperate interrupt controller block. This wrapper looks
--      functionally identical with respect to the services previously provided
--      by the OPB_IPIF. However, the implementation uses a smaller PLBV46 ipif
--      so the difference in functionality is implemented locally.
-- ~~~~~~
--  PVK              12/12/08       v2.01.a
-- ^^^^^^
--     Updated to new version v2.01.a
-- ~~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"  
--      generics:                               "C_*"  
--      user defined types:                     "*_TYPE"  
--      state machine next state:               "*_ns"  
--      state machine current state:            "*_cs"  
--      combinatorial signals:                  "*_com"  
--      pipelined or register delay signals:    "*_d#"  
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"  
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"  
--      ports:                                  - Names begin with Uppercase  
--      processes:                              "*_PROCESS"  
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.or_reduce;

library proc_common_v3_00_a;
use proc_common_v3_00_a.ipif_pkg.all;
use proc_common_v3_00_a.soft_reset;

library plbv46_slave_single_v1_01_a;

library interrupt_control_v2_01_a;

-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_BASEADDR           -- User logic base address                                                                                 
--      C_HIGHADDR           -- User logic high address                                                                                 
--      C_NUM_IIC_REGS       -- Number of IIC registers
--      C_SPLB_P2P           -- Point to Point connection
--      C_BUS2CORE_CLK_RATIO -- Bus to core clock ratio
--      C_NUM_IIC_REGS       -- Number of IIC Registers
--      C_SPLB_MID_WIDTH     -- The width of the Master ID bus
--      C_SPLB_NUM_MASTERS   -- The number of Master on the PLB bus
--      C_SPLB_AWIDTH        -- PLB address bus width
--      C_SPLB_DWIDTH        -- PLB data bus width
--      C_SIPIF_DWIDTH       -- IPIF data bus width
--      C_FAMILY             -- Target FPGA architecture
--
--
-- Definition of Ports:
-- IPIC
--      SPLB_Clk             -- System clock
--      SPLB_Rst             -- System Reset (active high)
--      IIC2Bus_IntrEvent    -- IIC Interrupt events        
--      IIC2INTC_Irpt        -- IP-2-interrupt controller
--   PLB Slave Signals       
--      PLB_ABus             -- PLB address bus          
--      PLB_UABus            -- PLB upper address bus
--      PLB_PAValid          -- PLB primary address valid
--      PLB_SAValid          -- PLB secondary address valid
--      PLB_rdPrim           -- PLB secondary to primary read request
--      PLB_wrPrim           -- PLB secondary to primary write request
--      PLB_masterID         -- PLB current master identifier
--      PLB_abort            -- PLB abort request
--      PLB_busLock          -- PLB bus lock
--      PLB_RNW              -- PLB read not write
--      PLB_BE               -- PLB byte enable
--      PLB_MSize            -- PLB data bus width indicator
--      PLB_size             -- PLB transfer size
--      PLB_type             -- PLB transfer type
--      PLB_lockErr          -- PLB lock error
--      PLB_wrDBus           -- PLB write data bus
--      PLB_wrBurst          -- PLB burst write transfer
--      PLB_rdBurst          -- PLB burst read transfer
--      PLB_wrPendReq        -- PLB pending bus write request
--      PLB_rdPendReq        -- PLB pending bus read request
--      PLB_wrPendPri        -- PLB pending bus write request priority
--      PLB_rdPendPri        -- PLB pending bus read request priority
--      PLB_reqPri           -- PLB current request 
--      PLB_TAttribute       -- PLB transfer attribute
--   Slave Responce Signal   
--      Sl_addrAck           -- Salve address ack
--      Sl_SSize             -- Slave data bus size
--      Sl_wait              -- Salve wait indicator
--      Sl_rearbitrate       -- Salve rearbitrate
--      Sl_wrDAck            -- Slave write data ack
--      Sl_wrComp            -- Salve write complete
--      Sl_wrBTerm           -- Salve terminate write burst transfer
--      Sl_rdDBus            -- Slave read data bus
--      Sl_rdWdAddr          -- Slave read word address
--      Sl_rdDAck            -- Salve read data ack
--      Sl_rdComp            -- Slave read complete
--      Sl_rdBTerm           -- Salve terminate read burst transfer
--      Sl_MBusy             -- Slave busy
--      Sl_MWrErr            -- Slave write error
--      Sl_MRdErr            -- Slave read error
--      Sl_MIRQ              -- Master interrput 
--
--  IP interconnect port signals
--      Bus2IP_Clk           -- Bus to IIC clock
--      Bus2IP_Reset         -- Bus to IIC reset
--      Bus2IIC_Addr         -- Bus to IIC address
--      Bus2IIC_BE           -- Bus to IIC byte enables
--      Bus2IIC_CS           -- Bus to IIC chip select
--      Bus2IIC_Data         -- Bus to IIC data bus
--      Bus2IIC_RNW          -- Bus to IIC read not write
--      Bus2IIC_RdCE         -- Bus to IIC read chip enable
--      Bus2IIC_WrCE         -- Bus to IIC write chip enable
--      IIC2Bus_Data         -- IIC to Bus data bus
--      IIC2Bus_WrAck        -- IIC to Bus write transfer acknowledge
--      IIC2Bus_RdAck        -- IIC to Bus read transfer acknowledge
--      IIC2Bus_Error        -- IIC to Bus error acknowledge
-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------
entity xps_ipif_ssp1 is
   generic
      (
         C_BASEADDR     : std_logic_vector(0 to 31):= X"FFFFFFFF";  
         -- User logic base address      
         C_HIGHADDR     : std_logic_vector(0 to 31):= X"00000000";  
         -- User logic high address  
         C_NUM_IIC_REGS : integer                   := 10;  
         -- Number of IIC Registers
         C_SPLB_P2P : integer range 0 to 1 := 0;
         -- Optimize slave interface for a point to point connection

         C_BUS2CORE_CLK_RATIO : integer range 1 to 2 := 1;
         -- Specifies the clock ratio from BUS to Core allowing
         -- the core to operate at a slower than the bus clock rate
         -- A value of 1 represents 1:1 and a value of 2 represents
         -- 2:1 where the bus clock is twice as fast as the core 
         -- clock.


         C_SPLB_MID_WIDTH : integer range 0 to 4 := 3;
         -- The width of the Master ID bus
         -- This is set to log2(C_SPLB_NUM_MASTERS)

         C_SPLB_NUM_MASTERS : integer range 1 to 16 := 8;
         -- The number of Master Devices connected to the PLB bus
         -- Research this to find out default value

         C_SPLB_AWIDTH : integer range 32 to 32 := 32;
         --  width of the PLB Address Bus (in bits)

         C_SPLB_DWIDTH : integer range 32 to 128 := 128;
         --  Width of the PLB Data Bus (in bits)

         C_SIPIF_DWIDTH : integer range 32 to 128 := 32;
         --  Width of IPIF Data Bus (in bits) Must be 32!

         C_FAMILY : string := "virtex4"
         -- Select the target architecture type
         -- see the family.vhd package in the proc_common
         -- library
         );
   port
      (
         -- System signals ----------------------------------------------------
         SPLB_Clk          : in  std_logic;
         SPLB_Rst          : in  std_logic;
         IIC2Bus_IntrEvent : in  std_logic_vector (0 to 7);  
                                             -- IIC Interrupt events
         IIC2INTC_Irpt     : out std_logic;  -- IP-2-interrupt controller

         -- Bus Slave signals -------------------------------------------------
         PLB_ABus          : in  std_logic_vector(0 to 31);
         PLB_UABus         : in  std_logic_vector(0 to 31);
         PLB_PAValid       : in  std_logic;
         PLB_SAValid       : in  std_logic;
         PLB_rdPrim        : in  std_logic;
         PLB_wrPrim        : in  std_logic;
         PLB_masterID      : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
         PLB_abort         : in  std_logic;
         PLB_busLock       : in  std_logic;
         PLB_RNW           : in  std_logic;
         PLB_BE            : in  std_logic_vector(0 to (C_SPLB_DWIDTH/8)-1);
         PLB_MSize         : in  std_logic_vector(0 to 1);
         PLB_size          : in  std_logic_vector(0 to 3);
         PLB_type          : in  std_logic_vector(0 to 2);
         PLB_lockErr       : in  std_logic;
         PLB_wrDBus        : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);
         PLB_wrBurst       : in  std_logic;
         PLB_rdBurst       : in  std_logic;
         PLB_wrPendReq     : in  std_logic;
         PLB_rdPendReq     : in  std_logic;
         PLB_wrPendPri     : in  std_logic_vector(0 to 1);
         PLB_rdPendPri     : in  std_logic_vector(0 to 1);
         PLB_reqPri        : in  std_logic_vector(0 to 1);
         PLB_TAttribute    : in  std_logic_vector(0 to 15);

         -- Slave Response Signals
         Sl_addrAck        : out std_logic;
         Sl_SSize          : out std_logic_vector(0 to 1);
         Sl_wait           : out std_logic;
         Sl_rearbitrate    : out std_logic;
         Sl_wrDAck         : out std_logic;
         Sl_wrComp         : out std_logic;
         Sl_wrBTerm        : out std_logic;
         Sl_rdDBus         : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
         Sl_rdWdAddr       : out std_logic_vector(0 to 3);
         Sl_rdDAck         : out std_logic;
         Sl_rdComp         : out std_logic;
         Sl_rdBTerm        : out std_logic;
         Sl_MBusy          : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
         Sl_MWrErr         : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
         Sl_MRdErr         : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
         Sl_MIRQ           : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);

         -- IP Interconnect (IPIC) port signals used by the IIC registers. 
         Bus2IIC_Clk       : out std_logic;
         Bus2IIC_Reset     : out std_logic;
         Bus2IIC_Addr      : out std_logic_vector(0 to C_SPLB_AWIDTH - 1);
         Bus2IIC_BE        : out std_logic_vector(0 to (C_SIPIF_DWIDTH/8) - 1);
         Bus2IIC_CS        : out std_logic;
         Bus2IIC_Data      : out std_logic_vector(0 to C_SIPIF_DWIDTH - 1);
         Bus2IIC_RNW       : out std_logic;
         Bus2IIC_RdCE      : out std_logic_vector(0 to C_NUM_IIC_REGS-1);
         Bus2IIC_WrCE      : out std_logic_vector(0 to C_NUM_IIC_REGS-1);
         IIC2Bus_Data      : in  std_logic_vector(0 to C_SIPIF_DWIDTH - 1);
         IIC2Bus_WrAck     : in  std_logic;
         IIC2Bus_RdAck     : in  std_logic;
         IIC2Bus_Error     : in  std_logic

         );

end entity xps_ipif_ssp1;



-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture imp of xps_ipif_ssp1 is

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------
   constant ZEROES : std_logic_vector(0 to 31) := X"00000000";

   constant INTR_BASEADDR    : std_logic_vector := C_BASEADDR;
   constant INTR_HIGHADDR    : std_logic_vector := C_BASEADDR or x"0000003F";
   constant RST_BASEADDR     : std_logic_vector := C_BASEADDR or X"00000040";
   constant RST_HIGHADDR     : std_logic_vector := C_BASEADDR or x"00000043";
   constant IIC_REG_BASEADDR : std_logic_vector := C_BASEADDR or x"00000100";
   constant IIC_REG_HIGHADDR : std_logic_vector := C_BASEADDR or x"000001FF";



   constant C_ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE :=
      (
         ZEROES & INTR_BASEADDR,     -- Interrupt controller
         ZEROES & INTR_HIGHADDR,
         ZEROES & RST_BASEADDR,      -- Software reset register
         ZEROES & RST_HIGHADDR,
         ZEROES & IIC_REG_BASEADDR,  -- IIC registers 
         ZEROES & IIC_REG_HIGHADDR
         );       

   constant C_ARD_IDX_INTERRUPT : integer := 0;
   constant C_ARD_IDX_RESET     : integer := 1;
   constant C_ARD_IDX_IIC_REGS  : integer := 2;

-- The C_IP_INTR_MODE_ARRAY must have the same width as the IP2Bus_IntrEvent
-- entity port.
   constant C_IP_INTR_MODE_ARRAY   : integer_array_type 
                                     := (3, 3, 3, 3, 3, 3, 3, 3);
   constant C_INCLUDE_DEV_PENCODER : boolean            := FALSE;
   constant C_INCLUDE_DEV_ISC      : boolean            := FALSE;

   constant C_NUM_INTERRUPT_REGS   : integer := 16;
   constant C_NUM_RESET_REGS       : integer := 1;

   constant C_ARD_NUM_CE_ARRAY : INTEGER_ARRAY_TYPE :=
      (
         C_ARD_IDX_INTERRUPT => C_NUM_INTERRUPT_REGS,
         C_ARD_IDX_RESET     => C_NUM_RESET_REGS,
         C_ARD_IDX_IIC_REGS  => C_NUM_IIC_REGS
         );

   SUBTYPE INTERRUPT_CE_RNG is integer
      range calc_start_ce_index(C_ARD_NUM_CE_ARRAY, 0)
      to calc_start_ce_index(C_ARD_NUM_CE_ARRAY, 0)+C_ARD_NUM_CE_ARRAY(0)-1;

   SUBTYPE RESET_CE_RNG is integer
      range calc_start_ce_index(C_ARD_NUM_CE_ARRAY, 1)
      to calc_start_ce_index(C_ARD_NUM_CE_ARRAY, 1)+C_ARD_NUM_CE_ARRAY(1)-1;

   SUBTYPE IIC_CE_RNG is integer
      range calc_start_ce_index(C_ARD_NUM_CE_ARRAY, 2)
      to calc_start_ce_index(C_ARD_NUM_CE_ARRAY, 2)+C_ARD_NUM_CE_ARRAY(2)-1;

-------------------------------------------------------------------------------
-- Signal and Type Declarations
-------------------------------------------------------------------------------
-- IPIC Signals

   signal xps_Bus2IP_Clk   : std_logic;
   signal xps_Bus2IP_Reset : std_logic;
   signal xps_IP2Bus_Data  : std_logic_vector(0 to C_SIPIF_DWIDTH - 1);
   signal xps_IP2Bus_WrAck : std_logic;
   signal xps_IP2Bus_RdAck : std_logic;
   signal xps_IP2Bus_Error : std_logic;
   signal xps_Bus2IP_Addr  : std_logic_vector(0 to C_SPLB_AWIDTH - 1);
   signal xps_Bus2IP_Data  : std_logic_vector(0 to C_SIPIF_DWIDTH - 1);
   signal xps_Bus2IP_RNW   : std_logic;
   signal xps_Bus2IP_BE    : std_logic_vector(0 to (C_SIPIF_DWIDTH/8) - 1);
   signal xps_Bus2IP_CS    : std_logic_vector(0 to 
                               ((C_ARD_ADDR_RANGE_ARRAY'length)/2)-1);
   signal xps_Bus2IP_RdCE  : std_logic_vector(0 to 
                                calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);
   signal xps_Bus2IP_WrCE  : std_logic_vector(0 to 
                                calc_num_ce(C_ARD_NUM_CE_ARRAY)-1);


-- Derived IPIC signals for use with the reset register functionality
   --signal reset2Bus_Data  : std_logic_vector(0 to C_SIPIF_DWIDTH-1);
   signal reset2Bus_WrAck  : std_logic;
   signal reset2Bus_RdAck  : std_logic;
   signal reset2Bus_Error  : std_logic;
   signal reset2ip_reset   : std_logic;

-- Derived IPIC signals for use with the interrupt controller
   signal Intr2Bus_DevIntr : std_logic;
   signal Intr2Bus_DBus    : std_logic_vector(0 to C_SIPIF_DWIDTH-1);
   signal Intr2Bus_WrAck   : std_logic;
   signal Intr2Bus_RdAck   : std_logic;
   signal Intr2Bus_Error   : std_logic;

   signal intr2_wrack_i    : std_logic;
   signal intr2_rdack_i    : std_logic;
   signal intr2_wrack_d1   : std_logic;
   signal intr2_rdack_d1   : std_logic;
   signal xps_bus2ip_be_i  : std_logic_vector(0 to (C_SIPIF_DWIDTH/8) - 1);
   signal word_access      : std_logic;
   signal intr2bus_dbus_i  : std_logic_vector(0 to C_SIPIF_DWIDTH-1);

-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
   X_PLB_SLAVE_IF : entity plbv46_slave_single_v1_01_a.plbv46_slave_single
      generic map (
         C_ARD_ADDR_RANGE_ARRAY => C_ARD_ADDR_RANGE_ARRAY,--[SLV64_ARRAY_TYPE]
         C_ARD_NUM_CE_ARRAY     => C_ARD_NUM_CE_ARRAY,  --[INTEGER_ARRAY_TYPE]
         C_SPLB_P2P             => C_SPLB_P2P,  --[integer range 0 to 1]
         -- Optimize slave interface for a point to point connection

         C_BUS2CORE_CLK_RATIO => C_BUS2CORE_CLK_RATIO, --[integer range 1 to 2]
         -- Specifies the clock ratio from BUS to Core allowing
         -- the core to operate at a slower than the bus clock rate
         -- A value of 1 represents 1:1 and a value of 2 represents
         -- 2:1 where the bus clock is twice as fast as the core 
         -- clock.

         C_SPLB_MID_WIDTH => C_SPLB_MID_WIDTH,  -- [integer range 1 to 4]
         -- The width of the Master ID bus
         -- This is set to log2(C_SPLB_NUM_MASTERS)

         C_SPLB_NUM_MASTERS => C_SPLB_NUM_MASTERS,  -- [integer range 1 to 16]
         -- The number of Master Devices connected to the PLB bus
         -- Research this to find out default value

         C_SPLB_AWIDTH => C_SPLB_AWIDTH,  -- [integer range 32 to 36]
         --  width of the PLB Address Bus (in bits)

         C_SPLB_DWIDTH => C_SPLB_DWIDTH,  -- [integer range 32 to 128]
         --  Width of the PLB Data Bus (in bits)

         C_SIPIF_DWIDTH => C_SIPIF_DWIDTH,  -- [integer range 32 to 128]
         --  Width of IPIF Data Bus (in bits)

         C_FAMILY => C_FAMILY)  -- [string]
      port map (

         -- System signals ----------------------------------------------------

         SPLB_Clk => SPLB_Clk,  -- [in  std_logic]
         SPLB_Rst => SPLB_Rst,  -- [in  std_logic]

         -- Bus Slave signals -------------------------------------------------

         PLB_ABus       => PLB_ABus,    
         PLB_UABus      => PLB_UABus,   
         PLB_PAValid    => PLB_PAValid, 
         PLB_SAValid    => PLB_SAValid, 
         PLB_rdPrim     => PLB_rdPrim,  
         PLB_wrPrim     => PLB_wrPrim,  
         PLB_masterID   => PLB_masterID,
         PLB_abort      => PLB_abort,   
         PLB_busLock    => PLB_busLock, 
         PLB_RNW        => PLB_RNW,     
         PLB_BE         => PLB_BE,  
         PLB_MSize      => PLB_MSize,   
         PLB_size       => PLB_size,    
         PLB_type       => PLB_type,    
         PLB_lockErr    => PLB_lockErr, 
         PLB_wrDBus     => PLB_wrDBus,  
         PLB_wrBurst    => PLB_wrBurst, 
         PLB_rdBurst    => PLB_rdBurst, 
         PLB_wrPendReq  => PLB_wrPendReq,   
         PLB_rdPendReq  => PLB_rdPendReq,   
         PLB_wrPendPri  => PLB_wrPendPri,   
         PLB_rdPendPri  => PLB_rdPendPri,   
         PLB_reqPri     => PLB_reqPri,   
         PLB_TAttribute => PLB_TAttribute, 


         -- Slave Response Signals
         Sl_addrAck     => Sl_addrAck,      
         Sl_SSize       => Sl_SSize, 
         Sl_wait        => Sl_wait,  
         Sl_rearbitrate => Sl_rearbitrate,  
         Sl_wrDAck      => Sl_wrDAck,  
         Sl_wrComp      => Sl_wrComp,  
         Sl_wrBTerm     => Sl_wrBTerm, 
         Sl_rdDBus      => Sl_rdDBus,  
         Sl_rdWdAddr    => Sl_rdWdAddr,
         Sl_rdDAck      => Sl_rdDAck,  
         Sl_rdComp      => Sl_rdComp,  
         Sl_rdBTerm     => Sl_rdBTerm, 
         Sl_MBusy       => Sl_MBusy,  
         Sl_MWrErr      => Sl_MWrErr,  
         Sl_MRdErr      => Sl_MRdErr,  
         Sl_MIRQ        => Sl_MIRQ,  

         -- IP Interconnect (IPIC) port signals 
         Bus2IP_Clk     => xps_Bus2IP_Clk,  
         Bus2IP_Reset   => xps_Bus2IP_Reset,
         IP2Bus_Data    => xps_IP2Bus_Data, 
         IP2Bus_WrAck   => xps_IP2Bus_WrAck,
         IP2Bus_RdAck   => xps_IP2Bus_RdAck,
         IP2Bus_Error   => xps_IP2Bus_Error,
         Bus2IP_Addr    => xps_Bus2IP_Addr, 
         Bus2IP_Data    => xps_Bus2IP_Data, 
         Bus2IP_RNW     => xps_Bus2IP_RNW,  
         Bus2IP_BE      => xps_Bus2IP_BE,  
         Bus2IP_CS      => xps_Bus2IP_CS,  
         Bus2IP_RdCE    => xps_Bus2IP_RdCE, 
         Bus2IP_WrCE    => xps_Bus2IP_WrCE  
         );



-------------------------------------------------------------------------------
-- INTERRUPT DEVICE
-------------------------------------------------------------------------------
   X_INTERRUPT_CONTROL : entity interrupt_control_v2_01_a.interrupt_control
      generic map (
         C_NUM_CE => C_NUM_INTERRUPT_REGS,  -- [integer range 4 to 16]
         -- Number of register chip enables required
         -- For C_IPIF_DWIDTH=32  Set C_NUM_CE = 16
         -- For C_IPIF_DWIDTH=64  Set C_NUM_CE = 8
         -- For C_IPIF_DWIDTH=128 Set C_NUM_CE = 4

         C_NUM_IPIF_IRPT_SRC => 1,  -- [integer range 1 to 29]

         C_IP_INTR_MODE_ARRAY => C_IP_INTR_MODE_ARRAY,  -- [INTEGER_ARRAY_TYPE]
         -- Interrupt Modes
         --1,  -- pass through (non-inverting)
         --2,  -- pass through (inverting)
         --3,  -- registered level (non-inverting)
         --4,  -- registered level (inverting)
         --5,  -- positive edge detect
         --6   -- negative edge detect

         C_INCLUDE_DEV_PENCODER => C_INCLUDE_DEV_PENCODER,  -- [boolean]
         -- Specifies device Priority Encoder function

         C_INCLUDE_DEV_ISC => C_INCLUDE_DEV_ISC,  -- [boolean]
         -- Specifies device ISC hierarchy
         -- Exclusion of Device ISC requires 
         -- exclusion of Priority encoder

         C_IPIF_DWIDTH => C_SIPIF_DWIDTH  -- [integer range 32 to 128]
         )
      port map (

         -- Inputs From the IPIF Bus 
         Bus2IP_Clk     => xps_Bus2IP_Clk,  
         Bus2IP_Reset   => reset2ip_reset,  
         Bus2IP_Data    => xps_Bus2IP_Data, 
         Bus2IP_BE      => xps_bus2ip_be_i,  
         Interrupt_RdCE => xps_Bus2IP_RdCE(INTERRUPT_CE_RNG),  
         Interrupt_WrCE => xps_Bus2IP_WrCE(INTERRUPT_CE_RNG),  

         -- Interrupt inputs from the IPIF sources that will 
         -- get registered in this design
         IPIF_Reg_Interrupts => "00",  

         -- Level Interrupt inputs from the IPIF sources
         IPIF_Lvl_Interrupts => "0",  

         -- Inputs from the IP Interface  
         IP2Bus_IntrEvent => IIC2Bus_IntrEvent,  

         -- Final Device Interrupt Output
         Intr2Bus_DevIntr => IIC2INTC_Irpt,  

         -- Status Reply Outputs to the Bus 
         Intr2Bus_DBus    => intr2bus_dbus_i,  
         Intr2Bus_WrAck   => open,--Intr2Bus_WrAck, 
         Intr2Bus_RdAck   => open,--Intr2Bus_RdAck, 
         Intr2Bus_Error   => Intr2Bus_Error, 
         Intr2Bus_Retry   => open,           
         Intr2Bus_ToutSup => open            
         );

-------------------------------------------------------------------------------
-- Logic to check if partial access is made to Interrupt register.
-- For any partial access, write will not have ant effect on the 
-- register and read will return zeros.
-- All partial access to interrupt registers will generate error.
-------------------------------------------------------------------------------
   xps_bus2ip_be_i <= "1111" when xps_Bus2IP_BE = "1111" else 
                      "0000" ;
   
   Intr2Bus_DBus   <= Intr2Bus_DBus_i when xps_Bus2IP_BE = "1111" else
                      (others => '0');
   
   word_access <= '1' when xps_Bus2IP_BE = "1111" else
                  '0';
   
   intr2_wrack_i <=  or_reduce(xps_Bus2IP_WrCE(INTERRUPT_CE_RNG));
   intr2_rdack_i <=  or_reduce(xps_Bus2IP_RdCE(INTERRUPT_CE_RNG));


-------------------------------------------------------------------------------
-- INTR_ACK_REG Process
-------------------------------------------------------------------------------
   INTR_ACK_REG:process(xps_Bus2IP_Clk) is
   begin
    if (xps_Bus2IP_Clk'event and xps_Bus2IP_Clk = '1') then
       if (reset2ip_reset = '1') then
           intr2_wrack_d1    <= '0';
           Intr2Bus_WrAck    <= '0';
           intr2_rdack_d1    <= '0';
           Intr2Bus_RdAck    <= '0';
       else
           intr2_wrack_d1    <= intr2_wrack_i;
           Intr2Bus_WrAck    <= intr2_wrack_i and (not intr2_wrack_d1);
           intr2_rdack_d1    <= intr2_rdack_i;
           Intr2Bus_RdAck    <= intr2_rdack_i and (not intr2_rdack_d1);
       end if;
     end if;
   end process INTR_ACK_REG;
   
   ---- Generate error for partial register access
   --Intr2Bus_Error <= (Intr2Bus_RdAck or Intr2Bus_WrAck) and (not word_access);
                 

-------------------------------------------------------------------------------
-- SOFT RESET REGISTER
-------------------------------------------------------------------------------
   X_SOFT_RESET : entity proc_common_v3_00_a.soft_reset
      generic map (
         C_SIPIF_DWIDTH => C_SIPIF_DWIDTH,  -- [integer]
         -- Width of the write data bus

         C_RESET_WIDTH => 4)  -- [integer] Value used by OPB IPIF
      port map (

         -- Inputs From the IPIF Bus 
         Bus2IP_Reset      => xps_Bus2IP_Reset,                  
         Bus2IP_Clk        => xps_Bus2IP_Clk,   
         Bus2IP_WrCE       => xps_Bus2IP_WrCE(RESET_CE_RNG'LEFT),  
         Bus2IP_Data       => xps_Bus2IP_Data,  
         Bus2IP_BE         => xps_Bus2IP_BE,  

         -- Final Device Reset Output
         Reset2IP_Reset    => reset2ip_reset,  

         -- Status Reply Outputs to the Bus 
         Reset2Bus_WrAck   => reset2Bus_WrAck,  
         Reset2Bus_Error   => reset2Bus_Error,  
         Reset2Bus_ToutSup => open);            


-------------------------------------------------------------------------------
-- RSTRDACK Process
-------------------------------------------------------------------------------
   RSTRDACK : process (xps_Bus2IP_Clk) is
      -- CE rising edge detector for the reset register's read CE's. There
      -- is no register here to read but a PLB read to this address will
      -- result in a hung bus with out this. Better safe then sorry!
      variable rdce_dly1 : std_logic;
   begin
      if (xps_Bus2IP_Clk'event and xps_Bus2IP_Clk = '1') then
         if (rdce_dly1 = '0' and xps_Bus2IP_RdCE(RESET_CE_RNG'left) = '1') then
            reset2Bus_RdAck <= '1';
         else
            reset2Bus_RdAck <= '0';
         end if;
         rdce_dly1 := xps_Bus2IP_RdCE(RESET_CE_RNG'left);
      end if;
   end process RSTRDACK;


-------------------------------------------------------------------------------
-- IIC Register (External) Connections
-------------------------------------------------------------------------------
   Bus2IIC_Clk <= xps_Bus2IP_Clk;
   --Bus2IIC_Reset <= xps_Bus2IP_Reset ;
   Bus2IIC_Reset <=  reset2ip_reset; --  combined reset from bus and SOFTRST
   Bus2IIC_Addr <= xps_Bus2IP_Addr;
   Bus2IIC_BE   <= xps_Bus2IP_BE;
   Bus2IIC_CS   <= xps_Bus2IP_CS(1);
   Bus2IIC_Data <= xps_Bus2IP_Data;
   Bus2IIC_RNW  <= xps_Bus2IP_RNW;
   Bus2IIC_RdCE <= xps_Bus2IP_RdCE(IIC_CE_RNG);
   Bus2IIC_WrCE <= xps_Bus2IP_WrCE(IIC_CE_RNG);



-------------------------------------------------------------------------------
-- Data Source Multiplexer to input of PLBV46_SLAVE_SINGLE IPIC Interface
-------------------------------------------------------------------------------

   -- These connections mux data/error/acks from the three sources (interrupt,
   -- reset, IIC regs) to the plbv46_slave_single block.

   -- Mutual exclusion applies. The reset2bus_data is don't care (it is a
   -- write-only register). Leaving it from the OR structure implies that the
   -- read back value will be zero. The interrupt controller also drives OUT
   -- zeroes when no register is selected for readback. Same for IIC register
   -- block. 
   xps_IP2Bus_Data <= Intr2Bus_DBus or IIC2Bus_Data;
   xps_IP2Bus_Error <= Intr2Bus_Error
                       or reset2Bus_Error
                       or IIC2Bus_Error;
   xps_IP2Bus_WrAck <= Intr2Bus_WrAck
                       or reset2Bus_WrAck
                       or IIC2Bus_WrAck;
   xps_IP2Bus_RdAck <= Intr2Bus_RdAck
                       or reset2Bus_RdAck
                       or IIC2Bus_RdAck;
   
end architecture imp;

