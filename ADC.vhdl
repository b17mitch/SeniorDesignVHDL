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
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


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

attribute ram_style : string;
attribute ram_style of Bram1 : signal is "block";
attribute ram_style of Bram2 : signal is "block";



signal shift_reg1: std_logic_vector(15 downto 0):= (others => '0');
signal shift_reg2: std_logic_vector(15 downto 0):= (others => '0');

signal Entry_counter: integer range 0 to 20 := 0;
signal CLK_counter: integer range 0 to 244141 :=0;-- i wanted it to take 5 seconds to write
signal wr_ptr : unsigned(10 downto 0) := (others => '0');

signal sclk_internal : std_logic := '0'; --preset low
signal cs_internal   : std_logic := '1';-- preset to off 
signal finished : std_logic := '0'; -- preset to 0
signal Bram_write: std_logic := '0';

TYPE State_type IS (COUNTING, OUTPUT, Done); --going fsm route
SIGNAL State : State_type;

attribute mark_debug: string;
attribute mark_debug of State: signal is "true";

COMPONENT ila_1

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;

begin

your_instance_name : ila_1
PORT MAP (
	clk => clk,
	probe0(0)=>DoutA,
	probe1(0)=>DOutB 
);

ADC_reading1<= DoutA; --connecting ports to wires
ADC_reading2<= DoutB; 

Sclk<=sclk_internal; --clk we are giving to the adc
CS<=cs_internal;-- this port is out so the wire goes to it

process(clk) --pl clk is about 100MHz -- should be 100MHz in constraint
   begin
   if rising_edge(clk) then
   Bram_write<='0';
        case state is
            when COUNTING =>
                if CLK_counter = 30 then --makes it so we get all of our data finished in 5 seconds instead of instantly
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
                shift_reg1(15-Entry_counter)<=ADC_reading1; --11 to 0  is 12
                shift_reg2(15-Entry_counter)<=ADC_reading2; --12 bit adc so waiting for 12 bits to read
                
                if Entry_counter = 15 then
                    Bram_write<='1';
                    state <= Done;
                else
                    Entry_counter <= Entry_counter + 1;
                end if;
            end if;
            when Done =>
                --sclk<='0';--set this low again
                cs_internal<='1'; -- disable cs
                Entry_counter<=0;
                wr_ptr<= wr_ptr+1;--tells us where we are in array
                if wr_ptr=2047 then
                    finished<='1'; -- wont be updated anywhere else so it just ends
                else
                state<=COUNTING;
                end if;
          
        end case;
        if Bram_write='1' then
        Bram1(to_integer(wr_ptr)) <= shift_reg1(11 downto 0); --Bram is temporary volatile
        Bram2(to_integer(wr_ptr))<=shift_reg2(11 downto 0);
         end if;
        end if;
end process;
end Behavioral;
