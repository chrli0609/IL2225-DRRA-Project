source ../phy/scr/read_design.tcl
source ../phy/scr/design_variables.tcl
source ../phy/scr/floorplan.tcl
create_floorplan -site core -core_density_size 0.251868007198 0.901249 10 10 10 10
source ../phy/scr/power_planning.tcl
place_design
ccopt_design
assign_io_pins
route_design
write_db ../phy/db/silagonn.dat
write_netlist ../phy/db/silagonn.v
write_sdf ../phy/db/silagonn.sdf
write_sdc ../phy/db/silagonn.sdc
