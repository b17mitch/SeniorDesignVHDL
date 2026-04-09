
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADC_tb is
end ADC_tb;

architecture bench of ADC_tb is
   
    signal clk   : std_logic := '0';
    signal Sclk  : std_logic;
    signal DoutA : std_logic := '0';
    signal DoutB : std_logic := '0';
    signal CS    : std_logic;

begin

    -- Instantiate the ADC
    uut: entity work.ADC 
    port map (
        clk   => clk,
        Sclk  => Sclk,
        DoutA => DoutA,
        DoutB => DoutB,
        CS    => CS
    );

    -- this is 100MHz but can make it shorter to fit the adc
    -- real change happens on the next high so we go through a cycle in the process block
    clk_process : process
    begin
        clk <= '0'; wait for 10 ns;  --this is the clk simulation
        clk <= '1'; wait for 10 ns;
    end process;

    -- Simple Stimulus
    stim_proc: process
    begin		
        -- Test 1: Force everything to '1'
        DoutA <= '1';
        DoutB <= '1';
        
        -- Wait for the state machine to run through one full cycle
        wait until falling_edge(CS); -- Wait for start
        wait until rising_edge(CS);  -- Wait for finish
        
        -- force everyhting to 0
        DoutA <= '0';
        DoutB <= '0';
        
        -- Wait for the second cycle to finish
        wait until falling_edge(CS);
        wait until rising_edge(CS);

        wait; 
    end process;
end bench;
