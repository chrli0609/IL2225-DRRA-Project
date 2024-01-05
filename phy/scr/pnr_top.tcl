source ../phy/scr/design_variables.tcl
cd ../phy/db/part
read_db drra_wrapper

foreach module $partition_module_list {
    read_ilm -cell $module -dir ${module}/ilm
}
flatten_ilm

place_design
ccopt_design
route_design

write_db drra_wrapper/pnr
