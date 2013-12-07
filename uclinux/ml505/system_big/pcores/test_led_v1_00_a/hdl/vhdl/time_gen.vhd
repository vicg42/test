-------------------------------------------------------------------------
-- Company     : Linkos
-- Engineer    : Golovachenko Victor
--
-- Create Date : 10/26/2007
-- Module Name : time_gen
--
-- ����������/�������� :
--   ������������� ������� ���������� ��� ��������� ����������
--
-- Revision:
-- Revision 0.01 - File Created
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.vicg_common_pkg.all;

entity time_gen is
generic
(
G_T05us : integer:=10#1000# -- ���-�� �������� ������� ����� p_in_clk
                            -- �������������� � 1/2 ������� 1us
);
port
(
p_out_en05us : out   std_logic;--//������ ��������� ����������:0.5us, 1us, 1ms, 1sec, 1min
p_out_en1us  : out   std_logic;
p_out_en1ms  : out   std_logic;
p_out_en1sec : out   std_logic;
p_out_en1min : out   std_logic;

-------------------------------
--System
-------------------------------
p_in_clk     : in    std_logic;
p_in_rst     : in    std_logic
);
end time_gen;

architecture behavioral of time_gen is

constant C_Tms                  : integer:=10#1000#;--1ms
constant C_Tsec                 : integer:=10#1000#;--1sec
constant C_Tmin                 : integer:=10#0060#;--1min

signal i_cnt_us                 : std_logic_vector(log2(G_T05us)-1 downto 0);
signal i_cnt_ms                 : std_logic_vector(log2(C_Tms)-1 downto 0);
signal i_cnt_sec                : std_logic_vector(log2(C_Tsec)-1 downto 0);
signal i_cnt_min                : std_logic_vector(log2(C_Tmin)-1 downto 0);
signal i_en05us                 : std_logic;
signal i_en1us                  : std_logic;
signal i_en1ms                  : std_logic;
signal i_en1sec                 : std_logic;
signal i_en1min                 : std_logic;

--MAIN
begin


process(p_in_rst,p_in_clk)
  variable a: std_logic;
begin
  if p_in_clk'event and p_in_clk='1' then
    if p_in_rst='1' then

    i_cnt_us<=(others=>'0');
    i_cnt_ms<=(others=>'0');
    i_cnt_sec<=(others=>'0');
    i_cnt_min<=(others=>'0');

    a:='0';
    i_en05us<='0';
    i_en1us <='0';
    i_en1ms <='0';
    i_en1sec<='0';
    i_en1min<='0';

    elsif i_cnt_us=CONV_STD_LOGIC_VECTOR(G_T05us-1, log2(G_T05us)) then
      i_cnt_us<=(others=>'0');
      i_en05us<='1';
      a:= not a;
      i_en1us<=a;
      if i_en1us='1' then
        if i_cnt_ms=CONV_STD_LOGIC_VECTOR(C_Tms-1, log2(C_Tms)) then
          i_en1ms<='1';
          i_cnt_ms<=(others=>'0');
          if i_cnt_sec=CONV_STD_LOGIC_VECTOR(C_Tsec-1, log2(C_Tsec)) then
            i_en1sec<='1';
            i_cnt_sec<=(others=>'0');
            if i_cnt_min=CONV_STD_LOGIC_VECTOR(C_Tmin-1, log2(C_Tmin)) then
              i_en1min<='1';
              i_cnt_min<=(others=>'0');
            else
              i_en1min<='0';
              i_cnt_min<=i_cnt_min+1;
            end if;
          else
            i_en1sec<='0';
            i_cnt_sec<=i_cnt_sec+1;
          end if;
        else
          i_en1ms<='0';
          i_cnt_ms<=i_cnt_ms+1;
        end if;
      end if;
    else
      i_en05us<='0';
      i_cnt_us<=i_cnt_us+1;
    end if;
  end if;
end process;

--�������� �����
--process(p_in_rst,p_in_clk)
--begin
--  if p_in_clk'event and p_in_clk='1' then
  p_out_en05us <= i_en05us;
  p_out_en1us  <= i_en1us and i_en05us;
  p_out_en1ms  <= i_en1ms and i_en1us and i_en05us;
  p_out_en1sec <= i_en1sec and i_en1ms and i_en1us and i_en05us;
  p_out_en1min <= i_en1min and i_en1sec and i_en1ms and i_en1us and i_en05us;
--  end if;
--end process;

--END MAIN
end Behavioral;
