#Set the source directory
set SOURCE_DIR ../rtl; 

vlib work
vlib dware

#Compile dware libraries into "dware"
set hierarchy_files [split [read [open ${SOURCE_DIR}/dware_hierarchy.txt r]] "\n"]
foreach filename [lrange ${hierarchy_files} 0 end-1] {
	vcom -2008 -work dware ${SOURCE_DIR}/${filename}
}
#set hierarchy_files [split [read [open ${SOURCE_DIR}/dware_hierarchy_verilog.txt r]] "\n"]
#foreach filename [lrange ${hierarchy_files} 0 end-1] {
#    vlog -v2001 -work dware ${SOURCE_DIR}/${filename}
#}

set hierarchy_files [split [read [open ${SOURCE_DIR}/dware_hierarchy_verilog.txt r]] "\n"]
foreach filename [lrange ${hierarchy_files} 0 end-1] {
    vlog -work dware ${SOURCE_DIR}/${filename}
}



#Compile silagonn design into "work"
set design_files [split [read [open ${SOURCE_DIR}/silagonn_hierarchy.txt r]] "\n"]
foreach filename [lrange ${design_files} 0 end-1] {
	vcom -2008 -work work ${SOURCE_DIR}/${filename}
}


#Compile const_package.vhd in the current directory
vcom -2008 -work work ../tb/vec_add/const_package.vhd
vcom -2008 -work work ../rtl/mtrf/top_const_types_package.vhd
vcom -2008 -work work ../rtl/mtrf/tb_instructions.vhd
vcom -2008 -work work ../rtl/dimarch/noc_types_n_constants.vhd

#Compile testbench.vhd in the current directory
vcom -2008 -work work ../tb/vec_add/testbench.vhd

#Open the simulation
vsim work.testbench -voptargs=+acc -debugDB

run 0 ns;
#Load the waveform 
do wave.do
#Run simulation
run 735ns;
