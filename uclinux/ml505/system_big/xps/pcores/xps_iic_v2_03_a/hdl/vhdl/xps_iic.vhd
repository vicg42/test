-------------------------------------------------------------------------------
-- xps_iic.vhd - entity/architecture pair
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
-- Filename:        xps_iic.vhd
-- Version:         v2.03.a                        
--
-- Description:     
--                  This file is the top level file that contains the iic xps 
--                  Bus Interface.
-------------------------------------------------------------------------------
-- Structure:
--
--           xps_iic.vhd
--              -- iic.vhd
--                  -- xps_ipif_ssp1.vhd
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
-- Author:      JAC
-- History:
--  JAC          10/07/01   -- Created
--
--  KC           10/08/01   --removed FIFO generics and Byte Enable generic
--
--  KC and JAC   10/17/01   --removed entity statement and added new generics
--
--  KC           11/29/01   --removed C_IP_REG_BASEADDR_OFFSET as a user
--                            settable generic
--
--  KC           12/03/01   -- assigned attribute S to all unused signals
--
--  KC           12/11/01   -- removed attribute S
--
--  KC           12/19/01   -- rename generic to ABUS and DBUS and both
--                               bi-directional pins changed names
--
--     DET     7/26/2002     ET inclusion
-- ~~~~~~
--      Added the Evaluation Timer to the top level. Also added the proc_common
--      Library call out.
-- ^^^^^^
--
--  KC     10/02/02   -- removed unsed IPIF ports per CR#157529
--
--  KC     09/30/03   -- Added GPO to close CR# 160041
--
--  KC     11/24/03   -- Rearranged the port declaration as a work 
--                       around for a psfutil issue
--
--  KC     03/04/04   -- updated xlpp comments to version opb_iic_v1_01_b
--
--  kc     05/01/04   -- Changed minimum C_GPO_WIDTH and major version for
--                       licensing attrubute, intead of true
--
--  kc     05/04/04   -- Rolled to version C because C_GPO_WIDTH default
--                       changed to 1 from 0
--  Prabhakar 07/13/04  updated with opb_ipif_v3_01_a. 
--
--  kc     06/02/10   -- New version with dynamic start and stop bits
--                       changed initial generic values to match the spec
--  TRD    10/22/07   -- New version with enhancements for SCL/SDA filtering
--
--  PVK              12/12/08       v2.01.a
-- ^^^^^^
--     Updated to new version v2.01.a
--     Removed the debounce componant definition from the file and added 
--     library reference. Fixed following CRs on the core.
--     1) CR:480811(300ns data hold time violation from SCL to SDA). As per the
--        Philips specification, the SDA hold time in master mode is 0 ns. This
--        is an enhancement in the core to have 300ns hold time on SDA by 
--        adding required delay on C_SCL_INERTIAL_DELAY.
--     2) CR:469153 (Data setup time violation) 
--     3) CR:468897 (Remove asynchronous reset from the core) 
--     4) CR:444069 (Repeated start setup time violation) 
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

library xps_iic_v2_03_a;
use xps_iic_v2_03_a.iic_pkg.all;

-------------------------------------------------------------------------------
-- Definition of Generics:
--   C_IIC_FREQ             -- Maximum frequency of Master Mode in Hz
--   C_TEN_BIT_ADR          -- 10 bit slave addressing
--   C_GPO_WIDTH            -- Width of General purpose output vector
--   C_CLK_FREQ             -- Specifies SPLB clock frequency
--   C_SCL_INERTIAL_DELAY   -- SCL filtering 
--   C_SDA_INERTIAL_DELAY   -- SDA filtering
--   C_BASEADDR             -- XPS IIC Base Address
--   C_HIGHADDR             -- XPS IIC High Address
--   C_SPLB_MID_WIDTH       -- PLB Master ID bus width
--   C_SPLB_NUM_MASTERS     -- Number of PLB masters 
--   C_SPLB_AWIDTH          -- Width of the PLB Least significant address bus
--   C_SPLB_DWIDTH          -- width of the PLB data bus
--   C_SPLB_NATIVE_DWIDTH   -- Slave bus data width
--   C_SPLB_SUPPORT_BURSTS  -- Burst/no burst support
--   C_FAMILY               -- XILINX FPGA family
-------------------------------------------------------------------------------
-- Definition of ports:
--
--   System Signals
--      SPLB_Clk            -- System clock
--      SPLB_Rst            -- System Reset (active high)
--      IP2INTC_Irpt        -- System interrupt output  
--
--   PLB Slave Signals 
--      PLB_ABus            -- PLB address bus          
--      PLB_UABus           -- PLB upper address bus
--      PLB_PAValid         -- PLB primary address valid
--      PLB_SAValid         -- PLB secondary address valid
--      PLB_rdPrim          -- PLB secondary to primary read request
--      PLB_wrPrim          -- PLB secondary to primary write request
--      PLB_masterID        -- PLB current master identifier
--      PLB_abort           -- PLB abort request
--      PLB_busLock         -- PLB bus lock
--      PLB_RNW             -- PLB read not write
--      PLB_BE              -- PLB byte enable
--      PLB_MSize           -- PLB data bus width indicator
--      PLB_size            -- PLB transfer size
--      PLB_type            -- PLB transfer type
--      PLB_lockErr         -- PLB lock error
--      PLB_wrDBus          -- PLB write data bus
--      PLB_wrBurst         -- PLB burst write transfer
--      PLB_rdBurst         -- PLB burst read transfer
--      PLB_wrPendReq       -- PLB pending bus write request
--      PLB_rdPendReq       -- PLB pending bus read request
--      PLB_wrPendPri       -- PLB pending bus write request priority
--      PLB_rdPendPri       -- PLB pending bus read request priority
--      PLB_reqPri          -- PLB current request 
--      PLB_TAttribute      -- PLB transfer attribute
--   Slave Responce Signal
--      Sl_addrAck          -- Salve address ack
--      Sl_SSize            -- Slave data bus size
--      Sl_wait             -- Salve wait indicator
--      Sl_rearbitrate      -- Salve rearbitrate
--      Sl_wrDAck           -- Slave write data ack
--      Sl_wrComp           -- Salve write complete
--      Sl_wrBTerm          -- Salve terminate write burst transfer
--      Sl_rdDBus           -- Slave read data bus
--      Sl_rdWdAddr         -- Slave read word address
--      Sl_rdDAck           -- Salve read data ack
--      Sl_rdComp           -- Slave read complete
--      Sl_rdBTerm          -- Salve terminate read burst transfer
--      Sl_MBusy            -- Slave busy
--      Sl_MWrErr           -- Slave write error
--      Sl_MRdErr           -- Slave read error
--      Sl_MIRQ             -- Master interrput 
--   IIC Signals
--      Sda_I               -- IIC serial data input
--      Sda_O               -- IIC serial data output
--      Sda_T               -- IIC seral data output enable
--      Scl_I               -- IIC serial clock input
--      Scl_O               -- IIC serial clock output
--      Scl_T               -- IIC serial clock output enable
--      Gpo                 -- General purpose outputs
--
-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------
entity xps_iic is

   generic (

      -- FPGA Family Type specification
      C_FAMILY              : string := "virtex5";
      -- Select the target architecture type
      
      -- PLBv46 Slave Attachment generics
      
      C_BASEADDR            : std_logic_vector(0 to 31) := X"FFFFFFFF";  
      C_HIGHADDR            : std_logic_vector(0 to 31) := X"00000000";  

      -- PLBV46 I/O specification generics
      C_SPLB_MID_WIDTH      : integer range 0 to 4 := 1;
      -- The width of the Master ID bus
      -- This is set to log2(C_SPLB_NUM_MASTERS)

      C_SPLB_NUM_MASTERS    : integer range 1 to 16 := 1;
      -- The number of Master Devices connected to the PLB bus
      -- Research this to find out default value

      C_SPLB_AWIDTH         : integer range 32 to 32 := 32;
      --  width of the PLB Address Bus (in bits)

      C_SPLB_DWIDTH         : integer range 32 to 128 := 32;
      --  Width of the PLB Data Bus (in bits)
      
      -- XPS IIC Feature generics
      C_IIC_FREQ            : integer    := 100E3;
      C_TEN_BIT_ADR         : integer    := 0;
      C_GPO_WIDTH           : integer    := 1;
      C_CLK_FREQ            : integer    := 25E6;
      C_SCL_INERTIAL_DELAY  : integer    := 0;  -- delay in nanoseconds
      C_SDA_INERTIAL_DELAY  : integer    := 0  -- delay in nanoseconds

      );

   port (

      -- System signals 
      SPLB_Clk         : in  std_logic;
      SPLB_Rst         : in  std_logic;
      IIC2INTC_Irpt    : out std_logic;  -- IP-2-interrupt controller

      -- Bus Slave signals 
      PLB_ABus         : in  std_logic_vector(0 to 31);
      PLB_UABus        : in  std_logic_vector(0 to 31);
      PLB_PAValid      : in  std_logic;
      PLB_SAValid      : in  std_logic;
      PLB_rdPrim       : in  std_logic;
      PLB_wrPrim       : in  std_logic;
      PLB_masterID     : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
      PLB_abort        : in  std_logic;
      PLB_busLock      : in  std_logic;
      PLB_RNW          : in  std_logic;
      PLB_BE           : in  std_logic_vector(0 to (C_SPLB_DWIDTH/8)-1);
      PLB_MSize        : in  std_logic_vector(0 to 1);
      PLB_size         : in  std_logic_vector(0 to 3);
      PLB_type         : in  std_logic_vector(0 to 2);
      PLB_lockErr      : in  std_logic;
      PLB_wrDBus       : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);
      PLB_wrBurst      : in  std_logic;
      PLB_rdBurst      : in  std_logic;
      PLB_wrPendReq    : in  std_logic;
      PLB_rdPendReq    : in  std_logic;
      PLB_wrPendPri    : in  std_logic_vector(0 to 1);
      PLB_rdPendPri    : in  std_logic_vector(0 to 1);
      PLB_reqPri       : in  std_logic_vector(0 to 1);
      PLB_TAttribute   : in  std_logic_vector(0 to 15);

      -- Slave Response Signals
      Sl_addrAck       : out std_logic;
      Sl_SSize         : out std_logic_vector(0 to 1);
      Sl_wait          : out std_logic;
      Sl_rearbitrate   : out std_logic;
      Sl_wrDAck        : out std_logic;
      Sl_wrComp        : out std_logic;
      Sl_wrBTerm       : out std_logic;
      Sl_rdDBus        : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
      Sl_rdWdAddr      : out std_logic_vector(0 to 3);
      Sl_rdDAck        : out std_logic;
      Sl_rdComp        : out std_logic;
      Sl_rdBTerm       : out std_logic;
      Sl_MBusy         : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
      Sl_MWrErr        : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
      Sl_MRdErr        : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
      Sl_MIRQ          : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);

      -- IIC interface signals 
      Sda_I            : in  std_logic;
      Sda_O            : out std_logic;
      Sda_T            : out std_logic;
      Scl_I            : in  std_logic;
      Scl_O            : out std_logic;
      Scl_T            : out std_logic;
      Gpo              : out std_logic_vector(32 - C_GPO_WIDTH to 32 - 1 )


      );

   attribute ADDR_TYPE   : string; 
   attribute ASSIGNMENT  : string;
   attribute HDL         : string; 
   attribute IMP_NETLIST : string; 
   attribute IP_GROUP    : string; 
   attribute IPTYPE      : string; 
   attribute SIGIS       : string; 
   attribute SIM_MODELS  : string; 
   attribute STYLE       : string; 

   attribute ADDR_TYPE   of  C_BASEADDR    :  constant is  "REGISTER"; 
   attribute ADDR_TYPE   of  C_HIGHADDR    :  constant is  "REGISTER"; 
   attribute ASSIGNMENT  of  C_BASEADDR    :  constant is  "REQUIRE"; 
   attribute ASSIGNMENT  of  C_HIGHADDR    :  constant is  "REQUIRE"; 
   attribute HDL         of  xps_iic       :  entity   is  "VHDL"; 
   attribute IMP_NETLIST of  xps_iic       :  entity   is  "TRUE"; 
   attribute IP_GROUP    of  xps_iic       :  entity   is  "LOGICORE"; 
   attribute IPTYPE      of  xps_iic       :  entity   is  "PERIPHERAL"; 
   attribute SIGIS       of  SPLB_Clk      :  signal   is  "CLK"; 
   attribute SIGIS       of  SPLB_Rst      :  signal   is  "RST"; 
   attribute SIGIS       of  IIC2INTC_Irpt :  signal   is  "INTR_LEVEL_HIGH";
   attribute SIM_MODELS  of  xps_iic       :  entity   is  "BEHAVIORAL"; 
   attribute STYLE       of  xps_iic       :  entity   is  "HDL"; 


end entity xps_iic;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture imp of xps_iic is
   
   constant C_NUM_IIC_REGS       : integer := num_ip_reg(C_GPO_WIDTH);   
   constant C_BUS2CORE_CLK_RATIO : integer := 1;  -- 1:1 plb to user clk ratio

   -- The native widith of the core is fixed at 32-bits.
   -- DO not CHANGE. 64|128 are not supported.
   -- The MPD file specifies this as a non-hdl type parameter to the EDK tools.
   -- The "SPLB_NATIVE_DWIDTH" nomenclature superceded the use of
   -- "SIPIF_DWIDTH".
   constant C_SPLB_NATIVE_DWIDTH : integer := 32;

   -- Optimize slave interface for a point to point connection
   constant C_SPLB_P2P           : integer range 0 to 1 := 0;

begin 
   
   X_IIC: entity xps_iic_v2_03_a.iic
      generic map (

         -- System Generics
         C_BASEADDR      => C_BASEADDR,  -- User logic base address
         C_HIGHADDR      => C_HIGHADDR,  --  User logic high address
         C_NUM_IIC_REGS  => C_NUM_IIC_REGS, -- Number of IIC Registers

         --iic Generics to be set by user
         C_CLK_FREQ    => C_CLK_FREQ,  --  default OPB2IPClk 100MHz
         C_IIC_FREQ    => C_IIC_FREQ,  --  default iic Serial 100KHz
         C_TEN_BIT_ADR => C_TEN_BIT_ADR,  -- [integer]
         C_GPO_WIDTH   => C_GPO_WIDTH,    -- [integer]
         C_SCL_INERTIAL_DELAY => C_SCL_INERTIAL_DELAY, -- delay in nanoseconds
         C_SDA_INERTIAL_DELAY => C_SDA_INERTIAL_DELAY,  -- delay in nanoseconds

         -- Transmit FIFO Generic
         -- Removed as user input 10/08/01
         -- Software will not be tested without FIFO's
         C_TX_FIFO_EXIST => TRUE,  -- [boolean]

         -- Recieve FIFO Generic
         -- Removed as user input 10/08/01
         -- Software will not be tested without FIFO's
         C_RC_FIFO_EXIST => TRUE,  -- [boolean]


         -- PLBV46 interface generics

         C_SPLB_P2P => C_SPLB_P2P,  
         -- Optimize slave interface for a point to point connection

         C_BUS2CORE_CLK_RATIO => C_BUS2CORE_CLK_RATIO,  
         -- Specifies the clock ratio from BUS to Core allowing
         -- the core to operate at a slower than the bus clock rate
         -- A value of 1 represents 1:1 and a value of 2 represents
         -- 2:1 where the bus clock is twice as fast as the core 
         -- clock.

         C_SPLB_MID_WIDTH => C_SPLB_MID_WIDTH,  -- [integer range 0 to 4]
         -- The width of the Master ID bus
         -- This is set to log2(C_SPLB_NUM_MASTERS)

         C_SPLB_NUM_MASTERS => C_SPLB_NUM_MASTERS,  -- [integer range 1 to 16]
         -- The number of Master Devices connected to the PLB bus
         -- Research this to find out default value

         C_SPLB_AWIDTH => C_SPLB_AWIDTH,  -- [integer range 32 to 32]
         --  width of the PLB Address Bus (in bits)

         C_SPLB_DWIDTH => C_SPLB_DWIDTH,  -- [integer range 32 to 128]
         --  Width of the PLB Data Bus (in bits)

         C_SIPIF_DWIDTH => C_SPLB_NATIVE_DWIDTH,  -- [integer range 32 to 128]
         --  Width of IPIF Data Bus (in bits) Must be 32!

         C_FAMILY => C_FAMILY  -- [string]
      )
      port map (

         -- System signals --------------
         SPLB_Clk       => SPLB_Clk,    
         SPLB_Rst       => SPLB_Rst,    
         IIC2INTC_Irpt  => IIC2INTC_Irpt,

         -- Bus Slave signals -----------
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

         -- Slave Response Signals ------
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

         -- IIC Bus Signals -------------
         Sda_I          => Sda_I,   
         Sda_O          => Sda_O,   
         Sda_T          => Sda_T,   
         Scl_I          => Scl_I,   
         Scl_O          => Scl_O,   
         Scl_T          => Scl_T,   
         Gpo            => Gpo  
         );
end architecture imp;
