source ../phy/scr/global_variables.tcl
setMultiCpuUsage -localCpu ${NUM_CPUS} -cpuPerRemoteHost 1 -remoteHost 0 -keepLicense true
setDistributeHost -local

set_db init_power_nets {VDD}
set_db init_ground_nets {VSS}
read_mmmc ${MMMC_FILE}
read_physical -lef ${LEF_FILE}
read_netlist ${NETLIST_FILE}
init_design