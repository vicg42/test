-------------------------------------------------------------------------------
-- iic_pkg.vhd - Package
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
-- Filename:        iic_pkg.vhd
-- Version:         v2.03.a
-- Description:     This file contains the constants used in the design of the
--                  iic bus interface.
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
--  KC            10/17/01      -- Added Addr_bits function to be consistent 
--                                 with OPB Arbiter which included the new 
--                                 generic C_HIGHADDR
--
--  KC            11/30/01      -- Removed C_IP_REG_BASEADDR_OFFSET as a user
--                                 settable generic and made it a constant
--
--  KC             09/30/03   -- Added GPO to close CR# 160041
--
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


package iic_pkg is

   ----------------------------------------------------------------------------
   -- Constant Declarations
   ----------------------------------------------------------------------------
   constant RESET_ACTIVE : std_logic              := '1'; -- Reset Constant
   
   constant DATA_BITS    : natural                := 8; -- FIFO Width Generic
   constant TX_FIFO_BITS : integer range 0 to 256 := 4; -- Number of addr bits
   constant RC_FIFO_BITS : integer range 0 to 256 := 4; -- Number of addr bits
   
   
   --IPIF Generics that must remain at these values for the IIC
   constant  DEV_BURST_ENABLE          : BOOLEAN := false;  
   constant  DEV_MAX_BURST_SIZE        : INTEGER := 64;  
   constant  RESET_PRESENT             : BOOLEAN := True;  
   constant  INTERRUPT_PRESENT         : BOOLEAN := True;  
   constant  INCLUDE_DEV_PENCODER      : BOOLEAN := False;  
   constant  IP_MASTER_PRESENT         : BOOLEAN := False;  
   constant  IP_REG_PRESENT            : BOOLEAN := True;  
   constant  IP_IRPT_NUM               : INTEGER := 8;    
   constant  IP_SRAM_PRESENT           : BOOLEAN := false;  
   constant  IP_SRAM_BASEADDR_OFFSET   : std_logic_vector := X"00001000";  
   constant  IP_SRAM_SIZE              : INTEGER := 256;  
   constant  WRFIFO_PRESENT            : BOOLEAN := false;
   constant  WRFIFO_BASEADDR_OFFSET    : std_logic_vector := X"00002100";  
   constant  WRFIFO_REG_BASEADDR_OFFSET: std_logic_vector := X"00002000";  
   constant  RDFIFO_PRESENT            : BOOLEAN := false; 
   constant  RDFIFO_BASEADDR_OFFSET    : std_logic_vector := X"00002200";  
   constant  RDFIFO_REG_BASEADDR_OFFSET: std_logic_vector := X"00002010";  
   constant  DMA_PRESENT               : BOOLEAN := false;  
   constant  DMA_REG_BASEADDR_OFFSET   : std_logic_vector := X"00002300";  
   constant  DMA_CHAN_NUM              : INTEGER := 2;  
   constant  DMA_CH1_TYPE              : INTEGER := 2;  
   constant  DMA_CH2_TYPE              : INTEGER := 3;  
   constant  DMA_ALLOW_BURST           : BOOLEAN := false;  
   constant  DMA_LENGTH_WIDTH          : INTEGER := 11;  
   constant  DMA_INTR_COALESCE         : BOOLEAN := false;  
   constant  DMA_PACKET_WAIT_UNIT_NS   : INTEGER := 1000000;  
   constant  DMA_TXL_FIFO_IPCE         : INTEGER := 8;  
   constant  DMA_TXS_FIFO_IPCE         : INTEGER := 9;  
   constant  DMA_RXL_FIFO_IPCE         : INTEGER := 7;  
   constant  DMA_RXS_FIFO_IPCE         : INTEGER := 15; 
   constant  OPB_CLK_PERIOD_PS         : INTEGER := 10000; 
   constant  IPIF_ABUS_WIDTH           : INTEGER := 32; 
   constant  IPIF_DBUS_WIDTH           : INTEGER := 32; 
   constant  VIRTEX_II                 : Boolean := false;
   constant  INCLUDE_DEV_ISC           : Boolean := false;
   constant  IP_REG_BASEADDR_OFFSET    : std_logic_vector := X"00000100";
   
   type STD_LOGIC_VECTOR_ARRAY is array (0 to 9) of std_logic_vector(24 to 31);
   type INTEGER_ARRAY is array (24 to 31) of integer; 
   ----------------------------------------------------------------------------
   -- Function and Procedure Declarations
   ----------------------------------------------------------------------------
   function num_ctr_bits(C_CLK_FREQ,C_IIC_FREQ : integer)  return integer;
   function Addr_Bits (x,y : std_logic_vector; addr_width : integer) return 
                                                                    integer;
   function num_ip_reg(C_GPO_WIDTH : integer)  return integer;
   function ten_bit_addr_used(C_TEN_BIT_ADR : integer) return std_logic_vector;
   function gpo_bit_used(C_GPO_WIDTH : integer) return std_logic_vector;
   function count_reg_bits_used(REG_BITS_USED : STD_LOGIC_VECTOR_ARRAY) return
                                                                INTEGER_ARRAY;
   function intrnl_hold_delay(C_CLK_FREQ,C_HOLD_FREQ : integer) return integer;

end package iic_pkg;


-------------------------------------------------------------------------------
-- Package body
-------------------------------------------------------------------------------
package body iic_pkg is

   ----------------------------------------------------------------------------
   -- Function Definitions
   ----------------------------------------------------------------------------
   -- Function num_ctr_bits
   --
   -- This function returns the number of bits required to count 1/2 the period
   -- of the SCL clock.
   --
   ----------------------------------------------------------------------------
   function num_ctr_bits(C_CLK_FREQ,C_IIC_FREQ : integer) return integer is
   
      variable num_bits    : integer :=0;
      variable i           : integer :=0;
      begin   
      --  for loop used because XST service pack 2 does not support While loops
      if C_CLK_FREQ/C_IIC_FREQ > C_CLK_FREQ/212766 then
         for i in 0 to 30 loop  -- 30 is a magic number needed for for loops
            if 2**i < C_CLK_FREQ/C_IIC_FREQ then
                  num_bits := num_bits + 1;   
            end if;
         end loop;
         return (num_bits);
      else
         for i in 0 to 30 loop
            if 2**i < C_CLK_FREQ/212766 then
                  num_bits := num_bits + 1; 
            end if;
         end loop;
         return (num_bits);
      end if;
   end function num_ctr_bits;         
   
   
   ----------------------------------------------------------------------------
   -- Function Addr_bits
   --
   -- This function converts an address range (base address and an upper 
   -- address) into the number of upper address bits needed for decoding a 
   -- device select signal
   ----------------------------------------------------------------------------
   function Addr_Bits (x,y : std_logic_vector; addr_width:integer)
    return integer is
     variable addr_nor : std_logic_vector(0 to addr_width-1);
   begin
     addr_nor := x xor y;
     for i in 0 to addr_width-1
     loop
       if addr_nor(i) = '1' then return i;
       end if;
     end loop;
     return addr_width;
   end function Addr_Bits;
   
   ----------------------------------------------------------------------------
   -- Function num_ip_reg
   --
   -- This function returns either 9 or 10 depending on C_GPO_WIDTH
   -- When the C_GPO_WIDTH=0 then no GPO register is needed so the number of
   -- registers implemented drops from 10 to 9.
   --
   ----------------------------------------------------------------------------
   function num_ip_reg(C_GPO_WIDTH : integer) return integer is
   
      begin   
      if C_GPO_WIDTH = 0 then
         return (9);
      else
         return (10);
      end if;
   end function num_ip_reg;         
   
   ----------------------------------------------------------------------------
   -- Function ten_bit_addr_used
   --
   -- This function returns either b"00000000" for no ten bit addressing or
   --                              b"00000111" for ten bit addressing
   --
   ----------------------------------------------------------------------------
   function ten_bit_addr_used(C_TEN_BIT_ADR : integer) return 
                                                           std_logic_vector is
      begin   
      if C_TEN_BIT_ADR = 0 then
         return (b"00000000");
      else
         return (b"00000111");
      end if;
   end function ten_bit_addr_used;         
   
   ----------------------------------------------------------------------------
   -- Function gpo_bit_used
   --
   -- This function returns b"00000000" up to b"11111111" depending on
   -- C_GPO_WIDTH
   --
   ----------------------------------------------------------------------------
   function gpo_bit_used(C_GPO_WIDTH : integer) return std_logic_vector is
      begin   
      if C_GPO_WIDTH = 0 then
         return (b"00000000");
      elsif C_GPO_WIDTH = 1 then
         return (b"00000001");
      elsif C_GPO_WIDTH = 2 then
         return (b"00000011");
      elsif C_GPO_WIDTH = 3 then
         return (b"00000111");
      elsif C_GPO_WIDTH = 4 then
         return (b"00001111");
      elsif C_GPO_WIDTH = 5 then
         return (b"00011111");
      elsif C_GPO_WIDTH = 6 then
         return (b"00111111");
      elsif C_GPO_WIDTH = 7 then
         return (b"01111111");
      elsif C_GPO_WIDTH = 8 then
         return (b"11111111");
      elsif C_GPO_WIDTH > 8 then
         return (b"11111111");
      end if;
   end function gpo_bit_used;  
   
   ----------------------------------------------------------------------------
   -- Function count_reg_bits_used
   --
   -- This function returns either b"00000000" for no ten bit addressing or
   --                              b"00000111" for ten bit addressing
   --
   ----------------------------------------------------------------------------
   function count_reg_bits_used(REG_BITS_USED : STD_LOGIC_VECTOR_ARRAY) 
                                         return INTEGER_ARRAY is 
      variable count : INTEGER_ARRAY;
   begin
      for i in 24 to 31 loop
         count(i) := 0;
         for m in 0 to 9 loop --IP_REG_NUM - 1
            if (REG_BITS_USED(m)(i) = '1') then
               count(i) := count(i) + 1;
            end if;
         end loop;
      end loop;
      return count;
   end function count_reg_bits_used;
   
   ----------------------------------------------------------------------------
   -- Function intrnl_hold_delay
   --
   -- This function returns the number of register required to meet the 300 ns 
   -- internal hold time.  Five clocks is added to account for other internal
   -- delays
   ----------------------------------------------------------------------------
   function intrnl_hold_delay(C_CLK_FREQ,C_HOLD_FREQ : integer) return 
                                                                integer is
   
      variable num_regs    : integer :=0;
      variable i           : integer :=0;
      begin   
         for i in 0 to 1000 loop  -- 30 is a magic number needed for for loops
            if i < C_CLK_FREQ/C_HOLD_FREQ then
                  num_regs := num_regs + 1;   
            end if;
         end loop;
         return (num_regs);
   end function intrnl_hold_delay;         



end package body iic_pkg;
