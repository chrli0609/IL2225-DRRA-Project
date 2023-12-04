################################################################################
# Design Compiler logic synthesis script
################################################################################
#
# This script is meant to be executed with the following directory structure
#
# project_top_folder
# |
# |- db: store output data like mapped designs or physical files like GDSII
# |
# |- phy: physical synthesis material (scripts, pins, etc)
# |
# |- rtl: contains rtl code for the design, it should also contain a
# |       hierarchy.txt file with the all the files that compose the design
# |
# |- syn: logic synthesis material (this script, SDC constraints, etc)
# |
# |- sim: simulation stuff like waveforms, reports, coverage etc.
# |
# |- tb: testbenches for the rtl code
# |
# |- exe: the directory where it should be executed. This keeps all the temp files
#         created by DC in that directory
#
#
# The standard way of executing the is from the project_top_folder
# with the following command
#
# $ genus -files ../syn/genus_synthesis.tcl
#
# Additionally it should be possible to do
#
# $ make syn
#
# If the standard Makefile is present in the project directory
# Please check if you have the right constraints in ./syn/constraints.sdc
# Additionaly, please make sure that you have replaced SRAM_model with SRAM Macro
################################################################################

set SynopsysHome /afs/ict.kth.se/pkg/synopsys/designcompiler/J-2014.09
set search_path "/afs/ict.kth.se/pkg/synopsys/designcompiler/J-2014.09/libraries/syn\
                 /afs/it.kth.se/pkg/synopsys/extra_libraries/standard_cell/TSMC/tcbn90g_110a/Front_End/timing_power/tcbn90g_110a/"


# SYNTH VHDL FILE DEFAULTS
set view_read_file_suffix 		"db sdb edif sedif vhd vhdl st script"
set view_analyze_file_suffix 		"v vhd vhdl"
set template_parameter_style 		"%d"; # Limits the lenght of comp. names

set link_path 				${search_path}
set target_library 			"tcbn90gtc.db"
set symbol_library 			"tcbn90g.sdb"

set synthetic_library 			"standard.sldb\
					 dw_foundation.sldb";

set link_library 			"* ${target_library}"

#set the top name

# Directories for output material
set REPORT_DIR  ../syn/rpt;      # synthesis reports: timing, area, etc.
set OUT_DIR ../syn/db;           # output files: netlist, sdf sdc etc.
set SOURCE_DIR ../rtl;           # rtl code that should be synthesised
set SYN_DIR ../syn;              # synthesis directory, synthesis scripts constraints etc.

#define the process
proc nth_pass {n} {
	global SYN_DIR
	global SOURCE_DIR
	global OUT_DIR
	global REPORT_DIR
	global TOP_NAME
	set prev_n [expr {$n - 1}]
	exec rm -rf ${OUT_DIR}/pass${n}
	exec mkdir -p ${OUT_DIR}/pass${n}
	remove_design -all
	
	# Anayze the files in ${SOURCE_DIR}/pkg_hierarchy.txt
	set hierarchy_files [split [read [open ${SOURCE_DIR}/pkg_hierarchy.txt r]] "\n"]
	foreach filename [lrange ${hierarchy_files} 0 end-1] {
	    if {![string equal [string index $filename 0] "#"]} {
	        if {[string equal [file extension $filename] ".vhd"]} {
	            analyze -format vhdl -lib WORK ${SOURCE_DIR}/${filename}
	        } elseif {[string equal [file extension $filename] ".v"]} {
	            analyze -format verilog -lib WORK ${SOURCE_DIR}/${filename}
	        }
	    }
	}
	# Compile the divider pipe, ${SOURCE_DIR}/mtrf/DPU/divider_pipe.vhd. We would like to import constraints in the next pass over divider pipe
	analyze -format vhdl -lib WORK ${SOURCE_DIR}/mtrf/DPU/divider_pipe.vhd
	elaborate divider_pipe
	current_design divider_pipe
	link
	uniquify
	if  {$n > 1} {
	    source ${OUT_DIR}/pass${prev_n}/divider_pipe.wscr
	}
	source ${SYN_DIR}/constraints.sdc
	compile
	
	# Compile the "silego" entity
	# Hint: analyze the files in ${SOURCE_DIR}/silego_hierarchy.txt. elaborate the design silego, set current_design to silego, link, uniquify, source global constraints, source constraints from previous pass, set dont_touch for divider pipe and compile
	
    # Compile all the Silago tile files
	# Hint: COmpile each tile one by one. Analyze and elaborate the tile design, set current_design to that tile, link, uniquify, source global constraints, source constraints from previous pass, set dont_touch for divider pipe, silego and compile
	
	# Analyze, elaborate the DRRA wrapper 
	# Hint: Analyze and elaborate the design, set current_design to the wrapper, link, source global constraints, set dont_touch for divider pipe, silego, all the tiles, DO NOT UNIQUIFY OR COMPILE! The design is already compiled as all the components are already compiled and there is no logic in wrapper outside of the tiles.
	
    #report timing of drra wrapper in the current pass
	
    #characterizing the constraints 
	characterize -constraints {Silago_bot_l_corner_inst_0_1/SILEGO_cell \
	                           Silago_bot_l_corner_inst_0_1/SILEGO_cell/MTRF_cell/dpu_gen/U_NACU_0/U_divider}
	current_design divider_pipe
	puts "write script"
	write_script > ${OUT_DIR}/pass${n}/divider_pipe.wscr
	current_design silego
	write_script > ${OUT_DIR}/pass${n}/silego.wscr
}

#Execute n passes. Decide  on a resonable n.


#Set current design to drra_wrapper and report timing, power, area.

#Write the netlist, ddc, sdc and sdf.