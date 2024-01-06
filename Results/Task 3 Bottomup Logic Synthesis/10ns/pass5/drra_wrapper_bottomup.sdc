###################################################################

# Created by write_sdc on Sat Jan  6 21:50:58 2024

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
create_clock [get_ports clk]  -period 10  -waveform {0 5}
set_clock_uncertainty -setup 0.65  [get_clocks clk]
set_clock_uncertainty -hold 0.45  [get_clocks clk]
set_false_path   -from [get_ports rst_n]
