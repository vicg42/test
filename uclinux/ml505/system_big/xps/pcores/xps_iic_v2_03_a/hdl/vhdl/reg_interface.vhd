-------------------------------------------------------------------------------
-- reg_interface.vhd - entity/architecture pair
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
-- Filename:        reg_interface.vhd
-- version          v2.03.a
-- Description:
--                  This file contains the interface between the IPIF
--                  and the iic controller.  All registers are generated
--                  here and all interrupts are processed here.
--
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
--  KC             09/30/03     -- Added GPO to close CR# 160041
-- ~~~~~~~
--  Prabhakar M    07/09/04    
-- ^^^^^^^
-- updated with ipif 3.01
-- ~~~~~~~
--  TRD           12/22/2006 
-- ^^^^^^^
--  Updates to PLBV46 (XPS) bus interface
-- ~~~~~~~
--  PVK              12/12/08       v2.01.a
-- ^^^^^^
--     Updated to new version v2.01.a
-- ~~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "Clk", "clk_div#", "clk_#x"
--      reset signals:                          "Rst", "rst_n"
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
--
library ieee;
use ieee.std_logic_1164.all;

library xps_iic_v2_03_a;
use xps_iic_v2_03_a.iic_pkg.all;

library unisim;
use unisim.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.or_muxcy;


-------------------------------------------------------------------------------
-- Port Declaration
-------------------------------------------------------------------------------
-- Definition of Generics:
--      C_TX_FIFO_EXIST     -- IIC transmit FIFO exist       
--      C_TX_FIFO_BITS      -- Transmit FIFO bit size 
--      C_RC_FIFO_EXIST     -- IIC receive FIFO exist       
--      C_RC_FIFO_BITS      -- Receive FIFO bit size
--      C_TEN_BIT_ADR       -- 10 bit slave addressing       
--      C_GPO_WIDTH         -- Width of General purpose output vector 
--      C_SIPIF_DWIDTH      -- Slave bus data width      
--      C_NUM_IIC_REGS      -- Number of IIC Registers 
--
-- Definition of Ports:
--      Clk                   -- System clock
--      Rst                   -- System reset
--      Bus2IIC_Data          -- Bus to IIC data bus
--      Bus2IIC_WrCE          -- Bus to IIC write chip enable
--      Bus2IIC_RdCE          -- Bus to IIC read chip enable
--      IIC2Bus_Data          -- IIC to Bus data bus
--      IIC2Bus_RdAck         -- IIC to Bus write transfer acknowledge
--      IIC2Bus_WrAck         -- IIC to Bus read transfer acknowledge
--      IIC2Bus_IntrEvent     -- IIC Interrupt events
--      Gpo                   -- General purpose outputs
--      Cr                    -- Control register
--      Msms_rst              -- MSMS reset signal
--      Rsta_rst              -- Repeated start reset
--      Msms_set              -- MSMS set 
--      DynMsmsSet            -- Dynamic MSMS set signal
--      DynRstaSet            -- Dynamic repeated start set signal
--      Cr_txModeSelect_set   -- Sets transmit mode select
--      Cr_txModeSelect_clr   -- Clears transmit mode select
--      Aas                   -- Addressed as slave indicator
--      Bb                    -- Bus busy indicator
--      Srw                   -- Slave read/write indicator
--      Abgc                  -- Addressed by general call indicator
--      Dtr                   -- Data transmit register
--      Rdy_new_xmt           -- New data loaded in shift reg indicator
--      Dtre                  -- Data transmit register empty
--      Drr                   -- Data receive register
--      Data_i2c              -- IIC data for processor
--      New_rcv_dta           -- New Receive Data ready
--      Ro_prev               -- Receive over run prevent
--      Adr                   -- IIC slave address
--      Ten_adr               -- IIC slave 10 bit address
--      Al                    -- Arbitration lost indicator
--      Txer                  -- Received acknowledge indicator
--      Tx_under_prev         -- DTR or Tx FIFO empty IRQ indicator
--      Tx_fifo_data          -- FIFO data to transmit
--      Tx_data_exists        -- next FIFO data exists
--      Tx_fifo_wr            -- Decode to enable writes to FIFO
--      Tx_fifo_rd            -- Decode to enable read from FIFO
--      Tx_fifo_rst           -- Reset Tx FIFO on IP Reset or CR(6)
--      Tx_fifo_Full          -- Transmit FIFO full indicator
--      Tx_addr               -- Transmit FIFO address
--      Rc_fifo_data          -- Read Fifo data for PLB
--      Rc_fifo_wr            -- Write IIC data to fifo
--      Rc_fifo_rd            -- PLB read from fifo
--      Rc_fifo_Full          -- Read Fifo is full prevent rcv overrun
--      Rc_data_Exists        -- Next FIFO data exists
--      Rc_addr               -- Receive FIFO address
-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------
entity reg_interface is
   generic(
      C_TX_FIFO_EXIST   : boolean := TRUE;
      C_TX_FIFO_BITS    : integer := 4;
      C_RC_FIFO_EXIST   : boolean := TRUE;
      C_RC_FIFO_BITS    : integer := 4;
      C_TEN_BIT_ADR     : integer := 0;
      C_GPO_WIDTH       : integer := 0;
      C_SIPIF_DWIDTH    : integer := 32;
      C_NUM_IIC_REGS    : integer
      );
   port(
      -- IPIF Interface Signals
      Clk               : in std_logic;
      Rst               : in std_logic;
      Bus2IIC_Data      : in std_logic_vector (0 to C_SIPIF_DWIDTH - 1);
      Bus2IIC_WrCE      : in std_logic_vector (0 to C_NUM_IIC_REGS - 1);
      Bus2IIC_RdCE      : in std_logic_vector (0 to C_NUM_IIC_REGS - 1);
      IIC2Bus_Data      : out std_logic_vector (0 to C_SIPIF_DWIDTH - 1);
      IIC2Bus_RdAck     : out std_logic;
      IIC2Bus_WrAck     : out std_logic;
      IIC2Bus_IntrEvent : out std_logic_vector (0 to 7);

      -- Internal iic Bus Registers
      -- GPO Register  Offset 124h
      Gpo               : out std_logic_vector(32 - C_GPO_WIDTH to
                                            C_SIPIF_DWIDTH - 1);
      -- Control Register  Offset 100h
      Cr                : out std_logic_vector(0 to 7);
      Msms_rst          : in  std_logic;  
      Rsta_rst          : in  std_logic;  
      Msms_set          : out std_logic;  

      DynMsmsSet          : in std_logic;  
      DynRstaSet          : in std_logic;  
      Cr_txModeSelect_set : in std_logic;  
      Cr_txModeSelect_clr : in std_logic;  

      -- Status Register  Offest 04h
      Aas                 : in std_logic;    
      Bb                  : in std_logic;    
      Srw                 : in std_logic;    
      Abgc                : in std_logic;    

      -- Data Transmit Register Offset 108h
      Dtr                 : out std_logic_vector(0 to 7);
      Rdy_new_xmt         : in  std_logic;
      Dtre                : out std_logic;

      -- Data Receive Register  Offset 10Ch
      Drr                 : out std_logic_vector(0 to 7);
      Data_i2c            : in  std_logic_vector(0 to 7);
      New_rcv_dta         : in  std_logic;  
      Ro_prev             : out std_logic;  

      -- Address Register Offset 10h
      Adr                 : out std_logic_vector(0 to 7);
        
      -- Ten Bit Address Register Offset 1Ch
      Ten_adr             : out std_logic_vector(5 to 7) := (others => '0');
      Al                  : in std_logic;  
      Txer                : in std_logic;  
      Tx_under_prev       : in std_logic;  

      --  FIFO input (fifo write) and output (fifo read)
      Tx_fifo_data        : in  std_logic_vector(0 to 7);  
      Tx_data_exists      : in  std_logic;  
      Tx_fifo_wr          : out std_logic;  
      Tx_fifo_rd          : out std_logic;  
      Tx_fifo_rst         : out std_logic;  
      Tx_fifo_Full        : in  std_logic;
      Tx_addr             : in  std_logic_vector(0 to C_TX_FIFO_BITS - 1);
      Rc_fifo_data        : in  std_logic_vector(0 to 7);  
      Rc_fifo_wr          : out std_logic;  
      Rc_fifo_rd          : out std_logic;  
      Rc_fifo_Full        : in  std_logic;  
      Rc_data_Exists      : in  std_logic;
      Rc_addr             : in  std_logic_vector(0 to C_RC_FIFO_BITS - 1)

      );

end reg_interface;


-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture imp of reg_interface is

   component LUT4
      generic(
         INIT : bit_vector := X"0000"
         );
      port (
         O  : out std_logic;
         I0 : in  std_logic := '0';
         I1 : in  std_logic := '0';
         I2 : in  std_logic := '0';
         I3 : in  std_logic := '0');
   end component;

   component MUXCY is
      port (
         O  : out std_logic;
         CI : in  std_logic;
         DI : in  std_logic;
         S  : in  std_logic
         );
   end component MUXCY;

   ----------------------------------------------------------------------------
   --  Constant Declarations
   ----------------------------------------------------------------------------
   constant CRR_BITS_USED : std_logic_vector(24 to 31) := b"01111111";
   constant SRR_BITS_USED : std_logic_vector(24 to 31) := b"11111111";
   constant TXF_BITS_USED : std_logic_vector(24 to 31) := b"11111111";
   constant RCF_BITS_USED : std_logic_vector(24 to 31) := b"11111111";
   constant SLV_BITS_USED : std_logic_vector(24 to 31) := b"11111110";
   constant TFO_BITS_USED : std_logic_vector(24 to 31) := b"00001111";
   constant RFO_BITS_USED : std_logic_vector(24 to 31) := b"00001111";

   -- Function call from iic_pkg.vhd
   constant TEN_BITS_USED : std_logic_vector(24 to 31)  
                                          := ten_bit_addr_used(C_TEN_BIT_ADR);

   constant PIR_BITS_USED : std_logic_vector(24 to 31) := b"00001111";

   -- Function call from iic_pkg.vhd
   constant GPO_BITS_USED : std_logic_vector(24 to 31)  
                                                 := gpo_bit_used(C_GPO_WIDTH);

   constant REG_BITS_USED : STD_LOGIC_VECTOR_ARRAY := (CRR_BITS_USED,
                                                       SRR_BITS_USED,
                                                       TXF_BITS_USED,
                                                       RCF_BITS_USED,
                                                       SLV_BITS_USED,
                                                       TFO_BITS_USED,
                                                       RFO_BITS_USED,
                                                       TEN_BITS_USED,
                                                       PIR_BITS_USED,
                                                       GPO_BITS_USED);

   constant J : INTEGER_ARRAY := count_reg_bits_used(REG_BITS_USED);

   ----------------------------------------------------------------------------
   -- Signal and Type Declarations
   ----------------------------------------------------------------------------

   signal cr_i           : std_logic_vector(0 to 7);  -- intrnl control reg
   signal sr_i           : std_logic_vector(0 to 7);  -- intrnl statuss reg
   signal dtr_i          : std_logic_vector(0 to 7);  -- intrnl dta trnsmt reg
   signal drr_i          : std_logic_vector(0 to 7);  -- intrnl dta receive reg
   signal adr_i          : std_logic_vector(0 to 7);  -- intrnl slave addr reg
   signal rc_fifo_pirq_i : std_logic_vector(4 to 7);  -- intrnl slave addr reg
   signal ten_adr_i      : std_logic_vector(5 to 7) := (others => '0');  
                                                      -- intrnl slave addr reg
   signal IIC2Bus_WrAck_i : std_logic;  -- internal Write Acknowledge
   signal wrce_or_in     : std_logic_vector(0 to C_NUM_IIC_REGS-4);
   signal wrce_or        : std_logic;
   signal IIC2Bus_RdAck_i : std_logic;  -- internal Read Acknowledge
   signal rdce_or        : std_logic;  -- Or of all the read CE's
   signal ro_a           : std_logic;  -- receive overrun SRFF
   signal ro_i           : std_logic;  -- receive overrun SRFF
   signal dtre_i         : std_logic;  -- data tranmit register empty register
   signal new_rcv_dta_d1 : std_logic;  -- delay new_rcv_dta to find rising edge
   signal msms_d1        : std_logic;  -- delay msms cr(5)
   signal ro_prev_i      : std_logic;  -- internal Ro_prev
   signal msms_set_i     : std_logic;  -- SRFF set on falling edge of msms
   signal rtx_i          : std_logic_vector(0 to 7);
   signal rrc_i          : std_logic_vector(0 to 7);
   signal rtn_i          : std_logic_vector(0 to 7);
   signal rpq_i          : std_logic_vector(0 to 7);
   signal gpo_i          : std_logic_vector(32 - C_GPO_WIDTH to 31); -- GPO

   signal rback_data : std_logic_vector(0 to 32 * C_NUM_IIC_REGS - 1)
                                                           := (others => '0');
begin

   ----------------------------------------------------------------------------
   -- CONTROL_REGISTER_PROCESS
   ----------------------------------------------------------------------------
   -- This process loads data from the PLB when there is a write request and 
   -- the control register is enabled.
   ----------------------------------------------------------------------------
   CONTROL_REGISTER_PROCESS : process (Clk)
   begin  -- process
      if (Clk'event and Clk = '1') then
         if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
            cr_i <= (others => '0');
         elsif                --  Load Control Register with PLB
            --  data if there is a write request
            --  and the control register is enabled
            Bus2IIC_WrCE(0) = '1' then
            cr_i(0 to 7) <= Bus2IIC_Data(24 to 31);
         else                 -- Load Control Register with iic data
            cr_i(0) <= cr_i(0);
            cr_i(1) <= cr_i(1);
            cr_i(2) <= (cr_i(2) or DynRstaSet) and not(Rsta_rst);
            cr_i(3) <= cr_i(3);
            cr_i(4) <= (cr_i(4) or Cr_txModeSelect_set) and 
                                not(Cr_txModeSelect_clr);
            cr_i(5) <= (cr_i(5) or DynMsmsSet) and not (Msms_rst);
            cr_i(6) <= cr_i(6);
            cr_i(7) <= cr_i(7);
         end if;
      end if;
   end process CONTROL_REGISTER_PROCESS;
   Cr <= cr_i;

   ----------------------------------------------------------------------------
   -- Delay msms by one clock to find falling edge
   ----------------------------------------------------------------------------
   MSMS_DELAY_PROCESS : process (Clk)
   begin  -- process
      if (Clk'event and Clk = '1') then
         if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
            msms_d1 <= '0';
         else
            msms_d1 <= cr_i(5);
         end if;
      end if;
   end process MSMS_DELAY_PROCESS;

   ----------------------------------------------------------------------------
   -- Set when a fall edge of msms has occurred and Ro_prev is active
   -- This will prevent a throttle condition when a master receiver and
   -- trying to initiate a stop condition.
   ----------------------------------------------------------------------------
   MSMS_EDGE_SET_PROCESS : process (Clk)
   begin  -- process
      if (Clk'event and Clk = '1') then
         if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
            msms_set_i <= '0';
         elsif ro_prev_i = '1' and cr_i(5) = '0' and msms_d1 = '1' then
            msms_set_i <= '1';
         elsif (cr_i(5) = '1' and msms_d1 = '0') or Bb = '0' then
            msms_set_i <= '0';
         else
            msms_set_i <= msms_set_i;
         end if;
      end if;
   end process MSMS_EDGE_SET_PROCESS;

   Msms_set <= msms_set_i;


   ----------------------------------------------------------------------------
   -- STATUS_REGISTER_PROCESS
   ----------------------------------------------------------------------------
   -- This process resets the status register. The status register is read only
   ----------------------------------------------------------------------------
   STATUS_REGISTER_PROCESS : process (Clk)
   begin  -- process
      if (Clk'event and Clk = '1') then
         if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
            sr_i <= (others => '0');
         else                         -- Load Status Register with iic data
            sr_i(0) <= not Tx_data_exists;
            sr_i(1) <= not Rc_data_Exists;
            sr_i(2) <= Rc_fifo_Full;
            sr_i(3) <= Tx_fifo_Full;  -- addressed by a general call
            sr_i(4) <= Srw;           -- slave read/write
            sr_i(5) <= Bb;            -- bus busy
            sr_i(6) <= Aas;           -- addressed as slave
            sr_i(7) <= Abgc;          -- addressed by a general call
         end if;
      end if;
   end process STATUS_REGISTER_PROCESS;


   ----------------------------------------------------------------------------
   -- Transmit FIFO CONTROL signal GENERATION
   ----------------------------------------------------------------------------
   -- This process allows the PLB to write data to the  write FIFO and assigns
   -- that data to the output port and to the internal signals for reading
   ----------------------------------------------------------------------------
   FIFO_GEN_DTR : if C_TX_FIFO_EXIST generate
      
      -------------------------------------------------------------------------
      -- FIFO_WR_CNTL_PROCESS  - Tx fifo write process
      -------------------------------------------------------------------------
      FIFO_WR_CNTL_PROCESS : process (Clk)
      begin
         if (Clk'event and Clk = '1') then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               Tx_fifo_wr <= '0';
            elsif
               Bus2IIC_WrCE(2) = '1' then
               Tx_fifo_wr <= '1';
            else
               Tx_fifo_wr <= '0';
            end if;
         end if;
      end process FIFO_WR_CNTL_PROCESS;

      -------------------------------------------------------------------------
      -- FIFO_DTR_REG_PROCESS
      -------------------------------------------------------------------------
      FIFO_DTR_REG_PROCESS : process (Tx_fifo_data)
      begin  -- process
         Dtr   <= Tx_fifo_data;
         dtr_i <= Tx_fifo_data;
      end process FIFO_DTR_REG_PROCESS;

      -------------------------------------------------------------------------
      -- Tx_FIFO_RD_PROCESS
      -------------------------------------------------------------------------
      -- This process generates the Read from the Transmit FIFO
      -------------------------------------------------------------------------
      Tx_FIFO_RD_PROCESS : process (Clk)
      begin
         if (Clk'event and Clk = '1') then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               Tx_fifo_rd <= '0';
            elsif Rdy_new_xmt = '1' then
               Tx_fifo_rd <= '1';
            elsif Rdy_new_xmt = '0'  --and Tx_data_exists = '1'
            then Tx_fifo_rd <= '0';
            end if;
         end if;
      end process Tx_FIFO_RD_PROCESS;

      -------------------------------------------------------------------------
      -- DTRE_PROCESS
      -------------------------------------------------------------------------
      -- This process generates the Data Transmit Register Empty Interrupt
      -- Interrupt(2)
      -------------------------------------------------------------------------
      DTRE_PROCESS : process (Clk)
      begin
         if (Clk'event and Clk = '1') then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               dtre_i <= '0';
            else
               dtre_i <= not (Tx_data_exists);
            end if;
         end if;
      end process DTRE_PROCESS;

      -------------------------------------------------------------------------
      -- Additional FIFO Interrupt
      -------------------------------------------------------------------------
      -- FIFO_Int_PROCESS generates interrupts back to the IPIF when Tx FIFO 
      -- exists
      -------------------------------------------------------------------------
      FIFO_INT_PROCESS : process (Clk)
      begin
         if (Clk'event and Clk = '1') then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               IIC2Bus_IntrEvent(7) <= '0';
            else
               IIC2Bus_IntrEvent(7) <= not Tx_addr(3);  -- Tx FIFO half empty
            end if;
         end if;
      end process FIFO_INT_PROCESS;


      -------------------------------------------------------------------------
      -- Tx_FIFO_RESET_PROCESS
      -------------------------------------------------------------------------
      -- This process generates the Data Transmit Register Empty Interrupt
      -- Interrupt(2)
      -------------------------------------------------------------------------
      TX_FIFO_RESET_PROCESS : process (Clk)
      begin
         if (Clk'event and Clk = '1') then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               Tx_fifo_rst <= '1';
            else
               Tx_fifo_rst <= cr_i(6);
            end if;
         end if;
      end process TX_FIFO_RESET_PROCESS;


   end generate FIFO_GEN_DTR;
   ----------------------------------------------------------------------------




   Dtre <= dtre_i;


   ----------------------------------------------------------------------------
   -- If a read FIFO exists then generate control signals
   ----------------------------------------------------------------------------
   RD_FIFO_CNTRL : if (C_RC_FIFO_EXIST) generate
      
      -------------------------------------------------------------------------
      -- WRITE_TO_READ_FIFO_PROCESS
      -------------------------------------------------------------------------
      WRITE_TO_READ_FIFO_PROCESS : process (Clk)
      begin
         if (Clk'event and Clk = '1') then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               Rc_fifo_wr <= '0';
            -- Load iic Data When new data x-fer complete and not x-mitting
            elsif  
               New_rcv_dta = '1' and new_rcv_dta_d1 = '0' then
               Rc_fifo_wr <= '1';
            else
               Rc_fifo_wr <= '0';
            end if;
         end if;
      end process WRITE_TO_READ_FIFO_PROCESS;

      -------------------------------------------------------------------------
      -- Assign the Receive FIFO data to the DRR so PLB can read the data
      -------------------------------------------------------------------------
      PLB_READ_FROM_READ_FIFO_PROCESS : process (Clk)
      begin  -- process
         if (Clk'event and Clk = '1') then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               Rc_fifo_rd <= '0';
            elsif Bus2IIC_RdCE(3) = '1' then
               Rc_fifo_rd <= '1';
            else
               Rc_fifo_rd <= '0';
            end if;
         end if;
      end process PLB_READ_FROM_READ_FIFO_PROCESS;

      -------------------------------------------------------------------------
      -- Assign the Receive FIFO data to the DRR so PLB can read the data
      -------------------------------------------------------------------------
      RD_FIFO_DRR_PROCESS : process (Rc_fifo_data)
      begin
         Drr   <= Rc_fifo_data;
         drr_i <= Rc_fifo_data;
      end process RD_FIFO_DRR_PROCESS;


      -------------------------------------------------------------------------
      -- Rc_FIFO_PIRQ
      -------------------------------------------------------------------------
      -- This process loads data from the PLB when there is a write request and
      -- the Rc_FIFO_PIRQ register is enabled.
      -------------------------------------------------------------------------
      Rc_FIFO_PIRQ_PROCESS : process (Clk)
      begin  -- process
         if (Clk'event and Clk = '1') then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               rc_fifo_pirq_i <= (others => '0');
            elsif             --  Load Status Register with PLB
               --  data if there is a write request
               --  and the status register is enabled
               Bus2IIC_WrCE(8) = '1' then
               rc_fifo_pirq_i(4 to 7) <= Bus2IIC_Data(28 to 31);
            else
               rc_fifo_pirq_i(4 to 7) <= rc_fifo_pirq_i(4 to 7);
            end if;
         end if;
      end process Rc_FIFO_PIRQ_PROCESS;


      -------------------------------------------------------------------------
      -- RC_FIFO_FULL_PROCESS
      -------------------------------------------------------------------------
      -- This process throttles the bus when receiving and the RC_FIFO_PIRQ is 
      -- equalto the Receive FIFO Occupancy value
      -------------------------------------------------------------------------
      RC_FIFO_FULL_PROCESS : process (Clk)
      begin  -- process
         if (Clk'event and Clk = '1') then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               ro_prev_i <= '0';

            elsif msms_set_i = '1' then
               ro_prev_i <= '0';

            elsif (rc_fifo_pirq_i(4) = Rc_addr(3) and
                   rc_fifo_pirq_i(5) = Rc_addr(2) and
                   rc_fifo_pirq_i(6) = Rc_addr(1) and
                   rc_fifo_pirq_i(7) = Rc_addr(0)) and
               Rc_data_Exists = '1'
            then
               ro_prev_i <= '1';
            else
               ro_prev_i <= '0';
            end if;
         end if;
      end process RC_FIFO_FULL_PROCESS;

      Ro_prev <= ro_prev_i;

   end generate RD_FIFO_CNTRL;

   ----------------------------------------------------------------------------
   -- RCV_OVRUN_PROCESS
   ----------------------------------------------------------------------------
   -- This process determines when the data receive register has had new data
   -- written to it without a read of the old data
   ----------------------------------------------------------------------------
   NEW_RECIEVE_DATA_PROCESS : process (Clk)  -- delay new_rcv_dta to find edge
   begin
      if (Clk'event and Clk = '1') then
         if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
            new_rcv_dta_d1 <= '0';
         else
            new_rcv_dta_d1 <= New_rcv_dta;
         end if;
      end if;
   end process NEW_RECIEVE_DATA_PROCESS;

   ----------------------------------------------------------------------------
   -- RCV_OVRUN_PROCESS
   ----------------------------------------------------------------------------
   RCV_OVRUN_PROCESS : process (Clk)
   begin  
      -- SRFF set when new data is received, reset when a read of DRR occurs
      -- The second SRFF is set when new data is again received before a
      -- read of DRR occurs.  This sets the Receive Overrun Status Bit
      if (Clk'event and Clk = '1') then
         if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
            ro_a <= '0';
         elsif New_rcv_dta = '1' and new_rcv_dta_d1 = '0' then
            ro_a <= '1';
         elsif New_rcv_dta = '0' and Bus2IIC_RdCE(3) = '1'
         then ro_a <= '0';
         else
            ro_a <= ro_a;
         end if;
      end if;
   end process RCV_OVRUN_PROCESS;

   ----------------------------------------------------------------------------
   -- ADDRESS_REGISTER_PROCESS
   ----------------------------------------------------------------------------
   -- This process loads data from the PLB when there is a write request and 
   -- the address register is enabled.
   ----------------------------------------------------------------------------
   ADDRESS_REGISTER_PROCESS : process (Clk)
   begin  -- process
      if (Clk'event and Clk = '1') then
         if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
            adr_i <= (others => '0');
         elsif                --  Load Status Register with PLB
            --  data if there is a write request
            --  and the status register is enabled
            --   Bus2IIC_WrReq = '1' and Bus2IIC_WrCE(4) = '1' then
            Bus2IIC_WrCE(4) = '1' then
            adr_i(0 to 7) <= Bus2IIC_Data(24 to 31);
         else
            adr_i <= adr_i;
         end if;
      end if;
   end process ADDRESS_REGISTER_PROCESS;

   Adr <= adr_i;

   ----------------------------------------------------------------------------
   -- This process asserts the WrAck when there is a write request and
   -- any write-able register used in this design is enabled.
   ----------------------------------------------------------------------------
   WRACK_OR_I : entity proc_common_v3_00_a.or_muxcy
      generic map (
         C_NUM_BITS => C_NUM_IIC_REGS
         )
      port map (
         In_bus => Bus2IIC_WrCE ,
         Or_out => wrce_or
         );

   ----------------------------------------------------------------------------
   -- WRACK_PROCESS
   ----------------------------------------------------------------------------
   WRACK_PROCESS : process (Clk)
   begin
      if (Clk'event and Clk = '1') then
         if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
            IIC2Bus_WrAck_i <= '0';
         elsif                -- Allows Wr_Ack to be active for one clock
            IIC2Bus_WrAck_i = '0' and wrce_or = '1' then
            IIC2Bus_WrAck_i <= '1';
         else
            IIC2Bus_WrAck_i <= '0';
         end if;
      end if;
   end process WRACK_PROCESS;
   
   IIC2Bus_WrAck <= IIC2Bus_WrAck_i;

   ----------------------------------------------------------------------------
   -- PER_BIT_GEN generate 
   ----------------------------------------------------------------------------
   PER_BIT_GEN : for i in 24 to C_SIPIF_DWIDTH-1 generate

      signal rback_chain   : std_logic_vector(0 to (C_NUM_IIC_REGS + 1)/2);
      signal rback_out     : std_logic_vector(0 to (C_NUM_IIC_REGS + 1)/2);
      signal pre_sort_data : std_logic_vector(0 to C_NUM_IIC_REGS - 1)
                                                           := (others => '0');
      signal pre_sort_ce : std_logic_vector(0 to C_NUM_IIC_REGS - 1)
                                                           := (others => '0');

   begin

      -------------------------------------------------------------------------
      -- PRE_SORT_LOOP process
      -------------------------------------------------------------------------
      -- This process multiplexes data to the IP2PLB_Data bus when there is a
      -- read request and a register is enabled.
      -------------------------------------------------------------------------
      PRE_SORT_LOOP : process (rback_data, Bus2IIC_RdCE) is
--            type COUNT_BITS is array (24 to 31) of integer;
         variable count : INTEGER_ARRAY := (0, 0, 0, 0, 0, 0, 0, 0);
      begin
         count(i) := 0;
         for m in 0 to C_NUM_IIC_REGS-1 loop
            if (REG_BITS_USED(m)(i) = '1') then
               pre_sort_data(count(i)) <= rback_data(m*32 + i);
               pre_sort_ce(count(i))   <= Bus2IIC_RdCE(m);
               count(i)                := count(i) + 1;  
                              -- keep track of how many valid
                              --reg bits in this read bit
            end if;
         end loop;
      end process PRE_SORT_LOOP;

      -------------------------------------------------------------------------
      -- RBACK_GEN generate 
      -------------------------------------------------------------------------
      RBACK_GEN : for k in 0 to ((J(i) + 1)/2) - 1 generate
         constant nopad : boolean := (k /= (J(i) + 1)/2-1) or
                                     (J(i) MOD 2 = 0);
      begin
         NO_PAD_GENERATE : if nopad generate
            NO_PAD_LUT4_I : LUT4
               generic map(
                  INIT => X"0777"
                  -- INIT => RBACK_INIT(k)
                  )
               port map (
                  O  => rback_out(k) ,          -- [out]
                  I0 => pre_sort_data(k*2) ,    -- [in]
                  I1 => pre_sort_ce(k*2) ,      -- [in]
                  I2 => pre_sort_data(k*2+1) ,  -- [in]
                  I3 => pre_sort_ce(k*2+1));    -- [in]

            NO_PAD_MUXCY_I : MUXCY
               port map (
                  O  => rback_chain(k+1),  --[out]
                  CI => rback_chain(k) ,   --[in]
                  DI => '1' ,              --[in]
                  S  => rback_out(k));     --[in]
         end generate NO_PAD_GENERATE;

         ----------------------------------------------------------------------
         -- RBACK_GEN generate 
         ----------------------------------------------------------------------
         PAD_GENERATE : if not nopad generate
            PAD_LUT4_I : LUT4
               generic map(
                  INIT => X"0777"
                  -- INIT => RBACK_INIT(k)
                  )
               port map (
                  O  => rback_out(k) ,        -- [out]
                  I0 => pre_sort_data(k*2) ,  -- [in]
                  I1 => pre_sort_ce(k*2) ,    -- [in]
                  I2 => '0' ,                 -- [in]
                  I3 => '0');                 -- [in]

            PAD_MUXCY_I : MUXCY
               port map (
                  O  => rback_chain(k+1),  --[out]
                  CI => rback_chain(k) ,   --[in]
                  DI => '1' ,              --[in]
                  S  => rback_out(k));     --[in]
         end generate PAD_GENERATE;

         IIC2Bus_Data(i) <= rback_chain(((J(i) + 1)/2));
      end generate RBACK_GEN;
      rback_chain(0) <= '0';
   end generate PER_BIT_GEN;

   ----------------------------------------------------------------------------
   -- READ_REGISTER_PROCESS
   ----------------------------------------------------------------------------
   rback_data(32*1-8 to 32*1-1) <= cr_i(0 to 7);
   rback_data(32*2-8 to 32*2-1) <= sr_i(0 to 7);
   rback_data(32*3-8 to 32*3-1) <= dtr_i(0 to 7);
   rback_data(32*4-8 to 32*4-1) <= drr_i(0 to 7);
   rback_data(32*5-8 to 32*5-1) <= adr_i(0 to 7);
   rback_data(32*6-8 to 32*6-1) <= rtx_i(0 to 7);
   rback_data(32*7-8 to 32*7-1) <= rrc_i(0 to 7);
   rback_data(32*8-8 to 32*8-1) <= rtn_i(0 to 7);
   rback_data(32*9-8 to 32*9-1) <= rpq_i(0 to 7);

   ----------------------------------------------------------------------------
   -- GPO_RBACK_GEN generate 
   ----------------------------------------------------------------------------
   GPO_RBACK_GEN : if C_GPO_WIDTH /= 0 generate
      rback_data(32*10-C_GPO_WIDTH to 32*10-1)
                             <= gpo_i(32 - C_GPO_WIDTH to C_SIPIF_DWIDTH - 1);

      wrce_or_in(6) <= Bus2IIC_WrCE(C_NUM_IIC_REGS - 1);
   end generate GPO_RBACK_GEN;

   rtx_i(0 to 3) <= (others => '0');
   rtx_i(4)      <= Tx_addr(3);
   rtx_i(5)      <= Tx_addr(2);
   rtx_i(6)      <= Tx_addr(1);
   rtx_i(7)      <= Tx_addr(0);

   rrc_i(0 to 3) <= (others => '0');
   rrc_i(4)      <= Rc_addr(3);
   rrc_i(5)      <= Rc_addr(2);
   rrc_i(6)      <= Rc_addr(1);
   rrc_i(7)      <= Rc_addr(0);

   rtn_i(0 to 4) <= (others => '0');
   rtn_i(5 to 7) <= ten_adr_i(5 to 7);

   rpq_i(0 to 3) <= (others => '0');
   rpq_i(4 to 7) <= rc_fifo_pirq_i(4 to 7);


   ----------------------------------------------------------------------------
   -- RDACK_OR_I - oring bus2iic rdce
   ----------------------------------------------------------------------------
   RDACK_OR_I : entity proc_common_v3_00_a.or_muxcy
      generic map (
         C_NUM_BITS => C_NUM_IIC_REGS
         )
      port map (
         In_bus => Bus2IIC_RdCE(0 to C_NUM_IIC_REGS-1) ,
         Or_out => rdce_or
         );

   ----------------------------------------------------------------------------
   -- IIC2BUS_RDACK
   ----------------------------------------------------------------------------
   -- IIC2BUS_RDACK is simply Bus2IIC_RdReq
   RDACK_PROCESS : process (Clk)
   begin  -- process
      if (Clk'event and Clk = '1') then
         if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
            IIC2Bus_RdAck_i <= '0';
         elsif
            -- Bus2IIC_RdReq = '1' and IIC2Bus_RdAck_i = '0' and 
            --rdce_or = '1' then
            IIC2Bus_RdAck_i = '0' and rdce_or = '1' then
            IIC2Bus_RdAck_i <= '1';
         else
            IIC2Bus_RdAck_i <= '0';
         end if;
      end if;
   end process RDACK_PROCESS;
   
   IIC2Bus_RdAck <= IIC2Bus_RdAck_i;

   ----------------------------------------------------------------------------
   -- Interrupts
   ----------------------------------------------------------------------------
   -- Int_PROCESS generates interrupts back to the IPIF
   ----------------------------------------------------------------------------
   INT_PROCESS : process (Clk)
   begin  -- process
      if (Clk'event and Clk = '1') then
         if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
            IIC2Bus_IntrEvent(0 to 6) <= (others => '0');
         else
            IIC2Bus_IntrEvent(0) <= Al;    -- arbitration lost interrupt
            IIC2Bus_IntrEvent(1) <= Txer;  -- transmit error interrupt
            IIC2Bus_IntrEvent(2) <= Tx_under_prev;  --dtre_i; 
                                           -- Data Tx Register Empty interrupt
            IIC2Bus_IntrEvent(3) <= ro_prev_i;  --New_rcv_dta; 
                                            -- Data Rc Register Full interrupt
            IIC2Bus_IntrEvent(4) <= not Bb;
            IIC2Bus_IntrEvent(5) <= Aas;
            IIC2Bus_IntrEvent(6) <= not Aas;
         end if;
      end if;
   end process INT_PROCESS;

   ----------------------------------------------------------------------------
   -- Ten Bit Slave Address Generate
   ----------------------------------------------------------------------------
   -- Int_PROCESS generates interrupts back to the IPIF
   ----------------------------------------------------------------------------
   TEN_ADR_GEN : if (C_TEN_BIT_ADR = 1) generate

      -------------------------------------------------------------------------
      -- TEN_ADR_REGISTER_PROCESS
      -------------------------------------------------------------------------
      TEN_ADR_REGISTER_PROCESS : process (Clk)
      begin  -- process
         if (Clk'event and Clk = '1') then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               ten_adr_i <= (others => '0');
            elsif             --  Load Status Register with PLB
               --  data if there is a write request
               --  and the status register is enabled
               Bus2IIC_WrCE(7) = '1' then
               ten_adr_i(5 to 7) <= Bus2IIC_Data(29 to 31);
            else
               ten_adr_i <= ten_adr_i;
            end if;
         end if;
      end process TEN_ADR_REGISTER_PROCESS;

      Ten_adr <= ten_adr_i;

   end generate TEN_ADR_GEN;

   ----------------------------------------------------------------------------
   -- General Purpose Ouput Register Generate
   ----------------------------------------------------------------------------
   -- Generate the GPO if C_GPO_WIDTH is not equal to zero
   ----------------------------------------------------------------------------
   GPO_GEN : if (C_GPO_WIDTH /= 0) generate

      -------------------------------------------------------------------------
      -- GPO_REGISTER_PROCESS
      -------------------------------------------------------------------------
      GPO_REGISTER_PROCESS : process (Clk)
      begin  -- process
         if Clk'event and Clk = '1' then
            if Rst = xps_iic_v2_03_a.iic_pkg.RESET_ACTIVE then
               gpo_i <= (others => '0');
            elsif             --  Load Status Register with PLB
               --  data if there is a write CE
               Bus2IIC_WrCE(C_NUM_IIC_REGS - 1) = '1' then
               gpo_i(32 - C_GPO_WIDTH to 31) <= 
                                          Bus2IIC_Data(32 - C_GPO_WIDTH to 31);
            else
               gpo_i <= gpo_i;
            end if;
         end if;
      end process GPO_REGISTER_PROCESS;

      Gpo <= gpo_i;

   end generate GPO_GEN;



end architecture imp;






