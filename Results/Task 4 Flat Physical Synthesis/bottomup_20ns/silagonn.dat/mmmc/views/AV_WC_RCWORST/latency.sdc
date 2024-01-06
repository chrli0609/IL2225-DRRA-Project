set_clock_latency -source -early -max -rise  -0.682334 [get_ports {clk}] -clock clk 
set_clock_latency -source -early -max -fall  -0.698327 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -max -rise  -0.682334 [get_ports {clk}] -clock clk 
set_clock_latency -source -late -max -fall  -0.698327 [get_ports {clk}] -clock clk 
