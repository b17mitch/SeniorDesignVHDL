

set_property PACKAGE_PIN K12 [get_ports Sclk]
set_property PACKAGE_PIN J11 [get_ports CS]
set_property PACKAGE_PIN J10 [get_ports DoutA]
set_property PACKAGE_PIN K13 [get_ports DoutB]



set_property IOSTANDARD LVCMOS33 [get_ports CS]
set_property IOSTANDARD LVCMOS33 [get_ports Sclk]
#set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports DoutA]
set_property IOSTANDARD LVCMOS33 [get_ports DoutB]

set_property IOSTANDARD LVCMOS18 [get_ports clk]
set_property PACKAGE_PIN C3 [get_ports clk]
