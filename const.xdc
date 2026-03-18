#  for 100MHz clock
create_clock -period 10.000 -name pl_clk0 [get_ports clk]
# Example for KR260 Pmod J1 (Check your specific schematic/manual for Site IDs)
set_property PACKAGE_PIN H12 [get_ports Sclk] #output
set_property PACKAGE_PIN J12 [get_ports CS] #output
set_property PACKAGE_PIN H11 [get_ports DoutA] #input
set_property PACKAGE_PIN J11 [get_ports DoutB] #input

# clk mapped to internal ps clk
set_property PACKAGE_PIN G11 [get_ports clk] #took this mappping from gpt because it was tedious
