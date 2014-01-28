-------------------------------------------------------------------------------
-- iic.vhd - entity/architecture pair
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
-- Filename:        iic.vhd
-- Version :        v2.03.a
--
-- Description:
--                  This file contains the top level file for the iic Bus
--                  Interface.
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
-- Author:      KC
-- History:
--  KC            02/05/01      -- First Point Design Release
--
--  KC            06/08/01      -- Made parameterization changes
--
--  KC            08/09/01      -- Updated files incorporate latest IPIF
--
--  KC            08/30/01      -- Updated files to incorporate the latest IPIF
--
--  KC            10/04/01      -- Updated files to incorporate latest IPIF
--                                  version opb_v1_23_a
--
--  KC            10/17/01      -- Added new generic C_HIGHADDR and removed
--                                 C_DEV_ADDR_DECODE_WIDTH to be consistent
--                                 with OPB Arbiter and microblaze
--
--  KC            11/29/01      -- Changed the default value and removed
--                                 C_IP_REG_BASEADDR_OFFSET as a user settable
--                                 generic
--
--  KC            12/19/01      -- rename generic to ABUS and DBUS and both
--                                 bi-directional pins changed names
--                              
--  KC            09/30/03      -- Added GPO to close CR# 160041
--  MP            08/01/04      -- Added RC_FIFO_WR_GEN & TX_FIFO_ER_GEN
--                Updated with ipif 3.01
--  MW            08/01/06      -- Added dynamic_master.vhd module to the design
--  TRD           10/22/07      -- Enhancement to filter SDA/SCL
-- ~~~~~~
--  PVK              12/12/08       v2.01.a
-- ^^^^^^
--     Updated to new version v2.01.a
--     Removed the debounce componant definition from the file and added 
--     library reference.
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

library proc_common_v3_00_a;
use proc_common_v3_00_a.srl_fifo;

-------------------------------------------------------------------------------
-- Definition of Generics:
--
--   C_BASEADDR             -- XPS IIC Base Address
--   C_HIGHADDR             -- XPS IIC High Address
--   C_NUM_IIC_REGS         -- Number of IIC Registers
--   C_CLK_FREQ             -- Specifies SPLB clock frequency
--   C_IIC_FREQ             -- Maximum frequency of Master Mode in Hz
--   C_TEN_BIT_ADR          -- 10 bit slave addressing
--   C_GPO_WIDTH            -- Width of General purpose output vector
--   C_SCL_INERTIAL_DELAY   -- SCL filtering 
--   C_SDA_INERTIAL_DELAY   -- SDA filtering
--   C_TX_FIFO_EXIST        -- IIC transmit FIFO exist
--   C_RC_FIFO_EXIST        -- IIC receive FIFO exist
--   C_SPLB_P2P             -- Specifies point to point connection
--   C_BUS2CORE_CLK_RATIO   -- Specifies the clock ratio from BUS to Core
--   C_SPLB_MID_WIDTH       -- PLB Master ID bus width
--   C_SPLB_NUM_MASTERS     -- Number of PLB masters 
--   C_SPLB_SMALLEST_MASTER -- Width of smallest PLB master
--   C_SPLB_AWIDTH          -- Width of the PLB Least significant address bus
--   C_SPLB_DWIDTH          -- width of the PLB data bus
--   C_SIPIF_DWIDTH         -- Slave bus data width
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
entity iic is
   generic (

      -- System Generics
      C_BASEADDR             : std_logic_vector(0 to 31) := X"FFFFFFFF";  
      C_HIGHADDR             : std_logic_vector(0 to 31) := X"00000000";  
      C_NUM_IIC_REGS         : integer                   := 10;  

      --IIC Generics to be set by user
      C_CLK_FREQ             : integer  := 100000000;  
      C_IIC_FREQ             : integer  := 100000;     
      C_TEN_BIT_ADR          : integer  := 0;
      C_GPO_WIDTH            : integer  := 0;
      C_SCL_INERTIAL_DELAY   : integer  := 0;  
      C_SDA_INERTIAL_DELAY   : integer  := 0;  
      C_TX_FIFO_EXIST        : boolean  := TRUE;
      C_RC_FIFO_EXIST        : boolean  := TRUE;
      C_SPLB_P2P             : integer range 0 to 1    := 0;
      C_BUS2CORE_CLK_RATIO   : integer range 1 to 2    := 1;
      C_SPLB_MID_WIDTH       : integer range 0 to 4    := 3;
      C_SPLB_NUM_MASTERS     : integer range 1 to 16   := 8;
      C_SPLB_SMALLEST_MASTER : integer range 32 to 128 := 128;
      C_SPLB_AWIDTH          : integer range 32 to 32  := 32;
      C_SPLB_DWIDTH          : integer range 32 to 128 := 128;
      C_SIPIF_DWIDTH         : integer range 32 to 128 := 32;
      C_FAMILY               : string   := "virtex5"
      );


   port
      (  
      -- System signals ----------------------------------------------------
      SPLB_Clk       : in  std_logic;
      SPLB_Rst       : in  std_logic;
      IIC2INTC_Irpt  : out std_logic;  -- IP-2-interrupt controller

      -- Bus Slave signals -------------------------------------------------
      PLB_ABus       : in  std_logic_vector(0 to 31);
      PLB_UABus      : in  std_logic_vector(0 to 31);
      PLB_PAValid    : in  std_logic;
      PLB_SAValid    : in  std_logic;
      PLB_rdPrim     : in  std_logic;
      PLB_wrPrim     : in  std_logic;
      PLB_masterID   : in  std_logic_vector(0 to C_SPLB_MID_WIDTH-1);
      PLB_abort      : in  std_logic;
      PLB_busLock    : in  std_logic;
      PLB_RNW        : in  std_logic;
      PLB_BE         : in  std_logic_vector(0 to (C_SPLB_DWIDTH/8)-1);
      PLB_MSize      : in  std_logic_vector(0 to 1);
      PLB_size       : in  std_logic_vector(0 to 3);
      PLB_type       : in  std_logic_vector(0 to 2);
      PLB_lockErr    : in  std_logic;
      PLB_wrDBus     : in  std_logic_vector(0 to C_SPLB_DWIDTH-1);
      PLB_wrBurst    : in  std_logic;
      PLB_rdBurst    : in  std_logic;
      PLB_wrPendReq  : in  std_logic;
      PLB_rdPendReq  : in  std_logic;
      PLB_wrPendPri  : in  std_logic_vector(0 to 1);
      PLB_rdPendPri  : in  std_logic_vector(0 to 1);
      PLB_reqPri     : in  std_logic_vector(0 to 1);
      PLB_TAttribute : in  std_logic_vector(0 to 15);

      -- Slave Response Signals
      Sl_addrAck     : out std_logic;
      Sl_SSize       : out std_logic_vector(0 to 1);
      Sl_wait        : out std_logic;
      Sl_rearbitrate : out std_logic;
      Sl_wrDAck      : out std_logic;
      Sl_wrComp      : out std_logic;
      Sl_wrBTerm     : out std_logic;
      Sl_rdDBus      : out std_logic_vector(0 to C_SPLB_DWIDTH-1);
      Sl_rdWdAddr    : out std_logic_vector(0 to 3);
      Sl_rdDAck      : out std_logic;
      Sl_rdComp      : out std_logic;
      Sl_rdBTerm     : out std_logic;
      Sl_MBusy       : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
      Sl_MWrErr      : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
      Sl_MRdErr      : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);
      Sl_MIRQ        : out std_logic_vector(0 to C_SPLB_NUM_MASTERS-1);

      -- IIC Bus Signals
      Sda_I          : in  std_logic;
      Sda_O          : out std_logic;
      Sda_T          : out std_logic;
      Scl_I          : in  std_logic;
      Scl_O          : out std_logic;
      Scl_T          : out std_logic;
      Gpo            : out std_logic_vector(32 - C_GPO_WIDTH to 
                                               C_SIPIF_DWIDTH - 1)
      );


end entity iic;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture imp of iic is

   signal Msms_rst       : std_logic;
   signal Msms_set       : std_logic;
   signal Rsta_rst       : std_logic;
   signal Dtc            : std_logic;
   signal Rdy_new_xmt    : std_logic;
   signal New_rcv_dta    : std_logic;
   signal Ro_prev        : std_logic;
   signal Dtre           : std_logic;
   signal Bb             : std_logic;
   signal Aas            : std_logic;
   signal Al             : std_logic;
   signal Srw            : std_logic;
   signal Txer           : std_logic;
   signal Tx_under_prev  : std_logic;
   signal Abgc           : std_logic;
   signal Data_i2c       : std_logic_vector(0 to 7);
   signal Adr            : std_logic_vector(0 to 7);
   signal Ten_adr        : std_logic_vector(5 to 7);
   signal Cr             : std_logic_vector(0 to 7);
   signal Drr            : std_logic_vector(0 to 7);
   signal Dtr            : std_logic_vector(0 to 7);
   signal Tx_fifo_data   : std_logic_vector(0 to 7);
   signal Tx_data_exists : std_logic;
   signal Tx_fifo_wr     : std_logic;
   signal Tx_fifo_wr_i   : std_logic;
   signal Tx_fifo_wr_d   : std_logic;
   signal Tx_fifo_rd     : std_logic;
   signal Tx_fifo_rd_i   : std_logic;
   signal Tx_fifo_rd_d   : std_logic;
   signal Tx_fifo_rst    : std_logic;
   signal Tx_fifo_full   : std_logic;
   signal Tx_addr        : std_logic_vector(0 to TX_FIFO_BITS - 1);
   signal Rc_fifo_data   : std_logic_vector(0 to 7);
   signal Rc_fifo_wr     : std_logic;
   signal Rc_fifo_wr_i   : std_logic;
   signal Rc_fifo_wr_d   : std_logic;
   signal Rc_fifo_rd     : std_logic;
   signal Rc_fifo_rd_i   : std_logic;
   signal Rc_fifo_rd_d   : std_logic;
   signal Rc_fifo_full   : std_logic;
   signal Rc_Data_Exists : std_logic;
   signal Rc_addr        : std_logic_vector(0 to RC_FIFO_BITS -1);
   signal Bus2IIC_Clk    : std_logic;
   signal Bus2IIC_Reset  : std_logic;
   signal IIC2Bus_Data   : std_logic_vector(0 to C_SIPIF_DWIDTH - 1) := 
                           (others => '0');
   signal IIC2Bus_WrAck  : std_logic                := '0';
   signal IIC2Bus_RdAck  : std_logic                := '0';
   signal IIC2Bus_Error     : std_logic := '0';
   signal IIC2Bus_IntrEvent : std_logic_vector(0 to 7) := (others => '0');
   signal Bus2IIC_Addr   : std_logic_vector(0 to IPIF_ABUS_WIDTH - 1);
   signal Bus2IIC_BE     : std_logic_vector(0 to C_SIPIF_DWIDTH / 8 - 1);
   signal Bus2IIC_CS     : std_logic;
   signal Bus2IIC_Data   : std_logic_vector(0 to C_SIPIF_DWIDTH - 1);
   signal Bus2IIC_RNW    : std_logic;
   signal Bus2IIC_RdCE   : std_logic_vector(0 to C_NUM_IIC_REGS - 1);
   signal Bus2IIC_WrCE   : std_logic_vector(0 to C_NUM_IIC_REGS - 1);

   -- signals for dynamic start/stop
   signal ctrlFifoDin         : std_logic_vector(0 to 1);
   signal dynamic_MSMS        : std_logic_vector(0 to 1);
   signal dynRstaSet          : std_logic;
   signal dynMsmsSet          : std_logic;
   signal txak                : std_logic;
   signal earlyAckDataState   : std_logic;
   signal ackDataState        : std_logic;
   signal earlyAckHdr         : std_logic;
   signal cr_txModeSelect_set : std_logic;
   signal cr_txModeSelect_clr : std_logic;
   signal txFifoRd            : std_logic;
   signal Msms_rst_r          : std_logic;
   signal ctrl_fifo_wr_i      : std_logic;

   -- Cleaned up inputs
   signal scl_clean : std_logic;
   signal sda_clean : std_logic;

begin

   ----------------------------------------------------------------------------
   -- xps_ipif_ssp1 instantiation
   ----------------------------------------------------------------------------
   X_XPS_IPIF_SSP1 : entity xps_iic_v2_03_a.xps_ipif_ssp1
      generic map (
         C_BASEADDR     => C_BASEADDR,  
         C_HIGHADDR     => C_HIGHADDR,  
         C_NUM_IIC_REGS => C_NUM_IIC_REGS,

         C_SPLB_P2P     => C_SPLB_P2P,  
         -- Optimize slave interface for a point to point connection

         C_BUS2CORE_CLK_RATIO => C_BUS2CORE_CLK_RATIO,  
         -- Specifies the clock ratio from BUS to Core allowing
         -- the core to operate at a slower than the bus clock rate
         -- A value of 1 represents 1:1 and a value of 2 represents
         -- 2:1 where the bus clock is twice as fast as the core 
         -- clock.


         C_SPLB_MID_WIDTH => C_SPLB_MID_WIDTH,
         -- The width of the Master ID bus
         -- This is set to log2(C_SPLB_NUM_MASTERS)

         C_SPLB_NUM_MASTERS => C_SPLB_NUM_MASTERS, 
         -- The number of Master Devices connected to the PLB bus
         -- Research this to find out default value

         C_SPLB_AWIDTH => C_SPLB_AWIDTH, 
         --  width of the PLB Address Bus (in bits)

         C_SPLB_DWIDTH => C_SPLB_DWIDTH, 
         --  Width of the PLB Data Bus (in bits)

         C_SIPIF_DWIDTH => C_SIPIF_DWIDTH,
         --  Width of IPIF Data Bus (in bits) Must be 32!

         C_FAMILY => C_FAMILY)        
      port map (

         -- System signals ----------------------------------------------------
         SPLB_Clk            => SPLB_Clk,    
         SPLB_Rst            => SPLB_Rst,    
         IIC2Bus_IntrEvent   => IIC2Bus_IntrEvent,  -- IIC Interrupt events
         IIC2INTC_Irpt       => IIC2INTC_Irpt,  --  IP-2-interrupt controller

         -- Bus Slave signals -------------------------------------------------
         PLB_ABus            => PLB_ABus,    
         PLB_UABus           => PLB_UABus,   
         PLB_PAValid         => PLB_PAValid, 
         PLB_SAValid         => PLB_SAValid, 
         PLB_rdPrim          => PLB_rdPrim,  
         PLB_wrPrim          => PLB_wrPrim,  
         PLB_masterID        => PLB_masterID,
         PLB_abort           => PLB_abort,   
         PLB_busLock         => PLB_busLock, 
         PLB_RNW             => PLB_RNW,     
         PLB_BE              => PLB_BE,  
         PLB_MSize           => PLB_MSize,   
         PLB_size            => PLB_size,    
         PLB_type            => PLB_type,    
         PLB_lockErr         => PLB_lockErr, 
         PLB_wrDBus          => PLB_wrDBus,  
         PLB_wrBurst         => PLB_wrBurst, 
         PLB_rdBurst         => PLB_rdBurst, 
         PLB_wrPendReq       => PLB_wrPendReq,   
         PLB_rdPendReq       => PLB_rdPendReq,   
         PLB_wrPendPri       => PLB_wrPendPri,   
         PLB_rdPendPri       => PLB_rdPendPri,   
         PLB_reqPri          => PLB_reqPri,  
         PLB_TAttribute      => PLB_TAttribute,  

         -- Slave Response Signals
         Sl_addrAck          => Sl_addrAck,      
         Sl_SSize            => Sl_SSize,  
         Sl_wait             => Sl_wait,  
         Sl_rearbitrate      => Sl_rearbitrate,  
         Sl_wrDAck           => Sl_wrDAck,  
         Sl_wrComp           => Sl_wrComp,  
         Sl_wrBTerm          => Sl_wrBTerm,      
         Sl_rdDBus           => Sl_rdDBus,  
         Sl_rdWdAddr         => Sl_rdWdAddr,     
         Sl_rdDAck           => Sl_rdDAck,  
         Sl_rdComp           => Sl_rdComp,  
         Sl_rdBTerm          => Sl_rdBTerm,      
         Sl_MBusy            => Sl_MBusy,  
         Sl_MWrErr           => Sl_MWrErr,  
         Sl_MRdErr           => Sl_MRdErr,  
         Sl_MIRQ             => Sl_MIRQ,  

         -- IP Interconnect (IPIC) port signals used by the IIC registers. ----
         Bus2IIC_Clk         => Bus2IIC_Clk,   
         Bus2IIC_Reset       => Bus2IIC_Reset,  
         Bus2IIC_Addr        => Bus2IIC_Addr,  
         Bus2IIC_BE          => Bus2IIC_BE,  
         Bus2IIC_CS          => Bus2IIC_CS,  
         Bus2IIC_Data        => Bus2IIC_Data,  
         Bus2IIC_RNW         => Bus2IIC_RNW,   
         Bus2IIC_RdCE        => Bus2IIC_RdCE,  
         Bus2IIC_WrCE        => Bus2IIC_WrCE,
         IIC2Bus_Data        => IIC2Bus_Data,  
         IIC2Bus_WrAck       => IIC2Bus_WrAck, 
         IIC2Bus_RdAck       => IIC2Bus_RdAck, 
         IIC2Bus_Error       => IIC2Bus_Error 
         ); 


   ----------------------------------------------------------------------------
   -- reg_interface instantiation
   ----------------------------------------------------------------------------
   REG_INTERFACE_I : entity xps_iic_v2_03_a.reg_interface
      generic map (
         C_TX_FIFO_EXIST     => C_TX_FIFO_EXIST ,
         C_TX_FIFO_BITS      => 4               ,
         C_RC_FIFO_EXIST     => C_RC_FIFO_EXIST ,
         C_RC_FIFO_BITS      => 4               ,
         C_TEN_BIT_ADR       => C_TEN_BIT_ADR   ,
         C_GPO_WIDTH         => C_GPO_WIDTH     ,
         C_SIPIF_DWIDTH      => C_SIPIF_DWIDTH  ,
         C_NUM_IIC_REGS      => C_NUM_IIC_REGS
         )
      port map (
         Clk                 => Bus2IIC_Clk,
         Rst                 => Bus2IIC_Reset,
         Bus2IIC_Data        => Bus2IIC_Data(0 to C_SIPIF_DWIDTH - 1),
         Bus2IIC_RdCE        => Bus2IIC_RdCE,
         Bus2IIC_WrCE        => Bus2IIC_WrCE,
         IIC2Bus_Data        => IIC2Bus_Data(0 to C_SIPIF_DWIDTH - 1),
         IIC2Bus_RdAck       => IIC2Bus_RdAck,
         IIC2Bus_WrAck       => IIC2Bus_WrAck,
         IIC2Bus_IntrEvent   => IIC2Bus_IntrEvent,
         Gpo                 => Gpo,
         Cr                  => Cr,
         Dtr                 => Dtr,
         Drr                 => Drr,
         Adr                 => Adr,
         Ten_adr             => Ten_adr,
         Msms_set            => Msms_set,
         Msms_rst            => Msms_rst,
         DynMsmsSet          => dynMsmsSet,
         DynRstaSet          => dynRstaSet,
         Cr_txModeSelect_set => cr_txModeSelect_set,
         Cr_txModeSelect_clr => cr_txModeSelect_clr,
         Rsta_rst            => Rsta_rst,
         Rdy_new_xmt         => Rdy_new_xmt,
         New_rcv_dta         => New_rcv_dta,
         Ro_prev             => Ro_prev,
         Dtre                => Dtre,
         Aas                 => Aas,
         Bb                  => Bb,
         Srw                 => Srw,
         Al                  => Al,
         Txer                => Txer,
         Tx_under_prev       => Tx_under_prev,
         Abgc                => Abgc,
         Data_i2c            => Data_i2c,
         Tx_fifo_data        => Tx_fifo_data(0 to 7),
         Tx_data_exists      => Tx_data_exists,
         Tx_fifo_wr          => Tx_fifo_wr,
         Tx_fifo_rd          => Tx_fifo_rd,
         Tx_fifo_full        => Tx_fifo_full,
         Tx_fifo_rst         => Tx_fifo_rst,
         Tx_addr             => Tx_addr(0 to TX_FIFO_BITS - 1),
         Rc_fifo_data        => Rc_fifo_data(0 to 7),
         Rc_fifo_wr          => Rc_fifo_wr,
         Rc_fifo_rd          => Rc_fifo_rd,
         Rc_fifo_full        => Rc_fifo_full,
         Rc_Data_Exists      => Rc_Data_Exists,
         Rc_addr             => Rc_addr(0 to RC_FIFO_BITS - 1)
         );



   ----------------------------------------------------------------------------
   -- The V5 inputs are so fast that they typically create glitches longer then
   -- the clock period due to the extremely slow rise/fall times on SDA/SCL
   -- signals. The inertial delay filter removes these.
   ----------------------------------------------------------------------------
   FILTER_I: entity xps_iic_v2_03_a.filter
      generic map (
         SCL_INERTIAL_DELAY  => C_SCL_INERTIAL_DELAY, -- [range 0 to 255]
         SDA_INERTIAL_DELAY  => C_SDA_INERTIAL_DELAY  -- [range 0 to 255]
         )
      port map (
         Sysclk         => Bus2IIC_Clk,  
         Rst            => Bus2IIC_Reset,
         Scl_noisy      => Scl_I,   
         Scl_clean      => scl_clean,   
         Sda_noisy      => Sda_I,   
         Sda_clean      => sda_clean); 


   ----------------------------------------------------------------------------
   -- iic_control instantiation
   ----------------------------------------------------------------------------
   IIC_CONTROL_I : entity xps_iic_v2_03_a.iic_control
      generic map (
         C_CLK_FREQ        => C_CLK_FREQ,
         C_IIC_FREQ        => C_IIC_FREQ,
         C_TEN_BIT_ADR     => C_TEN_BIT_ADR
         )

      port map (
         Sys_clk           => Bus2IIC_Clk,
         Reset             => Cr(7),
         Sda_I             => sda_clean,
         Sda_O             => Sda_O,
         Sda_T             => Sda_T,
         Scl_I             => scl_clean,
         Scl_O             => Scl_O,
         Scl_T             => Scl_T,
         Txak              => txak,
         Msms              => Cr(5),
         Msms_set          => Msms_set,
         Msms_rst          => Msms_rst_r,
         Rsta              => Cr(2),
         Rsta_rst          => Rsta_rst,
         Tx                => Cr(4),
         Gc_en             => Cr(1),
         Dtr               => Dtr,
         Adr               => Adr,
         Ten_adr           => Ten_adr,
         Bb                => Bb,
         Dtc               => Dtc,
         Aas               => Aas,
         Al                => Al,
         Srw               => Srw,
         Txer              => Txer,
         Tx_under_prev     => Tx_under_prev,
         Abgc              => Abgc,
         Data_i2c          => Data_i2c,
         New_rcv_dta       => New_rcv_dta,
         Ro_prev           => Ro_prev,
         Dtre              => Dtre,
         Rdy_new_xmt       => Rdy_new_xmt,
         EarlyAckHdr       => earlyAckHdr,
         EarlyAckDataState => earlyAckDataState,
         AckDataState      => ackDataState
         );


   ----------------------------------------------------------------------------
   -- Transmitter FIFO instantiation
   ----------------------------------------------------------------------------
   WRITE_FIFO_I : entity proc_common_v3_00_a.srl_fifo
      generic map (
         C_DATA_BITS    => DATA_BITS,
         C_DEPTH        => TX_FIFO_BITS
         )
      port map (
         Clk            => Bus2IIC_Clk,
         Reset          => Tx_fifo_rst,
         FIFO_Write     => Tx_fifo_wr_i,
         Data_In        => Bus2IIC_Data(24 to 31),
         FIFO_Read      => txFifoRd,
         Data_Out       => Tx_fifo_data(0 to 7),
         FIFO_Full      => Tx_fifo_full,
         Data_Exists    => Tx_data_exists,
         Addr           => Tx_addr(0 to TX_FIFO_BITS - 1)
         );

   ----------------------------------------------------------------------------
   -- Receiver FIFO instantiation
   ----------------------------------------------------------------------------
   READ_FIFO_I : entity proc_common_v3_00_a.srl_fifo
      generic map (
         C_DATA_BITS    => DATA_BITS,
         C_DEPTH        => RC_FIFO_BITS
         )              
      port map (        
         Clk            => Bus2IIC_Clk,
         Reset          => Bus2IIC_Reset,
         FIFO_Write     => Rc_fifo_wr_i,
         Data_In        => Data_i2c(0 to 7),
         FIFO_Read      => Rc_fifo_rd_i,
         Data_Out       => Rc_fifo_data(0 to 7),
         FIFO_Full      => Rc_fifo_full,
         Data_Exists    => Rc_Data_Exists,
         Addr           => Rc_addr(0 to RC_FIFO_BITS - 1)
         );

   ----------------------------------------------------------------------------
   -- PROCESS: TX_FIFO_WR_GEN
   -- purpose: generate TX FIFO write control signals
   ----------------------------------------------------------------------------
   TX_FIFO_WR_GEN : process(Bus2IIC_Clk)
   begin
      if(Bus2IIC_Clk'event and Bus2IIC_CLK = '1') then
         if(Bus2IIC_Reset = '1') then
            Tx_fifo_wr_d <= '0';
            Tx_fifo_rd_d <= '0';
         else
            Tx_fifo_wr_d <= Tx_fifo_wr;
            Tx_fifo_rd_d <= Tx_fifo_rd;
         end if;
      end if;
   end process TX_FIFO_WR_GEN;

   ----------------------------------------------------------------------------
   -- PROCESS: RC_FIFO_WR_GEN
   -- purpose: generate TX FIFO write control signals
   ----------------------------------------------------------------------------
   RC_FIFO_WR_GEN : process(Bus2IIC_Clk)
   begin
      if(Bus2IIC_Clk'event and Bus2IIC_Clk = '1') then
         if(Bus2IIC_Reset = '1') then
            Rc_fifo_wr_d <= '0';
            Rc_fifo_rd_d <= '0';
         else
            Rc_fifo_wr_d <= Rc_fifo_wr;
            Rc_fifo_rd_d <= Rc_fifo_rd;
         end if;
      end if;
   end process RC_FIFO_WR_GEN;

   Tx_fifo_wr_i <= Tx_fifo_wr and (not Tx_fifo_wr_d);
   Rc_fifo_wr_i <= Rc_fifo_wr and (not Rc_fifo_wr_d);

   Tx_fifo_rd_i <= Tx_fifo_rd and (not Tx_fifo_rd_d);
   Rc_fifo_rd_i <= Rc_fifo_rd and (not Rc_fifo_rd_d);


   ----------------------------------------------------------------------------
   -- Dynamic master interface
   -- Dynamic master start/stop and control logic
   ----------------------------------------------------------------------------
   DYN_MASTER_I : entity xps_iic_v2_03_a.dynamic_master
      port map (
         Clk                 => Bus2IIC_Clk ,   
         Rst                 => Tx_fifo_rst ,   
         dynamic_MSMS        => dynamic_MSMS ,  
         Cr                  => Cr ,            
         Tx_fifo_rd_i        => Tx_fifo_rd_i ,  
         Tx_data_exists      => Tx_data_exists ,
         ackDataState        => ackDataState ,  
         Tx_fifo_data        => Tx_fifo_data ,  
         earlyAckHdr         => earlyAckHdr ,   
         earlyAckDataState   => earlyAckDataState ,
         Bb                  => Bb ,            
         Msms_rst_r          => Msms_rst_r ,    
         dynMsmsSet          => dynMsmsSet ,    
         dynRstaSet          => dynRstaSet ,    
         Msms_rst            => Msms_rst ,      
         txFifoRd            => txFifoRd ,      
         txak                => txak ,          
         cr_txModeSelect_set => cr_txModeSelect_set, 
         cr_txModeSelect_clr => cr_txModeSelect_clr  
         );


   -- virtual reset. Since srl fifo address is rst at the same time, only the
   -- first entry in the srl fifo needs to have a value of '00' to appear 
   -- reset. Also, force data to 0 if a byte write is done to the txFifo.
   ctrlFifoDin <= Bus2IIC_Data(22 to 23) when (Tx_fifo_rst = '0' and 
                                               Bus2IIC_Reset = '0' and 
                                               Bus2IIC_Addr(31) = '0') else
                  "00";


   -- continuously write srl fifo while reset active
   ctrl_fifo_wr_i <= Tx_fifo_rst or Bus2IIC_Reset or Tx_fifo_wr_i;


   ----------------------------------------------------------------------------
   -- Control FIFO instantiation
   -- fifo used to set/reset MSMS bit in control register to create automatic 
   -- START/STOP conditions
   ----------------------------------------------------------------------------
   WRITE_FIFO_CTRL_I : entity proc_common_v3_00_a.srl_fifo
      generic map (
         C_DATA_BITS => 2,
         C_DEPTH     => TX_FIFO_BITS
         )
      port map (
         Clk         => Bus2IIC_Clk,
         Reset       => Tx_fifo_rst,
         FIFO_Write  => ctrl_fifo_wr_i,
         Data_In     => ctrlFifoDin,
         FIFO_Read   => txFifoRd,
         Data_Out    => dynamic_MSMS,
         FIFO_Full   => open,
         Data_Exists => open,
         Addr        => open
         );

end architecture imp;


