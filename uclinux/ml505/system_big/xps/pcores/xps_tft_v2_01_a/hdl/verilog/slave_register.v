//-----------------------------------------------------------------------------
// slave_register.v   
//-----------------------------------------------------------------------------
//  ***************************************************************************
//  ** DISCLAIMER OF LIABILITY                                               **
//  **                                                                       **
//  **  This file contains proprietary and confidential information of       **
//  **  Xilinx, Inc. ("Xilinx"), that is distributed under a license         **
//  **  from Xilinx, and may be used, copied and/or disclosed only           **
//  **  pursuant to the terms of a valid license agreement with Xilinx.      **
//  **                                                                       **
//  **  XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION                **
//  **  ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER           **
//  **  EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                  **
//  **  LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,            **
//  **  MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx        **
//  **  does not warrant that functions included in the Materials will       **
//  **  meet the requirements of Licensee, or that the operation of the      **
//  **  Materials will be uninterrupted or error-free, or that defects       **
//  **  in the Materials will be corrected. Furthermore, Xilinx does         **
//  **  not warrant or make any representations regarding use, or the        **
//  **  results of the use, of the Materials in terms of correctness,        **
//  **  accuracy, reliability or otherwise.                                  **
//  **                                                                       **
//  **  Xilinx products are not designed or intended to be fail-safe,        **
//  **  or for use in any application requiring fail-safe performance,       **
//  **  such as life-support or safety devices or systems, Class III         **
//  **  medical devices, nuclear facilities, applications related to         **
//  **  the deployment of airbags, or any other applications that could      **
//  **  lead to death, personal injury or severe property or                 **
//  **  environmental damage (individually and collectively, "critical       **
//  **  applications"). Customer assumes the sole risk and liability         **
//  **  of any use of Xilinx products in critical applications,              **
//  **  subject only to applicable laws and regulations governing            **
//  **  limitations on product liability.                                    **
//  **                                                                       **
//  **  Copyright 2008, 2009 Xilinx, Inc.                                    **
//  **  All rights reserved.                                                 **
//  **                                                                       **
//  **  This disclaimer and copyright notice must be retained as part        **
//  **  of this file at all times.                                           **
//  ***************************************************************************
//-----------------------------------------------------------------------------
// Filename:        slave_register.v
// Version:         v2.01a
// Description:     This module contains TFT control register and provides
//                  PLB or DCR interface to access those registers.
//                                   
// Verilog-Standard: Verilog'2001
//-----------------------------------------------------------------------------
// Structure:   
//                  xps_tft.vhd
//                     -- plbv46_master_burst.vhd               
//                     -- plbv46_slave_single.vhd
//                     -- tft_controller.v
//                            -- line_buffer.v
//                            -- v_sync.v
//                            -- h_sync.v
//                            -- slave_register.v
//                            -- tft_interface.v
//                                -- iic_init.v
//-----------------------------------------------------------------------------
// Author:          PVK
// History:
//   PVK           06/10/08    First Version
// ^^^^^^
//    --  Added PLB slave and DCR slave interface to access TFT Registers. 
// ~~~~~~~~
//-----------------------------------------------------------------------------
// Naming Conventions:
//      active low signals:                     "*_n"
//      clock signals:                          "clk", "clk_div#", "clk_#x" 
//      reset signals:                          "rst", "rst_n" 
//      parameters:                             "C_*" 
//      user defined types:                     "*_TYPE" 
//      state machine next state:               "*_ns" 
//      state machine current state:            "*_cs" 
//      combinatorial signals:                  "*_com" 
//      pipelined or register delay signals:    "*_d#" 
//      counter signals:                        "*cnt*"
//      clock enable signals:                   "*_ce" 
//      internal version of output port         "*_i"
//      device pins:                            "*_pin" 
//      ports:                                  - Names begin with Uppercase 
//      component instantiations:               "<MODULE>I_<#|FUNC>
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps

///////////////////////////////////////////////////////////////////////////////
// Module Declaration
///////////////////////////////////////////////////////////////////////////////

module slave_register(
  // DCR BUS
  DCR_Clk,          // DCR clock
  DCR_Rst,          // DCR reset
  DCR_ABus,         // DCR Address bus
  DCR_Sl_DBus,      // DCR slave data bus
  DCR_Read,         // DCR read request
  DCR_Write,        // DCR write request
  Sl_DCRAck,        // Slave DCR data ack
  Sl_DCRDBus,       // Slave DCR data bus

  // PLB Slave Interface
  PLB_Clk,          // Slave Interface clock
  PLB_Rst,          // Slave Interface reset
  Bus2IP_Data,      // Bus to IP data bus
  Bus2IP_RdCE,      // Bus to IP read chip enable
  Bus2IP_WrCE,      // Bus to IP write chip enable
  Bus2IP_BE,        // Bus to IP byte enable
  IP2Bus_Data,      // IP to Bus data bus
  IP2Bus_RdAck,     // IP to Bus read transfer acknowledgement
  IP2Bus_WrAck,     // IP to Bus write transfer acknowledgement
  IP2Bus_Error,     // IP to Bus error response

  // Registers
  TFT_base_addr,    // TFT Base Address reg    
  TFT_dps_reg,      // TFT display scan reg
  TFT_on_reg,       // TFT display on reg
  TFT_intr_en,      // TFT frame complete interrupt enable reg
  TFT_status,       // TFT frame complete status reg
  IIC_xfer_done,    // IIC configuration done
  TFT_iic_xfer,     // IIC configuration request
  TFT_iic_reg_addr, // IIC register address
  TFT_iic_reg_data  // IIC register data
  );


///////////////////////////////////////////////////////////////////////////////
// Parameter Declarations
///////////////////////////////////////////////////////////////////////////////

  parameter integer C_DCR_SPLB_SLAVE_IF      = 1;          
  parameter         C_DCR_BASEADDR           = "0010000000";
  parameter         C_DEFAULT_TFT_BASE_ADDR  = "11110000000";
  parameter integer C_SLV_DWIDTH             = 32;
  parameter integer C_NUM_REG                = 4;

///////////////////////////////////////////////////////////////////////////////
// Port Declarations
/////////////////////////////////////////////////////////////////////////////// 

  input                         DCR_Clk;
  input                         DCR_Rst;
  input  [0:9]                  DCR_ABus;
  input  [0:31]                 DCR_Sl_DBus;
  input                         DCR_Read;
  input                         DCR_Write;
  output                        Sl_DCRAck;
  output [0:31]                 Sl_DCRDBus;
  input                         PLB_Clk;
  input                         PLB_Rst;
  input  [0 : C_SLV_DWIDTH-1]   Bus2IP_Data;
  input  [0 : C_NUM_REG-1]      Bus2IP_RdCE;
  input  [0 : C_NUM_REG-1]      Bus2IP_WrCE;
  input  [0 : C_SLV_DWIDTH/8-1] Bus2IP_BE;
  output [0 : C_SLV_DWIDTH-1]   IP2Bus_Data;
  output                        IP2Bus_RdAck;
  output                        IP2Bus_WrAck;
  output                        IP2Bus_Error;
  output [0:10]                 TFT_base_addr;
  output                        TFT_dps_reg;
  output                        TFT_on_reg;
  output                        TFT_intr_en;
  input                         TFT_status;
  input                         IIC_xfer_done;
  output                        TFT_iic_xfer;
  output [0:7]                  TFT_iic_reg_addr;
  output [0:7]                  TFT_iic_reg_data;

///////////////////////////////////////////////////////////////////////////////
// Signal Declaration
///////////////////////////////////////////////////////////////////////////////
  reg                           TFT_intr_en;
  reg                           TFT_status_reg;
  reg                           TFT_dps_reg;
  reg                           TFT_on_reg;
  reg  [0:10]                   TFT_base_addr;
  reg  [0:C_SLV_DWIDTH-1]       IP2Bus_Data; 
  wire                          dcr_addr_hit;
  wire [0:9]                    dcr_base_addr;
  wire [0:31]                   Sl_DCRDBus;
  reg                           dcr_read_access;
  reg  [0:31]                   dcr_read_data;
  reg                           Sl_DCRAck;
  reg                           tft_status_d1;
  reg                           tft_status_d2;
  reg                           TFT_iic_xfer;
  reg [0:7]                     TFT_iic_reg_addr;
  reg [0:7]                     TFT_iic_reg_data;
  reg                           iic_xfer_done_d1;
  reg                           iic_xfer_done_d2;
  
///////////////////////////////////////////////////////////////////////////////
// TFT Register Interface 
///////////////////////////////////////////////////////////////////////////////
//---------------------
// Register         DCR  PLB  
//-- AR  - offset - 00 - 00
//-- CR  -        - 01 - 04
//-- ICR -        - 02 - 08
//-- Reserved     - 03 - 0C
//---------------------
//-- TFT Address Register(AR)
//-- BSR bits
//-- bit 0:10  - 11 MSB of Video Memory Address
//-- bit 11:31 - Reserved
//---------------------
//-- TFT Control Register(CR)
//-- BSR bits
//-- bit 0:29  - Reserved
//-- bit 30    - Display scan control bit
//-- bit 31    - TFT Display enable bit
///////////////////////////////////////////////////////////////////////////////
//---------------------
//-- TFT Interrupt Control Register(ICR)
//-- BSR bits
//-- bit 0:27  - Reserved
//-- bit 28    - Interrupt enable bit 
//-- bit 29:30 - Reserved
//-- bit 31    - Frame Complete Status bit
///////////////////////////////////////////////////////////////////////////////

  initial  Sl_DCRAck = 1'b0;

  generate 
    if (C_DCR_SPLB_SLAVE_IF == 1)
      begin : gen_plb_if
 
      /////////////////////////////////////////////////////////////////////////
      // PLB Interface 
      /////////////////////////////////////////////////////////////////////////
        wire bus2ip_rdce_or;
        wire bus2ip_wrce_or;
        wire bus2ip_rdce_pulse;
        wire bus2ip_wrce_pulse;
        reg  bus2ip_rdce_d1;
        reg  bus2ip_rdce_d2;
        reg  bus2ip_wrce_d1;
        reg  bus2ip_wrce_d2;
        wire word_access; 
        wire Sl_DCRAck;
       
        // oring of bus2ip_rdce and wrce
        assign bus2ip_rdce_or = Bus2IP_RdCE[0] | Bus2IP_RdCE[1] |
                                Bus2IP_RdCE[2] | Bus2IP_RdCE[3];

        assign bus2ip_wrce_or = Bus2IP_WrCE[0] | Bus2IP_WrCE[1] | 
                                Bus2IP_WrCE[2] | Bus2IP_WrCE[3];

        assign word_access    = (Bus2IP_BE == 4'b1111)? 1'b1 : 1'b0; 
        
        //---------------------------------------------------------------------
        //-- register combinational rdce 
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : REG_CE
          if (PLB_Rst)
            begin 
              bus2ip_rdce_d1 <= 1'b0; 
              bus2ip_rdce_d2 <= 1'b0;               
              bus2ip_wrce_d1 <= 1'b0; 
              bus2ip_wrce_d2 <= 1'b0;               
            end
          else 
            begin
              bus2ip_rdce_d1 <= bus2ip_rdce_or; 
              bus2ip_rdce_d2 <= bus2ip_rdce_d1;               
              bus2ip_wrce_d1 <= bus2ip_wrce_or; 
              bus2ip_wrce_d2 <= bus2ip_wrce_d1;               
            end
        end
           
        // generate pulse for bus2ip_rdce & bus2ip_wrce
        assign bus2ip_rdce_pulse = bus2ip_rdce_d1 & ~bus2ip_rdce_d2;
        assign bus2ip_wrce_pulse = bus2ip_wrce_d1 & ~bus2ip_wrce_d2;

        
        //---------------------------------------------------------------------
        //-- Generating the acknowledgement signals
        //---------------------------------------------------------------------
        assign IP2Bus_RdAck = bus2ip_rdce_pulse;
        
        assign IP2Bus_WrAck = bus2ip_wrce_pulse;
        
        assign IP2Bus_Error = ((bus2ip_rdce_pulse | bus2ip_wrce_pulse) && 
                                 (word_access == 1'b0))? 1'b1 : 1'b0;
        
        //---------------------------------------------------------------------
        //-- Writing to TFT Registers
        //---------------------------------------------------------------------
        // writing AR
        always @(posedge PLB_Clk)
        begin : WRITE_AR
          if (PLB_Rst)
            begin 
              TFT_base_addr <= C_DEFAULT_TFT_BASE_ADDR; 
            end
          else if (Bus2IP_WrCE[0] == 1'b1 & word_access == 1'b1)
            begin
              TFT_base_addr <= Bus2IP_Data[0:10];
            end
        end
        
        //---------------------------------------------------------------------
        // Writing CR
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : WRITE_CR
          if (PLB_Rst)
            begin 
              TFT_dps_reg   <= 1'b0; 
              TFT_on_reg    <= 1'b1; 
            end
          else if (Bus2IP_WrCE[1] == 1'b1 & word_access == 1'b1)
            begin
              TFT_dps_reg   <= Bus2IP_Data[30]; 
              TFT_on_reg    <= Bus2IP_Data[31]; 
            end
        end
        

        //---------------------------------------------------------------------
        // Writing ICR - Interrupt Enable
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : WRITE_ICR_IE
          if (PLB_Rst)
            begin 
              TFT_intr_en     <= 1'b0; 
            end
          else if (Bus2IP_WrCE[2] == 1'b1 & word_access == 1'b1)
            begin
              TFT_intr_en     <= Bus2IP_Data[28]; 
            end
        end

        //---------------------------------------------------------------------
        // Writing ICR - Frame Complete status 
        // For polled mode operation
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : WRITE_ICR_STAT
          if (PLB_Rst)
            begin 
              TFT_status_reg  <= 1'b0; 
            end
          else if (Bus2IP_WrCE[0] == 1'b1 & word_access == 1'b1)
            begin
              TFT_status_reg  <= 1'b0; 
            end
          else if (Bus2IP_WrCE[2] == 1'b1 & word_access == 1'b1)
            begin
              TFT_status_reg  <= Bus2IP_Data[31]; 
            end
          else if (tft_status_d2 == 1'b1)
            begin
              TFT_status_reg  <= 1'b1; 
            end
  
        end


        //---------------------------------------------------------------------
        // Writing IICR - IIC Register
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : WRITE_IICR
          if (PLB_Rst)
            begin 
              TFT_iic_reg_addr <= 8'b0;
              TFT_iic_reg_data <= 8'b0;
            end
          else if (Bus2IP_WrCE[3] == 1'b1 & word_access == 1'b1)
            begin
              TFT_iic_reg_addr  <= Bus2IP_Data[16:23]; 
              TFT_iic_reg_data  <= Bus2IP_Data[24:31]; 
            end
        end


        //---------------------------------------------------------------------
        // Writing IICR - XFER Register
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : WRITE_XFER
          if (PLB_Rst)
            begin 
              TFT_iic_xfer  <= 1'b0; 
            end
          else if (Bus2IP_WrCE[3] == 1'b1 & word_access == 1'b1)
            begin
              TFT_iic_xfer  <= Bus2IP_Data[0]; 
            end
          else if (iic_xfer_done_d2 == 1'b1)
            begin
              TFT_iic_xfer  <= 1'b0; 
            end
        end

        //---------------------------------------------------------------------
        // Synchronize the IIC_xfer_done signal w.r.t. SPLB_CLK
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : IIC_XFER_DONE_PLB_SYNC
          if (PLB_Rst)
            begin 
              iic_xfer_done_d1 <= 1'b0;
              iic_xfer_done_d2 <= 1'b0;
            end
          else
            begin
              iic_xfer_done_d1 <= IIC_xfer_done;
              iic_xfer_done_d2 <= iic_xfer_done_d1;
            end  
        end

        //---------------------------------------------------------------------
        // Synchronize the vsync_intr signal w.r.t. SPLB_CLK
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : VSYNC_INTR_PLB_SYNC
          if (PLB_Rst)
            begin 
              tft_status_d1 <= 1'b0;
              tft_status_d2 <= 1'b0;
            end
          else
            begin
              tft_status_d1 <= TFT_status;
              tft_status_d2 <= tft_status_d1;
            end  
        end

        
        //---------------------------------------------------------------------
        //-- Reading from TFT Registers
        //-- Bus2IP_RdCE[0] == AR
        //-- Bus2IP_RdCE[1] == CR
        //-- Bus2IP_RdCE[2] == ICR
        //-- Bus2IP_RdCE[3] == Reserved
        //---------------------------------------------------------------------
        always @(posedge PLB_Clk)
        begin : READ_REG
          
          
          if (PLB_Rst | ~word_access ) 
            begin 
              IP2Bus_Data[0:27]  <= 28'b0;
              IP2Bus_Data[28:31] <= 4'b0;
            end
          else if (Bus2IP_RdCE[0] == 1'b1)
            begin
              IP2Bus_Data[0:10]  <= TFT_base_addr;
              IP2Bus_Data[11:31] <= 20'b0;
            end
          else if (Bus2IP_RdCE[1] == 1'b1)
            begin
              IP2Bus_Data[0:29]  <= 30'b0;
              IP2Bus_Data[30]    <= TFT_dps_reg; 
              IP2Bus_Data[31]    <= TFT_on_reg;
            end
          else if (Bus2IP_RdCE[2] == 1'b1)
            begin
              IP2Bus_Data[0:27]  <= 28'b0;
              IP2Bus_Data[28]    <= TFT_intr_en;
              IP2Bus_Data[29:30] <= 2'b0;
              IP2Bus_Data[31]    <= TFT_status_reg; 
            end
          else if (Bus2IP_RdCE[3] == 1'b1)
            begin
              IP2Bus_Data[0]     <= TFT_iic_xfer;
              IP2Bus_Data[1: 15] <= 15'b0;
              IP2Bus_Data[16:23] <= TFT_iic_reg_addr;
              IP2Bus_Data[24:31] <= TFT_iic_reg_data; 
            end
          else 
            begin
              IP2Bus_Data  <= 32'b0;
            end
        end

        
        // Drive Zero on DCR Output Ports
        assign Sl_DCRDBus = 32'b0;         
        assign Sl_DCRAck  = 1'b0; 

        
      end  // End generate PLB Interface
  
    else                                  // if DCR interface is selected
      begin : gen_dcr_if                  // C_DCR_SPLB_SLAVE_IF=0
      
        // Define the DCR interface signals
    
        ///////////////////////////////////////////////////////////////////////
        // DCR Interface 
        ///////////////////////////////////////////////////////////////////////
        assign dcr_base_addr = C_DCR_BASEADDR;
        assign dcr_addr_hit  = (DCR_ABus[0:7] == dcr_base_addr[0:7]);
        
        //---------------------------------------------------------------------
        //-- DCR control logic
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : DCR_CONTROL_LOG
          if (DCR_Rst)
            begin 
              dcr_read_access <= 1'b0;
              Sl_DCRAck       <= 1'b0;
            end
          else         
            begin 
              dcr_read_access <= DCR_Read               & dcr_addr_hit;
              Sl_DCRAck       <= (DCR_Read | DCR_Write) & dcr_addr_hit;
            end
        end
          
        

        //---------------------------------------------------------------------
        //-- Writing to TFT Registers
        //---------------------------------------------------------------------
        // writing AR
        always @(posedge DCR_Clk)
        begin : WRITE_AR
          if (DCR_Rst)
            TFT_base_addr <= C_DEFAULT_TFT_BASE_ADDR;
          else if (DCR_Write & ~Sl_DCRAck & dcr_addr_hit & 
                                                      (DCR_ABus[8:9] == 2'b00))
            TFT_base_addr <= DCR_Sl_DBus[0:10];
        end

        //---------------------------------------------------------------------
        // writing CR
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : WRITE_CR
          if (DCR_Rst) 
            begin
              TFT_dps_reg <= 1'b0;
              TFT_on_reg  <= 1'b1;
            end
          else if (DCR_Write & ~Sl_DCRAck & dcr_addr_hit & 
                                                (DCR_ABus[8:9] == 2'b01)) 
            begin
              TFT_dps_reg <= DCR_Sl_DBus[30];
              TFT_on_reg  <= DCR_Sl_DBus[31];
            end
        end

        //---------------------------------------------------------------------
        // writing ICR - Interrupt Enable
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : WRITE_ICR_IE
          if (DCR_Rst) 
            begin
              TFT_intr_en <= 1'b0;
            end
          else if (DCR_Write & ~Sl_DCRAck & dcr_addr_hit & 
                                                (DCR_ABus[8:9] == 2'b10)) 
            begin
              TFT_intr_en <= DCR_Sl_DBus[28];
            end
        end


        //---------------------------------------------------------------------
        // writing ICR - Frame Complete status 
        // For polled mode operation
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : WRITE_ICR_STAT
          if (DCR_Rst) 
            begin
              TFT_status_reg <= 1'b0;
            end
          else if (DCR_Write & ~Sl_DCRAck & dcr_addr_hit & 
                                                      (DCR_ABus[8:9] == 2'b00))
            begin
              TFT_status_reg <= 1'b0;
            end
          else if (DCR_Write & ~Sl_DCRAck & dcr_addr_hit & 
                                                (DCR_ABus[8:9] == 2'b10)) 
            begin
              TFT_status_reg <= DCR_Sl_DBus[31];
            end
          else if (tft_status_d2 == 1'b1) 
            begin
              TFT_status_reg <= 1'b1;
            end
  
        end


        //---------------------------------------------------------------------
        // Writing IICR - IIC Register
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : WRITE_IICR_DCR
          if (DCR_Rst)
            begin 
              TFT_iic_reg_addr <= 8'b0;
              TFT_iic_reg_data <= 8'b0;
            end
          else if (DCR_Write & ~Sl_DCRAck & dcr_addr_hit & 
                                                (DCR_ABus[8:9] == 2'b11))
            begin
              TFT_iic_reg_addr  <= DCR_Sl_DBus[16:23]; 
              TFT_iic_reg_data  <= DCR_Sl_DBus[24:31]; 
            end
        end


        //---------------------------------------------------------------------
        // Writing IICR - XFER Register
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : WRITE_XFER_DCR
          if (DCR_Rst)
            begin 
              TFT_iic_xfer     <= 1'b0; 
            end
          else if (DCR_Write & ~Sl_DCRAck & dcr_addr_hit & 
                                                (DCR_ABus[8:9] == 2'b11))
            begin
              TFT_iic_xfer      <= DCR_Sl_DBus[0]; 
            end
          else if (iic_xfer_done_d2 == 1'b1)
            begin
              TFT_iic_xfer  <= 1'b0; 
            end
        end
        
        //---------------------------------------------------------------------
        // Synchronize the vsync_intr signal w.r.t. DCR_CLK
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : TFT_IIC_XFER_DCR_SYNC
          if (DCR_Rst) 
            begin
              iic_xfer_done_d1 <= 1'b0;
              iic_xfer_done_d2 <= 1'b0;
            end
          else
            begin
              iic_xfer_done_d1 <= IIC_xfer_done;
              iic_xfer_done_d2 <= iic_xfer_done_d1;
            end 
         end
 
        //---------------------------------------------------------------------
        // Synchronize the vsync_intr signal w.r.t. DCR_CLK
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : VSYNC_INTR_DCR_SYNC
          if (DCR_Rst) 
            begin
              tft_status_d1 <= 1'b0;
              tft_status_d2 <= 1'b0;
            end
          else
            begin
              tft_status_d1 <= TFT_status;
              tft_status_d2 <= tft_status_d1;
            end 
         end


        //---------------------------------------------------------------------
        //-- Reading from TFT Registers
        //---------------------------------------------------------------------
        always @(posedge DCR_Clk)
        begin : DCR_READ_DATA_I
          if (DCR_Read & dcr_addr_hit & ~Sl_DCRAck)
            dcr_read_data <= 
                         (DCR_ABus[8:9] == 2'b00)? {TFT_base_addr, 21'b0}  :
                         (DCR_ABus[8:9] == 2'b01)? {30'b0, TFT_dps_reg, 
                                                           TFT_on_reg}     : 
                         (DCR_ABus[8:9] == 2'b10)? {27'b0, TFT_intr_en,  
                                                     2'b0, TFT_status_reg} :
                         (DCR_ABus[8:9] == 2'b11)? {TFT_iic_xfer, 15'b0, 
                                                    TFT_iic_reg_addr, 
                                                    TFT_iic_reg_data}      : 
                                                   {32'b0};
        end
        
        assign Sl_DCRDBus = (dcr_read_access)? dcr_read_data : DCR_Sl_DBus;
        
     end // end DCR interface ;
      
  endgenerate // end generate     


endmodule


