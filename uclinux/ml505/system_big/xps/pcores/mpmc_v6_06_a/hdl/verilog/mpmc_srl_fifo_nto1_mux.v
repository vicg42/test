//-----------------------------------------------------------------------------
//-- (c) Copyright 2006 - 2009 Xilinx, Inc. All rights reserved.
//--
//-- This file contains confidential and proprietary information
//-- of Xilinx, Inc. and is protected under U.S. and
//-- international copyright and other intellectual property
//-- laws.
//--
//-- DISCLAIMER
//-- This disclaimer is not a license and does not grant any
//-- rights to the materials distributed herewith. Except as
//-- otherwise provided in a valid license issued to you by
//-- Xilinx, and to the maximum extent permitted by applicable
//-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//-- (2) Xilinx shall not be liable (whether in contract or tort,
//-- including negligence, or under any other theory of
//-- liability) for any loss or damage of any kind or nature
//-- related to, arising under or in connection with these
//-- materials, including for any direct, or any indirect,
//-- special, incidental, or consequential loss or damage
//-- (including loss of data, profits, goodwill, or any type of
//-- loss or damage suffered as a result of any action brought
//-- by a third party) even if such damage or loss was
//-- reasonably foreseeable or Xilinx had been advised of the
//-- possibility of the same.
//--
//-- CRITICAL APPLICATIONS
//-- Xilinx products are not designed or intended to be fail-
//-- safe, or for use in any application requiring fail-safe
//-- performance, such as life-support or safety devices or
//-- systems, Class III medical devices, nuclear facilities,
//-- applications related to the deployment of airbags, or any
//-- other applications that could lead to death, personal
//-- injury, or severe property or environmental damage
//-- (individually and collectively, "Critical
//-- Applications"). Customer assumes the sole risk and
//-- liability of any use of Xilinx products in Critical
//-- Applications, subject only to applicable laws and
//-- regulations governing limitations on product liability.
//--
//-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//-- PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
// MPMC Data Path
//-------------------------------------------------------------------------

// Description:    
//   Data Path for MPMC
//
// Structure:
//   mpmc_data_path
//     mpmc_write_fifo
//       mpmc_bram_fifo
//         mpmc_ramb16_sx_sx
//       mpmc_srl_fifo
//     mpmc_read_fifo
//       mpmc_bram_fifo
//         mpmc_ramb16_sx_sx
//       mpmc_srl_fifo
//     
//--------------------------------------------------------------------------
//
// History:
//   06/15/2007 Initial Version
//
//--------------------------------------------------------------------------
`timescale 1ns/1ps

module mpmc_srl_fifo_nto1_mux #
  (
   parameter C_RATIO         = 2,
   parameter C_SEL_WIDTH     = 1,
   parameter C_DATAOUT_WIDTH = 64
   )
  (
   input      [C_SEL_WIDTH-1:0]             Sel,
   input      [C_RATIO*C_DATAOUT_WIDTH-1:0] In,
   output reg [C_DATAOUT_WIDTH-1:0]         Out
   );
  generate
    if          (C_RATIO ==  1) begin : gen_1to1
      always @(*) Out <= In;
    end else if (C_RATIO ==  2) begin : gen_2to1
      always @(*) begin
        case (Sel)
          0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
          1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO ==  3) begin : gen_3to1
      always @(*) begin
        case (Sel)
          0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
          1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
          2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO ==  4) begin : gen_4to1
      always @(*) begin
        case (Sel)
          0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
          1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
          2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
          3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO ==  5) begin : gen_5to1
      always @(*) begin
        case (Sel)
          0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
          1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
          2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
          3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
          4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO ==  6) begin : gen_6to1
      always @(*) begin
        case (Sel)
          0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
          1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
          2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
          3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
          4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
          5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO ==  7) begin : gen_7to1
      always @(*) begin
        case (Sel)
          0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
          1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
          2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
          3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
          4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
          5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
          6: Out <= In[C_DATAOUT_WIDTH*7-1:C_DATAOUT_WIDTH*6];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO ==  8) begin : gen_8to1
      always @(*) begin
        case (Sel)
          0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
          1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
          2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
          3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
          4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
          5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
          6: Out <= In[C_DATAOUT_WIDTH*7-1:C_DATAOUT_WIDTH*6];
          7: Out <= In[C_DATAOUT_WIDTH*8-1:C_DATAOUT_WIDTH*7];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO == 9) begin : gen_9to1
      always @(*) begin
        case (Sel)
           0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
           1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
           2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
           3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
           4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
           5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
           6: Out <= In[C_DATAOUT_WIDTH*7-1:C_DATAOUT_WIDTH*6];
           7: Out <= In[C_DATAOUT_WIDTH*8-1:C_DATAOUT_WIDTH*7];
           8: Out <= In[C_DATAOUT_WIDTH*9-1:C_DATAOUT_WIDTH*8];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO == 10) begin : gen_10to1
      always @(*) begin
        case (Sel)
           0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
           1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
           2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
           3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
           4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
           5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
           6: Out <= In[C_DATAOUT_WIDTH*7-1:C_DATAOUT_WIDTH*6];
           7: Out <= In[C_DATAOUT_WIDTH*8-1:C_DATAOUT_WIDTH*7];
           8: Out <= In[C_DATAOUT_WIDTH*9-1:C_DATAOUT_WIDTH*8];
           9: Out <= In[C_DATAOUT_WIDTH*10-1:C_DATAOUT_WIDTH*9];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO == 11) begin : gen_11to1
      always @(*) begin
        case (Sel)
           0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
           1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
           2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
           3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
           4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
           5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
           6: Out <= In[C_DATAOUT_WIDTH*7-1:C_DATAOUT_WIDTH*6];
           7: Out <= In[C_DATAOUT_WIDTH*8-1:C_DATAOUT_WIDTH*7];
           8: Out <= In[C_DATAOUT_WIDTH*9-1:C_DATAOUT_WIDTH*8];
           9: Out <= In[C_DATAOUT_WIDTH*10-1:C_DATAOUT_WIDTH*9];
          10: Out <= In[C_DATAOUT_WIDTH*11-1:C_DATAOUT_WIDTH*10];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO == 12) begin : gen_12to1
      always @(*) begin
        case (Sel)
           0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
           1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
           2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
           3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
           4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
           5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
           6: Out <= In[C_DATAOUT_WIDTH*7-1:C_DATAOUT_WIDTH*6];
           7: Out <= In[C_DATAOUT_WIDTH*8-1:C_DATAOUT_WIDTH*7];
           8: Out <= In[C_DATAOUT_WIDTH*9-1:C_DATAOUT_WIDTH*8];
           9: Out <= In[C_DATAOUT_WIDTH*10-1:C_DATAOUT_WIDTH*9];
          10: Out <= In[C_DATAOUT_WIDTH*11-1:C_DATAOUT_WIDTH*10];
          11: Out <= In[C_DATAOUT_WIDTH*12-1:C_DATAOUT_WIDTH*11];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO == 13) begin : gen_13to1
      always @(*) begin
        case (Sel)
           0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
           1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
           2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
           3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
           4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
           5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
           6: Out <= In[C_DATAOUT_WIDTH*7-1:C_DATAOUT_WIDTH*6];
           7: Out <= In[C_DATAOUT_WIDTH*8-1:C_DATAOUT_WIDTH*7];
           8: Out <= In[C_DATAOUT_WIDTH*9-1:C_DATAOUT_WIDTH*8];
           9: Out <= In[C_DATAOUT_WIDTH*10-1:C_DATAOUT_WIDTH*9];
          10: Out <= In[C_DATAOUT_WIDTH*11-1:C_DATAOUT_WIDTH*10];
          11: Out <= In[C_DATAOUT_WIDTH*12-1:C_DATAOUT_WIDTH*11];
          12: Out <= In[C_DATAOUT_WIDTH*13-1:C_DATAOUT_WIDTH*12];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO == 14) begin : gen_14to1
      always @(*) begin
        case (Sel)
           0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
           1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
           2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
           3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
           4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
           5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
           6: Out <= In[C_DATAOUT_WIDTH*7-1:C_DATAOUT_WIDTH*6];
           7: Out <= In[C_DATAOUT_WIDTH*8-1:C_DATAOUT_WIDTH*7];
           8: Out <= In[C_DATAOUT_WIDTH*9-1:C_DATAOUT_WIDTH*8];
           9: Out <= In[C_DATAOUT_WIDTH*10-1:C_DATAOUT_WIDTH*9];
          10: Out <= In[C_DATAOUT_WIDTH*11-1:C_DATAOUT_WIDTH*10];
          11: Out <= In[C_DATAOUT_WIDTH*12-1:C_DATAOUT_WIDTH*11];
          12: Out <= In[C_DATAOUT_WIDTH*13-1:C_DATAOUT_WIDTH*12];
          13: Out <= In[C_DATAOUT_WIDTH*14-1:C_DATAOUT_WIDTH*13];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO == 15) begin : gen_15to1
      always @(*) begin
        case (Sel)
           0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
           1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
           2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
           3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
           4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
           5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
           6: Out <= In[C_DATAOUT_WIDTH*7-1:C_DATAOUT_WIDTH*6];
           7: Out <= In[C_DATAOUT_WIDTH*8-1:C_DATAOUT_WIDTH*7];
           8: Out <= In[C_DATAOUT_WIDTH*9-1:C_DATAOUT_WIDTH*8];
           9: Out <= In[C_DATAOUT_WIDTH*10-1:C_DATAOUT_WIDTH*9];
          10: Out <= In[C_DATAOUT_WIDTH*11-1:C_DATAOUT_WIDTH*10];
          11: Out <= In[C_DATAOUT_WIDTH*12-1:C_DATAOUT_WIDTH*11];
          12: Out <= In[C_DATAOUT_WIDTH*13-1:C_DATAOUT_WIDTH*12];
          13: Out <= In[C_DATAOUT_WIDTH*14-1:C_DATAOUT_WIDTH*13];
          14: Out <= In[C_DATAOUT_WIDTH*15-1:C_DATAOUT_WIDTH*14];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end else if (C_RATIO == 16) begin : gen_16to1
      always @(*) begin
        case (Sel)
           0: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
           1: Out <= In[C_DATAOUT_WIDTH*2-1:C_DATAOUT_WIDTH*1];
           2: Out <= In[C_DATAOUT_WIDTH*3-1:C_DATAOUT_WIDTH*2];
           3: Out <= In[C_DATAOUT_WIDTH*4-1:C_DATAOUT_WIDTH*3];
           4: Out <= In[C_DATAOUT_WIDTH*5-1:C_DATAOUT_WIDTH*4];
           5: Out <= In[C_DATAOUT_WIDTH*6-1:C_DATAOUT_WIDTH*5];
           6: Out <= In[C_DATAOUT_WIDTH*7-1:C_DATAOUT_WIDTH*6];
           7: Out <= In[C_DATAOUT_WIDTH*8-1:C_DATAOUT_WIDTH*7];
           8: Out <= In[C_DATAOUT_WIDTH*9-1:C_DATAOUT_WIDTH*8];
           9: Out <= In[C_DATAOUT_WIDTH*10-1:C_DATAOUT_WIDTH*9];
          10: Out <= In[C_DATAOUT_WIDTH*11-1:C_DATAOUT_WIDTH*10];
          11: Out <= In[C_DATAOUT_WIDTH*12-1:C_DATAOUT_WIDTH*11];
          12: Out <= In[C_DATAOUT_WIDTH*13-1:C_DATAOUT_WIDTH*12];
          13: Out <= In[C_DATAOUT_WIDTH*14-1:C_DATAOUT_WIDTH*13];
          14: Out <= In[C_DATAOUT_WIDTH*15-1:C_DATAOUT_WIDTH*14];
          15: Out <= In[C_DATAOUT_WIDTH*16-1:C_DATAOUT_WIDTH*15];
          default: Out <= In[C_DATAOUT_WIDTH*1-1:C_DATAOUT_WIDTH*0];
        endcase
      end
    end
  endgenerate
endmodule // mpmc_srl_fifo_nto1_mux

