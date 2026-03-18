----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2026 11:26:15 PM
-- Design Name: 
-- Module Name: ADC - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ADC is
--  Port ( );
port( -- keep these for finite state machine
Sclk: out std_logic;
clk: in std_logic;
DoutA: in std_logic; --two readings from adc
DoutB: in std_logic;
CS: out std_logic --enable
);
end ADC;

architecture Behavioral of ADC is
--constant CLK_RATE: integer := 1000000; --adc msx sample rate per second
signal ADC_reading1: std_logic; --going to read both inputs
signal ADC_reading2: std_logic; --going to read both inputs 
type ram_type is array (0 to 2047) of std_logic_vector(11 downto 0); --bram very tiny ammount
signal Bram1 : ram_type; --want to try no axi solution need to see if it works
signal Bram2: ram_type;

signal shift_reg1: std_logic_vector(11 downto 0):= (others => '0');
signal shift_reg2: std_logic_vector(11 downto 0):= (others => '0');

signal Entry_counter: integer range 0 to 20 := 0;
signal CLK_counter: integer range 0 to 244141 :=0;-- i wanted it to take 5 seconds to write
signal wr_ptr : unsigned(10 downto 0) := (others => '0');
signal finished: std_logic;

signal sclk_internal : std_logic := '0'; --preset low
signal cs_internal   : std_logic := '1';-- preset to off 

TYPE State_type IS (COUNTING, OUTPUT, Done); --going fsm route
SIGNAL State : State_type;


begin
ADC_reading1<= DoutA; --connecting ports to wires
ADC_reading2<= DoutB; 

Sclk<=sclk_internal; --clk we are giving to the adc
CS<=cs_internal;-- this port is out so the wire goes to it

process(clk) --pl clk is about 100MHz -- should be 100MHz in constraint
   begin
   if rising_edge(clk) then
        case state is
        
            when COUNTING =>
                if CLK_counter = 244141 then --makes it so we get all of our data finished in 5 seconds instead of instantly
                    CLK_counter <= 0;
                    cs_internal<='0'; --now adc should be accepting data when chip select is low
                    state <= OUTPUT; --goes to output state
                else
                    CLK_counter <= CLK_counter + 1;
                end if;

            when OUTPUT =>
                if sclk_internal='1' then
                    sclk_internal<='0';
                else
                sclk_internal<='1';
                shift_reg1(11-Entry_counter)<=ADC_reading1; --11 to 0  is 12
                shift_reg2(11-Entry_counter)<=ADC_reading2; --12 bit adc so waiting for 12 bits to read
                
                if Entry_counter = 11 and Finished /= '1' then
                    Bram1(to_integer(wr_ptr)) <= shift_reg1; --Bram is temporary volatile
                    Bram2(to_integer(wr_ptr))<=shift_reg2;
                    wr_ptr<= wr_ptr+1;--tells us where we are in array
                    state <= Done;
                else
                    Entry_counter <= Entry_counter + 1;
                end if;
            end if;
            when Done =>
                --sclk<='0';--set this low again
                cs_internal<='1'; -- disable cs
                if wr_ptr=2048 then
                    finished<='1'; -- wont be updated anywhere else so it just ends
                else
                state<=COUNTING;
                end if;
          
        end case;
        end if;
end process;
end Behavioral;
