if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name LIBSET_BC\
   -timing\
    [list ${::IMEX::libVar}/mmmc/tcbn90gbc.lib]
create_library_set -name LIBSET_WC\
   -timing\
    [list ${::IMEX::libVar}/mmmc/tcbn90gwc.lib]
create_library_set -name LIBSET_TC\
   -timing\
    [list ${::IMEX::libVar}/mmmc/tcbn90gtc.lib]
create_timing_condition -name cond_worst\
   -library_sets [list LIBSET_WC]\
   -opcond_library wc
create_timing_condition -name cond_best\
   -library_sets [list LIBSET_BC]\
   -opcond_library bc
create_rc_corner -name rc_best\
   -pre_route_res 1\
   -post_route_res 1\
   -pre_route_cap 1\
   -post_route_cap 1\
   -post_route_cross_cap 1\
   -pre_route_clock_res 0\
   -pre_route_clock_cap 0
create_rc_corner -name rc_worst\
   -pre_route_res 1\
   -post_route_res 1\
   -pre_route_cap 1\
   -post_route_cap 1\
   -post_route_cross_cap 1\
   -pre_route_clock_res 0\
   -pre_route_clock_cap 0
create_delay_corner -name WC_dc\
   -timing_condition {cond_worst}\
   -rc_corner rc_worst
create_delay_corner -name BC_dc\
   -timing_condition {cond_best}\
   -rc_corner rc_best
create_constraint_mode -name CM\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/CM/CM.sdc]
create_analysis_view -name AV_WC_RCWORST -constraint_mode CM -delay_corner WC_dc -latency_file ${::IMEX::dataVar}/mmmc/views/AV_WC_RCWORST/latency.sdc
create_analysis_view -name AV_BC_RCBEST -constraint_mode CM -delay_corner BC_dc -latency_file ${::IMEX::dataVar}/mmmc/views/AV_BC_RCBEST/latency.sdc
set_analysis_view -setup [list AV_WC_RCWORST] -hold [list AV_WC_RCWORST AV_BC_RCBEST]
