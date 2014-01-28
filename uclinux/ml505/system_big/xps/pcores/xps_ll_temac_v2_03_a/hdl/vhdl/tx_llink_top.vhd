------------------------------------------------------------------------------
-- $Id: tx_llink_top.vhd,v 1.1.4.39 2009/11/17 07:11:35 tomaik Exp $
------------------------------------------------------------------------------
-- tx_llink_top.vhd
------------------------------------------------------------------------------
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
------------------------------------------------------------------------------
-- Filename:        tx_llink_top.vhd
-- Version:         v2.00a
-- Description:     This is the transmit interface between LL and the hard
--                  Temac.
--
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--            -- xps_ll_temac.vhd
--               -- soft_temac_wrap.vhd
--               -- v4_temac_wrap.vhd
--               -- v5_temac_wrap.vhd
--               -- tx_llink_top.vhd           ******
--                  -- tx_temac_if.vhd
--                     -- tx_temac_if_sm.vhd
--                     -- tx_csum_mux.vhd
--                     -- tx_data_mux.vhd
--                     -- tx_cl_if.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:      DRP
-- History:
--  DRP      2006.05.02      -- First version
--
--  <initials>      <date>
-- ^^^^^^
--      Description of changes. If multiple lines are needed to fully describe
--      the changes made to the design, these lines should align with each other.
-- ~~~~~~
--
--  <initials>      <date>
-- ^^^^^^
--      More changes
-- ~~~~~~
--
-- MW    09/09/2008
--       -- Fixed CSUM offload build.  Broke it with the addition of VLAN.
--       -- Moved PIPE_DELAY_LL from this module to this tx_ll_if
--       -- Other changes for VLAN support       
--
-- MW    09/23/2008 
--       -- Modified txFIFO2IP_aFull_cmb behavior to model the behavior of almost 
--          full with the legacy 'sync_fifo'.  
--          -  With sync_fifo, when the fifo was full, data_count="1111111111"; 
--             however, with the switch to sync_fifo_fg, when the fifo is full the
--             data count = "0000000000.  As a result, txFIFO2IP_aFull_cmb would 
--             clear prematurely.  Fix uses the txFIFO2LL_Full flag in conjunction 
--             with the legacy txFIFO2IP_aFull_cmb logic. 
--
--
--
------------------------------------------------------------------------------
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
--      internal version of : out   std_logic; port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.conv_integer;

library proc_common_v3_00_a;
use proc_common_v3_00_a.coregen_comp_defs.all;
use proc_common_v3_00_a.proc_common_pkg.log2;

-- synopsys translate_off
library XilinxCoreLib;
-- synopsys translate_on

library xps_ll_temac_v2_03_a;
use xps_ll_temac_v2_03_a.all;

library unisim;
use unisim.vcomponents.all;

------------------------------------------------------------------------------
-- Port Declaration
------------------------------------------------------------------------------

entity tx_llink_top is
   generic(
      C_FAMILY            : string               := "virtex5";
      C_RESET_ACTIVE      : std_logic            :=       '1';
      C_TEMAC_TXCSUM      : integer              :=         0;
      C_CLIENT_DWIDTH     : integer              :=         8;
      C_TEMAC_TXFIFO      : integer              :=      4096;
      C_TEMAC_TYPE        : integer range 0 to 3 :=         0;
      C_TEMAC_TXVLAN_TRAN : integer              := 0;
      C_TEMAC_TXVLAN_TAG  : integer              := 0;
      C_TEMAC_TXVLAN_STRP : integer              := 0;
      C_TEMAC_STATS       : integer              := 0
      );

   port(
      LLTemac_Clk             : in  std_logic;
      LLTemac_Rst             : in  std_logic;
      LLTemac_Data            : in  std_logic_vector(0 to 31);
      LLTemac_SOF_n           : in  std_logic;
      LLTemac_SOP_n           : in  std_logic;
      LLTemac_EOF_n           : in  std_logic;
      LLTemac_EOP_n           : in  std_logic;
      LLTemac_SRC_RDY_n       : in  std_logic;
      LLTemac_REM             : in  std_logic_vector(0 to 3);
      LLTemac_DST_RDY_n       : out std_logic;

      TXFIFO_Und_Intr         : out std_logic;

      Tx2ClientPauseReq       : in  std_logic;
      ClientEmacPauseReq      : out std_logic;

      Tx_cmplt                : out std_logic;

      Tx_Cl_Clk               : in  std_logic;
      ClientEmacTxd           : out std_logic_vector(7 downto 0);
      ClientEmacTxdVld        : out std_logic;
      ClientEmacTxdVldMsw     : out std_logic;
      ClientEmacTxFirstByte   : out std_logic;
      ClientEmacTxUnderRun    : out std_logic;
      EmacClientTxAck         : in  std_logic;
      EmacClientTxCollision   : in  std_logic;
      EmacClientTxRetransmit  : in  std_logic;
      EmacClientTxCE          : in  std_logic;
      Tx2ClientUnderRunIntrpt : out std_logic;
      TtagRegData             : in  std_logic_vector(0 to 31);
      Tpid0RegData            : in  std_logic_vector(0 to 31);
      Tpid1RegData            : in  std_logic_vector(0 to 31);

      LlinkClkAddr            : out std_logic_vector(0 to 11);
      LlinkClkRdData          : in  std_logic_vector(18 to 31);

      LlinkClkTxVlanBramEnA   : out std_logic;

      LlinkClkNewFncEnbl      : in  std_logic;
      LlinkClkTxVStrpMode     : in  std_logic_vector(0 to 1);
      LlinkClkTxVTagMode      : in  std_logic_vector(0 to 1)
      );

end tx_llink_top;

------------------------------------------------------------------------------
-- Definition of Generics:
--
-- Definition of Ports:
--
------------------------------------------------------------------------------

architecture beh of tx_llink_top is

attribute KEEP : string;
attribute KEEP of Tx_Cl_Clk : signal is "TRUE";

------------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------------

constant FIFO_DEPTH_LOG2X : integer := 13;

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

signal lL2CSFIFO_data         : std_logic_vector(0 to 35);
signal lL2CSFIFO_wren         : std_logic;
signal lL2CSFIFO_wren_dly1    : std_logic;
signal cSFIFO2LL_Full         : std_logic;
signal iP2CSFIFO_RdReq        : std_logic;
signal cSFIFO2IP_Empty        : std_logic;
signal cSFIFO2IP_Und          : std_logic;
signal cSFIFO2IP_Ovr          : std_logic;
signal cSFIFO2IP_Data         : std_logic_vector(0 to 35);
signal txFIFO2IP_RdAck        : std_logic;
signal lL2TXFIFO_Data         : std_logic_vector(0 to 35);
signal lL2TXFIFO_Wren         : std_logic;
signal ip2TXFIFO_RdReq        : std_logic;
signal txFIFO2IP_Data         : std_logic_vector(0 to 35);
signal txFIFO2LL_Full         : std_logic;
signal txFIFO2IP_Empty        : std_logic;
signal txFIFO2IP_Und          : std_logic;
signal txFIFO2IP_Ovr          : std_logic;
signal txFIFO2IP_aFull        : std_logic;
signal csum_ready             : std_logic;
signal lLTemac_DST_RDY_n_i    : std_logic;

signal clientEmacTxd_i         : std_logic_vector(7 downto 0);
signal clientEmacTxdVld_i      : std_logic;
signal clientEmacTxdVldMsw_i   : std_logic;
signal clientEmacTxFirstByte_i : std_logic;
signal clientEmacTxUnderRun_i  : std_logic;
signal tx_cmplt_i              : std_logic;
signal clientEmacPauseReq_i    : std_logic;
signal t_sM_encoded            : std_logic_vector(0 to 2);
--signal sig_data_count          : std_logic_vector(log2(C_TEMAC_TXFIFO/4)-1 downto 0);
signal sig_data_count          : std_logic_vector(log2(C_TEMAC_TXFIFO/4) downto 0);

signal txFIFO2IP_aFull_cmb     : std_logic;
signal csfifo2ll_full_reg      : std_logic;

signal LLTemac_EOP_dly_n1      : std_logic;
signal LLTemac_SRC_RDY_dly_n1  : std_logic;
signal LLTemac_DST_RDY_dly_n1  : std_logic;

signal force_dest_rdy_high     : std_logic;
 

begin

------------------------------------------------------------------------------
-- Concurrent Signal Assignments
------------------------------------------------------------------------------

ClientEmacTxd        <= clientEmacTxd_i;
ClientEmacTxdVld     <= clientEmacTxdVld_i;
ClientEmacTxdVldMsw  <= clientEmacTxdVldMsw_i;
ClientEmacTxFirstByte <= clientEmacTxFirstByte_i;
ClientEmacTxUnderRun <= clientEmacTxUnderRun_i;
Tx_cmplt             <= tx_cmplt_i;
ClientEmacPauseReq      <= clientEmacPauseReq_i;

cSFIFO2IP_Und <= cSFIFO2IP_Empty and iP2CSFIFO_RdReq;
cSFIFO2IP_Ovr <= cSFIFO2LL_Full and lL2CSFIFO_wren;
txFIFO2IP_Und <= txFIFO2IP_Empty and iP2TXFIFO_RdReq;
txFIFO2IP_Ovr <= txFIFO2LL_Full and lL2TXFIFO_Wren;
lLTemac_DST_RDY_n_i <= cSFIFO2LL_Full_reg or txFIFO2LL_Full or txFIFO2IP_aFull or not csum_ready or force_dest_rdy_high;
LLTemac_DST_RDY_n <= lLTemac_DST_RDY_n_i;



I_TX_LL_IF : entity xps_ll_temac_v2_03_a.tx_ll_if
   generic map(
      C_FAMILY             => C_FAMILY,                           
      C_TEMAC_TXCSUM       => C_TEMAC_TXCSUM,                     
      C_FIFO_DEPTH_LOG2X   => FIFO_DEPTH_LOG2X,                   
      C_TEMAC_TXVLAN_TRAN  => C_TEMAC_TXVLAN_TRAN,                
      C_TEMAC_TXVLAN_TAG   => C_TEMAC_TXVLAN_TAG,                 
      C_TEMAC_TXVLAN_STRP  => C_TEMAC_TXVLAN_STRP                 
                                                                  
      )                                                           
   port map(                                                      
      LLTemac_Clk             => LLTemac_Clk,             -- in      
      LLTemac_Rst             => LLTemac_Rst,             -- in      
                                                                  
      LLTemac_Data_inc        => LLTemac_Data,            -- in        
      LLTemac_SOF_n_inc       => LLTemac_SOF_n,           -- in        
      LLTemac_SOP_n_inc       => LLTemac_SOP_n,           -- in        
      LLTemac_EOF_n_inc       => LLTemac_EOF_n,           -- in        
      LLTemac_EOP_n_inc       => LLTemac_EOP_n,           -- in        
      LLTemac_SRC_RDY_n_inc   => LLTemac_SRC_RDY_n,       -- in        
      LLTemac_REM_inc         => LLTemac_REM,             -- in       
      lLTemac_DST_RDY_n_inc   => lLTemac_DST_RDY_n_i,     -- in       
                                                                  
      LLTemac_SRC_RDY_dly_n1  => LLTemac_SRC_RDY_dly_n1,  -- out        
      LLTemac_DST_RDY_dly_n1  => LLTemac_DST_RDY_dly_n1,  -- out        
      LLTemac_EOP_dly_n1      => LLTemac_EOP_dly_n1,      -- out   
      
      force_dest_rdy_high     => force_dest_rdy_high,
                                                                      
      CSFIFO2LL_Full          => cSFIFO2LL_Full,          -- in   
      lL2CSFIFO_wren          => lL2CSFIFO_wren,          -- out  
      lL2CSFIFO_data          => lL2CSFIFO_data,          -- out  
                                                                  
      TXFIFO2LL_Full          => txFIFO2LL_Full,          -- in   
      txFIFO2IP_aFull         => txFIFO2IP_aFull,                 
      lL2TXFIFO_Data          => lL2TXFIFO_Data,          -- out  
      lL2TXFIFO_Wren          => lL2TXFIFO_Wren,          -- out  
      Csum_Ready              => csum_ready,              -- in   
                                                                  
      -- VLAN Support signals                                     
      TtagRegData             => TtagRegData,             -- in                                         
      Tpid0RegData            => Tpid0RegData,            -- in                                         
      Tpid1RegData            => Tpid1RegData,            -- in        
                                             
      LlinkClkAddr            => LlinkClkAddr,            -- out                                                                                                   
      LlinkClkRdData          => LlinkClkRdData,          -- in                                           
                              --    Bit         Bit         Bit   
                              -- 18 - 29        30          31                                     
                              --    VID      Strip En    Tag En   
      LlinkClkTxVlanBramEnA   => LlinkClkTxVlanBramEnA,    -- out 
                                                                                         
      LlinkClkNewFncEnbl      => LlinkClkNewFncEnbl,      -- in                                         
      LlinkClkTxVStrpMode     => LlinkClkTxVStrpMode,     -- in                                         
      LlinkClkTxVTagMode      => LlinkClkTxVTagMode       -- in                                         
      );                                                                                                                                                                            
                                                                                                                                                                                                                                            
     
   I_TX_CSUM_FIFO : entity proc_common_v3_00_a.sync_fifo_fg
      generic map (
         C_FAMILY             => C_FAMILY,                 --:    String  := "virtex5"; -- new for FIFO Gen
         C_DCOUNT_WIDTH       => (log2(C_TEMAC_TXFIFO/64)+1),                       --:    integer := 4 ;
         C_ENABLE_RLOCS       => 0,                        --:    integer := 0 ; -- not supported in sync fifo
         C_HAS_DCOUNT         => 0,                        --:    integer := 1 ;
         C_HAS_RD_ACK         => 1,                        --:    integer := 0 ;
         C_HAS_RD_ERR         => 0,                        --:    integer := 0 ;
         C_HAS_WR_ACK         => 0,                        --:    integer := 0 ;
         C_HAS_WR_ERR         => 0,                        --:    integer := 0 ;
         C_MEMORY_TYPE        => 1,                        --:    integer := 0 ;  -- 0 = distributed RAM, 1 = BRAM
         C_PORTS_DIFFER       => 0,                        --:    integer := 0 ;  
         C_RD_ACK_LOW         => 0,                        --:    integer := 0 ;
         C_READ_DATA_WIDTH    => 36,                       --:    integer := 16;
         C_READ_DEPTH         => (C_TEMAC_TXFIFO/64),      --:    integer := 16;
         C_RD_ERR_LOW         => 0,                        --:    integer := 0 ;
         C_WR_ACK_LOW         => 0,                        --:    integer := 0 ;
         C_WR_ERR_LOW         => 0,                        --:    integer := 0 ;
         C_WRITE_DATA_WIDTH   => 36,                       --:    integer := 16;
         C_WRITE_DEPTH        => (C_TEMAC_TXFIFO/64)       --:    integer := 16
         )
      port map (
         Clk          => LLTemac_Clk,      --: in  std_logic;
         Sinit        => LLTemac_Rst,      --: in  std_logic;
         Din          => lL2CSFIFO_data,   --: in  std_logic_vector(C_WRITE_DATA_WIDTH-1 downto 0);
         Wr_en        => lL2CSFIFO_wren,   --: in  std_logic;
         Rd_en        => iP2CSFIFO_RdReq,  --: in  std_logic;
         Dout         => cSFIFO2IP_Data,   --: out std_logic_vector(C_READ_DATA_WIDTH-1 downto 0);
         Full         => cSFIFO2LL_full,   --: out std_logic;
         Empty        => cSFIFO2IP_Empty,  --: out std_logic;
         Rd_ack       => txFIFO2IP_RdAck,  --: out std_logic;
         Wr_ack       => open,             --: out std_logic;
         Rd_err       => open,             --: out std_logic;
         Wr_err       => open,             --: out std_logic;
         Data_count   => open              --: out std_logic_vector(C_DCOUNT_WIDTH-1 downto 0)
         );
     
     
   I_TX_FIFO : entity proc_common_v3_00_a.sync_fifo_fg
      generic map (
         C_FAMILY             => C_FAMILY,                 --:    String  := "virtex5"; -- new for FIFO Gen
         C_DCOUNT_WIDTH       => (log2(C_TEMAC_TXFIFO/4)+1),                       --:    integer := 4 ;
         C_ENABLE_RLOCS       => 0,                        --:    integer := 0 ; -- not supported in sync fifo
         C_HAS_DCOUNT         => 1,                        --:    integer := 1 ;
         C_HAS_RD_ACK         => 0,                        --:    integer := 0 ;
         C_HAS_RD_ERR         => 0,                        --:    integer := 0 ;
         C_HAS_WR_ACK         => 0,                        --:    integer := 0 ;
         C_HAS_WR_ERR         => 0,                        --:    integer := 0 ;
         C_MEMORY_TYPE        => 1,                        --:    integer := 0 ;  -- 0 = distributed RAM, 1 = BRAM
         C_PORTS_DIFFER       => 0,                        --:    integer := 0 ;  
         C_RD_ACK_LOW         => 0,                        --:    integer := 0 ;
         C_READ_DATA_WIDTH    => 36,                       --:    integer := 16;
         C_READ_DEPTH         => (C_TEMAC_TXFIFO/4),       --:    integer := 16;
         C_RD_ERR_LOW         => 0,                        --:    integer := 0 ;
         C_WR_ACK_LOW         => 0,                        --:    integer := 0 ;
         C_WR_ERR_LOW         => 0,                        --:    integer := 0 ;
         C_WRITE_DATA_WIDTH   => 36,                       --:    integer := 16;
         C_WRITE_DEPTH        => (C_TEMAC_TXFIFO/4)        --:    integer := 16
         )
      port map (
         Clk          => LLTemac_Clk,      --: in  std_logic;
         Sinit        => LLTemac_Rst,      --: in  std_logic;
         Din          => lL2TXFIFO_Data,   --: in  std_logic_vector(C_WRITE_DATA_WIDTH-1 downto 0);
         Wr_en        => lL2TXFIFO_Wren,   --: in  std_logic;
         Rd_en        => ip2TXFIFO_RdReq,  --: in  std_logic;
         Dout         => txFIFO2IP_Data,   --: out std_logic_vector(C_READ_DATA_WIDTH-1 downto 0);
         Full         => txFIFO2LL_Full,   --: out std_logic;
         Empty        => txFIFO2IP_Empty,  --: out std_logic;
         Rd_ack       => open,             --: out std_logic;
         Wr_ack       => open,             --: out std_logic;
         Rd_err       => open,             --: out std_logic;
         Wr_err       => open,             --: out std_logic;
         Data_count   => sig_data_count    --: out std_logic_vector(C_DCOUNT_WIDTH-1 downto 0)
         );


--GAB 10/19/07 modified to fix timing path
--txFIFO2IP_aFull <= '1' when conv_integer(sig_data_count)>(C_TEMAC_TXFIFO/4)-2 else '0';

--MW 09/08/2008 Modified to model behavior of almost full with sync_fifo.  
-- -With sync_fifo, when the fifo was full, data_count="1111111111"; 
--  however with the switch to sync_fifo_fg, the fifo is full when data count = "0000000000.
--  So txFIFO2IP_aFull_cmb would clear prematurely
txFIFO2IP_aFull_cmb <= '1' when conv_integer(sig_data_count)>(C_TEMAC_TXFIFO/4)-3 or txFIFO2LL_Full = '1' else '0';

REG_AFULL : process(LLTemac_Clk)
    begin
        if(LLTemac_clk'EVENT and LLTemac_Clk='1')then
            if(LLTemac_Rst='1')then
                txFIFO2IP_aFull <= '0';
                csfifo2ll_full_reg <= '0';
                lL2CSFIFO_wren_dly1 <='0';
            else
                txFIFO2IP_aFull <= txFIFO2IP_aFull_cmb;
                csfifo2ll_full_reg <= csfifo2ll_full;
                lL2CSFIFO_wren_dly1 <= ll2csfifo_wren;
            end if;
        end if;
    end process REG_AFULL;



I_TX_TEMAC_IF : entity xps_ll_temac_v2_03_a.tx_temac_if 
   generic map(
      C_FAMILY                => C_FAMILY,
      C_RESET_ACTIVE          => C_RESET_ACTIVE,
      C_CLIENT_DWIDTH         => C_CLIENT_DWIDTH,
      C_TEMAC_TYPE            => C_TEMAC_TYPE
      )

   port map(
      LLTemac_Clk             => LLTemac_Clk,            -- in
      LLTemac_Rst             => LLTemac_Rst,            -- in

      IP2TXFIFO_RdReq         => ip2TXFIFO_RdReq,        -- out
      TXFIFO2IP_Data          => txFIFO2IP_Data,         -- in
      TXFIFO2IP_RdAck         => txFIFO2IP_RdAck,        -- in
      TXFIFO2IP_Empty         => txFIFO2IP_Empty,        -- in
      TXFIFO2IP_Und           => txFIFO2IP_Und,          -- in
      TXFIFO2IP_Ovr           => txFIFO2IP_Ovr,          -- in

      TXFIFO_Und_Intr         => TXFIFO_Und_Intr,        -- out

      CSFIFO2IP_Ovr           => cSFIFO2IP_Ovr,          -- in
      CSFIFO2IP_Und           => cSFIFO2IP_Und,          -- in
      CSFIFO2IP_Empty         => cSFIFO2IP_Empty,        -- in
      CSFIFO2IP_Data          => cSFIFO2IP_Data,         -- in
      IP2CSFIFO_RdReq         => iP2CSFIFO_RdReq,        -- out

      Tx2ClientPauseReq       => Tx2ClientPauseReq,      -- in
      ClientEmacPauseReq      => clientEmacPauseReq_i,   -- out

      Tx_cmplt                => tx_cmplt_i,             -- out
      Tx_Cl_Clk               => Tx_Cl_Clk,              -- in
      ClientEmacTxd           => clientEmacTxd_i,        -- out
      ClientEmacTxdVld        => clientEmacTxdVld_i,     -- out
      ClientEmacTxdVldMsw     => clientEmacTxdVldMsw_i,  -- out
      ClientEmacTxFirstByte   => clientEmacTxFirstByte_i,-- out
      ClientEmacTxUnderRun    => clientEmacTxUnderRun_i, -- out
      EmacClientTxAck         => EmacClientTxAck,        -- in
      EmacClientTxCollision   => EmacClientTxCollision,  -- in
      EmacClientTxRetransmit  => EmacClientTxRetransmit, -- in
      EmacClientTxCE          => EmacClientTxCE,         -- in
      Tx2ClientUnderRunIntrpt => Tx2ClientUnderRunIntrpt -- out
      );

------------------------------------------------------------------------------
-- This process throttles the locallink while the csum is being calculated
------------------------------------------------------------------------------
CSUM_CALC_THROTTLE : process(LLTemac_Clk)
   begin
      if(rising_edge(LLTemac_Clk)) then
         if(LLTemac_Rst='1' or lL2CSFIFO_wren_dly1='1') then
            csum_ready <= '1';
         elsif(LLTemac_EOP_dly_n1='0' and
            LLTemac_SRC_RDY_dly_n1='0' and
            LLTemac_DST_RDY_dly_n1='0') then
            csum_ready <= '0';
         end if;
      end if;
   end process;

end beh;
