set_property IOSTANDARD LVCMOS25 [get_ports clk]
set_property PACKAGE_PIN Y9 [get_ports clk]

set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS25} [get_ports {rst_n}]


set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS25} [get_ports {red[0]}]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS25} [get_ports {red[1]}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS25} [get_ports {red[2]}]
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS25} [get_ports {red[3]}]

set_property -dict {PACKAGE_PIN AB4 IOSTANDARD LVCMOS25} [get_ports {green[0]}]
set_property -dict {PACKAGE_PIN AB7 IOSTANDARD LVCMOS25} [get_ports {green[1]}]
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS25} [get_ports {green[2]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS25} [get_ports {green[3]}]

set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS25} [get_ports {blue[0]}]
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS25} [get_ports {blue[1]}]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS25} [get_ports {blue[2]}]
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS25} [get_ports {blue[3]}]


set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS25} [get_ports {vsync}]
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS25} [get_ports {hsync}]