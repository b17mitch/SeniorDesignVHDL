# SeniorDesignVHDL
Kria260 fpga board VHDL code <br>
3/17/26
##  Files: 
-Initial testing is being done in the ADC.vhdl file and constraints file on this Github page
## Implementation: 
-Using two Bram (block ram registers) of 2048 bits,  i'm making it easier on myself to read values via the ILA after bitstream is flashed.<br>
-Instead of using ps clk for the adc im splitting the clk by only allowing writes every ~200000 clk cycles so that i can record data over time and see it in the ILA instead of have it filled instantly.<br>
-This implementation uses an FSM to count 12 inputs ( 12-bit ADC), but each wire/ signal is one bit so i must wait til 12 bits are collected for a low to high transtion for the adc and chip select to be on (CS=0).<br>
-Program writes ends when 2048 entries are filled into each Bram.
